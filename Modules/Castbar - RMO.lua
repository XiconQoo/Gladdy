local pairs = pairs

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AceGUIWidgetLSMlists = AceGUIWidgetLSMlists
local Castbar = Gladdy:NewModule("Castbar", 70, {
    castBarHeight = 20,
    castBarTexture = "Smooth",
    castBarFontColor = {r = 1, g = 1, b = 1, a = 1},
    castBarFontSize = 12,
    castBarColor = {r = 1, g = 0.8, b = 0.2, a = 1},
    castBarBgColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.7},
    castBarGuesses = true,
})

function Castbar:Initialise()
    self.frames = {}

    self:RegisterMessage("CAST_START")
    self:RegisterMessage("CAST_STOP")
    self:RegisterMessage("UNIT_DEATH", "CAST_STOP")
end

function Castbar:CreateFrame(unit)
	local button = Gladdy.buttons[unit]
    local castBar = CreateFrame("StatusBar", nil, Gladdy.buttons[unit])
    castBar:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.castBarTexture))
    castBar:SetStatusBarColor(Gladdy.db.castBarColor.r, Gladdy.db.castBarColor.g, Gladdy.db.castBarColor.b, Gladdy.db.castBarColor.a)
    castBar:SetMinMaxValues(0, 100)
	local castBarBorder = CreateFrame("Frame", nil, castBar)
    castBarBorder:SetBackdrop({edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 23,
	insets = {left = 4, right = 4, top = 4, bottom = 4},})
    castBarBorder:SetFrameStrata("HIGH")
    castBarBorder:Hide()
    castBar:SetScript("OnUpdate", function(self, elapsed)
        if (self.isCasting) then
            if (self.value >= self.maxValue) then
                Castbar:CAST_STOP(unit)
            else
                self.value = self.value + elapsed
                self:SetValue(self.value)
                self.timeText:SetFormattedText("%.1f", self.value)
            end
        elseif (self.isChanneling) then
            if (self.value <= 0) then
                Castbar:CAST_STOP(unit)
            else
                self.value = self.value - elapsed
                self:SetValue(self.value)
                self.timeText:SetFormattedText("%.1f", self.value)
            end
        end
    end)

	castBar.bg = castBar:CreateTexture(nil, "BACKGROUND")
    castBar.bg:SetAlpha(1)
	castBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.castBarTexture))
    castBar.bg:SetVertexColor(Gladdy.db.castBarBgColor.r, Gladdy.db.castBarBgColor.g, Gladdy.db.castBarBgColor.b, Gladdy.db.castBarBgColor.a)
	


    castBar.icon = castBar:CreateTexture(nil)
    castBar.icon:ClearAllPoints()
    castBar.icon:SetPoint("RIGHT", castBar, "LEFT", -8, 0) -- Icon of castbar
    castBar.icon:SetTexCoord(0, 1, 0, 1)

    castBar.spellText = castBar:CreateFontString(nil, "LOW")
    castBar.spellText:SetFont(Gladdy.LSM:Fetch("font"), Gladdy.db.castBarFontSize)
    castBar.spellText:SetTextColor(Gladdy.db.castBarFontColor.r, Gladdy.db.castBarFontColor.g, Gladdy.db.castBarFontColor.b, Gladdy.db.castBarFontColor.a)
    castBar.spellText:SetShadowOffset(1, -1)
    castBar.spellText:SetShadowColor(0, 0, 0, 1)
    castBar.spellText:SetJustifyH("CENTER")
    castBar.spellText:SetPoint("LEFT", 7, 1) -- Text of the spell

    castBar.timeText = castBar:CreateFontString(nil, "LOW")
    castBar.timeText:SetFont(Gladdy.LSM:Fetch("font"), Gladdy.db.castBarFontSize)
    castBar.timeText:SetTextColor(Gladdy.db.castBarFontColor.r, Gladdy.db.castBarFontColor.g, Gladdy.db.castBarFontColor.b, Gladdy.db.castBarFontColor.a)
    castBar.timeText:SetShadowOffset(1, -1)
    castBar.timeText:SetShadowColor(0, 0, 0, 1)
    castBar.timeText:SetJustifyH("CENTER")
    castBar.timeText:SetPoint("RIGHT", -4, 1) -- text of cast timer
	
	button.castBarBorder = castBarBorder
    self.frames[unit] = castBar
    self:ResetUnit(unit)
end

