local TBS = TomoBloodlustSound
local satedIDs = {
    57723, 57724, 80354, 95809, 160455, 264689, 390435,
}
local POLL_INTERVAL = 0.5
local FLICKER_GRACE = 1.5
local playerActive = false
local ticker, rearmTimer
local generation = 0
local suppressUntil = 0
local lastConflict = false
TBS.lastDetection = nil
TBS.lustActive = false

local foreverBuffIDs = {
    [2825] = true, [32182] = true, [80353] = true,
    [264667] = true, [272678] = true, [390386] = true, [90355] = true,
}
local satedSet = {}
for _, spellID in ipairs(satedIDs) do satedSet[spellID] = true end

local function isKnownAura(aura, includeBuffs)
    if not aura then return false end
    -- The Forever beta uses the modern secret-value rules: never index
    -- tables or compare protected IDs before checking in a guarded call.
    local ok, found = pcall(function()
        local id = aura.spellId
        return type(id) == "number" and
            (satedSet[id] or (includeBuffs and foreverBuffIDs[id])) or false
    end)
    return ok and found or false
end

local function hasSated()
    local auras = C_UnitAuras
    if not auras then return false end
    local byID = auras.GetPlayerAuraBySpellID
    if byID then
        for _, spellID in ipairs(satedIDs) do
            if byID(spellID) then return true end
        end
        if TBS.isForever then
            for spellID in pairs(foreverBuffIDs) do
                if byID(spellID) then return true end
            end
        end
        -- Retail's normal path does not need to scan indexed auras.
        if not TBS.isForever then return false end
    end
    local byIndex = auras.GetAuraDataByIndex
    if not byIndex then return false end
    for i = 1, 40 do
        local aura = byIndex("player", i, "HARMFUL")
        if not aura then break end
        if isKnownAura(aura, false) then return true end
    end
    if TBS.isForever then
        for i = 1, 40 do
            local aura = byIndex("player", i, "HELPFUL")
            if not aura then break end
            if isKnownAura(aura, true) then return true end
        end
    end
    return false
end

local function setActiveSilently(value)
    playerActive = value
    TBS.lustActive = value
    if not value then TBS.StopAlert() end
    if TBS.UpdateUI then TBS.UpdateUI() end
end

local function onDetected()
    if playerActive then return end
    playerActive = true
    TBS.lustActive = true
    if GetTime() >= suppressUntil and TBS.ShouldAlert() then
        TBS.lastDetection = date("%H:%M:%S")
        TBS.PlayAlert()
        if TBS.db.showChat then TBS.Print("|cff55ead9" .. TBS.L.CHAT_START .. "|r") end
        TBS.Debug("Sated / Exhaustion appeared")
    else
        TBS.Debug("Alert suppressed: zone/login settle or TomoMod conflict")
    end
    if TBS.UpdateUI then TBS.UpdateUI() end
end

local function onEnded()
    if not playerActive then return end
    playerActive = false
    TBS.lustActive = false
    TBS.StopAlert()
    if TBS.db and TBS.db.showChat and TBS.ShouldAlert() then
        TBS.Print("|cff8b9ab9" .. TBS.L.CHAT_END .. "|r")
    end
    TBS.Debug("Sated / Exhaustion expired")
    if TBS.UpdateUI then TBS.UpdateUI() end
end

local function cancelRearm()
    if rearmTimer then rearmTimer:Cancel(); rearmTimer = nil end
end

local function tick()
    if not TBS.db or not TBS.db.enabled then return end
    local conflict = TBS.TomoModConflict()
    if conflict ~= lastConflict then
        lastConflict = conflict
        if TBS.UpdateUI then TBS.UpdateUI() end
    end
    local sated = hasSated()
    if sated then
        cancelRearm()
        if not playerActive then onDetected() end
    elseif playerActive and not rearmTimer then
        local token = generation
        rearmTimer = C_Timer.NewTimer(FLICKER_GRACE, function()
            rearmTimer = nil
            if generation ~= token then return end
            if not hasSated() then onEnded() end
        end)
    end
end

local function stop()
    generation = generation + 1
    if ticker then ticker:Cancel(); ticker = nil end
    cancelRearm()
    setActiveSilently(false)
end

function TBS.UpdateDetection()
    if not TBS.db then return end
    if not TBS.db.enabled then
        stop()
        return
    end
    if not ticker then
        -- Enabling while already Sated must not replay an old Bloodlust.
        generation = generation + 1
        suppressUntil = GetTime() + 3
        setActiveSilently(hasSated())
        ticker = C_Timer.NewTicker(POLL_INTERVAL, tick)
    end
end

local zone = CreateFrame("Frame")
zone:RegisterEvent("PLAYER_ENTERING_WORLD")
zone:RegisterEvent("UNIT_AURA")
zone:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        generation = generation + 1
        cancelRearm()
        suppressUntil = math.max(suppressUntil, GetTime() + 3)
        local token = generation
        -- The previous aura cache can be stale during a loading screen.
        C_Timer.After(2, function()
            if token ~= generation then return end
            if TBS.db and TBS.db.enabled then
                setActiveSilently(hasSated())
            end
        end)
    elseif event == "UNIT_AURA" and unit == "player" then
        if TBS.db and TBS.db.enabled and ticker then tick() end
    end
end)
