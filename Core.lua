local addonName, ns = ...
local zygorName = "ZygorGuidesViewer"
local color = ns.color
local font
local zygor
local events = CreateFrame("Frame")
local decorated = setmetatable({}, {__mode = "k"})
local viewers = setmetatable({}, {__mode = "k"})
local skinnedProgress = setmetatable({}, {__mode = "k"})

local function canStyle(frame)
    if not frame or frame:IsForbidden() or frame:IsProtected() then return false end
    if InCombatLockdown() then
        events:RegisterEvent("PLAYER_REGEN_ENABLED")
        return false
    end
    return true
end

local function findFont()
    local locale = GetLocale()
    if locale == "koKR" or locale == "zhCN" or locale == "zhTW" then return end

    local probe = CreateFont(addonName .. "FontProbe")
    for _, candidate in ipairs({
        "Interface\\AddOns\\AzerothBuddy\\Media\\Expressway.ttf",
        "Interface\\AddOns\\AzerothBuddyUI\\Media\\Expressway.ttf",
        "Fonts\\FRIZQT__.TTF",
    }) do
        -- Font objects may return nil on success. Missing files can raise.
        local ok, loaded = pcall(probe.SetFont, probe, candidate, 12, "")
        local path = ok and loaded ~= false and probe:GetFont()
        if path and path:lower() == candidate:lower() then return candidate end
    end
end

local function setFont(region, textColor)
    if not region then return end
    if font then
        local path, size, flags = region:GetFont()
        if path and path ~= font and size then region:SetFont(font, size, flags) end
    end
    if textColor then region:SetTextColor(unpack(textColor)) end
end

local function setPanel(frame, background)
    frame:SetBackdrop(ns.panel)
    frame:SetBackdropColor(unpack(background))
    frame:SetBackdropBorderColor(unpack(color.border))
end

local function decorateHeader(frame, hasBase)
    if not canStyle(frame) or decorated[frame] then return end
    if not hasBase then
        local base = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
        base:SetAllPoints(frame)
        base:SetColorTexture(unpack(color.header))
    end
    local stone = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
    stone:SetPoint("TOPLEFT", 1, -1)
    stone:SetPoint("BOTTOMRIGHT", -1, 1)
    stone:SetTexture(ns.rock)
    stone:SetAlpha(.36)
    decorated[frame] = true
end

local buttonTints = {
    {"GetNormalTexture", color.text}, {"GetPushedTexture", color.gold},
    {"GetHighlightTexture", color.gold}, {"GetDisabledTexture", color.disabled},
}
local corners = {"TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner"}

local function tintButton(button)
    if not canStyle(button) then return end
    for _, state in ipairs(buttonTints) do
        local texture = button[state[1]](button)
        if texture then texture:SetVertexColor(unpack(state[2])) end
    end
end

local function tintCorners(frame)
    if not canStyle(frame) then return end
    -- Zygor can replace some corner textures with a white fill when aligning panels.
    for _, corner in ipairs(corners) do
        if frame[corner] then frame[corner]:SetVertexColor(unpack(color.border)) end
    end
end

local function skinProgress(bar)
    if not canStyle(bar) or skinnedProgress[bar] then return end
    setPanel(bar, color.inset)
    bar.Texture:SetTexCoord(0, 1, 0, 1)
    bar.CapLeft:SetAlpha(0)
    bar.CapRight:SetAlpha(0)
    setFont(bar.Text, color.text)
    skinnedProgress[bar] = true
end

