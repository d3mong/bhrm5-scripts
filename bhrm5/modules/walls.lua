-- ============================================================
--  BHRM5 Enhanced Wallhack / ESP  |  D3MONG
--  Separates PLAYERS from NPCs with different colors
--  Green = visible | Red = behind wall (NPCs)
--  Blue = visible | Yellow = behind wall (Players)
-- ============================================================

local Walls = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

Walls._highlights = {}
Walls._npcEnabled = false
Walls._playerEnabled = false
Walls._conn = nil

-- Color settings
Walls._npcVisibleColor = Color3.fromRGB(0, 255, 80)
Walls._npcHiddenColor = Color3.fromRGB(255, 40, 40)
Walls._playerVisibleColor = Color3.fromRGB(0, 150, 255)
Walls._playerHiddenColor = Color3.fromRGB(255, 200, 0)
Walls._fillAlpha = 0.45

-- ---- Raycast Visibility Check ------------------------------

local function canSee(head)
    local camera = workspace.CurrentCamera
    if not camera or not head then return false end
    
    local lp = Players.LocalPlayer
    local char = lp and lp.Character
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = char
        and { char, head.Parent }
        or  { head.Parent }
    
    local origin = camera.CFrame.Position
    local dir = head.Position - origin
    local result = workspace:Raycast(origin, dir, params)
    
    if result == nil then return true end
    if result.Instance:IsDescendantOf(head.Parent) then return true end
    return false
end

-- ---- Highlight Helpers -------------------------------------

local function makeHighlight(model, isPlayer)
    local old = model:FindFirstChild("D3MONG_ESP")
    if old then old:Destroy() end
    
    local hl = Instance.new("Highlight")
    hl.Name = "D3MONG_ESP"
    hl.Adornee = model
    
    if isPlayer then
        hl.FillColor = Walls._playerHiddenColor
        hl.OutlineColor = Color3.fromRGB(0, 150, 255)
    else
        hl.FillColor = Walls._npcHiddenColor
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    end
    
    hl.FillTransparency = Walls._fillAlpha
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = model
    
    return hl
end

local function removeHL(model)
    if Walls._highlights[model] then
        local data = Walls._highlights[model]
        if data and data.highlight then
            pcall(function() data.highlight:Destroy() end)
        end
        Walls._highlights[model] = nil
    end
end

-- ---- Public API --------------------------------------------

function Walls.enableNPCs(npcManager)
    Walls._npcEnabled = true
    Walls._npcManager = npcManager
    Walls._startUpdate()
    print("[D3MONG] NPC ESP Enabled")
end

function Walls.disableNPCs()
    Walls._npcEnabled = false
    for model, data in pairs(Walls._highlights) do
        if data and not data.isPlayer then
            removeHL(model)
        end
    end
    Walls._checkDisconnect()
    print("[D3MONG] NPC ESP Disabled")
end

function Walls.enablePlayers(playerManager)
    Walls._playerEnabled = true
    Walls._playerManager = playerManager
    Walls._startUpdate()
    print("[D3MONG] Player ESP Enabled")
end

function Walls.disablePlayers()
    Walls._playerEnabled = false
    for model, data in pairs(Walls._highlights) do
        if data and data.isPlayer then
            removeHL(model)
        end
    end
    Walls._checkDisconnect()
    print("[D3MONG] Player ESP Disabled")
end

function Walls._checkDisconnect()
    if not Walls._npcEnabled and not Walls._playerEnabled then
        if Walls._conn then
            Walls._conn:Disconnect()
            Walls._conn = nil
        end
        Walls._highlights = {}
    end
end

function Walls._startUpdate()
    if Walls._conn then return end
    
    local timer = 0
    Walls._conn = RunService.RenderStepped:Connect(function(dt)
        -- Attach highlights to NPCs if enabled
        if Walls._npcEnabled and Walls._npcManager then
            for model in pairs(Walls._npcManager:getAll()) do
                if model and model.Parent and not Walls._highlights[model] then
                    Walls._highlights[model] = {
                        highlight = makeHighlight(model, false),
                        isPlayer = false
                    }
                end
            end
        end
        
        -- Attach highlights to Players if enabled
        if Walls._playerEnabled and Walls._playerManager then
            for model in pairs(Walls._playerManager:getAll()) do
                if model and model.Parent and not Walls._highlights[model] then
                    Walls._highlights[model] = {
                        highlight = makeHighlight(model, true),
                        isPlayer = true
                    }
                end
            end
        end
        
        -- Remove highlights for dead/gone entities
        for model, data in pairs(Walls._highlights) do
            if not model or not model.Parent then
                removeHL(model)
            elseif data.isPlayer and not Walls._playerEnabled then
                removeHL(model)
            elseif not data.isPlayer and not Walls._npcEnabled then
                removeHL(model)
            end
        end
        
        -- Update colors every 0.1s
        timer = timer + dt
        if timer >= 0.1 then
            timer = 0
            for model, data in pairs(Walls._highlights) do
                if model and model.Parent and data and data.highlight then
                    local head = model:FindFirstChild("Head")
                    if head then
                        local visible = canSee(head)
                        if data.isPlayer then
                            data.highlight.FillColor = visible
                                and Walls._playerVisibleColor
                                or Walls._playerHiddenColor
                        else
                            data.highlight.FillColor = visible
                                and Walls._npcVisibleColor
                                or Walls._npcHiddenColor
                        end
                    end
                end
            end
        end
    end)
end

function Walls.setNPCVisibleColor(c)
    Walls._npcVisibleColor = c
end

function Walls.setNPCHiddenColor(c)
    Walls._npcHiddenColor = c
end

function Walls.setPlayerVisibleColor(c)
    Walls._playerVisibleColor = c
end

function Walls.setPlayerHiddenColor(c)
    Walls._playerHiddenColor = c
end

function Walls.setFillTransparency(v)
    Walls._fillAlpha = v
    for _, data in pairs(Walls._highlights) do
        if data and data.highlight then
            data.highlight.FillTransparency = v
        end
    end
end

function Walls.isNPCEnabled() return Walls._npcEnabled end
function Walls.isPlayerEnabled() return Walls._playerEnabled end

return Walls
