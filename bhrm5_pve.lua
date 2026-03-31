-- ============================================================
--   Black Hawk Rescue Mission 5  |  PVE Script
--   Author  : D3MONG
--   Version : 1.0
-- ============================================================

local Rayfield = loadstring(game:HttpGet(
    'https://sirius.menu/rayfield'
))()

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer

local ESPEnabled          = false
local AntiRecoilEnabled   = false
local ESPColor            = Color3.fromRGB(255, 50, 50)
local ESPFillTransparency = 0.5
local AntiRecoilStrength  = 1.0
local ESPHighlights       = {}
local AntiRecoilConn      = nil
local lastCamCFrame       = nil

-- ESP LOGIC
local function applyESP(player)
    if player == LocalPlayer then return end
    local function attachHighlight(char)
        if not char then return end
        if ESPHighlights[player] then ESPHighlights[player]:Destroy() end
        local hl = Instance.new("Highlight")
        hl.Adornee             = char
        hl.FillColor           = ESPColor
        hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency    = ESPFillTransparency
        hl.OutlineTransparency = 0
        hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent              = char
        ESPHighlights[player]  = hl
    end
    if player.Character then attachHighlight(player.Character) end
    player.CharacterAdded:Connect(function(char)
        if ESPEnabled then task.wait(0.3) attachHighlight(char) end
    end)
end

local function removeESP(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
    end
end

local function enableAllESP()
    for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
end

local function disableAllESP()
    for p in pairs(ESPHighlights) do removeESP(p) end
end

local function refreshESPColors()
    for _, hl in pairs(ESPHighlights) do
        hl.FillColor        = ESPColor
        hl.FillTransparency = ESPFillTransparency
    end
end

Players.PlayerAdded:Connect(function(p)
    if ESPEnabled then applyESP(p) end
end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ANTI-RECOIL LOGIC
local function enableAntiRecoil()
    local camera = workspace.CurrentCamera
    lastCamCFrame = nil
    AntiRecoilConn = RunService.RenderStepped:Connect(function()
        if lastCamCFrame then
            local cur = camera.CFrame
            local _, lastPitch, _ = lastCamCFrame:ToEulerAnglesYXZ()
            local _, curPitch,  _ = cur:ToEulerAnglesYXZ()
            local delta = curPitch - lastPitch
            if delta < -0.0015 then
                camera.CFrame = cur * CFrame.Angles(math.abs(delta) * AntiRecoilStrength, 0, 0)
            end
        end
        lastCamCFrame = camera.CFrame
    end)
end

local function disableAntiRecoil()
    if AntiRecoilConn then AntiRecoilConn:Disconnect() AntiRecoilConn = nil end
    lastCamCFrame = nil
end

-- RAYFIELD WINDOW
local Window = Rayfield:CreateWindow({
    Name             = "BHRM5 PVE  |  D3MONG",
    Icon             = 0,
    LoadingTitle     = "Black Hawk Rescue Mission 5",
    LoadingSubtitle  = "by D3MONG",
    Theme            = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "D3MONG_Scripts",
        FileName   = "BHRM5PVE",
    },
    KeySystem = false,
})

-- PVE TAB
local PVETab = Window:CreateTab("PVE Mode", "crosshair")

PVETab:CreateSection("Visuals")

PVETab:CreateToggle({
    Name         = "Wallhack (ESP)",
    CurrentValue = false,
    Flag         = "WallhackEnabled",
    Callback     = function(value)
        ESPEnabled = value
        if value then
            enableAllESP()
            Rayfield:Notify({ Title = "Wallhack ON", Content = "Players visible through walls.", Duration = 3, Image = 4483362458 })
        else
            disableAllESP()
            Rayfield:Notify({ Title = "Wallhack OFF", Content = "ESP removed.", Duration = 3, Image = 4483362458 })
        end
    end,
})

PVETab:CreateColorPicker({
    Name     = "ESP Fill Color",
    Color    = Color3.fromRGB(255, 50, 50),
    Flag     = "ESPFillColor",
    Callback = function(value)
        ESPColor = value
        refreshESPColors()
    end,
})

PVETab:CreateSlider({
    Name         = "ESP Fill Transparency",
    Range        = {0, 1},
    Increment    = 0.05,
    Suffix       = "",
    CurrentValue = 0.5,
    Flag         = "ESPFillTransparency",
    Callback     = function(value)
        ESPFillTransparency = value
        refreshESPColors()
    end,
})

PVETab:CreateSection("Combat")

PVETab:CreateToggle({
    Name         = "Anti-Recoil",
    CurrentValue = false,
    Flag         = "AntiRecoilEnabled",
    Callback     = function(value)
        AntiRecoilEnabled = value
        if value then
            enableAntiRecoil()
            Rayfield:Notify({ Title = "Anti-Recoil ON", Content = "Recoil will be compensated.", Duration = 3, Image = 4483362458 })
        else
            disableAntiRecoil()
            Rayfield:Notify({ Title = "Anti-Recoil OFF", Content = "Normal camera restored.", Duration = 3, Image = 4483362458 })
        end
    end,
})

PVETab:CreateSlider({
    Name         = "Anti-Recoil Strength",
    Range        = {0.1, 3.0},
    Increment    = 0.1,
    Suffix       = "x",
    CurrentValue = 1.0,
    Flag         = "AntiRecoilStrength",
    Callback     = function(value)
        AntiRecoilStrength = value
    end,
})

-- SETTINGS TAB
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateSection("Configuration")

SettingsTab:CreateButton({
    Name     = "Save Config",
    Callback = function()
        Rayfield:SaveConfigurations()
        Rayfield:Notify({ Title = "Saved!", Content = "Settings saved.", Duration = 3, Image = 4483362458 })
    end,
})

SettingsTab:CreateButton({
    Name     = "Load Config",
    Callback = function()
        Rayfield:LoadConfigurations()
        Rayfield:Notify({ Title = "Loaded!", Content = "Config loaded.", Duration = 3, Image = 4483362458 })
    end,
})

SettingsTab:CreateSection("Script")

SettingsTab:CreateLabel("D3MONG  |  BHRM5 PVE v1.0")

SettingsTab:CreateButton({
    Name     = "Unload Script",
    Callback = function()
        disableAllESP()
        disableAntiRecoil()
        Rayfield:Destroy()
    end,
})

Rayfield:LoadConfigurations()
