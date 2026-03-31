-- ============================================================
--  BHRM5 Enhanced Loader by D3MONG
--  Anti-Detection + Obfuscation
--  Community: SEKUMPUL
-- ============================================================

local player = game.Players.LocalPlayer
local placeId = game.PlaceId

-- Anti-detection: Randomize script names and timing
local function randomString(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

-- Anti-detection: Random delay
local function randomWait()
    task.wait(math.random(50, 150) / 1000)
end

-- Black Hawk Rescue Mission 5 Place IDs
local PVE_PLACE_IDS = {
    [2916899287] = true,  -- Main game
    [3701546109] = true   -- PVE mode
}

-- Obfuscated remote script loader
local function loadRemoteScript(url)
    task.spawn(function()
        randomWait()
        local cache_bust = randomString(8) .. "_" .. tostring(os.time())
        local success, result = pcall(function()
            return game:HttpGet(url .. "?v=" .. cache_bust)
        end)
        if success and result then
            local fn, err = loadstring(result)
            if fn then
                pcall(fn)
            end
        end
    end)
end

local function loadMain()
    loadRemoteScript("https://raw.githubusercontent.com/d3mong/bhrm5-scripts/main/bhrm5/main.lua")
end

-- Auto-load if place ID matches
if PVE_PLACE_IDS[placeId] then
    randomWait()
    loadMain()
    return
end

-- Manual mode selection
local screenGui = Instance.new("ScreenGui")
screenGui.Name = randomString(12)
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 180)
frame.Position = UDim2.new(0.5, -160, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "BHRM5 | D3MONG"
title.TextColor3 = Color3.fromRGB(85, 170, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, 0, 0, 20)
sub.Position = UDim2.new(0, 0, 0, 42)
sub.BackgroundTransparency = 1
sub.Text = "SEKUMPUL Community"
sub.TextColor3 = Color3.fromRGB(180, 180, 180)
sub.Font = Enum.Font.Gotham
sub.TextSize = 13
sub.Parent = frame

local function createButton(name, text, color, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 45)
    btn.Position = UDim2.new(0.1, 0, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

local loadButton = createButton("Load", "LOAD SCRIPT", Color3.fromRGB(60, 180, 60), 75)

loadButton.MouseButton1Click:Connect(function()
    loadButton.Text = "Loading..."
    task.wait(0.2)
    screenGui:Destroy()
    loadMain()
end)
