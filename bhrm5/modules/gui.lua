-- ============================================================
--  BHRM5 Enhanced GUI Module with Rayfield
--  Author : D3MONG
--  Focused: ESP, Aimbot, No Recoil only
-- ============================================================

local GUI = {}

function GUI:init(NPCManager, PlayerManager, Walls, NoRecoil, Aimbot)

    -- Load Rayfield from your custom URL
    local Rayfield = loadstring(game:HttpGet(
        'https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'
    ))()

    -- ---- Window -------------------------------------------
    local Window = Rayfield:CreateWindow({
        Name = "BHRM5 Enhanced | D3MONG",
        LoadingTitle = "Black Hawk Rescue Mission 5",
        LoadingSubtitle = "by D3MONG",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "D3MONG_BHRM5",
            FileName = "BHRM5_Config"
        },
        Discord = {
            Enabled = false,
            Invite = "sirius",
            RememberJoins = true
        },
        KeySystem = true,
        KeySettings = {
            Title = "BHRM5 | D3MONG",
            Subtitle = "Key System",
            Note = "Join the discord (discord.gg/sirius)",
            FileName = "D3MONG_Key",
            SaveKey = false,
            GrabKeyFromSite = false,
            Key = "Hello"
        }
    })

    -- ---- Tab: ESP & Visuals -------------------------------
    local VisualTab = Window:CreateTab("ESP & Visuals", 4483362458)
    
    local ESPSection = VisualTab:CreateSection("ESP Settings", false)

    -- NPC ESP Toggle
    VisualTab:CreateToggle({
        Name = "NPC ESP",
        Info = "Shows NPCs through walls (Green = Visible, Red = Hidden)",
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
        Info = "Shows REAL PLAYERS through walls (Blue = Visible, Yellow = Hidden)",
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
        Info = "Adjust the transparency of ESP highlights",
        Range = {0, 100},
        Increment = 5,
        Suffix = "%",
        CurrentValue = 45,
        Flag = "ESPTransparency",
        Callback = function(Value)
            Walls.setFillTransparency(Value / 100)
        end,
    })

    -- Color Pickers Section
    local ColorSection = VisualTab:CreateSection("ESP Colors", false)

    VisualTab:CreateColorPicker({
        Name = "NPC Visible Color",
        Info = "Color when NPC is visible",
        Color = Color3.fromRGB(0, 255, 80),
        Flag = "NPCVisibleColor",
        Callback = function(Value)
            Walls.setNPCVisibleColor(Value)
        end
    })

    VisualTab:CreateColorPicker({
        Name = "NPC Hidden Color",
        Info = "Color when NPC is behind wall",
        Color = Color3.fromRGB(255, 40, 40),
        Flag = "NPCHiddenColor",
        Callback = function(Value)
            Walls.setNPCHiddenColor(Value)
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Player Visible Color",
        Info = "Color when player is visible",
        Color = Color3.fromRGB(0, 150, 255),
        Flag = "PlayerVisibleColor",
        Callback = function(Value)
            Walls.setPlayerVisibleColor(Value)
        end
    })

    VisualTab:CreateColorPicker({
        Name = "Player Hidden Color",
        Info = "Color when player is behind wall",
        Color = Color3.fromRGB(255, 200, 0),
        Flag = "PlayerHiddenColor",
        Callback = function(Value)
            Walls.setPlayerHiddenColor(Value)
        end
    })

    -- ---- Tab: Combat --------------------------------------
    local CombatTab = Window:CreateTab("Combat", 4483362458)
    
    -- Aimbot Section
    local AimbotSection = CombatTab:CreateSection("Aimbot", false)

    CombatTab:CreateToggle({
        Name = "Aimbot",
        Info = "Auto-aim at targets. Hold RIGHT MOUSE to aim",
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

    CombatTab:CreateToggle({
        Name = "Target NPCs",
        Info = "Allow aimbot to target NPCs",
        CurrentValue = true,
        Flag = "AimbotTargetNPCs",
        Callback = function(Value)
            Aimbot.setTargetNPCs(Value)
        end,
    })

    CombatTab:CreateToggle({
        Name = "Target Players",
        Info = "Allow aimbot to target real players",
        CurrentValue = false,
        Flag = "AimbotTargetPlayers",
        Callback = function(Value)
            Aimbot.setTargetPlayers(Value)
        end,
    })

    CombatTab:CreateSlider({
        Name = "Aimbot FOV",
        Info = "Field of view for aimbot (pixels from crosshair)",
        Range = {50, 500},
        Increment = 10,
        Suffix = "px",
        CurrentValue = 200,
        Flag = "AimbotFOV",
        Callback = function(Value)
            Aimbot.setFOV(Value)
        end,
    })

    CombatTab:CreateSlider({
        Name = "Aimbot Smoothness",
        Info = "How smooth the aim is (lower = smoother but slower)",
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
    local RecoilSection = CombatTab:CreateSection("Recoil Control", false)

    CombatTab:CreateToggle({
        Name = "No Recoil",
        Info = "Removes weapon recoil",
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

    CombatTab:CreateSlider({
        Name = "Recoil Reduction",
        Info = "How much recoil to remove",
        Range = {0, 100},
        Increment = 10,
        Suffix = "%",
        CurrentValue = 100,
        Flag = "RecoilStrength",
        Callback = function(Value)
            NoRecoil.setStrength(Value / 100)
        end,
    })

    -- ---- Tab: Info & Settings -----------------------------
    local InfoTab = Window:CreateTab("Info & Settings", 4483362458)
    
    local InfoSection = InfoTab:CreateSection("Script Information", true)

    InfoTab:CreateLabel("BHRM5 Enhanced Script v2.0")
    InfoTab:CreateLabel("Created by D3MONG")
    
    InfoTab:CreateParagraph({
        Title = "How to Use",
        Content = "Enable ESP to see NPCs/Players through walls. Use Aimbot with Right Mouse Button held. Toggle No Recoil for better accuracy. Adjust colors and settings as needed."
    }, InfoSection)

    InfoTab:CreateParagraph({
        Title = "Controls",
        Content = "Left Shift = Hide/Show UI | Right Mouse = Hold to Aim (when aimbot enabled)"
    }, InfoSection)

    -- Stats Section
    local StatsSection = InfoTab:CreateSection("Live Statistics", false)

    local NPCLabel = InfoTab:CreateLabel("NPCs: 0", StatsSection)
    local PlayerLabel = InfoTab:CreateLabel("Players: 0", StatsSection)

    -- Update stats every second
    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                local npcCount = NPCManager:getCount()
                local playerCount = PlayerManager:getCount()
                NPCLabel:Set("NPCs Detected: " .. tostring(npcCount))
                PlayerLabel:Set("Players Detected: " .. tostring(playerCount))
            end)
        end
    end)

    -- Actions Section
    local ActionSection = InfoTab:CreateSection("Actions", false)

    InfoTab:CreateButton({
        Name = "Unload Script",
        Info = "Completely removes the script and all features",
        Interact = 'Click to Unload',
        Callback = function()
            Walls.disableNPCs()
            Walls.disablePlayers()
            NoRecoil.disable()
            Aimbot.disable()
            NPCManager:cleanup()
            PlayerManager:cleanup()
            Rayfield:Destroy()
        end,
    })

    InfoTab:CreateButton({
        Name = "Reload Config",
        Info = "Reload saved configuration",
        Interact = 'Reload',
        Callback = function()
            Rayfield:LoadConfiguration()
        end,
    })

    -- ---- Keybind: Hide/Show UI ----------------------------
    local UIS = game:GetService("UserInputService")
    local UIVisible = true

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            UIVisible = not UIVisible
            -- Toggle Rayfield visibility
            pcall(function()
                local gui = game:GetService("CoreGui"):FindFirstChild("Rayfield")
                if not gui then
                    gui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Rayfield")
                end
                if gui then
                    gui.Enabled = UIVisible
                end
            end)
        end
    end)

    -- Load saved configuration
    Rayfield:LoadConfiguration()
end

return GUI
