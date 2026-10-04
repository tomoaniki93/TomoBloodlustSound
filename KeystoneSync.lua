-- KeystoneSync.lua -- Optional Mythic+ features backed by the bundled library.
local TBS = TomoBloodlustSound
local L = TBS.L
-- Exclude every Keystone API and callback on Forever, even if another addon
-- exported a global LibTomoKeystoneSync before this standalone loaded.
if TBS.isForever then
    TBS.KeySync = nil
    function TBS.GetPartyKeyRows() return {} end
    function TBS.GetKnownKeyRows() return {} end
    function TBS.RequestKeys() TBS.Print(L.KEY_UNAVAILABLE); return false end
    function TBS.PrintKeys() TBS.Print(L.KEY_UNAVAILABLE) end
    return
end
local KeySync = _G["LibTomoKeystoneSync-1.0"]
TBS.KeySync = KeySync

local function safeMapName(mapID)
    if type(mapID) ~= "number" or mapID <= 0 then return nil end
    if not C_ChallengeMode or not C_ChallengeMode.GetMapUIInfo then return nil end
    local ok, name = pcall(C_ChallengeMode.GetMapUIInfo, mapID)
    if ok and type(name) == "string" and name ~= "" then return name end
    return nil
end

function TBS.FormatKeystone(entry)
    if not entry then return L.KEY_AWAITING end
    local level = tonumber(entry.level) or 0
    if level <= 0 then return L.KEY_NONE end
    local mapID = tonumber(entry.challengeMapID or entry.mythicPlusMapID) or 0
    local name = safeMapName(mapID) or (L.KEY_MAP .. " " .. tostring(mapID))
    return string.format("+%d  %s", level, name)
end

local function unitFullName(unit)
    local name, realm = UnitName(unit)
    if not name then return nil end
    if realm and realm ~= "" then return name .. "-" .. realm end
    return name
end

function TBS.GetPartyKeyRows()
    local rows = {}
    if not KeySync then return rows end
    if KeySync.RefreshOwnKeystone then KeySync.RefreshOwnKeystone() end
    local function add(unit)
        local name = unitFullName(unit)
        if not name then return end
        local entry = KeySync.GetKeystoneInfo(unit)
        rows[#rows + 1] = { name = name, entry = entry, own = unit == "player" }
    end
    add("player")
    if IsInRaid and IsInRaid() then
        local maxMembers = GetNumGroupMembers and GetNumGroupMembers() or 0
        for i = 1, maxMembers do
            local unit = "raid" .. i
            if UnitExists(unit) and not UnitIsUnit(unit, "player") then add(unit) end
        end
    elseif IsInGroup and IsInGroup() then
        local maxMembers = GetNumSubgroupMembers and GetNumSubgroupMembers() or 4
        for i = 1, math.min(maxMembers, 4) do
            local unit = "party" .. i
            if UnitExists(unit) then add(unit) end
        end
    end
    return rows
end

function TBS.GetKnownKeyRows()
    local results = {}
    if not KeySync then return results end
    local data = KeySync.GetAllKeystonesInfo and KeySync.GetAllKeystonesInfo() or {}
    for name, entry in pairs(data) do
        if type(name) == "string" and type(entry) == "table" then
            results[#results + 1] = { name = name, entry = entry, own = false }
        end
    end
    table.sort(results, function(a, b)
        local at, bt = tonumber(a.entry.updated) or 0, tonumber(b.entry.updated) or 0
        if at == bt then return a.name < b.name end
        return at > bt
    end)
    return results
end

function TBS.RequestKeys(where)
    if not KeySync then TBS.Print(L.KEY_UNAVAILABLE); return false end
    local sent
    if where == "guild" then
        sent = KeySync.RequestKeystoneDataFromGuild()
    else
        sent = KeySync.RequestKeystoneDataFromParty()
    end
    TBS.Print(sent and L.KEY_REQUESTED or L.KEY_NOT_CONNECTED)
    if TBS.UpdateUI then TBS.UpdateUI() end
    return not not sent
end

function TBS.PrintKeys(mode)
    local rows = mode == "known" and TBS.GetKnownKeyRows() or TBS.GetPartyKeyRows()
    TBS.Print(mode == "known" and L.KEY_KNOWN_CHAT or L.KEY_GROUP_CHAT)
    if #rows == 0 then TBS.Print(L.KEY_NO_RESULTS); return end
    for _, row in ipairs(rows) do
        TBS.Print("|cff55ead9" .. row.name .. "|r  " .. TBS.FormatKeystone(row.entry))
    end
end

if KeySync and KeySync.RegisterCallback then
    KeySync.RegisterCallback("TomoBloodlustSound", "KeystoneUpdate", function()
        -- The runtime instance is shared with other addons; use the library's
        -- callback rather than a second addon-message handler or transport.
        if TBS.UpdateUI then TBS.UpdateUI() end
    end)
end
