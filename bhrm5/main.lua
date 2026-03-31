-- ============================================================
--  BHRM5 v1.0 by D3MONG
-- ============================================================

if typeof(clear) == "function" then clear() end

local GITHUB_BASE = "https://raw.githubusercontent.com/d3mong/bhrm5-scripts/main/bhrm5/modules/"
local BUST        = tostring(os.time())

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

-- Load only what we have
local NPCManager = loadModule("npc_manager")
local Walls      = loadModule("walls")
local NoRecoil   = loadModule("norecoil")
local GUI        = loadModule("gui")

if not NPCManager or not Walls or not NoRecoil or not GUI then
    warn("[D3MONG] One or more modules failed. Check your GitHub repo files.")
    return
end

-- Start NPC scanning immediately
NPCManager:scan()

-- Hand everything to GUI
GUI:init(NPCManager, Walls, NoRecoil)