local function skinViewer(frame)
    if not canStyle(frame) then return end
    local controls = frame.Controls
    if frame.Border then tintCorners(frame.Border.Back) end
    decorateHeader(controls.TitleBar)
    tintButton(controls.PrevButton)
    tintButton(controls.NextButton)
    tintButton(controls.CloseButton)
    if canStyle(controls.StepNum) then setFont(controls.StepNum.Step, color.gold) end
    if canStyle(controls.DefaultStateButton) then
        setFont(controls.DefaultStateButton:GetFontString(), color.text)
    end

    local scrollbar = controls.Scroll.Bar
    if canStyle(scrollbar) then scrollbar.ThumbTexture:SetVertexColor(unpack(color.bronze)) end
    skinProgress(controls.ProgressBar)
    if frame.stickySepPool then
        for separator in frame.stickySepPool:EnumerateActive() do
            separator:SetVertexColor(unpack(color.bronze))
        end
    end
end

local function observeViewer(frame)
    if not canStyle(frame) or viewers[frame] or not frame.Controls or type(frame.ApplySkin) ~= "function" then return end
    hooksecurefunc(frame, "ApplySkin", skinViewer)
    if type(frame.AlignFrame) == "function" then
        hooksecurefunc(frame, "AlignFrame", function(self) tintCorners(self.Border.Back) end)
    end
    viewers[frame] = true
    skinViewer(frame)
end

local function skinGuideRows(menu)
    local main = menu.MainFrame
    if not canStyle(main) or not main.GuideListScrollFrame then return end
    for _, row in ipairs(main.GuideListScrollFrame.rows) do
        if row:IsShown() and canStyle(row) then setFont(row.title) end
    end
end

local function skinGuideTabs(menu)
    local main = menu.MainFrame
    if not canStyle(main) then return end
    for _, button in pairs(main.Header.Tabs) do
        if canStyle(button) then
            button:SetNormalTextColor(unpack(color.muted))
            button:SetHighlightTextColor(unpack(color.gold))
            setFont(button:GetFontString(), button.isHighlightLocked and color.gold or color.muted)
        end
    end
end

local function skinMenuButtons(buttons)
    for _, button in pairs(buttons or {}) do
        if canStyle(button) then setFont(button.caption) end
    end
end

local function skinGuideMenu(menu)
    local main = menu.MainFrame
    if not canStyle(main) then return end
    decorateHeader(main.Header, true)
    tintButton(main.Header.CloseButton)
    tintCorners(main.WideColumn)
    tintCorners(main.MenuColumn)
    tintCorners(main.RightColumn)
    tintCorners(main.FullColumn)
    local section = main.CenterColumn.SectionInfo
    for _, column in ipairs({section, main.WideColumn, main.FullColumn}) do
        setFont(column.Name, color.gold)
        if canStyle(column.Decor) then
            column.Decor:SetBackdrop(ns.fill)
            column.Decor:SetBackdropColor(unpack(color.bronze))
        end
    end
    if canStyle(main.MenuGuides.SearchEdit) then setFont(main.MenuGuides.SearchEdit) end
    local searchOptions = main.MenuGuides.Options
    if canStyle(searchOptions) then setFont(searchOptions.caption) end
    if main.MenuGuides.OptionsDecor then main.MenuGuides.OptionsDecor:SetVertexColor(unpack(color.border)) end
    setFont(main.RightColumn.GuideTitle, color.gold)
    setFont(main.RightColumn.GuideDesc, color.text)
    setFont(main.RightColumn.GuideProgressLabel, color.muted)
    skinProgress(main.RightColumn.GuideProgress)

    if canStyle(menu.FeaturedTooltip) then
        setPanel(menu.FeaturedTooltip, color.inset)
        setFont(menu.FeaturedTooltip.Text, color.text)
    end
    if menu.MissingPopup and canStyle(menu.MissingPopup.Frame) then
        setPanel(menu.MissingPopup.Frame, color.window)
        setFont(menu.MissingPopup.Text, color.text)
    end

    skinGuideTabs(menu)
    skinGuideRows(menu)
    skinMenuButtons(main.MenuColumn.GuideButtons)
    skinMenuButtons(main.MenuOptions.buttons)
end

local function skinOptions(addon)
    for _, key in ipairs({"font_dialog", "font_dialog_gray", "font_dialoglarge", "font_dialogsmall", "font_dialog_red"}) do
        setFont(addon[key])
    end
