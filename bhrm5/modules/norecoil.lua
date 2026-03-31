-- ============================================================
--  BHRM5 No Recoil  |  D3MONG
-- ============================================================

local NoRecoil   = {}
local RunService = game:GetService("RunService")

NoRecoil._enabled  = false
NoRecoil._strength = 1.0
NoRecoil._conn     = nil
NoRecoil._lastCF   = nil

local THRESHOLD = 0.0018

function NoRecoil.enable()
    if NoRecoil._enabled then return end
    NoRecoil._enabled = true
    NoRecoil._lastCF  = nil

    local cam = workspace.CurrentCamera

    NoRecoil._conn = RunService.RenderStepped:Connect(function()
        local curCF = cam.CFrame

        if NoRecoil._lastCF then
            local _, lastP, _ = NoRecoil._lastCF:ToEulerAnglesYXZ()
            local _, curP,  _ = curCF:ToEulerAnglesYXZ()
            local delta = curP - lastP

            if delta < -THRESHOLD then
                local fix = math.abs(delta) * NoRecoil._strength
                cam.CFrame = curCF * CFrame.Angles(fix, 0, 0)
            end
        end

        NoRecoil._lastCF = cam.CFrame
    end)
end

function NoRecoil.disable()
    NoRecoil._enabled = false
    if NoRecoil._conn then
        NoRecoil._conn:Disconnect()
        NoRecoil._conn = nil
    end
    NoRecoil._lastCF = nil
end

function NoRecoil.setStrength(v)
    NoRecoil._strength = math.clamp(v, 0.1, 3.0)
end

function NoRecoil.isEnabled()
    return NoRecoil._enabled
end

return NoRecoil
