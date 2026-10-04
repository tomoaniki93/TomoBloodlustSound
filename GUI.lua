local TBS = TomoBloodlustSound
local L, C = TBS.L, TBS.colors
local UI, pages, navButtons, refreshers = nil, {}, {}, {}
local currentPage = "dashboard"

local function rgba(c)
    return c[1], c[2], c[3], c[4] or 1
end
local function paint(frame, bg, border)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(rgba(bg or C.panel))
    frame:SetBackdropBorderColor(rgba(border or C.border))
end
local function panel(parent, x, y, w, h, bg, border)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    f:SetSize(w, h)
    paint(f, bg, border)
    return f
end
local function font(parent, text, size, color, x, y, width, height, bold)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont((GameFontNormal and GameFontNormal:GetFont()) or "Fonts\\FRIZQT__.TTF",
        size or 12, bold and "OUTLINE" or "")
    fs:SetTextColor(rgba(color or C.white))
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    if width then fs:SetWidth(width) end
    if height then fs:SetHeight(height) end
    fs:SetText(text or "")
    return fs
end
local function bar(parent, x, y, w, h, color)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture("Interface\\Buttons\\WHITE8X8")
    t:SetVertexColor(rgba(color))
    t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    t:SetSize(w, h)
    return t
end
local function button(parent, text, x, y, w, h, callback, accent)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetSize(w, h)
    b._accent = accent or C.raised
    b._normal = accent or C.raised
    paint(b, b._normal, accent and accent or C.border)
    local t = font(b, text, 11, accent and C.bg or C.white, 0, 0, w, h, true)
    t:ClearAllPoints(); t:SetPoint("CENTER")
    t:SetWidth(w - 8); t:SetJustifyH("CENTER"); t:SetJustifyV("MIDDLE")
    b.text = t
    b:SetScript("OnEnter", function(self) self:SetBackdropColor(rgba(C.purple)) end)
    b:SetScript("OnLeave", function(self) self:SetBackdropColor(rgba(self._normal)) end)
    b:SetScript("OnClick", callback)
    return b
