local target = "ZygorGuidesViewer"
local skinName = "ZygorRetailSkin"
local installed = assert(arg[1], "Zygor installation path required")
local locale, combat = "deDE", false
local expressway = "Interface\\AddOns\\AzerothBuddy\\Media\\Expressway.ttf"
local clientFont = "Fonts\\FRIZQT__.TTF"
local availableFont = expressway
local eventFrame
local hooks = 0
local function noop() end

-- Only the visual API is exposed. An unexpected interaction or frame mutation fails the test.
local function visual(parent)
    local region = {writes=0, path="OpenSans.ttf", size=12, flags="OUTLINE", parent=parent}
    function region:GetFont() return self.path, self.size, self.flags end
    function region:SetFont(path, size, flags)
        assert(not combat or not self.parent, "font changed in combat")
        self.path, self.size, self.flags = path, size, flags
        self.writes = self.writes + 1
    end
    for _, method in ipairs({"SetTextColor", "SetVertexColor", "SetColorTexture", "SetTexCoord",
        "SetAlpha", "SetAllPoints", "SetPoint", "SetTexture"}) do
        region[method] = function(self, ...)
            assert(not combat and not (self.parent and (self.parent.protected or self.parent.forbidden)),
                "changed an inaccessible region")
            self.writes = self.writes + 1
            self[method .. "Args"] = {...}
        end
    end
    return region
end

