-- ============================================================
--  BHRM5 Enhanced GUI  |  D3MONG
--  Community: SEKUMPUL
-- ============================================================

local GUI = {}

function GUI:init(NPCManager, PlayerManager, Walls, NoRecoil, Aimbot)

    local Rayfield = loadstring(game:HttpGet(
        'https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'
    ))()

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
            Title = "BHRM5 Enhanced",
            Subtitle = "Key System",
            Note = "Join discord.gg/aJ4ZWEz387",
            FileName = "D3MONG_Key",
            SaveKey = true,
            GrabKeyFromSite = false,
            Key = "demong"
        }
    })

    -- ========================================================
    -- TAB 1: ESP
    -- ========================================================
    local ESPTab = Window:CreateTab("ESP", 4483362458)
    
    ESPTab:CreateSection("ESP Controls", false)

    ESPTab:CreateToggle({
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

    ESPTab:CreateToggle({
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

    ESPTab:CreateSlider({
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

    ESPTab:CreateSection("NPC Colors", false)

    ESPTab:CreateColorPicker({
        Name = "NPC Visible",
        Color = Color3.fromRGB(0, 255, 80),
        Flag = "NPCVisibleColor",
        Callback = function(Value)
            Walls.setNPCVisibleColor(Value)
        end
    })

    ESPTab:CreateColorPicker({
        Name = "NPC Hidden",
        Color = Color3.fromRGB(255, 40, 40),
        Flag = "NPCHiddenColor",
        Callback = function(Value)
            Walls.setNPCHiddenColor(Value)
        end
    })

    ESPTab:CreateSection("Player Colors", false)

    ESPTab:CreateColorPicker({
        Name = "Player Visible",
        Color = Color3.fromRGB(0, 150, 255),
        Flag = "PlayerVisibleColor",
        Callback = function(Value)
            Walls.setPlayerVisibleColor(Value)
        end
    })

    ESPTab:CreateColorPicker({
        Name = "Player Hidden",
        Color = Color3.fromRGB(255, 200, 0),
        Flag = "PlayerHiddenColor",
        Callback = function(Value)
            Walls.setPlayerHiddenColor(Value)
        end
    })

    -- ========================================================
    -- TAB 2: AIMBOT
    -- ========================================================
    local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
    
    AimbotTab:CreateSection("Aimbot Settings", false)

    AimbotTab:CreateToggle({
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

    AimbotTab:CreateToggle({
        Name = "Target NPCs",
        CurrentValue = true,
        Flag = "AimbotTargetNPCs",
        Callback = function(Value)
            Aimbot.setTargetNPCs(Value)
        end,
    })

    AimbotTab:CreateToggle({
        Name = "Target Players",
        CurrentValue = false,
        Flag = "AimbotTargetPlayers",
        Callback = function(Value)
            Aimbot.setTargetPlayers(Value)
        end,
    })

    AimbotTab:CreateSlider({
        Name = "FOV",
        Range = {50, 500},
        Increment = 10,
        Suffix = "px",
        CurrentValue = 200,
        Flag = "AimbotFOV",
        Callback = function(Value)
            Aimbot.setFOV(Value)
        end,
    })

    AimbotTab:CreateSlider({
        Name = "Smoothness",
        Range = {1, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 20,
        Flag = "AimbotSmoothness",
        Callback = function(Value)
            Aimbot.setSmoothness(Value / 100)
        end,
    })

    -- ========================================================
    -- TAB 3: COMBAT
    -- ========================================================
    local CombatTab = Window:CreateTab("Combat", 4483362458)
    
    CombatTab:CreateSection("No Recoil", false)

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
    -- TAB 4: INFO
    -- ========================================================
    local InfoTab = Window:CreateTab("Info", 4483362458)
    
    InfoTab:CreateSection("Statistics", false)

    local NPCLabel = InfoTab:CreateLabel("NPCs: 0")
    local PlayerLabel = InfoTab:CreateLabel("Players: 0")

    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                NPCLabel:Set("NPCs: " .. tostring(NPCManager:getCount()))
                PlayerLabel:Set("Players: " .. tostring(PlayerManager:getCount()))
            end)
        end
    end)

    InfoTab:CreateSection("Information", false)

    InfoTab:CreateLabel("Version: 2.0")
    InfoTab:CreateLabel("Author: D3MONG")
    InfoTab:CreateLabel("Community: SEKUMPUL")

    InfoTab:CreateSection("Controls", false)

    InfoTab:CreateLabel("INSERT = Toggle UI")
    InfoTab:CreateLabel("Right Mouse = Aimbot")

    InfoTab:CreateSection("Actions", false)

    InfoTab:CreateButton({
        Name = "Unload Script",
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

    -- ========================================================
    -- UI TOGGLE
    -- ========================================================
    local UIS = game:GetService("UserInputService")
    
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            Rayfield:Toggle()
        end
    end)

    Rayfield:LoadConfiguration()
end

return GUI
