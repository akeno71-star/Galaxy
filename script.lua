--// 🌌 GalaxyHub GOD VERSION

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlaceID = game.PlaceId

-- SETTINGS
local MAX_PLAYERS = 3
local SAFE_DISTANCE = 300 -- studs (~ fake 2-3km)

-- STATES
local playerDetect = false
local friendDetect = false
local lowServer = false
local safeMode = false
local moonFinder = false

-- TARGETS
local targets = {}

local visited = {}

-- 🌌 BLUR EFFECT
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 15

-- UI 🧊
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "GalaxyHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 360)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true

-- Glass effect
local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,200)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🌌 GalaxyHub GOD"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)

-- Player Counter
local counter = Instance.new("TextLabel", frame)
counter.Position = UDim2.new(0,0,0,30)
counter.Size = UDim2.new(1,0,0,25)
counter.BackgroundTransparency = 1
counter.TextColor3 = Color3.fromRGB(0,255,150)
counter.Text = "Players: 0"

-- WARNING TEXT
local warnText = Instance.new("TextLabel", frame)
warnText.Position = UDim2.new(0,0,0,55)
warnText.Size = UDim2.new(1,0,0,25)
warnText.BackgroundTransparency = 1
warnText.TextColor3 = Color3.fromRGB(255,80,80)
warnText.Text = ""

-- TOGGLE CREATOR
local function toggle(name, y, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9,0,0,28)
    btn.Position = UDim2.new(0.05,0,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name.." : OFF"

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name.." : "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0,200,120) or Color3.fromRGB(40,40,60)
        callback(state)
    end)
end

-- TOGGLES
toggle("Player Detector", 90, function(v) playerDetect = v end)
toggle("Friend Detector", 125, function(v) friendDetect = v end)
toggle("Low Server Finder", 160, function(v) lowServer = v end)
toggle("Safe Mode", 195, function(v) safeMode = v end)
toggle("Full Moon Finder", 230, function(v) moonFinder = v end)

-- CHECK TARGET
local function isTarget(p)
    for _, name in pairs(targets) do
        if p.Name == name or p.DisplayName == name then
            return true
        end
    end
    return false
end

-- DISTANCE CHECK
local function getDistance(p)
    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        return (p.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

-- ESCAPE
local function escape()
    TeleportService:Teleport(PlaceID)
end

-- LOW SERVER
local function getLowServer()
    local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success then
        for _, s in pairs(result.data) do
            if s.playing <= MAX_PLAYERS and not visited[s.id] then
                visited[s.id] = true
                return s.id
            end
        end
    end
end

local function hopLow()
    local id = getLowServer()
    if id then
        TeleportService:TeleportToPlaceInstance(PlaceID, id, LocalPlayer)
    end
end

-- 🌕 FULL MOON CHECK (simple simulation)
local function isFullMoon()
    return Lighting.ClockTime >= 0 and Lighting.ClockTime <= 1
end

-- LOOP
while true do
    task.wait(2)

    Character = LocalPlayer.Character or Character

    -- Player Counter
    counter.Text = "Players: "..#Players:GetPlayers()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then

            -- Distance warning
            local dist = getDistance(p)
            if dist < SAFE_DISTANCE then
                warnText.Text = "⚠ Player Nearby!"
                if safeMode then
                    escape()
                end
            end

            -- Detect target
            if playerDetect and isTarget(p) then
                escape()
            end

            -- Detect friend
            if friendDetect and LocalPlayer:IsFriendsWith(p.UserId) then
                escape()
            end
        end
    end

    -- Clear warning if safe
    task.wait(1)
    warnText.Text = ""

    -- Low server hop
    if lowServer then
        hopLow()
    end

    -- Full moon finder
    if moonFinder and not isFullMoon() then
        hopLow()
    end
end
