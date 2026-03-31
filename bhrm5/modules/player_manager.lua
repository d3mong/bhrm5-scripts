-- ============================================================
--  BHRM5 Player Manager  |  D3MONG
--  Detects and tracks REAL PLAYERS only (not NPCs)
-- ============================================================

local PlayerManager = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

PlayerManager._players = {}
PlayerManager._connections = {}

-- ---- Helpers ------------------------------------------------

local function getRootPart(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Root")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChildWhichIsA("BasePart")
end

local function getPlayerFromCharacter(character)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == character then
            return player
        end
    end
    return nil
end

local function isValidPlayerCharacter(model)
    if not model or not model:IsA("Model") then return false end
    
    local player = getPlayerFromCharacter(model)
    if not player then return false end
    if player == Players.LocalPlayer then return false end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local head = model:FindFirstChild("Head")
    if not humanoid or not head then return false end
    
    if humanoid.Health <= 0 then return false end
    
    return true, player
end

-- ---- Track / Untrack ----------------------------------------

local function trackPlayer(model, player)
    if PlayerManager._players[model] then return end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local head = model:FindFirstChild("Head")
    local root = getRootPart(model)
    
    PlayerManager._players[model] = {
        model = model,
        player = player,
        head = head,
        root = root,
        humanoid = humanoid,
    }
    
    local diedConn = humanoid.Died:Connect(function()
        PlayerManager._players[model] = nil
    end)
    local removeConn = model.AncestryChanged:Connect(function()
        if not model.Parent then
            PlayerManager._players[model] = nil
        end
    end)
    
    table.insert(PlayerManager._connections, diedConn)
    table.insert(PlayerManager._connections, removeConn)
end

-- ---- Public API ---------------------------------------------

function PlayerManager:scan()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local isValid, plr = isValidPlayerCharacter(player.Character)
            if isValid then
                trackPlayer(player.Character, plr)
            end
        end
    end
    
    local conn = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            local isValid, plr = isValidPlayerCharacter(character)
            if isValid then
                trackPlayer(character, plr)
            end
        end)
    end)
    table.insert(self._connections, conn)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            player.CharacterAdded:Connect(function(character)
                task.wait(0.5)
                local isValid, plr = isValidPlayerCharacter(character)
                if isValid then
                    trackPlayer(character, plr)
                end
            end)
        end
    end
end

function PlayerManager:getAll()
    for model in pairs(self._players) do
        if not model or not model.Parent then
            self._players[model] = nil
        end
    end
    return self._players
end

function PlayerManager:getCount()
    local n = 0
    for _ in pairs(self:getAll()) do n = n + 1 end
    return n
end

function PlayerManager:cleanup()
    for _, c in ipairs(self._connections) do
        pcall(function() c:Disconnect() end)
    end
    self._connections = {}
    self._players = {}
end

return PlayerManager
