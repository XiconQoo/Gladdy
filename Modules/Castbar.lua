local pairs = pairs

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AceGUIWidgetLSMlists = AceGUIWidgetLSMlists
local Castbar = Gladdy:NewModule("Castbar", 70, {
    castBarHeight = 20,
    castBarWidth = 160,
    castBarIconSize = 22,
    castBarBorderSize = 8,
    castBarFontSize = 12,
    castBarTexture = "Smooth",
    castBarIconStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    castBarBorderStyle = "Gladdy Tooltip round",
    castBarColor = { r = 1, g = 0.8, b = 0.2, a = 1 },
    castBarBgColor = { r = 0, g = 0, b = 0, a = 0.4 },
    castBarIconColor = { r = 0, g = 0, b = 0, a = 1 },
    castBarBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    castBarFontColor = { r = 1, g = 1, b = 1, a = 1 },
    castBarGuesses = true,
    castBarPos = "LEFT",
    castBarXOffset = 0,
    castBarYOffset = 0,
    castBarIconPos = "LEFT",
    castBarFont = "DorisPP",
    castBarSparkEnabled = true,
    castBarSparkColor = { r = 1, g = 1, b = 1, a = 1 },
})

function Castbar:Initialise()
    self.frames = {}

    self:RegisterMessage("CAST_START")
    self:RegisterMessage("CAST_STOP")
    self:RegisterMessage("UNIT_DEATH", "CAST_STOP")
end

function Castbar:CreateFrame(unit)
    local castBar = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    castBar:SetBackdrop({ edgeFile = Gladdy.LSM:Fetch("border", Gladdy.db.castBarBorderStyle),
                                 edgeSize = Gladdy.db.castBarBorderSize })
    castBar:SetBackdropBorderColor(Gladdy.db.castBarBorderColor.r, Gladdy.db.castBarBorderColor.g, Gladdy.db.castBarBorderColor.b, Gladdy.db.castBarBorderColor.a)
    castBar:SetFrameLevel(1)

    castBar.bar = CreateFrame("StatusBar", nil, castBar)
    castBar.bar:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.castBarTexture))
    castBar.bar:SetStatusBarColor(Gladdy.db.castBarColor.r, Gladdy.db.castBarColor.g, Gladdy.db.castBarColor.b, Gladdy.db.castBarColor.a)
    castBar.bar:SetMinMaxValues(0, 100)
    castBar.bar:SetFrameLevel(0)

    castBar.spark = castBar:CreateTexture(nil, "OVERLAY")
    castBar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    castBar.spark:SetBlendMode("ADD")
    castBar.spark:SetWidth(16)
    castBar.spark:SetHeight(Gladdy.db.castBarHeight * 1.8)
    castBar.spark.position = 0

    castBar:SetScript("OnUpdate", function(self, elapsed)
        if (self.isCasting) then
            if (self.value >= self.maxValue) then
                Castbar:CAST_STOP(unit)
            else
                self.value = self.value + elapsed
                self.bar:SetValue(self.value)
                self.timeText:SetFormattedText("%.1f", self.maxValue - self.value)
            end
        elseif (self.isChanneling) then
            if (self.value <= 0) then
                Castbar:CAST_STOP(unit)
            else
                self.value = self.value - elapsed
                self.bar:SetValue(self.value)
                self.timeText:SetFormattedText("%.1f", self.value)
            end
        end
        if self.isCasting or self.isChanneling then
            self.spark.position = ((self.value) / self.maxValue) * (Gladdy.db.castBarWidth - (Gladdy.db.castBarBorderSize/Gladdy.db.statusbarBorderOffset)*2)
            if ( self.spark.position < 0 ) then
                self.spark.position = 0
            end
            self.spark:SetPoint("CENTER", self.bar, "LEFT", self.spark.position, 0)
        end
    end)

    castBar.bg = castBar.bar:CreateTexture(nil, "BACKGROUND")
    castBar.bg:SetAlpha(1)
    castBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.castBarTexture))
    castBar.bg:SetVertexColor(Gladdy.db.castBarBgColor.r, Gladdy.db.castBarBgColor.g, Gladdy.db.castBarBgColor.b, Gladdy.db.castBarBgColor.a)
    castBar.bg:SetAllPoints(castBar.bar)

    castBar.icon = CreateFrame("Frame", nil, castBar)
    castBar.icon.texture = castBar.icon:CreateTexture(nil, "BACKGROUND")
    castBar.icon.texture:SetAllPoints(castBar.icon)
    castBar.icon.texture.overlay = castBar.icon:CreateTexture(nil, "BORDER")
    castBar.icon.texture.overlay:SetAllPoints(castBar.icon.texture)
    castBar.icon.texture.overlay:SetTexture(Gladdy.db.castBarIconStyle)

    castBar.icon:ClearAllPoints()
    if (Gladdy.db.castBarIconPos == "LEFT") then
        castBar.icon:SetPoint("RIGHT", castBar, "LEFT", -3, 0) -- Icon of castbar
    else
        castBar.icon:SetPoint("LEFT", castBar, "RIGHT", 3, 0) -- Icon of castbar
    end

    castBar.spellText = castBar:CreateFontString(nil, "LOW")
    castBar.spellText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), Gladdy.db.castBarFontSize)
    castBar.spellText:SetTextColor(Gladdy.db.castBarFontColor.r, Gladdy.db.castBarFontColor.g, Gladdy.db.castBarFontColor.b, Gladdy.db.castBarFontColor.a)
    castBar.spellText:SetShadowOffset(1, -1)
    castBar.spellText:SetShadowColor(0, 0, 0, 1)
    castBar.spellText:SetJustifyH("CENTER")
    castBar.spellText:SetPoint("LEFT", 7, 0) -- Text of the spell

    castBar.timeText = castBar:CreateFontString(nil, "LOW")
    castBar.timeText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), Gladdy.db.castBarFontSize)
    castBar.timeText:SetTextColor(Gladdy.db.castBarFontColor.r, Gladdy.db.castBarFontColor.g, Gladdy.db.castBarFontColor.b, Gladdy.db.castBarFontColor.a)
    castBar.timeText:SetShadowOffset(1, -1)
    castBar.timeText:SetShadowColor(0, 0, 0, 1)
    castBar.timeText:SetJustifyH("CENTER")
    castBar.timeText:SetPoint("RIGHT", -4, 0) -- text of cast timer

    Gladdy.buttons[unit].castBar = castBar
    self.frames[unit] = castBar
    self:ResetUnit(unit)