end

local function skinLatestTab(tabs)
    local tab = tabs.Pool[#tabs.Pool]
    if tab and canStyle(tab.Button) then setFont(tab.Text) end
end

local function install()
    local addon = _G.ZGV
    if not addon or addon.name ~= zygorName or not addon.IsRetail then return end
    if not addon.Skins or type(addon.Skins.GetSkin) ~= "function" then return end
    local skin = addon.Skins:GetSkin("default")
    if not skin or type(skin.CreateFrame) ~= "function" or type(skin.GetStyle) ~= "function" then return end
    local starlight = skin:GetStyle("starlight")
    if not starlight then return end

    zygor = addon
    -- Retain Zygor's style IDs so its saved profiles also work without this addon.
    for _, id in ipairs({"starlight", "starlight-glass", "stealth", "stealth-glass"}) do
        local style = skin:GetStyle(id)
        if style then
            -- The older Stealth style ships without the option widget assets.
            style.AceGUIInputTexture = style.AceGUIInputTexture or starlight.AceGUIInputTexture
            style.AceGUISliderThumb = style.AceGUISliderThumb or starlight.AceGUISliderThumb
            style.AceGUISliderBackdrop = style.AceGUISliderBackdrop or starlight.AceGUISliderBackdrop
            ns.ApplyPalette(style)
        end
    end
    ns.ApplyNavigationPalette(addon.Pointer)

    font = findFont()
    if font then
        addon.Font, addon.FontBold = font, font
        skinOptions(addon)
        if type(addon.Options_Initialize) == "function" then
            hooksecurefunc(addon, "Options_Initialize", skinOptions)
        end
    end

    -- Secure post-hooks observe the original lifecycle without replacing handlers.
    hooksecurefunc(skin, "CreateFrame", function(self) observeViewer(self.frame) end)
    observeViewer(addon.Frame)

    local menu = addon.GuideMenu
    if menu and type(menu.ApplySkin) == "function" then
        menu.BUTTONS_NORMAL_COLOR = color.muted
        menu.BUTTONS_HIGHLIGHT_COLOR = color.gold
        hooksecurefunc(menu, "ApplySkin", function() skinGuideMenu(menu) end)
        if font and type(menu.Update) == "function" then
            hooksecurefunc(menu, "Update", function() skinGuideRows(menu) end)
        end
        if type(menu.Open) == "function" then
            hooksecurefunc(menu, "Open", function() skinGuideTabs(menu) end)
        end
        if font and type(menu.PrepareGuidesMenuButtons) == "function" then
            hooksecurefunc(menu, "PrepareGuidesMenuButtons", function()
                skinMenuButtons(menu.MainFrame.MenuColumn.GuideButtons)
            end)
        end
        if font and type(menu.ShowOptionButtons) == "function" then
            hooksecurefunc(menu, "ShowOptionButtons", function()
                skinMenuButtons(menu.MainFrame.MenuOptions.buttons)
            end)
        end
        skinGuideMenu(menu)
    end

    local tabs = addon.Tabs
    if font and tabs and type(tabs.CreateTab) == "function" then
        hooksecurefunc(tabs, "CreateTab", skinLatestTab)
    end
end

events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" then
        if name ~= addonName and name ~= zygorName then return end
        if not zygor then install() end
        if not zygor then return end
        self:UnregisterEvent("ADDON_LOADED")
    else
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        if zygor.Frame then
            if viewers[zygor.Frame] then skinViewer(zygor.Frame) else observeViewer(zygor.Frame) end
        end
        if zygor.GuideMenu then skinGuideMenu(zygor.GuideMenu) end
        if zygor.Tabs then
            for _, tab in ipairs(zygor.Tabs.Pool) do
                if canStyle(tab.Button) then setFont(tab.Text) end
            end
        end
    end
end)
