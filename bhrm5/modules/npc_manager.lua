-- ============================================================
--  BHRM5 NPC Manager  |  D3MONG
--  Detection: Any workspace model with Humanoid (not a player)
--  Works regardless of NPC container naming in BRM5
-- ============================================================

local NPCManager  = {}
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")

NPCManager._npcs        = {}   -- [model] = { model, head, root, humanoid }
NPCManager._connections = {}

-- ---- Helpers ------------------------------------------------

local function isPlayerCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return true
        end
    end
    return false
end

local function getRootPart(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Root")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChildWhichIsA("BasePart")
end

local function isValidNPC(model)
    if not model or not model:IsA("Model") then return false end
    if isPlayerCharacter(model) then return false end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local head     = model:FindFirstChild("Head")
    if not humanoid or not head then return false end

    -- Must be alive
    if humanoid.Health <= 0 then return false end

    return true
end

-- ---- Track / Untrack ----------------------------------------

local function trackModel(model)
    if NPCManager._npcs[model] then return end
    if not isValidNPC(model) then return end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local head     = model:FindFirstChild("Head")
    local root     = getRootPart(model)

    NPCManager._npcs[model] = {
        model    = model,
        head     = head,
        root     = root,
        humanoid = humanoid,
    }

    -- Remove when NPC dies or is destroyed
    local diedConn = humanoid.Died:Connect(function()
        NPCManager._npcs[model] = nil
    end)
    local removeConn = model.AncestryChanged:Connect(function()
        if not model.Parent then
            NPCManager._npcs[model] = nil
        end
    end)

    table.insert(NPCManager._connections, diedConn)
    table.insert(NPCManager._connections, removeConn)
end

-- ---- Public API ---------------------------------------------

function NPCManager:scan()
    -- Scan all current descendants in workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            trackModel(obj)
        end
    end

    -- Watch for anything added to workspace
    local conn = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            task.wait(0.5) -- wait for children to load
            trackModel(obj)
        end
    end)
    table.insert(self._connections, conn)

    -- Periodic rescan every 3s to catch any missed NPCs
    local rescanConn = RunService.Heartbeat:Connect(function()
        -- lightweight: only scan top-level workspace children
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and not self._npcs[obj] then
                trackModel(obj)
                -- also check children
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Model") then
                        trackModel(child)
                    end
                end
            end
        end
    end)
    table.insert(self._connections, rescanConn)
end

function NPCManager:getAll()
    -- Clean dead entries
    for model in pairs(self._npcs) do
        if not model or not model.Parent then
            self._npcs[model] = nil
        end
    end
    return self._npcs
end

function NPCManager:getCount()
    local n = 0
    for _ in pairs(self:getAll()) do n = n + 1 end
    return n
end

function NPCManager:cleanup()
    for _, c in ipairs(self._connections) do
        pcall(function() c:Disconnect() end)
    end
    self._connections = {}
    self._npcs = {}
end

return NPCManager
