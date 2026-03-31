-- ============================================================
--  BHRM5 GUI Module
--  Author : D3MONG
--  Uses   : Rayfield UI Library
-- ============================================================

local GUI = {}

function GUI:init(NPCManager, Walls, NoRecoil)

    -- Load Rayfield
    local Rayfield = loadstring(game:HttpGet(
        "https://sirius.menu/rayfield", true
    ))()

    -- ---- Window -------------------------------------------
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

    -- ---- Left Shift = Hide / Show -------------------------
    local UIS       = game:GetService("UserInputService")
    local CoreGui   = game:GetService("CoreGui")
    local UIVisible = true

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            UIVisible = not UIVisible
            local gui = CoreGui:FindFirstChild("Rayfield")
                     or game:GetService("Players")
                            .LocalPlayer
                            :WaitForChild("PlayerGui")
                            :FindFirstChild("Rayfield")
            if gui then gui.Enabled = UIVisible end
        end
    end)

    -- ---- Tab: PVE Mode ------------------------------------
    local PVETab = Window:CreateTab("PVE Mode", "crosshair")

    PVETab:CreateSection("Visuals")

    PVETab:CreateToggle({
        Name         = "Wallhack (ESP)",
        CurrentValue = false,
        Flag         = "WallhackEnabled",
        Callback     = function(value)
            if value then
                Walls.enable(NPCManager)
                Rayfield:Notify({
                    Title    = "Wallhack ON",
                    Content  = "Green = visible | Red = behind wall",
                    Duration = 3,
                    Image    = 4483362458,
                })
            else
                Walls.disable()
                Rayfield:Notify({
                    Title    = "Wallhack OFF",
                    Content  = "ESP removed.",
                    Duration = 3,
                    Image    = 4483362458,
                })
            end
        end,
    })

    PVETab:CreateSection("Combat")

    PVETab:CreateToggle({
        Name         = "No Recoil",
        CurrentValue = false,
        Flag         = "NoRecoilEnabled",
        Callback     = function(value)
            if value then
                NoRecoil.enable()
                Rayfield:Notify({
                    Title    = "No Recoil ON",
                    Content  = "Camera + weapon patch active.",
                    Duration = 3,
                    Image    = 4483362458,
                })
            else
                NoRecoil.disable()
                Rayfield:Notify({
                    Title    = "No Recoil OFF",
                    Content  = "Normal recoil restored.",
                    Duration = 3,
                    Image    = 4483362458,
                })
            end
        end,
    })

    PVETab:CreateSlider({
        Name         = "Recoil Strength Cancel",
        Range        = {1, 10},
        Increment    = 1,
        Suffix       = "x",
        CurrentValue = 10,
        Flag         = "NoRecoilStrength",
        Callback     = function(value)
            NoRecoil.setStrength(value / 10)
        end,
    })

    -- ---- Tab: Settings ------------------------------------
    local SettingsTab = Window:CreateTab("Settings", "settings")

    SettingsTab:CreateSection("Script Info")
    SettingsTab:CreateLabel("D3MONG  |  BHRM5 PVE v1.0")
    SettingsTab:CreateLabel("Left Shift = Hide / Show UI")

    SettingsTab:CreateSection("Actions")

    SettingsTab:CreateButton({
        Name     = "Unload Script",
        Callback = function()
            Walls.disable()
            NoRecoil.disable()
            NPCManager:cleanup()
            Rayfield:Destroy()
        end,
    })

    Rayfield:LoadConfigurations()
end

return GUI
