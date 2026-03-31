-- ============================================================
--  BHRM5 No-Recoil Module
--  Author  : D3MONG
--  Method  : RenderStepped camera pitch correction
--            (no weapon ModuleScript patching needed)
-- ============================================================

local Weapons     = {}
local RunService  = game:GetService("RunService")

-- Internal state
local _conn       = nil
local _lastCF     = nil
local _strength   = 1.0     -- 1.0 = full cancel, 0.5 = half cancel
local _smoothing  = 0.85    -- lerp factor (0-1), higher = snappier correction
local _enabled    = false

-- Threshold: minimum pitch kick (radians) before we correct.
-- Too low = corrects normal mouse movement. Too high = misses soft recoil.
local RECOIL_THRESHOLD = 0.0018

-- ---- Core ---------------------------------------------------

local function startLoop()
    local camera = workspace.CurrentCamera
    _lastCF = nil

    _conn = RunService.RenderStepped:Connect(function()
        if not _enabled then return end

        local curCF = camera.CFrame

        if _lastCF then
            -- Extract pitch angles
            local _, lastPitch, _ = _lastCF:ToEulerAnglesYXZ()
            local _, curPitch,  _ = curCF:ToEulerAnglesYXZ()

            local delta = curPitch - lastPitch

            -- Recoil pushes camera UP = negative pitch delta
            if delta < -RECOIL_THRESHOLD then
                local correction = math.abs(delta) * _strength

                -- Smooth the correction with lerp to avoid jarring snaps
                local smoothedCorrection = correction * _smoothing

                camera.CFrame = curCF * CFrame.Angles(smoothedCorrection, 0, 0)
            end
        end

        _lastCF = camera.CFrame
    end)
end

local function stopLoop()
    if _conn then
        _conn:Disconnect()
        _conn = nil
    end
    _lastCF = nil
end

-- ---- Weapon patch (optional secondary method) ---------------
-- Tries to zero out recoil values inside weapon configs.
-- Safe: wrapped in pcall, does not error if structure differs.

local function tryPatchWeaponConfigs(replicatedStorage, options)
    if not options or not options.recoil then return end

    local ok, weaponsFolder = pcall(function()
        return replicatedStorage
            .Shared
            .Configs
            .Weapon
            .Weapons_Player
    end)
    if not ok or not weaponsFolder then return end

    for _, platform in ipairs(weaponsFolder:GetChildren()) do
        if platform.Name:match("^Platform_") then
            for _, weapon in ipairs(platform:GetChildren()) do
                for _, child in ipairs(weapon:GetChildren()) do
                    if child:IsA("ModuleScript")
                    and child.Name:match("^Receiver%.") then
                        pcall(function()
                            local recv = require(child)
                            if recv and recv.Config and recv.Config.Tune then
                                local t = recv.Config.Tune
                                t.Recoil_X            = 0
                                t.Recoil_Z            = 0
                                t.RecoilForce_Tap     = 0
                                t.RecoilForce_Impulse = 0
                                t.Recoil_Range        = Vector2.zero
                                t.Recoil_Camera       = 0
                            end
                        end)
                    end
                end
            end
        end
    end
end

-- ---- Public API ---------------------------------------------

-- Called by main.lua as: Weapons.patchWeapons(ReplicatedStorage, patchOptions)
function Weapons.patchWeapons(replicatedStorage, patchOptions)
    -- Always run camera correction if recoil patch is on
    if patchOptions and patchOptions.recoil then
        if not _enabled then
            _enabled = true
            startLoop()
        end
        -- Also try the config patch as a bonus
        tryPatchWeaponConfigs(replicatedStorage, patchOptions)
    else
        if _enabled then
            _enabled = false
            stopLoop()
        end
    end
end

function Weapons.setStrength(value)
    _strength = math.clamp(value, 0.1, 3.0)
end

function Weapons.setSmoothing(value)
    _smoothing = math.clamp(value, 0.1, 1.0)
end

function Weapons.isEnabled()
    return _enabled
end

return Weapons