end
local function checkbox(parent, text, x, y, width, field, onChanged)
    local b = CreateFrame("Button", nil, parent)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetSize(width, 29)
    local square = panel(b, 0, -3, 20, 20, C.raised, C.border)
    local dot = square:CreateTexture(nil, "ARTWORK")
    dot:SetTexture("Interface\\Buttons\\WHITE8X8")
    dot:SetVertexColor(rgba(C.teal))
    dot:SetPoint("CENTER"); dot:SetSize(12, 12)
    local caption = font(b, text, 11, C.white, 31, -6, width - 32, 27)
    b.square, b.dot, b.caption = square, dot, caption
    b.Refresh = function()
        local checked = TBS.db and TBS.db[field]
        dot:SetShown(not not checked)
        square:SetBackdropBorderColor(rgba(checked and C.teal or C.border))
    end
    b:SetScript("OnClick", function()
        if not TBS.db then return end
        TBS.db[field] = not TBS.db[field]
        if onChanged then onChanged(TBS.db[field]) end
        TBS.Refresh()
    end)
    refreshers[#refreshers + 1] = b.Refresh
    return b
end
local function addPage(name)
    local p = CreateFrame("Frame", nil, UI)
    p:SetPoint("TOPLEFT", UI, "TOPLEFT", 229, -105)
    p:SetSize(595, 430)
    p:Hide()
    pages[name] = p
    return p
end
local function setPage(name)
    currentPage = name
    for id, p in pairs(pages) do p:SetShown(id == name) end
    for id, b in pairs(navButtons) do
        local active = id == name
        b:SetBackdropColor(rgba(active and C.raised or C.bg))
        b:SetBackdropBorderColor(rgba(active and C.purple or C.bg))
        b._accentBar:SetVertexColor(rgba(active and C.teal or C.bg))
        b.label:SetTextColor(rgba(active and C.white or C.dim))
    end
    if TBS.UpdateUI then TBS.UpdateUI() end
end

local function buildDashboard(p)
    font(p, L.DASHBOARD, 22, C.white, 3, -3, 385, 34, true)
    font(p, L.SUBTITLE, 12, C.dim, 3, -39, 470, 24)
    local status = panel(p, 0, -78, 588, 112, C.panel)
    bar(status, 0, 0, 4, 112, C.teal)
    font(status, L.STATUS, 10, C.dim, 17, -14, 200, 20, true)
    status.value = font(status, L.READY, 22, C.teal, 17, -38, 425, 29, true)
    status.description = font(status, L.READY_DESC, 11, C.dim, 17, -78, 555, 31)
    local sound = panel(p, 0, -205, 588, 135, C.panel)
    font(sound, L.SELECTED, 10, C.dim, 17, -13, 350, 20, true)
    sound.selected = font(sound, "Taluani BL", 25, C.white, 17, -43, 280, 36, true)
    button(sound, L.PREVIEW, 17, -92, 129, 30, function() TBS.PlayPreview() end, C.teal)
    button(sound, L.STOP, 155, -92, 91, 30, function() TBS.StopPreview() end)
    button(sound, L.CHANGE, 426, -92, 145, 30, function() setPage("library") end)
    local event = panel(p, 0, -355, 588, 66, C.panel)
    font(event, L.LAST_EVENT, 10, C.dim, 17, -13, 350, 20, true)
    event.value = font(event, L.NEVER, 12, C.white, 17, -36, 545, 24)
    p.Update = function()
        if not TBS.db then return end
        local conflict = TBS.TomoModConflict()
        local enabled = TBS.db.enabled
        status.value:SetText(not enabled and L.DISABLED or (conflict and L.MUTED or L.READY))
        status.value:SetTextColor(rgba(not enabled and C.dim or (conflict and C.amber or C.teal)))
        status.description:SetText(not enabled and L.DISABLED_DESC or (conflict and L.MUTED_DESC or L.READY_DESC))
        sound.selected:SetText(TBS.sounds[TBS.db.sound].name)
        event.value:SetText(TBS.lastDetection or L.NEVER)
    end
end

local function buildLibrary(p)
    font(p, L.LIBRARY_TITLE, 22, C.white, 3, -3, 470, 35, true)
    font(p, L.LIBRARY_DESC, 11, C.dim, 3, -44, 560, 36)
    local rows = {}
    for i, id in ipairs(TBS.soundOrder) do
        local entry = TBS.sounds[id]
        local r = panel(p, 0, -79 - (i - 1) * 69, 588, 62, C.panel)
        bar(r, 0, 0, 3, 62, C.purple)
        font(r, string.format("%02d", i), 12, C.purple, 16, -21, 25, 25, true)
        font(r, entry.name, 14, C.white, 51, -10, 250, 25, true)
        font(r, entry.desc, 9, C.dim, 51, -36, 250, 19)
        button(r, "|cff55ead9>|r", 390, -14, 45, 34, function() TBS.PlayPreview(id) end)
        local choose = button(r, L.SELECT_SOUND, 446, -14, 127, 34, function()
            TBS.db.sound = id
            TBS.PlayPreview(id)
            TBS.UpdateUI()
        end)
        rows[id] = { frame = r, choose = choose }
    end
    p.Update = function()
        if not TBS.db then return end
        for id, item in pairs(rows) do
            local selected = id == TBS.db.sound
            item.frame:SetBackdropBorderColor(rgba(selected and C.purple or C.border))
            item.choose._normal = selected and C.purple or C.raised
            item.choose:SetBackdropColor(rgba(item.choose._normal))
            item.choose.text:SetText(selected and L.SELECTED_TAG or L.SELECT_SOUND)
            item.choose.text:SetTextColor(rgba(selected and C.bg or C.white))
        end
    end
end

local function buildSettings(p)
    font(p, L.SETTINGS, 22, C.white, 3, -3, 490, 35, true)
    local audio = panel(p, 0, -49, 588, 187, C.panel)
    bar(audio, 0, 0, 3, 187, C.purple)
    font(audio, L.AUDIO, 11, C.purple, 15, -13, 420, 20, true)
    font(audio, L.CHANNEL, 11, C.white, 15, -40, 430, 24)
    local channelButtons = {}
    for i, channel in ipairs(TBS.channelOrder) do
        local b = button(audio, channel, 15 + (i - 1) * 112, -64, 103, 28, function()
            TBS.db.channel = channel
            TBS.UpdateUI()
        end)
        channelButtons[channel] = b
    end
    local volumeText = font(audio, L.VOLUME, 11, C.white, 15, -107, 390, 21)
    local volumePercent = font(audio, "100%", 11, C.teal, 510, -107, 50, 23, true)
    volumePercent:SetJustifyH("RIGHT")
    local slider = CreateFrame("Slider", nil, audio, "BackdropTemplate")
    slider:SetPoint("TOPLEFT", audio, "TOPLEFT", 16, -139)
    slider:SetSize(547, 9)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(0, 100)
    slider:SetValueStep(1)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    paint(slider, C.raised, C.border)
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local thumb = slider:GetThumbTexture()
    if thumb then thumb:SetSize(16, 20) end
    local filling = bar(slider, 1, -1, 1, 7, C.teal)
    local updating = false
    slider:SetScript("OnValueChanged", function(self, value)
        local v = math.floor(value + .5)
        volumePercent:SetText(v .. "%")
        filling:SetWidth(math.max(1, (self:GetWidth() - 3) * v / 100))
        if not updating and TBS.db then TBS.SetChannelVolume(TBS.db.channel, v) end
    end)
    font(audio, L.VOLUME_NOTE, 10, C.dim, 15, -162, 554, 39)
    local general = panel(p, 0, -246, 588, 136, C.panel)
    bar(general, 0, 0, 3, 136, C.teal)
    font(general, L.GENERAL, 11, C.teal, 15, -11, 460, 20, true)
    checkbox(general, L.ENABLE, 17, -39, 550, "enabled")
    checkbox(general, L.CHAT, 17, -70, 265, "showChat")
    checkbox(general, L.DEBUG, 313, -70, 248, "debug")
    checkbox(general, L.MINIMAP, 17, -101, 550, "minimap")
    local advanced = panel(p, 0, -390, 588, 57, C.panel)
    font(advanced, L.DUPLICATES_WARN, 9, C.amber, 18, -35, 551, 20)
    checkbox(advanced, L.DUPLICATES, 17, -5, 550, "allowDuplicates")
    p.Update = function()
        if not TBS.db then return end
        for channel, b in pairs(channelButtons) do
            local selected = TBS.db.channel == channel
            b._normal = selected and C.purple or C.raised
            b:SetBackdropColor(rgba(b._normal))
            b:SetBackdropBorderColor(rgba(selected and C.purple or C.border))
            b.text:SetTextColor(rgba(selected and C.bg or C.white))
        end
        local v = TBS.GetChannelVolume(TBS.db.channel)
        updating = true
        slider:SetValue(v)
        volumePercent:SetText(v .. "%")
        filling:SetWidth(math.max(1, (slider:GetWidth() - 3) * v / 100))
        updating = false
    end
end

local function buildMythic(p)
    font(p, L.KEY_TITLE, 22, C.white, 3, -3, 550, 35, true)
    font(p, L.KEY_DESC, 11, C.dim, 3, -44, 565, 38)

    local heading = panel(p, 0, -87, 588, 80, C.panel)
    bar(heading, 0, 0, 3, 80, C.teal)
    heading.title = font(heading, L.KEY_GROUP, 11, C.teal, 16, -13, 530, 22, true)
    heading.summary = font(heading, L.KEY_AWAITING, 13, C.white, 16, -41, 555, 29)

    local actions = panel(p, 0, -178, 588, 53, C.panel)
    button(actions, L.KEY_PARTY_REQUEST, 11, -10, 139, 32, function() TBS.RequestKeys("party") end, C.teal)
    button(actions, L.KEY_GUILD_REQUEST, 157, -10, 139, 32, function() TBS.RequestKeys("guild") end)
    button(actions, L.KEY_SHOW_CHAT, 303, -10, 132, 32, function()
        TBS.PrintKeys(p.showKnown and "known" or "party")
    end)
    local swap = button(actions, L.KEY_VIEW_KNOWN, 442, -10, 134, 32, function()
        p.showKnown = not p.showKnown
        p.Update()
    end)

    local list = panel(p, 0, -242, 588, 174, C.panel)
    local rows = {}
    for i = 1, 6 do
        local y = -9 - (i - 1) * 27
        local item = {
            name = font(list, "", 11, C.white, 13, y, 230, 23),
            value = font(list, "", 11, C.teal, 245, y, 329, 23),
        }
        item.value:SetJustifyH("RIGHT")
        rows[#rows + 1] = item
    end
    local note = font(p, L.KEY_NOTE, 10, C.dim, 7, -421, 572, 34)
    note:SetJustifyV("TOP")
    p.showKnown = false
    p.Update = function()
        local viewKnown = p.showKnown
        local data = viewKnown and TBS.GetKnownKeyRows() or TBS.GetPartyKeyRows()
        heading.title:SetText(viewKnown and L.KEY_KNOWN or L.KEY_GROUP)
        heading.summary:SetText(#data > 0 and string.format("%d %s", #data, viewKnown and L.KEY_VIEW_KNOWN or L.KEY_GROUP) or L.KEY_EMPTY)
        swap.text:SetText(viewKnown and L.KEY_VIEW_GROUP or L.KEY_VIEW_KNOWN)
        for i, row in ipairs(rows) do
            local entry = data[i]
            row.name:SetText(entry and entry.name or "")
            row.value:SetText(entry and TBS.FormatKeystone(entry.entry) or "")
        end
    end
end

local function buildCommands(p)
    font(p, L.COMMANDS_TITLE, 22, C.white, 3, -3, 520, 35, true)
    font(p, L.COMMANDS_DESC, 11, C.dim, 3, -42, 560, 30)
    local commands = {
        { "/tbs settings", L.CMD_CONFIG, function() setPage("settings") end },
        { "/tbs preview", L.CMD_PREVIEW, function() TBS.PlayPreview() end },
        { "/tbs stop", L.CMD_STOP, function() TBS.Command("stop") end },
        { "/tbs on / off", L.CMD_TOGGLE, function() TBS.Command(TBS.db.enabled and "off" or "on") end },
        { "/tbs status", L.CMD_STATUS, function() TBS.Command("status") end },
        { "/tbs minimap", L.CMD_MINIMAP, function() TBS.Command("minimap") end },
        { "/tbs help", L.CMD_HELP, function() TBS.Command("help") end },
    }
    if not TBS.isForever then
        commands[#commands + 1] = { "/tbs key", L.CMD_KEY, function() TBS.Command("key") end }
        commands[#commands + 1] = { "/tbs guild", L.CMD_GUILD, function() TBS.Command("guild") end }
        commands[#commands + 1] = { "/tbs known", L.CMD_KNOWN, function() TBS.Command("known") end }
    end
    local rowHeight = TBS.isForever and 45 or 34
    for i, item in ipairs(commands) do
        local y = -77 - (i - 1) * rowHeight
        local card = panel(p, 0, y, 588, rowHeight - 3, C.panel)
        font(card, item[1], 11, C.teal, 12, -10, 185, 20, true)
        font(card, item[2], 10, C.white, 199, -11, 280, 23)
        button(card, ">", 539, -4, 38, rowHeight - 11, item[3], C.purple)
    end
    if TBS.isForever then
        font(p, L.FOREVER_NOTE, 10, C.amber, 5, -393, 576, 34)
    end
end

local function buildAbout(p)
    font(p, L.ABOUT, 22, C.white, 3, -3, 570, 36, true)
    local info = panel(p, 0, -58, 588, 260, C.panel)
    bar(info, 0, 0, 3, 260, C.purple)
    local logo = info:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface\\AddOns\\TomoBloodlustSound\\Assets\\Textures\\Icon.tga")
    logo:SetPoint("TOPLEFT", info, "TOPLEFT", 17, -17)
    logo:SetSize(72, 72)
    font(info, "TomoBloodlustSound", 18, C.white, 105, -25, 445, 28, true)
    font(info, "v" .. TBS.version .. "  •  TomoAniki", 11, C.teal, 105, -55, 445, 24)
    font(info, L.ABOUT_DESC, 12, C.white, 17, -108, 546, 50)
    font(info, L.ABOUT_DETECTION, 11, C.dim, 17, -156, 546, 48)
    font(info, L.ABOUT_SOUNDS, 11, C.dim, 17, -214, 546, 45)
    local details = panel(p, 0, -333, 588, 114, C.panel)
    font(details, L.ABOUT_AUDIO, 11, C.white, 17, -13, 546, 49)
    font(details, TBS.isForever and
        "Commandes : /tbs, /tbs settings, /tbs commands, /tbs preview, /tbs stop, /tbs on/off, /tbs minimap, /tbs help"
        or L.ABOUT_COMMANDS, 10, C.teal, 17, -71, 546, 47)
end

local function buildUI()
    if UI then return end
    UI = CreateFrame("Frame", "TomoBloodlustSoundStudio", UIParent, "BackdropTemplate")
    UI:SetSize(850, 590)
    UI:SetPoint("CENTER")
    UI:SetFrameStrata("DIALOG")
    UI:SetClampedToScreen(true)
    UI:SetMovable(true)
    UI:EnableMouse(true)
    UI:RegisterForDrag("LeftButton")
    UI:SetScript("OnDragStart", UI.StartMoving)
    UI:SetScript("OnDragStop", UI.StopMovingOrSizing)
    paint(UI, C.bg, C.border)
    UI:Hide()
    bar(UI, 0, 0, 850, 4, C.purple)
    bar(UI, 18, -19, 4, 48, C.teal)
    font(UI, L.TITLE, 20, C.white, 35, -21, 520, 30, true)
    font(UI, L.STUDIO .. "  /  v" .. TBS.version, 10, C.dim, 36, -53, 520, 22)
    button(UI, "X", 805, -20, 29, 28, function() UI:Hide() end)
    bar(UI, 18, -85, 812, 1, C.border)
    local sidebar = panel(UI, 15, -105, 195, 447, C.bg, C.bg)
    local items = {
        { "dashboard", L.DASHBOARD }, { "library", L.LIBRARY },
        { "settings", L.SETTINGS }, { "commands", L.COMMANDS },
    }
    if not TBS.isForever then items[#items + 1] = { "mythic", L.MYTHIC } end
    items[#items + 1] = { "about", L.ABOUT }
    local itemSpacing = #items == 6 and 50 or 56
    for i, entry in ipairs(items) do
        local id = entry[1]
        local b = CreateFrame("Button", nil, sidebar, "BackdropTemplate")
        b:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 0, -8 - (i - 1) * itemSpacing)
        b:SetSize(188, 44)
        paint(b, C.bg, C.bg)
        b._accentBar = bar(b, 0, 0, 3, 44, C.bg)
        font(b, string.format("%02d", i), 10, C.teal, 13, -14, 24, 20, true)
        b.label = font(b, entry[2], 12, C.dim, 41, -12, 140, 25, true)
        b:SetScript("OnClick", function() setPage(id) end)
        navButtons[id] = b
    end
    bar(UI, 215, -106, 1, 445, C.border)
    buildDashboard(addPage("dashboard"))
    buildLibrary(addPage("library"))
    buildSettings(addPage("settings"))
    buildCommands(addPage("commands"))
    if not TBS.isForever then buildMythic(addPage("mythic")) end
    buildAbout(addPage("about"))
    bar(UI, 17, -562, 816, 1, C.border)
    font(UI, L.SOURCE, 10, C.dim, 21, -571, 565, 17)
    font(UI, "/tbs", 10, C.teal, 779, -571, 55, 16, true):SetJustifyH("RIGHT")
    setPage(currentPage)
end

function TBS.OpenUI(page)
    if not TBS.db then TBS.InitializeDB() end
    buildUI()
    if page and pages[page] then setPage(page) end
    UI:Show()
    TBS.UpdateUI()
end
function TBS.ToggleUI()
    if not TBS.db then TBS.InitializeDB() end
    buildUI()
    if UI:IsShown() then UI:Hide() else TBS.OpenUI() end
end
function TBS.UpdateUI()
    if not TBS.db then return end
    for _, callback in ipairs(refreshers) do callback() end
    for _, p in pairs(pages) do if p.Update then p.Update() end end
end

local minimapButton, quickMenu
local function positionMinimap()
    if not minimapButton or not TBS.db or not Minimap then return end
    local a = math.rad(TBS.db.minimapAngle or 225)
    minimapButton:ClearAllPoints()
    -- Standard minimap orbit; works with square minimaps and button bags.
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * 80, math.sin(a) * 80)
end

local function closeMenu()
    if quickMenu then quickMenu:Hide() end
end

local function buildQuickMenu()
    if quickMenu then return quickMenu end
    local m = CreateFrame("Frame", "TomoBloodlustSoundQuickMenu", UIParent, "BackdropTemplate")
    m:SetSize(247, TBS.isForever and 290 or 326)
    m:SetFrameStrata("DIALOG")
    m:SetFrameLevel(300)
    m:SetClampedToScreen(true)
    paint(m, C.bg, C.purple)
    bar(m, 0, 0, 247, 3, C.teal)
    font(m, L.MINIMAP_MENU, 14, C.white, 13, -13, 206, 25, true)
    local items = {
        { L.MINIMAP_CONFIG, function() TBS.OpenUI("settings") end },
        { L.MINIMAP_COMMANDS, function() TBS.OpenUI("commands") end },
        { L.MINIMAP_PREVIEW, function() TBS.PlayPreview() end },
        { L.MINIMAP_STOP, function() TBS.Command("stop") end },
        { TBS.db.enabled and L.MINIMAP_OFF or L.MINIMAP_ON, function()
            TBS.Command(TBS.db.enabled and "off" or "on")
        end },
        { L.MINIMAP_HELP, function() TBS.ShowHelp() end },
    }
    if not TBS.isForever then
        items[#items + 1] = { L.MYTHIC, function() TBS.OpenUI("mythic") end }
    end
    for i, item in ipairs(items) do
        local b = button(m, item[1], 12, -43 - (i - 1) * 36, 223, 30, function()
            closeMenu()
            item[2]()
        end)
        b._actionName = item[1]
        if i == 5 then m.alertLabel = b.text end
    end
    m:Hide()
    quickMenu = m
    return m
end

function TBS.ToggleMinimapMenu()
    if not TBS.db then return end
    local menu = buildQuickMenu()
    if menu:IsShown() then menu:Hide(); return end
    menu.alertLabel:SetText(TBS.db.enabled and L.MINIMAP_OFF or L.MINIMAP_ON)
    menu:ClearAllPoints()
    menu:SetPoint("TOPRIGHT", minimapButton, "BOTTOMLEFT", -4, -4)
    menu:Show()
end

function TBS.UpdateMinimap()
    if not Minimap or not TBS.db then return end
    if not minimapButton then
        local b = CreateFrame("Button", "TomoBloodlustSoundMinimapButton", Minimap, "BackdropTemplate")
        b:SetSize(30, 30)
        b:SetFrameStrata("MEDIUM")
        paint(b, C.bg, C.purple)
        local tex = b:CreateTexture(nil, "ARTWORK")
        tex:SetTexture("Interface\\AddOns\\TomoBloodlustSound\\Assets\\Textures\\Icon.tga")
        tex:SetPoint("CENTER")
        tex:SetSize(27, 27)
        b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        b:SetScript("OnClick", function(_, which)
            if which == "RightButton" then TBS.ToggleMinimapMenu()
            else closeMenu(); TBS.ToggleUI() end
        end)
        b:SetScript("OnEnter", function(self)
            if not GameTooltip then return end
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine("TomoBloodlustSound", .674, .475, 1)
            GameTooltip:AddLine(L.MINIMAP_TOOLTIP, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function()
            if GameTooltip then GameTooltip:Hide() end
        end)
        b:RegisterForDrag("LeftButton")
        b:SetScript("OnDragStart", function(self)
            closeMenu()
            self:SetScript("OnUpdate", function()
                local cursorX, cursorY = GetCursorPosition()
                local scale = Minimap:GetEffectiveScale()
                local mapX, mapY = Minimap:GetCenter()
                if not mapX or not mapY or not scale or scale == 0 then return end
                local dx, dy = cursorX / scale - mapX, cursorY / scale - mapY
                local atan2 = math.atan2
                local angle
                if atan2 then angle = atan2(dy, dx)
                elseif dx == 0 then angle = dy > 0 and math.pi / 2 or -math.pi / 2
                else angle = math.atan(dy / dx) + (dx < 0 and math.pi or 0) end
                TBS.db.minimapAngle = math.deg(angle) % 360
                positionMinimap()
            end)
        end)
        b:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
        minimapButton = b
    end
    minimapButton:SetShown(TBS.db.minimap)
    if not TBS.db.minimap then closeMenu() end
    positionMinimap()
end

-- Provide an entry point in Blizzard's AddOns settings too.
local registration = CreateFrame("Frame")
registration:RegisterEvent("PLAYER_LOGIN")
registration:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    local pane = CreateFrame("Frame", "TomoBloodlustSoundOptionsPanel")
    pane.name = "TomoBloodlustSound"
    pane:SetSize(640, 420)
    font(pane, "TomoBloodlustSound", 22, C.white, 16, -18, 440, 38, true)
    font(pane, L.ABOUT_DESC, 13, C.dim, 16, -61, 510, 47)
    button(pane, L.OPEN, 16, -116, 235, 34, function() TBS.ToggleUI() end, C.teal)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, pane, "TomoBloodlustSound")
        if ok and cat then
            if pcall(Settings.RegisterAddOnCategory, cat) then TBS.settingsCategory = cat end
        elseif InterfaceOptions_AddCategory then
            pcall(InterfaceOptions_AddCategory, pane)
        end
    elseif InterfaceOptions_AddCategory then
        pcall(InterfaceOptions_AddCategory, pane)
    end
end)