end

function Castbar:UpdateFrame(unit)
    local button = Gladdy.buttons[unit]
    local castBar = self.frames[unit]
    if (not castBar) then
        return
    end

    castBar:SetWidth(Gladdy.db.castBarWidth)
    castBar:SetHeight(Gladdy.db.castBarHeight)
    castBar:SetBackdrop({ edgeFile = Gladdy.LSM:Fetch("border", Gladdy.db.castBarBorderStyle),
                                 edgeSize = Gladdy.db.castBarBorderSize })
    castBar:SetBackdropBorderColor(Gladdy.db.castBarBorderColor.r, Gladdy.db.castBarBorderColor.g, Gladdy.db.castBarBorderColor.b, Gladdy.db.castBarBorderColor.a)

    castBar.bar:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.castBarTexture))
    castBar.bar:ClearAllPoints()
    castBar.bar:SetPoint("TOPLEFT", castBar, "TOPLEFT", (Gladdy.db.castBarBorderSize/Gladdy.db.statusbarBorderOffset), -(Gladdy.db.castBarBorderSize/Gladdy.db.statusbarBorderOffset))
    castBar.bar:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", -(Gladdy.db.castBarBorderSize/Gladdy.db.statusbarBorderOffset), (Gladdy.db.castBarBorderSize/Gladdy.db.statusbarBorderOffset))

    castBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.castBarTexture))
    castBar.bg:SetVertexColor(Gladdy.db.castBarBgColor.r, Gladdy.db.castBarBgColor.g, Gladdy.db.castBarBgColor.b, Gladdy.db.castBarBgColor.a)

    if Gladdy.db.castBarSparkEnabled then
        castBar.spark:SetHeight(Gladdy.db.castBarHeight * 1.8)
        castBar.spark:SetVertexColor(Gladdy.db.castBarSparkColor.r, Gladdy.db.castBarSparkColor.g, Gladdy.db.castBarSparkColor.b, Gladdy.db.castBarSparkColor.a)
    else
        castBar.spark:SetAlpha(0)
    end

    castBar.icon:SetWidth(Gladdy.db.castBarIconSize)
    castBar.icon:SetHeight(Gladdy.db.castBarIconSize)
    castBar.icon.texture:SetAllPoints(castBar.icon)
    castBar.icon:ClearAllPoints()

    local rightMargin = 0
    local leftMargin = 0
    if (Gladdy.db.castBarIconPos == "LEFT") then
        castBar.icon:SetPoint("RIGHT", castBar, "LEFT", -1, 0) -- Icon of castbar
        rightMargin = Gladdy.db.castBarIconSize + 1
    else
        castBar.icon:SetPoint("LEFT", castBar, "RIGHT", 1, 0) -- Icon of castbar
        leftMargin = Gladdy.db.castBarIconSize + 1
    end

    castBar:ClearAllPoints()
    local horizontalMargin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
    local verticalMargin = (Gladdy.db.powerBarHeight)/2
    if (Gladdy.db.castBarPos == "LEFT") then
        if (Gladdy.db.drCooldownPos == "LEFT" and Gladdy.db.drEnabled) then
            castBar:SetPoint("BOTTOMRIGHT", button.drFrame, "TOPRIGHT", -leftMargin + Gladdy.db.castBarXOffset, Gladdy.db.padding + Gladdy.db.castBarYOffset)
        else
            if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
                horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize - Gladdy.db.trinketSize * 0.1) + Gladdy.db.padding
                if (Gladdy.db.classIconPos == "LEFT") then
                    horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize - Gladdy.db.classIconSize * 0.1) + Gladdy.db.padding
                end
            elseif (Gladdy.db.classIconPos == "LEFT") then
                horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize - Gladdy.db.classIconSize * 0.1) + Gladdy.db.padding
                if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
                    horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize - Gladdy.db.trinketSize * 0.1) + Gladdy.db.padding
                end
            end
            castBar:SetPoint("RIGHT", button.healthBar, "LEFT", -horizontalMargin - leftMargin + Gladdy.db.castBarXOffset, Gladdy.db.castBarYOffset - verticalMargin)
        end
    end
    if (Gladdy.db.castBarPos == "RIGHT") then
        if (Gladdy.db.drCooldownPos == "RIGHT" and Gladdy.db.drEnabled) then
            castBar:SetPoint("BOTTOMLEFT", button.drFrame, "TOPLEFT", rightMargin + Gladdy.db.castBarXOffset, Gladdy.db.padding + Gladdy.db.castBarYOffset)
        else
            if (Gladdy.db.trinketPos == "RIGHT" and Gladdy.db.trinketEnabled) then
                horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize - Gladdy.db.trinketSize * 0.1) + Gladdy.db.padding
                if (Gladdy.db.classIconPos == "RIGHT") then
                    horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize - Gladdy.db.classIconSize * 0.1) + Gladdy.db.padding
                end
            elseif (Gladdy.db.classIconPos == "RIGHT") then
                horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize - Gladdy.db.classIconSize * 0.1) + Gladdy.db.padding
                if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
                    horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize - Gladdy.db.trinketSize * 0.1) + Gladdy.db.padding
                end
            end
            castBar:SetPoint("LEFT", button.healthBar, "RIGHT", horizontalMargin + rightMargin + Gladdy.db.castBarXOffset, Gladdy.db.castBarYOffset - verticalMargin)
        end
    end

    castBar.spellText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), Gladdy.db.castBarFontSize)
    castBar.spellText:SetTextColor(Gladdy.db.castBarFontColor.r, Gladdy.db.castBarFontColor.g, Gladdy.db.castBarFontColor.b, Gladdy.db.castBarFontColor.a)

    castBar.timeText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), Gladdy.db.castBarFontSize)
    castBar.timeText:SetTextColor(Gladdy.db.castBarFontColor.r, Gladdy.db.castBarFontColor.g, Gladdy.db.castBarFontColor.b, Gladdy.db.castBarFontColor.a)

    castBar.icon.texture.overlay:SetTexture(Gladdy.db.castBarIconStyle)
    castBar.icon.texture.overlay:SetVertexColor(Gladdy.db.castBarIconColor.r, Gladdy.db.castBarIconColor.g, Gladdy.db.castBarIconColor.b, Gladdy.db.castBarIconColor.a)
