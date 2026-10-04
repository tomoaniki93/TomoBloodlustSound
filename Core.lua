local ADDON = ...
local TBS = {}
_G.TomoBloodlustSound = TBS
TBS.name = ADDON or "TomoBloodlustSound"
TBS.version = "1.2.0"
TBS.client = _G.TomoBloodlustSoundClient or { isForever = false }
TBS.isForever = TBS.client.isForever
TBS.L = TomoBloodlustSound_L
TBS.colors = {
    bg = { 0.047, 0.052, 0.080, 0.98 },
    panel = { 0.078, 0.084, 0.124, 0.97 },
    raised = { 0.112, 0.118, 0.170, 1 },
    border = { 0.205, 0.215, 0.293, 1 },
    purple = { 0.674, 0.475, 1.000, 1 },
    teal = { 0.333, 0.918, 0.851, 1 },
    white = { 0.947, 0.952, 1.000, 1 },
    dim = { 0.592, 0.616, 0.710, 1 },
    amber = { 1.000, 0.729, 0.369, 1 },
}

local BASE = "Interface\\AddOns\\TomoBloodlustSound\\Assets\\Sounds\\"
local OLD_BASE = "Interface\\AddOns\\TomoMod\\Assets\\Sounds\\"
TBS.soundOrder = { "TALUANI", "GOLDEN_KPOP", "SPINNING_CAT", "CHIPI_CHAPA", "BLWOW_Danger" }
TBS.sounds = {
    TALUANI       = { name = "Taluani BL",   file = "Taluani_BL.ogg",   desc = "ORIGINAL" },
    GOLDEN_KPOP   = { name = "Golden Kpop",  file = "Golden_Lust.ogg",  desc = "ENERGY" },
    SPINNING_CAT  = { name = "Spinning Cat", file = "Spining_Cat.ogg", desc = "CHAOS" },
    CHIPI_CHAPA   = { name = "Chipi Chapa",  file = "Chipi.ogg",        desc = "FUN" },
    BLWOW_Danger  = { name = "BLWOW Danger", file = "BLWOW_Danger.ogg", desc = "ALERT" },
}
TBS.channelOrder = { "Master", "SFX", "Music", "Ambience", "Dialog" }
local channelCVars = {
    Master = "Sound_MasterVolume", SFX = "Sound_SFXVolume", Music = "Sound_MusicVolume",
    Ambience = "Sound_AmbienceVolume", Dialog = "Sound_DialogVolume",
}
local defaults = {
    enabled = true, sound = "TALUANI", channel = "Master", showChat = false, debug = false,
    minimap = true, minimapAngle = 225, allowDuplicates = false,
}
TBS.defaults = defaults

local function chat(msg)
    print("|cffac79ffTomo|r|cff55ead9Bloodlust|r|cffffffffSound|r  " .. tostring(msg))
end
TBS.Print = chat
function TBS.Debug(message)
    if TBS.db and TBS.db.debug then chat("|cff8b9ab9[debug]|r " .. tostring(message)) end
end
function TBS.TomoModConflict()
    local old = _G.TomoModDB
    return not (TBS.db and TBS.db.allowDuplicates)
        and type(old) == "table" and type(old.lustSound) == "table"
        and old.lustSound.enabled == true and _G.TomoMod_LustSound ~= nil
end
function TBS.ShouldAlert()
    return TBS.db and TBS.db.enabled and not TBS.TomoModConflict()
end
function TBS.GetChannelVolume(channel)
    local fn = (C_CVar and C_CVar.GetCVar) or GetCVar
    local value = fn and tonumber(fn(channelCVars[channel] or channelCVars.Master)) or 1
    return math.floor(math.max(0, math.min(1, value or 1)) * 100 + .5)
end
function TBS.SetChannelVolume(channel, value)
    local fn = (C_CVar and C_CVar.SetCVar) or SetCVar
    if fn then
        local percent = math.max(0, math.min(100, tonumber(value) or 100))
        fn(channelCVars[channel] or channelCVars.Master, string.format("%.2f", percent / 100))
    end
end

local previewHandle, alertHandle
local function safeStop(handle)
    if handle then StopSound(handle, 500) end
end
local function play(selected)
    local entry = TBS.sounds[selected] or TBS.sounds.TALUANI
    local channel = (TBS.db and TBS.db.channel) or "Master"
    -- The installed sound pack owns these files. The legacy path allows an
    -- existing TomoMod installation to work before the pack is copied.
    local success, handle = PlaySoundFile(BASE .. entry.file, channel)
    if not success and C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("TomoMod") then
        success, handle = PlaySoundFile(OLD_BASE .. entry.file, channel)
    end
    if not success then
        TBS.Debug("PlaySoundFile failed: " .. entry.file .. " (" .. channel .. ")")
        return nil
    end
    return handle
end
function TBS.StopPreview()
    safeStop(previewHandle)
    previewHandle = nil
end
function TBS.PlayPreview(selected)
    TBS.StopPreview()
    previewHandle = play(selected or (TBS.db and TBS.db.sound))
    if not previewHandle then chat(TBS.L.SOUND_MISSING) end
    return previewHandle ~= nil
end
function TBS.PlayAlert()
    if not TBS.ShouldAlert() then return end
    safeStop(alertHandle)
    alertHandle = play(TBS.db.sound)
    if not alertHandle then TBS.Debug("Bloodlust detected but audio unavailable") end
