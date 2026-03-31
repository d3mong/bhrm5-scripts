-- ============================================================
--  BHRM5 Enhanced v2.0 by D3MONG
--  Community: SEKUMPUL
-- ============================================================

if typeof(clear) == "function" then clear() end

local GITHUB_BASE = "https://raw.githubusercontent.com/d3mong/bhrm5-scripts/main/bhrm5/modules/"
local BUST = tostring(os.time())

local function loadModule(name)
    local url = GITHUB_BASE .. name .. ".lua?v=" .. BUST
    local ok, res = pcall(game.HttpGet, game, url)
    if not ok or res == "" then
        warn("[D3MONG] Could not download: " .. name)
        return nil
    end
    local fn, err = loadstring(res)
    if not fn then
        warn("[D3MONG] Compile error in " .. name .. ": " .. tostring(err))
        return nil
    end
    local ok2, result = pcall(fn)
    if not ok2 then
        warn("[D3MONG] Runtime error in " .. name .. ": " .. tostring(result))
        return nil
    end
    return result
end

-- Load all modules
local NPCManager = loadModule("npc_manager")
local PlayerManager = loadModule("player_manager")
local Walls = loadModule("walls")
local NoRecoil = loadModule("norecoil")
local Aimbot = loadModule("aimbot")
local GUI = loadModule("gui")

if not NPCManager or not PlayerManager or not Walls or not NoRecoil or not Aimbot or not GUI then
    warn("[D3MONG] One or more modules failed.")
    return
end

-- Start scanning
NPCManager:scan()
PlayerManager:scan()

-- Initialize GUI
GUI:init(NPCManager, PlayerManager, Walls, NoRecoil, Aimbot)
