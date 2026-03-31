-- ============================================================
--  BHRM5 No Recoil Module
--  Author : D3MONG
--  Two methods:
--   1. Camera pitch correction  (works always)
--   2. Weapon config zero-out   (deeper patch)
-- ============================================================

local NoRecoil   = {}
local RunService = game:GetService("RunService")

NoRecoil._enabled    = false
NoRecoil._strength   = 1.0   -- 1.0 = full cancel
NoRecoil._conn       = nil
NoRecoil._lastCF     = nil

-- Minimum pitch delta to treat as recoil kick (radians)
-- Prevents normal mouse movement from being cancelled
local THRESHOLD = 0.0020

-- ---- Method 1: Camera Correction ----------------------------

local function startCameraCorrection()
    local camera = workspace.CurrentCamera
    NoRecoil._lastCF = nil

    NoRecoil._conn = RunService.RenderStepped:Connect(function()
        if not NoRecoil._enabled then return end

        local curCF = camera.CFrame

        if NoRecoil._lastCF then
            local _, lastPitch, _ = NoRecoil._lastCF:ToEulerAnglesYXZ()
            local _, curPitch,  _ = curCF:ToEulerAnglesYXZ()

            local delta = curPitch - lastPitch

            -- Upward recoil = negative pitch delta
            if delta < -THRESHOLD then
                local fix = math.abs(delta) * NoRecoil._strength
                camera.CFrame = curCF * CFrame.Angles(fix, 0, 0)
            end
        end

        NoRecoil._lastCF = camera.CFrame
    end)
end

local function stopCameraCorrection()
    if NoRecoil._conn then
        NoRecoil._conn:Disconnect()
        NoRecoil._conn = nil
    end
    NoRecoil._lastCF = nil
end

-- ---- Method 2: Weapon Config Patch --------------------------
-- Zeroes out recoil values inside BHRM5 weapon configs
-- Path: ReplicatedStorage > Shared > Configs > Weapon > Weapons_Player

local function patchWeaponConfigs()
    local ok, folder = pcall(function()
        return game:GetService("ReplicatedStorage")
            .Shared.Configs.Weapon.Weapons_Player
    end)
    if not ok or not folder then
        warn("[D3MONG] Weapon folder not found - camera correction only")
        return
    end

    local patched = 0
    for _, platform in ipairs(folder:GetChildren()) do
        for _, weapon in ipairs(platform:GetChildren()) do
            for _, child in ipairs(weapon:GetChildren()) do
                if child:IsA("ModuleScript")
                and child.Name:match("^Receiver%.") then
                    pcall(function()
                        local r = require(child)
                        if r and r.Config and r.Config.Tune then
                            local t = r.Config.Tune
                            t.Recoil_X            = 0
                            t.Recoil_Z            = 0
                            t.RecoilForce_Tap     = 0
                            t.RecoilForce_Impulse = 0
                            t.Recoil_Range        = Vector2.zero
                            t.Recoil_Camera       = 0
                            patched = patched + 1
                        end
                    end)
                end
            end
        end
    end

    if patched > 0 then
        print("[D3MONG] Patched " .. patched .. " weapon(s)")
    end
end

-- ---- Public API ---------------------------------------------

function NoRecoil.enable()
    if NoRecoil._enabled then return end
    NoRecoil._enabled = true
    startCameraCorrection()  -- always runs
    patchWeaponConfigs()     -- tries deep patch too
end

function NoRecoil.disable()
    NoRecoil._enabled = false
    stopCameraCorrection()
end

function NoRecoil.setStrength(value)
    NoRecoil._strength = math.clamp(value, 0.1, 3.0)
end

function NoRecoil.isEnabled()
    return NoRecoil._enabled
end

return NoRecoil