end
function TBS.StopAlert()
    safeStop(alertHandle)
    alertHandle = nil
end

function TBS.InitializeDB()
    local db = _G.TomoBloodlustSoundDB
    if type(db) ~= "table" then db = {}; _G.TomoBloodlustSoundDB = db end
    -- Read legacy values without modifying TomoMod's database. Only migrate
    -- on the first run; users can then configure both addons independently.
    if not db._initialized then
        local old = _G.TomoModDB and _G.TomoModDB.lustSound
        if type(old) == "table" then
            for _, key in ipairs({ "enabled", "sound", "channel", "showChat", "debug" }) do
                if old[key] ~= nil then db[key] = old[key] end
            end
            db._imported = true
        end
        db._initialized = true
    end
    for key, value in pairs(defaults) do
        if db[key] == nil then db[key] = value end
    end
    if not TBS.sounds[db.sound] then db.sound = defaults.sound end
    if not channelCVars[db.channel] then db.channel = defaults.channel end
    TBS.db = db
end
function TBS.Refresh()
    if TBS.UpdateDetection then TBS.UpdateDetection() end
    if TBS.UpdateUI then TBS.UpdateUI() end
    if TBS.UpdateMinimap then TBS.UpdateMinimap() end
end
function TBS.Reset()
    local db = TBS.db
    if not db then return end
    for key, value in pairs(defaults) do db[key] = value end
    TBS.StopPreview()
    TBS.Refresh()
end

function TBS.ShowHelp()
    local help = {
        { "/tbs", TBS.L.CMD_CONFIG },
        { "/tbs settings", TBS.L.CMD_CONFIG },
        { "/tbs commands", TBS.L.COMMANDS },
        { "/tbs preview", TBS.L.CMD_PREVIEW },
        { "/tbs stop", TBS.L.CMD_STOP },
        { "/tbs on / off", TBS.L.CMD_TOGGLE },
        { "/tbs status", TBS.L.CMD_STATUS },
        { "/tbs minimap show / hide / reset", TBS.L.CMD_MINIMAP },
    }
    if not TBS.isForever then
        help[#help + 1] = { "/tbs key", TBS.L.CMD_KEY }
        help[#help + 1] = { "/tbs guild", TBS.L.CMD_GUILD }
        help[#help + 1] = { "/tbs known", TBS.L.CMD_KNOWN }
    end
    for _, item in ipairs(help) do chat("|cff55ead9" .. item[1] .. "|r - " .. item[2]) end
end

function TBS.Command(raw)
    if not TBS.db then TBS.InitializeDB() end
    local cmd, arg = (raw or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    cmd = cmd or ""
    arg = arg or ""
    if cmd == "preview" or cmd == "test" then TBS.PlayPreview()
    elseif cmd == "stop" then TBS.StopPreview(); TBS.StopAlert()
    elseif cmd == "on" then TBS.db.enabled = true; TBS.Refresh(); chat(TBS.L.SOUND_ON)
    elseif cmd == "off" then TBS.db.enabled = false; TBS.Refresh(); chat(TBS.L.SOUND_OFF)
    elseif cmd == "status" then
        chat(TBS.TomoModConflict() and TBS.L.STATUS_DUP or (TBS.ShouldAlert() and TBS.L.STATUS_OK or TBS.L.STATUS_OFF))
    elseif cmd == "minimap" or cmd == "map" then
        if arg == "reset" then
            TBS.db.minimapAngle = TBS.defaults.minimapAngle
            TBS.db.minimap = true
        elseif arg == "show" or arg == "on" then TBS.db.minimap = true
        elseif arg == "hide" or arg == "off" then TBS.db.minimap = false
        else TBS.db.minimap = not TBS.db.minimap end
        TBS.Refresh()
        chat(TBS.db.minimap and TBS.L.MINIMAP_RESTORE or TBS.L.MINIMAP_HIDDEN)
    elseif cmd == "help" or cmd == "?" then TBS.ShowHelp()
    elseif cmd == "commands" or cmd == "commandes" then TBS.OpenUI("commands")
    elseif cmd == "settings" or cmd == "config" or cmd == "options" then TBS.OpenUI("settings")
    elseif cmd == "sounds" or cmd == "library" then TBS.OpenUI("library")
    elseif cmd == "key" or cmd == "keys" or cmd == "guild" or cmd == "known" then
        if TBS.isForever then chat(TBS.L.KEY_UNAVAILABLE); return end
        if cmd == "guild" then TBS.RequestKeys("guild")
        elseif cmd == "known" then TBS.PrintKeys("known")
        elseif TBS.RequestKeys("party") then
            C_Timer.After(3, function() TBS.PrintKeys("party") end)
        end
    elseif cmd == "" then TBS.ToggleUI()
    else TBS.ShowHelp() end
end

SLASH_TOMOBLOODLUSTSOUND1 = "/tbs"
SLASH_TOMOBLOODLUSTSOUND2 = "/tbls"
SLASH_TOMOBLOODLUSTSOUND3 = "/tomobloodlust"
SlashCmdList.TOMOBLOODLUSTSOUND = TBS.Command

local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    TBS.InitializeDB()
    TBS.Refresh()
    if TBS.db._imported then
        TBS.Debug(TBS.L.IMPORTED)
        TBS.db._imported = nil
    end
end)
