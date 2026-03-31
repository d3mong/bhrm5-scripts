-- BHRM5 v1.0 by D3MONG
-- Black Hawk Rescue Mission 5 — PVE Script

if typeof(clear) == "function" then clear() end

local MAIN_VERSION  = "d3mong-bhrm5-2026"
local GITHUB_BASE   = "https://raw.githubusercontent.com/d3mong/bhrm5-scripts/main/bhrm5/modules/"
local CACHE_BUSTER  = MAIN_VERSION .. "-" .. tostring(os.time())

local function loadModule(moduleName)
    local url = GITHUB_BASE .. moduleName .. ".lua?v=" .. CACHE_BUSTER
    local ok, response = pcall(function() return game:HttpGet(url) end)
    if not ok or type(response) ~= "string" or response == "" then
        warn("[D3MONG] Failed to download: " .. moduleName)
        return nil
    end
    local chunk, err = loadstring(response)
    if not chunk then
        warn("[D3MONG] Failed to compile: " .. moduleName .. " | " .. tostring(err))
        return nil
    end
    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[D3MONG] Failed to run: " .. moduleName .. " | " .. tostring(result))
        return nil
    end
    return result
end

local Services      = loadModule("services")
local Config        = loadModule("config")
local NPCManager    = loadModule("npc_manager")
local TargetSizing  = loadModule("silent")
local Markers       = loadModule("walls")
local Lighting      = loadModule("fullbright")
local Weapons       = loadModule("norecoil")
local GUI           = loadModule("gui")

if not (Services and Config and NPCManager and TargetSizing and Markers and Lighting and Weapons and GUI) then
    error("[D3MONG] One or more modules failed to load. Check your GitHub repo.")
end

Config:load()
Lighting:storeOriginalSettings(Services.Lighting)

local runtimeConnections = {}

local function saveConfig() Config:save() end

local function syncMouseState()
    if Config.guiVisible then
        Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        Services.UserInputService.MouseIconEnabled = true
    end
end

local function forceMouseLock()
    Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    Services.UserInputService.MouseIconEnabled = false
end

local function toggleGUIVisibility()
    local wasVisible = Config.guiVisible
    Config.guiVisible = GUI:toggleVisibility()
    if Config.guiVisible then syncMouseState()
    elseif wasVisible then forceMouseLock() end
    return Config.guiVisible
end

local function disconnectAll()
    for _, c in ipairs(runtimeConnections) do pcall(function() c:Disconnect() end) end
    runtimeConnections = {}
end

local callbacks = {
    onSizingToggle = function(e)
        Config.sizingEnabled = e
        if not e then TargetSizing:cleanup(NPCManager) end
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        saveConfig()
    end,
    onShowTargetBoxToggle = function(e)
        Config.showTargetBox = e
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        saveConfig()
    end,
    onHighlightsToggle = function(e)
        Config.highlightEnabled = e
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        if e then Markers.enable(NPCManager, Config) else Markers.disable() end
        saveConfig()
    end,
    onFullBrightToggle = function(e)
        Config.fullBrightEnabled = e
        if not e then Lighting:restoreOriginal(Services.Lighting) end
        saveConfig()
    end,
    onStabilityToggle = function(e)
        Config.patchOptions.recoil = e
        Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
        saveConfig()
    end,
    onFiremodeOptionsToggle = function(e)
        Config.patchOptions.firemodes = e
        Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
        saveConfig()
    end,
    onVisibleRChange   = function(v) Config:updateVisibleColor(v,nil,nil) saveConfig() end,
    onVisibleGChange   = function(v) Config:updateVisibleColor(nil,v,nil) saveConfig() end,
    onVisibleBChange   = function(v) Config:updateVisibleColor(nil,nil,v) saveConfig() end,
    onHiddenRChange    = function(v) Config:updateHiddenColor(v,nil,nil)  saveConfig() end,
    onHiddenGChange    = function(v) Config:updateHiddenColor(nil,v,nil)  saveConfig() end,
    onHiddenBChange    = function(v) Config:updateHiddenColor(nil,nil,v)  saveConfig() end,
    onNPCDetectionRadiusChange = function(v)
        Config:updateNPCDetectionRadius(v)
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        saveConfig()
    end,
    onVisibilityToggle = function() toggleGUIVisibility() end,
    onUnload = function()
        if Config.isUnloaded then return end
        Config.isUnloaded = true
        disconnectAll()
        Markers.disable()
        TargetSizing:cleanup(NPCManager)
        NPCManager:cleanup()
        Lighting:restoreOriginal(Services.Lighting)
        Config.guiVisible = false
        saveConfig()
        forceMouseLock()
        GUI:destroy()
    end
}

GUI:init(Services, Config, callbacks)
syncMouseState()
NPCManager:scanWorkspace(Services.Workspace, Markers, Config)
NPCManager:setupListener(Services.Workspace, Markers, Config)
if Config.highlightEnabled then Markers.enable(NPCManager, Config) end
if Config.patchOptions.recoil or Config.patchOptions.firemodes then
    Weapons.patchWeapons(Services.ReplicatedStorage, Config.patchOptions)
end

local mA, tA, nA = 0, 0, 0
table.insert(runtimeConnections, Services.RunService.Heartbeat:Connect(function(dt)
    if Config.isUnloaded then return end
    if Config.guiVisible then syncMouseState() end
    Lighting:update(Services.Lighting, Config)
    nA += dt
    if nA >= Config.NPC_REFRESH_INTERVAL then
        NPCManager:refreshTrackedNPCs(Services.Workspace, Markers, TargetSizing, Config)
        nA = 0
    end
    mA += dt
    if mA >= Config.RAYCAST_COOLDOWN then
        pcall(Markers.updateColors, NPCManager,
            Services.Workspace.CurrentCamera, Services.Workspace,
            Services.localPlayer, Config)
        mA = 0
    end
    tA += dt
    if tA >= Config.TARGET_SYNC_INTERVAL then
        TargetSizing:updateAllTargets(NPCManager, Config)
        tA = 0
    end
end))

-- LEFT SHIFT = Toggle GUI
table.insert(runtimeConnections, Services.UserInputService.InputBegan:Connect(function(input, gp)
    if Config.isUnloaded or gp then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        toggleGUIVisibility()
    end
end))