function Castbar:UpdateFrame(unit)
	local button = Gladdy.buttons[unit]
    local castBar = self.frames[unit]
    if (not castBar) then return end

    local healthBar = Gladdy.modules.Healthbar.frames[unit]
    local classIcon = Gladdy.modules.Classicon.frames[unit]
    local iconSize = Gladdy.db.healthBarHeight + Gladdy.db.powerBarHeight
	
	castBar.bg:SetWidth(160)
    castBar.bg:SetHeight(18)
	castBar.bg:ClearAllPoints()
    castBar.bg:SetPoint("RIGHT", castBar, "RIGHT", 0, 0)
   
    castBar:SetWidth(160)
    castBar:SetHeight(18)
	
	button.castBarBorder:SetWidth(175)
	button.castBarBorder:SetHeight(28)
    button.castBarBorder:ClearAllPoints()
    button.castBarBorder:SetPoint("RIGHT", castBar, "RIGHT", 8, 0)
    button.castBarBorder:SetBackdropBorderColor(0, 0, 0, 1)

	
    castBar.icon:SetWidth(32)
    castBar.icon:SetHeight(32)

    castBar:ClearAllPoints()
	if( Gladdy.db.classIconPos == "LEFT" ) then
    castBar:SetPoint("TOPLEFT", classIcon, "BOTTOMLEFT", Gladdy.db.castBarHeight + -377, 58) -- move all (icon, text and castbar)
	end
	if( Gladdy.db.classIconPos == "RIGHT" ) then
	castBar:SetPoint("TOPLEFT", classIcon, "BOTTOMLEFT", Gladdy.db.castBarHeight + -187, 50)
	end

    castBar.spellText:SetFont(Gladdy.LSM:Fetch("font"), Gladdy.db.castBarFontSize)
    castBar.spellText:SetTextColor(Gladdy.db.castBarFontColor.r, Gladdy.db.castBarFontColor.g, Gladdy.db.castBarFontColor.b, Gladdy.db.castBarFontColor.a)
    castBar.timeText:SetFont(Gladdy.LSM:Fetch("font"), Gladdy.db.castBarFontSize)
    castBar.timeText:SetTextColor(Gladdy.db.castBarFontColor.r, Gladdy.db.castBarFontColor.g, Gladdy.db.castBarFontColor.b, Gladdy.db.castBarFontColor.a)
end

function Castbar:ResetUnit(unit)
    self:CAST_STOP(unit)
end

function Castbar:Test(unit)
    local spell, _, icon, value, maxValue, event

    if (unit == "arena2") then
        spell, _, icon = GetSpellInfo(27072)
        value, maxValue, event = 0, 2.5, "cast"
    elseif (unit == "arena4") then
        spell, _, icon = GetSpellInfo(27220)
        value, maxValue, event = 5, 5, "channel"
    elseif (unit == "arena5") then
        spell, _, icon = GetSpellInfo(20770)
        value, maxValue, event = 0, 10, "cast"
    end

    if (spell) then
        self:CAST_START(unit, spell, icon, value, maxValue, event)
    end
end

function Castbar:CAST_START(unit, spell, icon, value, maxValue, event)
	local button = Gladdy.buttons[unit]
    local castBar = self.frames[unit]
    if (not castBar) then return end

    castBar.value = value
    castBar.maxValue = maxValue
    castBar:SetMinMaxValues(0, maxValue)
    castBar:SetValue(value)
    castBar.icon:SetTexture(icon)
    castBar.spellText:SetText(spell)
    castBar.timeText:SetText(maxValue)
    castBar.isCasting = event == "cast"
    castBar.isChanneling = event == "channel"
	castBar.bg:Show()
	button.castBarBorder:Show()
end

function Castbar:CAST_STOP(unit)
    local castBar = self.frames[unit]
	local button = Gladdy.buttons[unit]
    if (not castBar) then return end

    castBar.isCasting = false
    castBar.isChanneling = false
    castBar.value = 0
    castBar.maxValue = 0
    castBar.icon:SetTexture("")
    castBar.spellText:SetText("")
    castBar.timeText:SetText("")
    castBar:SetValue(0)
	castBar.bg:Hide()
	button.castBarBorder:Hide()
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
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

local function colorOption(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile[key].r, Gladdy.dbi.profile[key].g, Gladdy.dbi.profile[key].b, Gladdy.dbi.profile[key].a
        end,
        set = function(info, r, g, b ,a)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile[key].r, Gladdy.dbi.profile[key].g, Gladdy.dbi.profile[key].b, Gladdy.dbi.profile[key].a = r, g, b, a
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
        castBarGuesses = option({
            type = "toggle",
            name = L["Castbar guesses on/off"],
            desc = L["If disabled, castbars will stop as soon as you lose your 'unit', e.g. mouseover or your party targeting someone else."
            .."\nDisable this, if you see castbars, even though the player isn't casting."],
            order = 2,
        }),
        castBarHeight = option({
            type = "range",
            name = L["Bar height"],
            desc = L["Height of the bar"],
            order = 3,
            min = 0,
            max = 50,
            step = 1,
        }),
        castBarFontSize = option({
            type = "range",
            name = L["Font size"],
            desc = L["Size of the text"],
            order = 4,
            min = 1,
            max = 20,
        }),
        castBarTexture = option({
            type = "select",
            name = L["Bar texture"],
            desc = L["Texture of the bar"],
            order = 5,
            dialogControl = "LSM30_Statusbar",
            values = AceGUIWidgetLSMlists.statusbar,
        }),
        castBarFontColor = colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the text"],
            order = 6,
            hasAlpha = true,
        }),
        castBarColor = colorOption({
            type = "color",
            name = L["Bar color"],
            desc = L["Color of the cast bar"],
            order = 7,
            hasAlpha = true,
        }),
        castBarBgColor = colorOption({
            type = "color",
            name = L["Background color"],
            desc = L["Color of the cast bar background"],
            order = 8,
            hasAlpha = true,
        }),
    }
end