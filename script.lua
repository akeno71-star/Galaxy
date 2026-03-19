--// 🌌 GalaxyHub REBUILT (Fixed + Pro)

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
local SAFE_DISTANCE = 350

-- STATES
local Toggles = {
    PlayerDetect = false,
    FriendDetect = false,
    LowServer = false,
    SafeMode = false,
    FullMoon = false
}

-- TARGET LIST (editable)
local targets = {
    "SHEHEROZ9",
    "SHEHEROZ1FF",
    "lordsiam_8",
    "Mr_Khan"
}

local visited = {}

-- 🌫 Blur (Glass UI)
if not Lighting:FindFirstChild("GalaxyBlur") then
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Name = "GalaxyBlur"
    blur.Size = 12
end

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "GalaxyHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 380)
frame.Position = UDim2.new(0.05,0,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,200)

-- Glow animation
task.spawn(function()
    while true do
        TweenService:Create(stroke, TweenInfo.new(1), {Color = Color3.fromRGB(0,200,255)}):Play()
        task.wait(1)
        TweenService:Create(stroke, TweenInfo.new(1), {Color = Color3.fromRGB(0,255,150)}):Play()
        task.wait(1)
    end
end)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🌌 GalaxyHub PRO"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)

-- Player Counter
local counter = Instance.new("TextLabel", frame)
counter.Position = UDim2.new(0,0,0,30)
counter.Size = UDim2.new(1,0,0,25)
counter.BackgroundTransparency = 1
counter.TextColor3 = Color3.fromRGB(0,255,150)

-- Warning Text
local warnText = Instance.new("TextLabel", frame)
warnText.Position = UDim2.new(0,0,0,55)
warnText.Size = UDim2.new(1,0,0,25)
warnText.BackgroundTransparency = 1
warnText.TextColor3 = Color3.fromRGB(255,80,80)

-- Toggle creator
local function createToggle(name, key, y)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9,0,0,30)
    btn.Position = UDim2.new(0.05,0,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name.." : OFF"

    btn.MouseButton1Click:Connect(function()
        Toggles[key] = not Toggles[key]
        btn.Text = name.." : "..(Toggles[key] and "ON" or "OFF")
        btn.BackgroundColor3 = Toggles[key] and Color3.fromRGB(0,200,120) or Color3.fromRGB(40,40,60)
    end)
end

-- Input box
local function createBox(placeholder, y)
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.9,0,0,30)
    box.Position = UDim2.new(0.05,0,0,y)
    box.PlaceholderText = placeholder
    box.BackgroundColor3 = Color3.fromRGB(30,30,50)
    box.TextColor3 = Color3.new(1,1,1)

    box.FocusLost:Connect(function()
        if box.Text ~= "" then
            table.insert(targets, box.Text)
            box.Text = ""
        end
    end)
end

-- Create UI
createToggle("Player Detector", "PlayerDetect", 90)
createToggle("Friend Detector", "FriendDetect", 130)
createToggle("Low Server Finder", "LowServer", 170)
createToggle("Safe Mode", "SafeMode", 210)
createToggle("Full Moon Finder", "FullMoon", 250)

createBox("Enter Username / Name", 300)

-- Functions
local function isTarget(p)
    for _, name in pairs(targets) do
        if p.Name == name or p.DisplayName == name then
            return true
        end
    end
    return false
end

local function getDistance(p)
    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("HumanoidRootPart") then
        return (p.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function escape()
    TeleportService:Teleport(PlaceID)
end

local function getLowServer()
    local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and data then
        for _, s in pairs(data.data) do
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

local function isFullMoon()
    return Lighting.ClockTime >= 0 and Lighting.ClockTime <= 1
end

-- Main Loop
while true do
    task.wait(2)

    Character = LocalPlayer.Character or Character

    counter.Text = "Players: "..#Players:GetPlayers()
    warnText.Text = ""

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then

            local dist = getDistance(p)

            if dist < SAFE_DISTANCE then
                warnText.Text = "⚠ Nearby Player!"
                if Toggles.SafeMode then
                    escape()
                end
            end

            if Toggles.PlayerDetect and isTarget(p) then
                escape()
            end

            if Toggles.FriendDetect and LocalPlayer:IsFriendsWith(p.UserId) then
                escape()
            end
        end
    end

    if Toggles.LowServer then
        hopLow()
    end

    if Toggles.FullMoon and not isFullMoon() then
        hopLow()
    end
end
