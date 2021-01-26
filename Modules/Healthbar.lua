local pairs = pairs
local floor = math.floor

local CreateFrame = CreateFrame
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AceGUIWidgetLSMlists = AceGUIWidgetLSMlists
local Healthbar = Gladdy:NewModule("Healthbar", 100, {
    healthBarHeight = 50,
    healthBarTexture = "Smooth",
    healthBarFontColor = {r = 1, g = 1, b = 1, a = 1},
    healthBarFontSize = 12,
    healthActual = false,
    healthMax = true,
    healthPercentage = true,
})

function Healthbar:Initialise()
    self.frames = {}

    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("UNIT_HEALTH")
    self:RegisterMessage("UNIT_DEATH")
end

function Healthbar:CreateFrame(unit)
	local button = Gladdy.buttons[unit]
    local healthBar = CreateFrame("StatusBar", nil, Gladdy.buttons[unit])
    healthBar:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.healthBarTexture))
    healthBar:SetMinMaxValues(0, 100)
	
	local healthBarBorder = CreateFrame("Frame", nil, healthBar)
    healthBarBorder:SetBackdrop({edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 13,
	insets = {left = 4, right = 4, top = 4, bottom = 4},})
    healthBarBorder:SetFrameStrata("HIGH")
	
	local classIconBarBorder = CreateFrame("Frame", nil, healthBar)
    classIconBarBorder:SetBackdrop({edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 30,
	insets = {left = 4, right = 4, top = 4, bottom = 4},})
    classIconBarBorder:SetFrameStrata("HIGH")
	
	local trinketBorder2 = CreateFrame("Frame", nil, healthBar)
    trinketBorder2:SetBackdrop({edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 30,
	insets = {left = 4, right = 4, top = 4, bottom = 4},})
    trinketBorder2:SetFrameStrata("HIGH")
	
   healthBar.bg = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.healthBarTexture))
    healthBar.bg:ClearAllPoints()
    healthBar.bg:SetAllPoints(healthBar)
    healthBar.bg:SetAlpha(1)
	healthBar.bg:SetVertexColor(0.7, 0.7, 0.7, 0.7)
	

    healthBar.nameText = healthBar:CreateFontString(nil, "LOW")
    if( Gladdy.db.healthBarFontSize < 1 ) then
    	healthBar.nameText:SetFont(Gladdy.LSM:Fetch("font"), 1)
    	healthBar.nameText:Hide()
    else
    	healthBar.nameText:SetFont(Gladdy.LSM:Fetch("font"), Gladdy.db.healthBarFontSize)
    	healthBar.nameText:Show()
    end
    healthBar.nameText:SetTextColor(Gladdy.db.healthBarFontColor.r, Gladdy.db.healthBarFontColor.g, Gladdy.db.healthBarFontColor.b, Gladdy.db.healthBarFontColor.a)
    healthBar.nameText:SetShadowOffset(1, -1)
    healthBar.nameText:SetShadowColor(0, 0, 0, 1)
    healthBar.nameText:SetJustifyH("CENTER")
    healthBar.nameText:SetPoint("LEFT", 5, 0)

    healthBar.healthText = healthBar:CreateFontString(nil, "LOW")
    if( Gladdy.db.healthBarFontSize < 1 ) then
    	healthBar.healthText:SetFont(Gladdy.LSM:Fetch("font"), 1)
    	healthBar.healthText:Hide()
    else
    	healthBar.healthText:SetFont(Gladdy.LSM:Fetch("font"), Gladdy.db.healthBarFontSize)
    	healthBar.healthText:Hide()
    end	
    healthBar.healthText:SetTextColor(Gladdy.db.healthBarFontColor.r, Gladdy.db.healthBarFontColor.g, Gladdy.db.healthBarFontColor.b, Gladdy.db.healthBarFontColor.a)
    healthBar.healthText:SetShadowOffset(1, -1)
    healthBar.healthText:SetShadowColor(0, 0, 0, 1)
    healthBar.healthText:SetJustifyH("CENTER")
    healthBar.healthText:SetPoint("RIGHT", -5, 0)
	
	button.trinketBorder2 = trinketBorder2
	button.classIconBarBorder = classIconBarBorder
	button.healthBarBorder = healthBarBorder
    self.frames[unit] = healthBar
    self:ResetUnit(unit)
end

