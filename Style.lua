local _, ns = ...

local color = {
    window = {.048, .035, .024, .96},
    inset = {.026, .021, .016, .93},
    header = {.20, .12, .055, .92},
    border = {.56, .40, .22, .83},
    bronze = {.68, .49, .28, 1},
    gold = {1, .82, .44, 1},
    text = {.96, .91, .81, 1},
    muted = {.76, .70, .61, 1},
    disabled = {.58, .54, .48, 1},
    button = {.31, .24, .16, 1},
    hover = {.41, .30, .18, 1},
    highlight = {1, .74, .35, .18},
    selected = {.27, .18, .095, 1},
}
ns.color = color

local white = "Interface\\Buttons\\WHITE8X8"
local panel = {bgFile = white, edgeFile = white, edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1}}
local fill = {bgFile = white}
local bar = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"
ns.panel = panel
ns.fill = fill
ns.rock = "Interface\\FrameGeneral\\UI-Background-Rock"

-- These properties are consumed by the installed Zygor style engine.
-- Geometry, atlas coordinates and the original style IDs continue to come from Zygor.
function ns.ApplyPalette(style)
    local overrides = {
        MainBackdrop = panel, MainBackdropColor = color.window, MainBackdropBorderColor = color.border,
        SecBackdrop = fill, SecBackdropColor = color.inset, TriBackdropColor = color.selected,
        Backdrop = panel, BackdropColor = color.window, BackdropBorderColor = color.border,
        Accent = color.hover, ActiveSectionColor = color.gold,
        WindowBackdrop = panel, WindowBackdropColor = color.window, WindowBackdropBorderColor = color.border,
        WindowBottomBackdrop = panel, WindowBottomBackdropColor = color.inset, WindowBottomBackdropBorderColor = color.border,
        SystemBarBackdropColor = color.header, SystemBarBackdropBorderColor = color.border,
        TabBackdropColor = color.inset, TabsBackdropActive = color.bronze, TabsTextColor = color.text,
        TabsTextColorOver = color.gold, TabsSeparatorColor = color.border, TabsBorderColor = color.border,
        StepBackdrop = fill, StepBackdropColor = color.inset, StepBackdropBorderColor = color.inset,
        StepStickySeparatorColor = color.bronze, StepLineIconMarginRight = 4,
        ButtonHighlight = color.highlight, TitleButtonHighlightAlpha = .4,
        ButtonBackdrop1 = panel, ButtonColor1 = color.button, ButtonBorderColor1 = color.border,
        ButtonHighlightColor1 = color.hover, ButtonTextColor1Over = color.gold, ButtonTextColor1Out = color.text,
        ButtonBackdrop2 = fill, ButtonColor2 = color.button, ButtonHighlightColor2 = color.hover,
        ButtonBackdrop3 = panel, ButtonBorderColor3 = color.border,
        ButtonHighlightColor3 = color.hover, ButtonBorderColorHighlightColor3 = color.bronze,
        ScrollBarColor = color.bronze,
        ProgressBarBackdrop = panel, ProgressBarBackdropColor = color.inset,
        ProgressBarBackdropBorderColor = color.border, ProgressBarTextureFile = bar,
        ProgressBarTextureFileOffset = {0, 1, 0, 1}, ProgressBarTextureColor = color.gold,
        ProgressBarCapsColor = {0, 0, 0, 0}, ProgressBarDecorUse = 0,
        FloatMenuBackdrop = panel, FloatMenuBackdropColor = color.window,
        FloatMenuBackdropBorderColor = color.border, FloatMenuSeparatorolor = color.border,
        FloatMenuSmallBackdrop = panel, FloatMenuSmallBackdropColor = color.window,
        FloatMenuSmallBackdropBorderColor = color.border,
        UIDropDownBackdrop = panel, UIDropDownBackdropColor = color.inset,
        UIDropDownBorderColor = color.border, UIDropDownLabelColor = color.text,
        DropDownBackdrop1 = panel, DropDownBackdrop1Color = color.inset,
        DropDownBackdrop2 = panel, DropDownBackdrop2Color = color.inset, DropDownBackdrop2BorderColor = color.border,
        DropDownPulloutBackdrop = panel, DropDownPulloutColor = color.window, DropDownPulloutBorderColor = color.border,
        DropDownItemColor = color.inset,
        SearchBackdrop = panel, SearchEditBackdropColor = color.inset, SearchEditBorderColor = color.border,
        SearchEditTextColor = color.muted, SearchEditTextColorActive = color.text,
        StyleAceGUI = true, AceGUIDropDownBackdrop = panel, AceGUIDropDownBackdropColor = color.window,
        AceGUIDropDownBackdropBorderColor = color.border,
        AceGUIEditBackdrop = panel, AceGUIEditBackdropMultiline = panel,
        AceGUIEditBackdropColor = color.inset, AceGUIEditBackdropBorderColor = color.border,
        AceGUIButtonTexture = panel, AceGUIButtonTextureColor = color.button,
        AceGUIButtonTextColor = color.text, AceGUIButtonTextColorDisabled = color.disabled,
        GuideMenuBackdrop = panel, GuideMenuBackdropColor = color.window, GuideMenuBackdropBorderColor = color.border,
        GuideMenuHeaderFooterBackground = color.header, GuideMenuHeaderFooterBorder = color.border,
        GuideMenuSectionBorder = color.border, GuideMenuGuideButtonDecorColor = color.gold,
        GuideMenuContentBackground = color.inset, GuideMenuDetailsBackground = color.window,
        GuideMenuContentBackdrop = panel, GuideMenuContentBackdropColor = color.inset,
        GuideMenuContentBackdropBorderColor = color.border,
        GuideMenuMenuBackground = panel, GuideMenuMenuBackgroundColor = color.window,
        GuideMenuMenuBackdropBorderColor = color.border,
        GuideMenuDetailsBackdrop = panel, GuideMenuDetailsBackdropColor = color.window,
        GuideMenuDetailsBackdropBorderColor = color.border,
        GuideMenuExpandedBackdrop = panel, GuideMenuExpandedBackdropColor = color.inset,
        GuideMenuExpandedBackdropBorderColor = color.border,
        NotificationDecorColor = color.bronze, NotificationTextColor = color.text,
        NotificationTextColorOver = color.gold, NotificationBubbleColor = color.gold, MessageNotify = color.gold,
        WidgetsTextColor = color.text, WidgetsDragColor = color.header,
        WidgetsPopupBackdropColor = color.inset, WidgetsPopupBackdropBorderColor = color.border,
        CreatureViewerLabelBackground = color.header, CreatureViewerLabelColor = color.text,
        GoldguideHeaderFooterColor = color.header,
        AuctionToolsHeaderFooterBackground = color.header, AuctionToolsHeaderFooterBorder = color.border,
    }
    for key, value in pairs(overrides) do style[key] = value end
    for _, key in ipairs({
        "ActionBar", "FindNearest", "Notification", "NotificationPopupHeader", "NotificationPopupContent",
        "Goldguide", "WorldQuest", "AuctionTools", "Bug", "GearFinder", "Widgets", "Creature", "Money",
    }) do
        style[key .. "Backdrop"] = panel
        style[key .. "BackdropColor"] = color.window
        style[key .. "BackdropBorderColor"] = color.border
    end
end

function ns.ApplyNavigationPalette(pointer)
    if not pointer then return end
    for _, id in ipairs({"Starlight", "Stealth"}) do
        local options = pointer.ArrowSkins and pointer.ArrowSkins[id] and pointer.ArrowSkins[id].options
        -- The native gradient retains the red / amber / green direction cues.
        if options and options.ar and not options.color_gradient and not options.color_gradients then
            options.ar, options.ag, options.ab = 1, .45, .36
            options.br, options.bg, options.bb = unpack(color.gold, 1, 3)
            options.cr, options.cg, options.cb = .51, .84, .44
        end
    end

    local marker = pointer.Icons and pointer.Icons.mapmarker
    if marker and marker.tex then
        marker.tex.r, marker.tex.g, marker.tex.b = unpack(color.gold, 1, 3)
    end
end
