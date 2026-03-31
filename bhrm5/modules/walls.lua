-- ============================================================
--  BHRM5 Wallhack / ESP  |  D3MONG
--  Uses Highlight (AlwaysOnTop) per NPC
--  Green = you can see them | Red = behind a wall
-- ============================================================

local Walls       = {}
local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")

Walls._highlights    = {}
Walls._enabled       = false
Walls._conn          = nil
Walls._visibleColor  = Color3.fromRGB(0, 255, 80)
Walls._hiddenColor   = Color3.fromRGB(255, 40, 40)
Walls._fillAlpha     = 0.45

-- ---- Raycast Visibility Check ------------------------------

local function canSee(head)
    local camera = workspace.CurrentCamera
    if not camera or not head then return false end

    local lp   = Players.LocalPlayer
    local char = lp and lp.Character

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = char
        and { char, head.Parent }
        or  { head.Parent }

    local origin = camera.CFrame.Position
    local dir    = head.Position - origin
    local result = workspace:Raycast(origin, dir, params)

    if result == nil then return true end
    if result.Instance:IsDescendantOf(head.Parent) then return true end
    return false
end

-- ---- Highlight Helpers -------------------------------------

local function makeHighlight(npcModel)
    local old = npcModel:FindFirstChild("D3MONG_ESP")
    if old then old:Destroy() end

    local hl                   = Instance.new("Highlight")
    hl.Name                    = "D3MONG_ESP"
    hl.Adornee                 = npcModel
    hl.FillColor               = Walls._hiddenColor
    hl.OutlineColor            = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency        = Walls._fillAlpha
    hl.OutlineTransparency     = 0
    hl.DepthMode               = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent                  = npcModel
    return hl
end

local function removeHL(npcModel)
    local hl = Walls._highlights[npcModel]
    if hl then pcall(function() hl:Destroy() end) end
    Walls._highlights[npcModel] = nil
end

-- ---- Public API --------------------------------------------

function Walls.enable(npcManager)
    if Walls._enabled then return end
    Walls._enabled = true

    local timer = 0
    Walls._conn = RunService.RenderStepped:Connect(function(dt)
        if not Walls._enabled then return end

        -- Attach highlights to any new NPCs
        for model in pairs(npcManager:getAll()) do
            if not Walls._highlights[model] then
                Walls._highlights[model] = makeHighlight(model)
            end
        end

        -- Remove highlights for dead/gone NPCs
        for model in pairs(Walls._highlights) do
            if not model or not model.Parent then
                removeHL(model)
            end
        end

        -- Update colors every 0.1s
        timer = timer + dt
        if timer >= 0.1 then
            timer = 0
            for model, hl in pairs(Walls._highlights) do
                if model and model.Parent then
                    local head = model:FindFirstChild("Head")
                    if head then
                        hl.FillColor = canSee(head)
                            and Walls._visibleColor
                            or  Walls._hiddenColor
                    end
                end
            end
        end
    end)
end

function Walls.disable()
    Walls._enabled = false
    if Walls._conn then Walls._conn:Disconnect() Walls._conn = nil end
    for model in pairs(Walls._highlights) do removeHL(model) end
    Walls._highlights = {}
end

function Walls.setVisibleColor(c) Walls._visibleColor = c end
function Walls.setHiddenColor(c)  Walls._hiddenColor  = c end
function Walls.setFillTransparency(v)
    Walls._fillAlpha = v
    for _, hl in pairs(Walls._highlights) do hl.FillTransparency = v end
end
function Walls.isEnabled() return Walls._enabled end

return Walls