function Healthbar:UpdateFrame(unit)
	local button = Gladdy.buttons[unit]
    local healthBar = self.frames[unit]
    if (not healthBar) then return end

    local iconSize = Gladdy.db.healthBarHeight + Gladdy.db.powerBarHeight

    healthBar:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.healthBarTexture))
    healthBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.healthBarTexture))

    healthBar:ClearAllPoints()
    healthBar:SetPoint("TOPLEFT", Gladdy.buttons[unit], "TOPLEFT", iconSize, 0)
    healthBar:SetPoint("BOTTOMRIGHT", Gladdy.buttons[unit], "BOTTOMRIGHT")
	
	button.healthBarBorder:SetWidth(184)
	button.healthBarBorder:SetHeight(54)
    button.healthBarBorder:ClearAllPoints()
    button.healthBarBorder:SetPoint("RIGHT", healthBar, "RIGHT", 2, 0)
    button.healthBarBorder:SetBackdropBorderColor(0, 0, 0, 1)
	
	button.classIconBarBorder:SetWidth(73)
	button.classIconBarBorder:SetHeight(78)
    button.classIconBarBorder:ClearAllPoints()
    button.classIconBarBorder:SetBackdropBorderColor(0, 0, 0, 1)
	
	button.trinketBorder2:SetWidth(70)
	button.trinketBorder2:SetHeight(75)
    button.trinketBorder2:ClearAllPoints()
    button.trinketBorder2:SetBackdropBorderColor(0, 0, 0, 1)
	
	if( Gladdy.db.classIconPos == "RIGHT" ) then
	button.classIconBarBorder:SetPoint("RIGHT", healthBar, "RIGHT", -180, -9)
	button.trinketBorder2:SetPoint("RIGHT", healthBar, "RIGHT", 73, -9)
	end
	if( Gladdy.db.classIconPos == "LEFT" ) then
	button.classIconBarBorder:SetPoint("RIGHT", healthBar, "RIGHT", 73, -9)
	button.trinketBorder2:SetPoint("RIGHT", healthBar, "RIGHT", 140, -9)
	end
	
	if(Gladdy.db.healthBarFontSize < 1) then
		healthBar.nameText:SetFont(Gladdy.LSM:Fetch("font"), 1)
	    healthBar.healthText:SetFont(Gladdy.LSM:Fetch("font"), 1)
	    healthBar.nameText:Hide()
	    healthBar.healthText:Hide()
	else
	    healthBar.nameText:SetFont(Gladdy.LSM:Fetch("font"), Gladdy.db.healthBarFontSize)
	    healthBar.nameText:Show()
	    healthBar.healthText:SetFont(Gladdy.LSM:Fetch("font"), Gladdy.db.healthBarFontSize)
	    healthBar.healthText:Show()
    end
    healthBar.nameText:SetTextColor(Gladdy.db.healthBarFontColor.r, Gladdy.db.healthBarFontColor.g, Gladdy.db.healthBarFontColor.b, Gladdy.db.healthBarFontColor.a)
    healthBar.healthText:SetTextColor(Gladdy.db.healthBarFontColor.r, Gladdy.db.healthBarFontColor.g, Gladdy.db.healthBarFontColor.b, Gladdy.db.healthBarFontColor.a)
end

function Healthbar:ResetUnit(unit)
    local healthBar = self.frames[unit]
    if (not healthBar) then return end

    healthBar:SetStatusBarColor(1, 1, 1, 1)
    healthBar.nameText:SetText("")
    healthBar.healthText:SetText("")
    healthBar:SetValue(0)
end

function Healthbar:Test(unit)
    local healthBar = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not healthBar or not button) then return end

    self:ENEMY_SPOTTED(unit)
    self:UNIT_HEALTH(unit, button.health, button.healthMax)
end

function Healthbar:ENEMY_SPOTTED(unit)
    local healthBar = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not healthBar or not button) then return end

    healthBar:SetStatusBarColor(RAID_CLASS_COLORS[button.class].r, RAID_CLASS_COLORS[button.class].g, RAID_CLASS_COLORS[button.class].b, 1)
    healthBar.nameText:SetText(button.name)
end

function Healthbar:UNIT_HEALTH(unit, health, healthMax)
    local healthBar = self.frames[unit]
    if (not healthBar) then return end

    local healthPercentage = floor(health * 100 / healthMax)
    local healthText

    if (Gladdy.db.healthActual) then
        healthText = healthMax > 999 and ("%.1fk"):format(health / 1000) or health
    end

    if (Gladdy.db.healthMax) then
        local text = healthMax > 999 and ("%.1fk"):format(healthMax / 1000) or healthMax
        if (healthText) then
            healthText = ("%s/%s"):format(healthText, text)
        else
            healthText = text
        end
    end

    if (Gladdy.db.healthPercentage) then
        if (healthText) then
            healthText = ("%s (%d%%)"):format(healthText, healthPercentage)
        else
            healthText = ("%d%%"):format(healthPercentage)
        end
    end

    healthBar.healthText:SetText(healthText)
    healthBar:SetValue(healthPercentage)
end

function Healthbar:UNIT_DEATH(unit)
    local healthBar = self.frames[unit]
    if (not healthBar) then return end

    healthBar:SetValue(0)
    healthBar.healthText:SetText(L["DEAD"])
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

function Healthbar:GetOptions()
    return {
        healthBarHeight = option({
            type = "range",
            name = L["Bar height"],
            desc = L["Height of the bar"],
            order = 2,
            min = 10,
            max = 50,
            step = 1,
        }),
        healthBarTexture = option({
            type = "select",
            name = L["Bar texture"],
            desc = L["Texture of the bar"],
            order = 3,
            dialogControl = "LSM30_Statusbar",
            values = AceGUIWidgetLSMlists.statusbar,
        }),
        healthBarFontColor = colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the text"],
            order = 4,
            hasAlpha = true,
        }),
        healthBarFontSize = option({
            type = "range",
            name = L["Font size"],
            desc = L["Size of the text"],
            order = 5,
            min = 0,
            max = 20,
        }),
        healthActual = option({
            type = "toggle",
            name = L["Show the actual health"],
            desc = L["Show the actual health on the health bar"],
            order = 6,
        }),
        healthMax = option({
            type = "toggle",
            name = L["Show max health"],
            desc = L["Show max health on the health bar"],
            order = 7,
        }),
        healthPercentage = option({
            type = "toggle",
            name = L["Show health percentage"],
            desc = L["Show health percentage on the health bar"],
            order = 8,
        }),
    }
end