end

function Castbar:ResetUnit(unit)
    self:CAST_STOP(unit)
end

function Castbar:Test(unit)
    local spell, _, icon, value, maxValue, event

    if (unit == "arena2") then
        spell, _, icon = GetSpellInfo(27072)
        value, maxValue, event = 0, 60, "cast"
    elseif (unit == "arena1") then
        spell, _, icon = GetSpellInfo(27220)
        value, maxValue, event = 60, 60, "channel"
    elseif (unit == "arena3") then
        spell, _, icon = GetSpellInfo(20770)
        value, maxValue, event = 0, 60, "cast"
    end

    if (spell) then
        self:CAST_START(unit, spell, icon, value, maxValue, event)
    end
end

function Castbar:CAST_START(unit, spell, icon, value, maxValue, event)
    local castBar = self.frames[unit]
    if (not castBar) then
        return
    end

    castBar.value = value
    castBar.maxValue = maxValue
    castBar.bar:SetMinMaxValues(0, maxValue)
    castBar.bar:SetValue(value)
    castBar.icon.texture:SetTexture(icon)
    castBar.spellText:SetText(spell)
    castBar.timeText:SetText(maxValue)
    castBar.isCasting = event == "cast"
    castBar.isChanneling = event == "channel"
    castBar.bg:Show()
    castBar:Show()
    castBar.icon:Show()
end

