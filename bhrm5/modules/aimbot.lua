-- ============================================================
--  BHRM5 Aimbot  |  D3MONG
--  Simple aimbot for NPCs and Players
-- ============================================================

local Aimbot = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

Aimbot._enabled = false
Aimbot._targetNPCs = true
Aimbot._targetPlayers = false
Aimbot._fov = 200
Aimbot._smoothness = 0.2
Aimbot._conn = nil
Aimbot._npcManager = nil
Aimbot._playerManager = nil

-- ---- Helpers ------------------------------------------------

local function getClosestTarget()
    local camera = workspace.CurrentCamera
    local localPlayer = Players.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar then return nil end
    
    local closestTarget = nil
    local shortestDistance = Aimbot._fov
    
    -- Check NPCs if enabled
    if Aimbot._targetNPCs and Aimbot._npcManager then
        for model, data in pairs(Aimbot._npcManager:getAll()) do
            if model and model.Parent and data.head then
                local screenPos, onScreen = camera:WorldToViewportPoint(data.head.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = data.head
                    end
                end
            end
        end
    end
    
    -- Check Players if enabled
    if Aimbot._targetPlayers and Aimbot._playerManager then
        for model, data in pairs(Aimbot._playerManager:getAll()) do
            if model and model.Parent and data.head then
                local screenPos, onScreen = camera:WorldToViewportPoint(data.head.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = data.head
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- ---- Public API ---------------------------------------------

function Aimbot.enable(npcManager, playerManager)
    if Aimbot._enabled then return end
    Aimbot._enabled = true
    Aimbot._npcManager = npcManager
    Aimbot._playerManager = playerManager
    
    print("[D3MONG] Aimbot Enabled - Hold RIGHT MOUSE to aim")
    
    Aimbot._conn = RunService.RenderStepped:Connect(function()
        if not Aimbot._enabled then return end
        
        -- Only aim when right mouse button is held
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            return
        end
        
        local target = getClosestTarget()
        if target then
            local camera = workspace.CurrentCamera
            local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
            
            -- Smooth aim
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, Aimbot._smoothness)
        end
    end)
end

function Aimbot.disable()
    Aimbot._enabled = false
    if Aimbot._conn then
        Aimbot._conn:Disconnect()
        Aimbot._conn = nil
    end
    print("[D3MONG] Aimbot Disabled")
end

function Aimbot.setTargetNPCs(value)
    Aimbot._targetNPCs = value
end

function Aimbot.setTargetPlayers(value)
    Aimbot._targetPlayers = value
end

function Aimbot.setFOV(value)
    Aimbot._fov = math.clamp(value, 50, 500)
end

function Aimbot.setSmoothness(value)
    Aimbot._smoothness = math.clamp(value, 0.01, 1.0)
end

function Aimbot.isEnabled()
    return Aimbot._enabled
end

return Aimbot
