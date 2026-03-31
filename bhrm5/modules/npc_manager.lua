-- ============================================================
--  BHRM5 NPC Manager
--  Author : D3MONG
--  Scans workspace for BHRM5 enemy NPCs and tracks them
-- ============================================================

local NPCManager  = {}
local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Active tracked NPCs: [model] = { model, head, root }
NPCManager._npcs        = {}
NPCManager._connections = {}
NPCManager._scanConn    = nil

-- ---- BHRM5 NPC Detection ------------------------------------
-- In BHRM5, enemy NPCs are structured as:
--   Workspace > Model (container) > NPCS (npc model)
-- Each NPC has a Head part and a root (HumanoidRootPart or Root)

local function getRootPart(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Root")
        or model:FindFirstChild("UpperTorso")
end

local function isValidNPC(model)
    if not model or not model:IsA("Model") then return false end
    if model.Name ~= "NPCS" then return false end
    if not model:FindFirstChild("Head") then return false end
    if not getRootPart(model) then return false end
    return true
end

local function getPlayerRadius()
    local char = localPlayer and localPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    return root and root.Position or nil
end

-- ---- Core Tracking ------------------------------------------

local function trackNPC(model)
    if NPCManager._npcs[model] then return end
    if not isValidNPC(model) then return end

    local head = model:FindFirstChild("Head")
    local root = getRootPart(model)

    NPCManager._npcs[model] = {
        model = model,
        head  = head,
        root  = root,
    }

    -- Auto-remove when NPC is destroyed
    local conn = model.AncestryChanged:Connect(function()
        if not model.Parent then
            NPCManager._npcs[model] = nil
        end
    end)
    table.insert(NPCManager._connections, conn)
end

local function scanContainer(container)
    if not container or not container:IsA("Model") then return end
    if container.Name ~= "Model" then return end

    for _, child in ipairs(container:GetChildren()) do
        if isValidNPC(child) then
            trackNPC(child)
        end
    end

    -- Watch for NPCs added later into this container
    local conn = container.ChildAdded:Connect(function(child)
        task.wait(0.2)
        if isValidNPC(child) then
            trackNPC(child)
        end
    end)
    table.insert(NPCManager._connections, conn)
end

-- ---- Public API ---------------------------------------------

function NPCManager:scan()
    -- Scan all current workspace children
    for _, obj in ipairs(workspace:GetChildren()) do
        scanContainer(obj)
    end

    -- Watch for new containers added to workspace
    local conn = workspace.ChildAdded:Connect(function(obj)
        task.wait(0.2)
        scanContainer(obj)
    end)
    table.insert(self._connections, conn)
end

function NPCManager:getAll()
    -- Clean up dead NPCs first
    for model in pairs(self._npcs) do
        if not model or not model.Parent then
            self._npcs[model] = nil
        end
    end
    return self._npcs
end

function NPCManager:getCount()
    local count = 0
    for _ in pairs(self:getAll()) do
        count = count + 1
    end
    return count
end

function NPCManager:getNearby(maxDistance)
    local origin = getPlayerRadius()
    if not origin then return self:getAll() end

    local nearby = {}
    for model, data in pairs(self:getAll()) do
        if data.root then
            local dist = (data.root.Position - origin).Magnitude
            if dist <= maxDistance then
                nearby[model] = data
            end
        end
    end
    return nearby
end

function NPCManager:cleanup()
    for _, conn in ipairs(self._connections) do
        pcall(function() conn:Disconnect() end)
    end
    self._connections = {}
    self._npcs = {}
end

return NPCManager