local function frame()
    local widget = {textures={}, text=visual()}
    function widget:IsForbidden() return self.forbidden end
    function widget:IsProtected() return self.protected end
    function widget:IsShown() return not self.hidden end
    function widget:GetFontString() return self.text end
    function widget:CreateTexture()
        local texture = visual(self)
        self.textures[#self.textures + 1] = texture
        return texture
    end
    for _, method in ipairs({"SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor"}) do
        widget[method] = function(self, ...)
            assert(not combat and not self.protected and not self.forbidden, "changed an inaccessible frame")
            self[method .. "Args"] = {...}
        end
    end
    return widget
end

local function button()
    local widget = frame()
    widget.caption = visual(widget)
    widget.LeftDecor = visual(widget)
    for _, state in ipairs({"Normal", "Pushed", "Highlight", "Disabled"}) do
        local texture = visual(widget)
        widget["Get" .. state .. "Texture"] = function() return texture end
    end
    function widget:SetNormalTextColor(...) self.text:SetTextColor(...) end
    function widget:SetHighlightTextColor(...) self.highlight = {...} end
    return widget
end

local function progress()
    local bar = frame()
    bar.Text, bar.Texture = visual(bar), visual(bar)
    bar.CapLeft, bar.CapRight = visual(bar), visual(bar)
    bar.value = 35
    return bar
end

function CreateFrame(kind)
    assert(kind == "Frame")
    local events = {}
    eventFrame = {
        RegisterEvent = function(_, event) events[event] = true end,
        UnregisterEvent = function(_, event) events[event] = nil end,
        SetScript = function(self, script, callback)
            assert(script == "OnEvent", "a per-frame update was registered")
            self.callback = callback
        end,
        Fire = function(self, event, ...)
            if events[event] then self:callback(event, ...) end
        end,
        events = events,
    }
    return eventFrame
end
function CreateFont()
    return {
        SetFont = function(self, path)
            if path ~= availableFont then error("font missing") end
            self.path = path
        end,
        GetFont = function(self) return self.path end,
    }
end
function InCombatLockdown() return combat end
function GetLocale() return locale end
function hooksecurefunc(object, method, callback)
    local original = assert(object[method])
    hooks = hooks + 1
    object[method] = function(...)
        local first, second = original(...)
        callback(...)
        return first, second
    end
end

local function loadZygorStyles(addon)
    addon.UI = {SkinData=noop}
    addon.DIR = "Interface\\AddOns\\" .. target
    addon.SKINSDIR = addon.DIR .. "\\Skins\\"
    addon.F = {HTMLColor=function(hex)
        return tonumber(hex:sub(2, 3), 16) / 255, tonumber(hex:sub(4, 5), 16) / 255,
            tonumber(hex:sub(6, 7), 16) / 255, (tonumber(hex:sub(8, 9), 16) or 255) / 255
    end}
    assert(loadfile(installed .. "/Skins.lua"))(target, addon)
    local skin = addon.Skins:AddSkin("default", "Default")
    for _, dir in ipairs({"Starlight", "Starlight-glass", "Stealth", "Stealth-glass"}) do
        local loadStyle = assert(loadfile(installed .. "/Skins/Default/" .. dir .. "/Style.lua"))
        -- Zygor's style files obtain their namespace from the addon loader.
        loadStyle(target, addon)
    end
    return skin
end

local function createZygor()
    local viewer = frame()
    viewer.Border = {Back=frame()}
    viewer.Border.Back.TopLeftCorner = visual(viewer.Border.Back)
    function viewer:AlignFrame() self.nativeAligned = true end
    local step = frame()
    step.Step = visual(step)
    local scroll = frame()
    scroll.ThumbTexture = visual(scroll)
    local prev, nextButton = button(), button()
    nextButton.protected = true
    local nativeClicks = 0
    prev.click = function() nativeClicks = nativeClicks + 1 end
    viewer.Controls = {TitleBar=frame(), PrevButton=prev, NextButton=nextButton, CloseButton=button(),
        StepNum=step, DefaultStateButton=button(), Scroll={Bar=scroll}, ProgressBar=progress()}
    function viewer:ApplySkin() self.nativeApplied = (self.nativeApplied or 0) + 1 end

    local menu = {ApplySkin=noop, PrepareGuidesMenuButtons=noop, ShowOptionButtons=noop}
    function menu:Open() self.MainFrame.Header.Tabs.Home.isHighlightLocked = true end
    function menu:Update()
        local row = self.MainFrame.GuideListScrollFrame.rows[1]
        row.title:SetFont("OpenSansB.ttf", 12, "")
        return "native"
    end
    local function createMenu()
        local header = frame()
        header.Tabs = {Home=button()}
        header.CloseButton = button()
        local function column()
            local widget = frame()
            widget.Name, widget.Decor = visual(widget), frame()
            return widget
        end
        local guideRow, safeRow = frame(), frame()
        guideRow.title, safeRow.title = visual(guideRow), visual(safeRow)
        safeRow.forbidden = true
        menu.FeaturedTooltip = frame()
        menu.FeaturedTooltip.Text = visual(menu.FeaturedTooltip)
        menu.MainFrame = frame()
        local main = menu.MainFrame
        main.Header, main.MenuColumn, main.MenuOptions = header, frame(), {buttons={button()}}
        main.MenuColumn.GuideButtons = {button()}
        main.CenterColumn, main.WideColumn, main.FullColumn = {SectionInfo=column()}, column(), column()
        main.MenuGuides = {SearchEdit=frame(), Options=button(), OptionsDecor=visual()}
        main.MenuGuides.SearchEdit = setmetatable(main.MenuGuides.SearchEdit, {__index=visual()})
        main.RightColumn = frame()
        local rightColumn = main.RightColumn
        rightColumn.GuideTitle, rightColumn.GuideDesc, rightColumn.GuideProgressLabel =
            visual(rightColumn), visual(rightColumn), visual(rightColumn)
        rightColumn.GuideProgress = progress()
        main.GuideListScrollFrame = {rows={guideRow, safeRow}}
        menu:ApplySkin()
    end

    local tabs = {Pool={}}
    function tabs:CreateTab()
        local tab = {Button=button(), Text=visual()}
        self.Pool[#self.Pool + 1] = tab
        return tab
    end

    local addon = {
        name=target, IsRetail=true, Font="OpenSans.ttf", FontBold="OpenSansB.ttf",
        GuideMenu=menu, Tabs=tabs, db={profile={skin="default", skinstyle="stealth"}},
        Pointer={ArrowSkins={Starlight={options={ar=1}}, Stealth={options={ar=1}}}, Icons={mapmarker={tex={}}}},
    }
    function addon:Options_Initialize() self.font_dialog = visual() end
    local skin = loadZygorStyles(addon)
    function skin:CreateFrame()
        self.frame, addon.Frame = viewer, viewer
        viewer:ApplySkin()
        return viewer
    end
    return addon, skin, viewer, createMenu, function() return nativeClicks end
end

local function loadSkin()
    local ns = {}
    assert(loadfile("Style.lua"))(skinName, ns)
    assert(loadfile("Core.lua"))(skinName, ns)
    return ns, eventFrame
end

local _, absentEvents = loadSkin()
absentEvents:Fire("ADDON_LOADED", skinName)
assert(hooks == 0 and not absentEvents.events.PLAYER_REGEN_ENABLED)

-- Ignore other clients even if their Zygor global is present.
ZGV = createZygor()
ZGV.IsRetail = false
local _, wrongClientEvents = loadSkin()
wrongClientEvents:Fire("ADDON_LOADED", skinName)
assert(hooks == 0 and wrongClientEvents.events.ADDON_LOADED)
ZGV = nil

-- Zygor may load after the skin; install once when its event arrives.
local _, delayedEvents = loadSkin()
delayedEvents:Fire("ADDON_LOADED", skinName)
ZGV = createZygor()
delayedEvents:Fire("ADDON_LOADED", target)
assert(not delayedEvents.events.ADDON_LOADED and ZGV.Font == expressway)
local installedHooks = hooks
delayedEvents:Fire("ADDON_LOADED", target)
assert(hooks == installedHooks)

local zygor, skin, viewer, createMenu, clickCount = createZygor()
ZGV = zygor
local ns, events = loadSkin()
events:Fire("ADDON_LOADED", skinName)
assert(not events.events.ADDON_LOADED)
assert(zygor.Font == expressway)
zygor:Options_Initialize()
assert(zygor.font_dialog:GetFont() == expressway)
assert(zygor.db.profile.skin == "default" and zygor.db.profile.skinstyle == "stealth")
for _, id in ipairs({"starlight", "starlight-glass", "stealth", "stealth-glass"}) do
    local style = skin:GetStyle(id)
    assert(style:GetProp("WindowBackdropColor") == ns.color.window)
    assert(style:GetProp("ProgressBarDecorUse") == 0)
    assert(style:GetProp("StyleAceGUI") and style:GetProp("AceGUISliderThumb"))
    assert(style:GetProp("AceGUISliderBackdrop"))
    assert(style:GetProp("AceGUIInputTexture") and style:GetProp("TitleButtons"))
    assert(style:GetDir():find(id, 1, true))
end
assert(zygor.Pointer.ArrowSkins.Starlight.options.bg == ns.color.gold[2])
assert(zygor.Pointer.Icons.mapmarker.tex.r == ns.color.gold[1])
assert(skin:CreateFrame() == viewer)
assert(viewer.nativeApplied == 1 and #viewer.Controls.TitleBar.textures == 2)
viewer:AlignFrame()
assert(viewer.nativeAligned and viewer.Border.Back.TopLeftCorner.SetVertexColorArgs[1] == ns.color.border[1])
assert(viewer.Controls.NextButton:GetNormalTexture().writes == 0)
viewer.Controls.PrevButton.click()
assert(clickCount() == 1)
assert(viewer.Controls.ProgressBar.value == 35 and viewer.Controls.ProgressBar.Texture.SetTexCoordArgs[2] == 1)
local path, size, flags = viewer.Controls.StepNum.Step:GetFont()
assert(path == expressway and size == 12 and flags == "OUTLINE")
viewer:ApplySkin()
assert(viewer.nativeApplied == 2 and #viewer.Controls.TitleBar.textures == 2)
assert(zygor.Tabs:CreateTab().Text:GetFont() == expressway)

createMenu()
local menu = zygor.GuideMenu
menu:Open("Home")
assert(menu:Update() == "native")
local main = menu.MainFrame
assert(main.GuideListScrollFrame.rows[1].title:GetFont() == expressway)
assert(main.GuideListScrollFrame.rows[2].title:GetFont() == "OpenSans.ttf")
assert(main.Header.Tabs.Home.text.SetTextColorArgs[2] == ns.color.gold[2])
assert(menu.FeaturedTooltip.Text:GetFont() == expressway)
menu.FeaturedTooltip.forbidden = true
menu:ApplySkin()
assert(#main.Header.textures == 1)

combat = true
viewer:ApplySkin()
menu:ApplySkin()
local tab = zygor.Tabs:CreateTab()
assert(tab.Text:GetFont() == "OpenSans.ttf" and events.events.PLAYER_REGEN_ENABLED)
combat = false
events:Fire("PLAYER_REGEN_ENABLED")
assert(not events.events.PLAYER_REGEN_ENABLED and tab.Text:GetFont() == expressway)

-- New Lua state after a reload has fresh addon objects and style data.
availableFont = clientFont
ZGV, skin = createZygor()
local _, reloadEvents = loadSkin()
reloadEvents:Fire("ADDON_LOADED", skinName)
assert(ZGV.Font == clientFont and skin:CreateFrame().Controls.StepNum.Step:GetFont() == clientFont)

locale = "zhTW"
ZGV = createZygor()
local _, localEvents = loadSkin()
localEvents:Fire("ADDON_LOADED", skinName)
assert(ZGV.Font == "OpenSans.ttf")

-- Starting Zygor without the skin leaves its built-in style ID and assets valid.
ZGV, skin = createZygor()
assert(ZGV.Font == "OpenSans.ttf" and ZGV.db.profile.skinstyle == "stealth")
assert(not skin:GetStyle("stealth"):GetProp("StyleAceGUI"))
print("Zygor Retail Skin: load, built-in styles, visuals, combat deferral and independent reload OK")
