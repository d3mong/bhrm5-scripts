-- ============================================================
--  BHRM5 Enhanced GUI Module  |  D3MONG
--  Community: SEKUMPUL (discord.gg/aJ4ZWEz387)
--  Focused: ESP, Aimbot, No Recoil
-- ============================================================

local GUI = {}

function GUI:init(NPCManager, PlayerManager, Walls, NoRecoil, Aimbot)

    -- Load Rayfield
    local Rayfield = loadstring(game:HttpGet(
        'https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'
    ))()

    -- ---- Window Configuration -----------------------------
    local Window = Rayfield:CreateWindow({
        Name = "BHRM5 Enhanced | D3MONG",
        LoadingTitle = "SEKUMPUL Community",
        LoadingSubtitle = "by D3MONG",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "D3MONG_BHRM5",
            FileName = "BHRM5_Config"
        },
        Discord = {
            Enabled = true,
            Invite = "aJ4ZWEz387",
            RememberJoins = true
        },
        KeySystem = true,
        KeySettings = {
            Title = "BHRM5 | D3MONG",
            Subtitle = "Key System",
            Note = "Key: demong | Discord: discord.gg/aJ4ZWEz387",
            FileName = "D3MONG_Key",
            SaveKey = true,
            GrabKeyFromSite = false,
            Key = "demong"
        }
    })

    -- ========================================================
    -- TAB 1: ESP & VISUALS
    -- ========================================================
    local VisualTab = Window:CreateTab("ESP & Visuals", 4483362458)
    
    VisualTab:CreateSection("ESP Settings", false)

    -- NPC ESP Toggle
    VisualTab:CreateToggle({
        Name = "NPC ESP",
        CurrentValue = false,
        Flag = "NPCESPEnabled",
        Callback = function(Value)
            if Value then
                Walls.enableNPCs(NPCManager)
            else
                Walls.disableNPCs()
            end
        end,
    })

    -- Player ESP Toggle
    VisualTab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Flag = "PlayerESPEnabled",
        Callback = function(Value)
            if Value then
                Walls.enablePlayers(PlayerManager)
            else
                Walls.disablePlayers()
            end
        end,
    })

    -- ESP Transparency Slider
    VisualTab:CreateSlider({
        Name = "ESP Transparency",
        Range = {0, 100},
        Increment = 5,
        Suffix = "%",
        CurrentValue = 45,
        Flag = "ESPTransparency",
        Callback = function(Value)
            Walls.setFillTransparency(Value / 100)
        end,
    })

    -- ESP Colors Section
    VisualTab:CreateSection("ESP Colors", false)

    -- NPC Visible Color
    VisualTab:CreateColorPicker({
        Name = "NPC Visible Color",
        Color = Color3.fromRGB(0, 255, 80),
        Flag = "NPCVisibleColor",
        Callback = function(Value)
            Walls.setNPCVisibleColor(Value)
        end
    })

    -- NPC Hidden Color
    VisualTab:CreateColorPicker({
        Name = "NPC Hidden Color",
        Color = Color3.fromRGB(255, 40, 40),
        Flag = "NPCHiddenColor",
        Callback = function(Value)
            Walls.setNPCHiddenColor(Value)
        end
    })

    -- Player Visible Color
    VisualTab:CreateColorPicker({
        Name = "Player Visible Color",
        Color = Color3.fromRGB(0, 150, 255),
        Flag = "PlayerVisibleColor",
        Callback = function(Value)
            Walls.setPlayerVisibleColor(Value)
        end
    })

    -- Player Hidden Color
    VisualTab:CreateColorPicker({
        Name = "Player Hidden Color",
        Color = Color3.fromRGB(255, 200, 0),
        Flag = "PlayerHiddenColor",
        Callback = function(Value)
            Walls.setPlayerHiddenColor(Value)
        end
    })

    -- ========================================================
    -- TAB 2: COMBAT
    -- ========================================================
    local CombatTab = Window:CreateTab("Combat", 4483362458)
    
    CombatTab:CreateSection("Aimbot", false)

    -- Aimbot Toggle
    CombatTab:CreateToggle({
        Name = "Enable Aimbot",
        CurrentValue = false,
        Flag = "AimbotEnabled",
        Callback = function(Value)
            if Value then
                Aimbot.enable(NPCManager, PlayerManager)
            else
                Aimbot.disable()
            end
        end,
    })

    -- Target NPCs
    CombatTab:CreateToggle({
        Name = "Target NPCs",
        CurrentValue = true,
        Flag = "AimbotTargetNPCs",
        Callback = function(Value)
            Aimbot.setTargetNPCs(Value)
        end,
    })

    -- Target Players
    CombatTab:CreateToggle({
        Name = "Target Players",
        CurrentValue = false,
        Flag = "AimbotTargetPlayers",
        Callback = function(Value)
            Aimbot.setTargetPlayers(Value)
        end,
    })

    -- Aimbot FOV
    CombatTab:CreateSlider({
        Name = "Aimbot FOV",
        Range = {50, 500},
        Increment = 10,
        Suffix = "px",
        CurrentValue = 200,
        Flag = "AimbotFOV",
        Callback = function(Value)
            Aimbot.setFOV(Value)
        end,
    })

    -- Aimbot Smoothness
    CombatTab:CreateSlider({
        Name = "Aimbot Smoothness",
        Range = {1, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 20,
        Flag = "AimbotSmoothness",
        Callback = function(Value)
            Aimbot.setSmoothness(Value / 100)
        end,
    })

    -- Recoil Section
    CombatTab:CreateSection("Recoil Control", false)

    -- No Recoil Toggle
    CombatTab:CreateToggle({
        Name = "No Recoil",
        CurrentValue = false,
        Flag = "NoRecoilEnabled",
        Callback = function(Value)
            if Value then
                NoRecoil.enable()
            else
                NoRecoil.disable()
            end
        end,
    })

    -- Recoil Strength
    CombatTab:CreateSlider({
        Name = "Recoil Reduction",
        Range = {0, 100},
        Increment = 10,
        Suffix = "%",
        CurrentValue = 100,
        Flag = "RecoilStrength",
        Callback = function(Value)
            NoRecoil.setStrength(Value / 100)
        end,
    })

    -- ========================================================
    -- TAB 3: SETTINGS & INFO
    -- ========================================================
    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    
    SettingsTab:CreateSection("Information", true)

    SettingsTab:CreateLabel("BHRM5 Enhanced Script v2.0")
    SettingsTab:CreateLabel("Created by D3MONG")
    SettingsTab:CreateLabel("Community: SEKUMPUL")
    
    SettingsTab:CreateParagraph({
        Title = "How to Use",
        Content = "Toggle ESP to see NPCs/Players through walls. Enable Aimbot and hold RIGHT MOUSE BUTTON to aim. Use No Recoil for better accuracy. All settings are saved automatically."
    })

    SettingsTab:CreateParagraph({
        Title = "Controls",
        Content = "INSERT Key = Toggle UI Visibility | Right Mouse Button = Aimbot (when enabled)"
    })

    SettingsTab:CreateParagraph({
        Title = "Discord Community",
        Content = "Join SEKUMPUL: discord.gg/aJ4ZWEz387 for support, updates, and more scripts!"
    })

    -- Live Stats
    SettingsTab:CreateSection("Live Statistics", false)

    local NPCLabel = SettingsTab:CreateLabel("NPCs: 0")
    local PlayerLabel = SettingsTab:CreateLabel("Players: 0")

    -- Update stats every second
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local npcCount = NPCManager:getCount()
                local playerCount = PlayerManager:getCount()
                NPCLabel:Set("NPCs Detected: " .. tostring(npcCount))
                PlayerLabel:Set("Players Detected: " .. tostring(playerCount))
            end)
        end
    end)

    -- Actions Section
    SettingsTab:CreateSection("Actions", false)

    SettingsTab:CreateButton({
        Name = "Unload Script",
        Callback = function()
            Walls.disableNPCs()
            Walls.disablePlayers()
            NoRecoil.disable()
            Aimbot.disable()
            NPCManager:cleanup()
            PlayerManager:cleanup()
            Rayfield:Destroy()
            print("[D3MONG] Script unloaded successfully!")
        end,
    })

    SettingsTab:CreateButton({
        Name = "Reload Configuration",
        Callback = function()
            Rayfield:LoadConfiguration()
            print("[D3MONG] Configuration reloaded!")
        end,
    })

    -- ========================================================
    -- UI TOGGLE (INSERT KEY)
    -- ========================================================
    local UIS = game:GetService("UserInputService")
    
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            Rayfield:Toggle()
        end
    end)

    -- Load saved configuration
    Rayfield:LoadConfiguration()
    
    print("[D3MONG] GUI Loaded | SEKUMPUL Community")
end

return GUI
