-- ============================================================
--  BHRM5 Walls Module
--  Author  : D3MONG
--  Method  : Highlight (AlwaysOnTop) + Raycast color update
-- ============================================================

local Walls       = {}
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Internal state
Walls._enabled       = false
Walls._highlights    = {}   -- [npcModel] = Highlight instance
Walls._updateConn    = nil
Walls._scanConn      = nil
Walls._visibleColor  = Color3.fromRGB(0, 255, 0)   -- green = can see
Walls._hiddenColor   = Color3.fromRGB(255, 0, 0)    -- red   = behind wall
Walls._config        = nil

-- ---- Helpers ------------------------------------------------

-- BHRM5 NPCs live inside Workspace > Model > NPCS
local function getNPCsInWorkspace()
    local found = {}
    for _, container in ipairs(workspace:GetChildren()) do
        if container:IsA("Model") and container.Name == "Model" then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Model") and child.Name == "NPCS" then
                    table.insert(found, child)
                end
            end
        end
    end
    return found
end

local function getHead(npc)
    return npc:FindFirstChild("Head")
end

-- Cast a ray from camera to NPC head
-- Returns true if the head is directly visible (not blocked)
local function isVisible(head)
    local camera = workspace.CurrentCamera
    if not camera or not head then return false end

    local origin    = camera.CFrame.Position
    local direction = head.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local char = localPlayer.Character
    params.FilterDescendantsInstances = char and {char, head} or {head}

    local result = workspace:Raycast(origin, direction, params)
    return result == nil or result.Instance:IsDescendantOf(head.Parent)
end

-- ---- Core ---------------------------------------------------

local function attachHighlight(npc)
    if Walls._highlights[npc] then return end
    local head = getHead(npc)
    if not head then return end

    local hl                   = Instance.new("Highlight")
    hl.Name                    = "D3MONG_Wall"
    hl.Adornee                 = npc
    hl.FillColor               = Walls._hiddenColor
    hl.OutlineColor            = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency        = 0.4
    hl.OutlineTransparency     = 0
    hl.DepthMode               = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent                  = npc

    Walls._highlights[npc] = hl
end

local function removeHighlight(npc)
    local hl = Walls._highlights[npc]
    if hl then
        pcall(function() hl:Destroy() end)
        Walls._highlights[npc] = nil
    end
end

local function removeAllHighlights()
    for npc in pairs(Walls._highlights) do
        removeHighlight(npc)
    end
end

-- Scan workspace and attach highlights to all found NPCs
local function scanAndAttach()
    for _, npc in ipairs(getNPCsInWorkspace()) do
        attachHighlight(npc)
    end
end

-- Update highlight colors based on line-of-sight
local function updateColors()
    for npc, hl in pairs(Walls._highlights) do
        -- Remove highlight if NPC is gone
        if not npc or not npc.Parent then
            removeHighlight(npc)
        else
            local head = getHead(npc)
            if head then
                hl.FillColor = isVisible(head)
                    and Walls._visibleColor
                    or  Walls._hiddenColor
            end
        end
    end
end

-- ---- Public API ---------------------------------------------

function Walls.enable(_, config)
    if Walls._enabled then return end
    Walls._enabled = true

    if config then
        Walls._visibleColor = config.visibleColor or Walls._visibleColor
        Walls._hiddenColor  = config.hiddenColor  or Walls._hiddenColor
        Walls._config       = config
    end

    -- Initial scan
    scanAndAttach()

    -- Re-scan every 0.5s for new NPCs
    Walls._scanConn = RunService.Heartbeat:Connect(function()
        if not Walls._enabled then return end
        scanAndAttach()
    end)

    -- Update colors every frame
    local acc = 0
    Walls._updateConn = RunService.RenderStepped:Connect(function(dt)
        if not Walls._enabled then return end
        acc = acc + dt
        if acc >= 0.15 then
            updateColors()
            acc = 0
        end
    end)
end

function Walls.disable()
    Walls._enabled = false

    if Walls._scanConn then
        Walls._scanConn:Disconnect()
        Walls._scanConn = nil
    end
    if Walls._updateConn then
        Walls._updateConn:Disconnect()
        Walls._updateConn = nil
    end

    removeAllHighlights()
end

function Walls.setVisibleColor(color)
    Walls._visibleColor = color
end

function Walls.setHiddenColor(color)
    Walls._hiddenColor = color
end

function Walls.isEnabled()
    return Walls._enabled
end

-- Compatibility shim for main.lua Markers.updateColors call
function Walls.updateColors(_, camera, ws, player, config)
    if not Walls._enabled then return end
    updateColors()
end

-- Compatibility shims used by npc_manager
function Walls.createBoxForPart(part, config) end
function Walls.destroyBoxForPart(part) end
function Walls.destroyAllBoxes() end

return Walls