function Castbar:CAST_STOP(unit)
    local castBar = self.frames[unit]
    if (not castBar) then
        return
    end

    castBar.isCasting = false
    castBar.isChanneling = false
    castBar.value = 0
    castBar.maxValue = 0
    castBar.icon.texture:SetTexture("")
    castBar.spellText:SetText("")
    castBar.timeText:SetText("")
    castBar.bar:SetValue(0)
    castBar.bg:Hide()
    castBar:Hide()
    castBar.icon:Hide()
end

local function option(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile[key]
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile[key] = value
            Gladdy.options.args.Castbar.args.castBarBorderSize.max = Gladdy.db.castBarHeight/2
            if Gladdy.db.castBarBorderSize > Gladdy.db.castBarHeight/2 then
                Gladdy.db.castBarBorderSize = Gladdy.db.castBarHeight/2
            end
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Castbar:GetOptions()
    return {
        headerCastbar = {
            type = "header",
            name = L["Cast Bar"],
            order = 2,
        },
        castBarHeight = option({
            type = "range",
            name = L["Bar height"],
            desc = L["Height of the bar"],
            order = 3,
            min = 0,
            max = 50,
            step = 1,
        }),
        castBarWidth = option({
            type = "range",
            name = L["Bar width"],
            desc = L["Width of the bars"],
            order = 4,
            min = 0,
            max = 300,
            step = 1,
        }),
        castBarBorderSize = option({
            type = "range",
            name = L["Border size"],
            order = 5,
            min = 0.5,
            max = Gladdy.db.castBarHeight/2,
            step = 0.5,
        }),
        castBarTexture = option({
            type = "select",
            name = L["Bar texture"],
            desc = L["Texture of the bar"],
            order = 9,
            dialogControl = "LSM30_Statusbar",
            values = AceGUIWidgetLSMlists.statusbar,
        }),
        castBarColor = Gladdy:colorOption({
            type = "color",
            name = L["Bar color"],
            desc = L["Color of the cast bar"],
            order = 10,
            hasAlpha = true,
        }),
        castBarBgColor = Gladdy:colorOption({
            type = "color",
            name = L["Background color"],
            desc = L["Color of the cast bar background"],
            order = 11,
            hasAlpha = true,
        }),
        --Icon
        headerIcon = {
            type = "header",
            name = L["Icon"],
            order = 20,
        },
        castBarIconSize = option({
            type = "range",
            name = L["Icon size"],
            order = 21,
            min = 0,
            max = 100,
            step = 1,
        }),
        --spark
        headerSpark = {
            type = "header",
            name = L["Spark"],
            order = 25,
        },
        castBarSparkEnabled = option({
            type = "toggle",
            name = L["Spark enabled"],
            order = 26,
        }),
        castBarSparkColor = Gladdy:colorOption({
            type = "color",
            name = L["Spark color"],
            desc = L["Color of the cast bar spark"],
            order = 27,
            hasAlpha = true,
        }),
        --position
        headerPosition = {
            type = "header",
            name = L["Position"],
            order = 30,
        },
        castBarPos = option({
            type = "select",
            name = L["Castbar position"],
            order = 31,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        castBarIconPos = option( {
            type = "select",
            name = L["Icon position"],
            order = 32,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        castBarXOffset = option({
            type = "range",
            name = L["Horizontal offset"],
            order = 33,
            min = -300,
            max = 300,
            step = 0.1,
        }),
        castBarYOffset = option({
            type = "range",
            name = L["Vertical offset"],
            order = 34,
            min = -300,
            max = 300,
            step = 0.1,
        }),
        --Font
        headerFont = {
            type = "header",
            name = L["Font"],
            order = 40,
        },
        castBarFont = option({
            type = "select",
            name = L["Font"],
            desc = L["Font of the castbar"],
            order = 41,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        castBarFontSize = option({
            type = "range",
            name = L["Font size"],
            desc = L["Size of the text"],
            order = 42,
            min = 1,
            max = 20,
        }),
        castBarFontColor = Gladdy:colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the text"],
            order = 43,
            hasAlpha = true,
        }),
        --Borders
        headerBorder = {
            type = "header",
            name = L["Borders"],
            order = 50,
        },
        castBarBorderStyle = option({
            type = "select",
            name = L["Status Bar border"],
            order = 51,
            dialogControl = "LSM30_Border",
            values = AceGUIWidgetLSMlists.border,
        }),
        castBarBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Status Bar border color"],
            order = 52,
            hasAlpha = true,
        }),
        castBarIconStyle = option({
            type = "select",
            name = L["Icon border"],
            order = 53,
            values = Gladdy:GetIconStyles(),
        }),
        castBarIconColor = Gladdy:colorOption({
            type = "color",
            name = L["Icon border color"],
            order = 54,
            hasAlpha = true,
        }),
    }
end