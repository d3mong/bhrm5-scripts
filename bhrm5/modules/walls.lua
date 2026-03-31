-- ============================================================
--  BHRM5 Walls Module
--  Author : D3MONG
--  Shows NPCs through walls using Highlight instances
--  Green = NPC you can see | Red = NPC behind a wall
-- ============================================================

local Walls       = {}
local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local localPlayer = Players.LocalPlayer

Walls._highlights   = {}   -- [npcModel] = Highlight
Walls._enabled      = false
Walls._renderConn   = nil

-- Default colors
Walls._visibleColor = Color3.fromRGB(0, 255, 80)    -- bright green
Walls._hiddenColor  = Color3.fromRGB(255, 40, 40)   -- red
Walls._fillAlpha    = 0.45

-- ---- Raycast Visibility Check -------------------------------

local function canSeeHead(head)
    local camera = workspace.CurrentCamera
    if not camera or not head then return false end

    local origin = camera.CFrame.Position
    local target = head.Position
    local direction = target - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local char = localPlayer.Character
    params.FilterDescendantsInstances = char
        and { char, head.Parent }
        or  { head.Parent }

    local result = workspace:Raycast(origin, direction, params)

    -- No hit = clear line of sight
    -- Hit something that is part of the NPC = also visible
    if result == nil then return true end
    if result.Instance:IsDescendantOf(head.Parent) then return true end
    return false
end

-- ---- Highlight Management -----------------------------------

local function createHighlight(npcModel)
    -- Remove existing one first
    local existing = npcModel:FindFirstChild("D3MONG_ESP")
    if existing then existing:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name                = "D3MONG_ESP"
    hl.Adornee             = npcModel
    hl.FillColor           = Walls._hiddenColor
    hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency    = Walls._fillAlpha
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent              = npcModel

    return hl
end

local function removeHighlight(npcModel)
    local hl = Walls._highlights[npcModel]
    if hl then
        pcall(function() hl:Destroy() end)
        Walls._highlights[npcModel] = nil
    end
end

-- ---- Render Loop -------------------------------------------

local REFRESH_RATE = 0.12  -- seconds between color updates
local _timer = 0

local function updateLoop(dt)
    if not Walls._enabled then return end
    _timer = _timer + dt

    if _timer < REFRESH_RATE then return end
    _timer = 0

    for npcModel, hl in pairs(Walls._highlights) do
        -- Remove highlight if NPC is gone
        if not npcModel or not npcModel.Parent then
            removeHighlight(npcModel)
        else
            local head = npcModel:FindFirstChild("Head")
            if head then
                hl.FillColor = canSeeHead(head)
                    and Walls._visibleColor
                    or  Walls._hiddenColor
            end
        end
    end
end

-- ---- Public API ---------------------------------------------

function Walls.enable(npcManager)
    if Walls._enabled then return end
    Walls._enabled = true

    -- Attach highlight to all known NPCs
    for npcModel in pairs(npcManager:getAll()) do
        Walls._highlights[npcModel] = createHighlight(npcModel)
    end

    -- Keep syncing with npc_manager for new NPCs
    Walls._renderConn = RunService.RenderStepped:Connect(function(dt)
        -- Attach to any new NPCs not yet highlighted
        for npcModel in pairs(npcManager:getAll()) do
            if not Walls._highlights[npcModel] then
                Walls._highlights[npcModel] = createHighlight(npcModel)
            end
        end
        updateLoop(dt)
    end)
end

function Walls.disable()
    Walls._enabled = false

    if Walls._renderConn then
        Walls._renderConn:Disconnect()
        Walls._renderConn = nil
    end

    for npcModel in pairs(Walls._highlights) do
        removeHighlight(npcModel)
    end
    Walls._highlights = {}
end

function Walls.setVisibleColor(color)
    Walls._visibleColor = color
end

function Walls.setHiddenColor(color)
    Walls._hiddenColor = color
end

function Walls.setFillTransparency(value)
    Walls._fillAlpha = value
    for _, hl in pairs(Walls._highlights) do
        hl.FillTransparency = value
    end
end

function Walls.isEnabled()
    return Walls._enabled
end

return Walls
