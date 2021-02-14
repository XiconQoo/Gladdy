local pairs = pairs
local floor = math.floor

local CreateFrame = CreateFrame

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AceGUIWidgetLSMlists = AceGUIWidgetLSMlists
local Powerbar = Gladdy:NewModule("Powerbar", 90, {
    powerBarFont = "DorisPP",
    powerBarHeight = 20,
    powerBarTexture = "Smooth",
    powerBarBorder = "Interface\\AddOns\\Gladdy\\Images\\UI-Tooltip-Border_round_selfmade",
    powerBarBorderSize = 9,
    powerBarBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    powerBarFontColor = { r = 1, g = 1, b = 1, a = 1 },
    powerBarBgColor = { r = 0.3, g = 0.3, b = 0.3, a = 0.7 },
    powerBarFontSize = 10,
    powerActual = true,
    powerMax = true,
    powerPercentage = false,
})

function Powerbar:Initialise()
    self.frames = {}

    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("UNIT_SPEC")
    self:RegisterMessage("UNIT_POWER")
    self:RegisterMessage("UNIT_DEATH")
end

function Powerbar:CreateFrame(unit)
    local button = Gladdy.buttons[unit]

    local powerBar = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    powerBar:SetBackdrop({ edgeFile = Gladdy.db.powerBarBorder,
                                  edgeSize = Gladdy.db.powerBarBorderSize })
    powerBar:SetBackdropBorderColor(Gladdy.db.powerBarBorderColor.r, Gladdy.db.powerBarBorderColor.g, Gladdy.db.powerBarBorderColor.b, Gladdy.db.powerBarBorderColor.a)
    powerBar:SetFrameLevel(1)

    powerBar.energy = CreateFrame("StatusBar", nil, powerBar)
    powerBar.energy:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.powerBarTexture))
    powerBar.energy:SetMinMaxValues(0, 100)
    powerBar.energy:SetFrameLevel(0)

    powerBar.bg = powerBar.energy:CreateTexture(nil, "BACKGROUND")
    powerBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.powerBarTexture))
    powerBar.bg:ClearAllPoints()
    powerBar.bg:SetAllPoints(powerBar.energy)
    powerBar.bg:SetVertexColor(Gladdy.db.powerBarBgColor.r, Gladdy.db.powerBarBgColor.g, Gladdy.db.powerBarBgColor.b, Gladdy.db.powerBarBgColor.a)

    powerBar.raceText = powerBar:CreateFontString(nil, "LOW")
    powerBar.raceText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.powerBarFont), Gladdy.db.powerBarFontSize)
    powerBar.raceText:SetTextColor(Gladdy.db.powerBarFontColor.r, Gladdy.db.powerBarFontColor.g, Gladdy.db.powerBarFontColor.b, Gladdy.db.powerBarFontColor.a)
    powerBar.raceText:SetShadowOffset(1, -1)
    powerBar.raceText:SetShadowColor(0, 0, 0, 1)
    powerBar.raceText:SetJustifyH("CENTER")
    powerBar.raceText:SetPoint("LEFT", 5, 1)

    powerBar.powerText = powerBar:CreateFontString(nil, "LOW")
    powerBar.powerText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.powerBarFont), Gladdy.db.powerBarFontSize)
    powerBar.powerText:SetTextColor(Gladdy.db.powerBarFontColor.r, Gladdy.db.powerBarFontColor.g, Gladdy.db.powerBarFontColor.b, Gladdy.db.powerBarFontColor.a)
    powerBar.powerText:SetShadowOffset(1, -1)
    powerBar.powerText:SetShadowColor(0, 0, 0, 1)
    powerBar.powerText:SetJustifyH("CENTER")
    powerBar.powerText:SetPoint("RIGHT", -5, 1)

    button.powerBar = powerBar
    self.frames[unit] = powerBar
    self:ResetUnit(unit)
end

function Powerbar:UpdateFrame(unit)
    local powerBar = self.frames[unit]
    if (not powerBar) then
        return
    end

    local healthBar = Gladdy.modules.Healthbar.frames[unit]


    powerBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.powerBarTexture))
    powerBar.bg:SetVertexColor(Gladdy.db.powerBarBgColor.r, Gladdy.db.powerBarBgColor.g, Gladdy.db.powerBarBgColor.b, Gladdy.db.powerBarBgColor.a)

    powerBar:SetWidth(healthBar:GetWidth())
    powerBar:SetHeight(Gladdy.db.powerBarHeight)

    powerBar:ClearAllPoints()
    powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)

    powerBar:SetBackdrop({ edgeFile = Gladdy.db.powerBarBorder,
                                  edgeSize = Gladdy.db.powerBarBorderSize })
    powerBar:SetBackdropBorderColor(Gladdy.db.powerBarBorderColor.r, Gladdy.db.powerBarBorderColor.g, Gladdy.db.powerBarBorderColor.b, Gladdy.db.powerBarBorderColor.a)

    powerBar.energy:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.powerBarTexture))
    powerBar.energy:ClearAllPoints()
    powerBar.energy:SetPoint("TOPLEFT", powerBar, "TOPLEFT", (Gladdy.db.powerBarBorderSize/7), -(Gladdy.db.powerBarBorderSize/7))
    powerBar.energy:SetPoint("BOTTOMRIGHT", powerBar, "BOTTOMRIGHT", -(Gladdy.db.powerBarBorderSize/7), (Gladdy.db.powerBarBorderSize/7))

    powerBar.raceText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.powerBarFont), Gladdy.db.powerBarFontSize)
    powerBar.raceText:SetTextColor(Gladdy.db.powerBarFontColor.r, Gladdy.db.powerBarFontColor.g, Gladdy.db.powerBarFontColor.b, Gladdy.db.powerBarFontColor.a)
    powerBar.powerText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.powerBarFont), Gladdy.db.powerBarFontSize)
    powerBar.powerText:SetTextColor(Gladdy.db.powerBarFontColor.r, Gladdy.db.powerBarFontColor.g, Gladdy.db.powerBarFontColor.b, Gladdy.db.powerBarFontColor.a)
end

function Powerbar:ResetUnit(unit)
    local powerBar = self.frames[unit]
    if (not powerBar) then
        return
    end

    powerBar.energy:SetStatusBarColor(1, 1, 1, 1)
    powerBar.raceText:SetText("")
    powerBar.powerText:SetText("")
    powerBar.energy:SetValue(0)
end

function Powerbar:Test(unit)
    local powerBar = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not powerBar or not button) then
        return
    end

    self:ENEMY_SPOTTED(unit)
    self:UNIT_POWER(unit, button.power, button.powerMax, button.powerType)
end

function Powerbar:ENEMY_SPOTTED(unit)
    local powerBar = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not powerBar or not button) then
        return
    end

    local raceText = button.raceLoc

    if (button.spec) then
        raceText = button.spec .. " " .. raceText
    end

    powerBar.raceText:SetText(raceText)
end

function Powerbar:UNIT_SPEC(unit, spec)
    local powerBar = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not powerBar or not button) then
        return
    end

    powerBar.raceText:SetText(spec .. " " .. button.raceLoc)
end

function Powerbar:UNIT_POWER(unit, power, powerMax, powerType)
    local powerBar = self.frames[unit]
    if (not powerBar) then
        return
    end

    local powerPercentage = floor(power * 100 / powerMax)
    local powerText

    if (Gladdy.db.powerActual) then
        powerText = powerMax > 999 and ("%.1fk"):format(power / 1000) or power
    end

    if (Gladdy.db.powerMax) then
        local text = powerMax > 999 and ("%.1fk"):format(powerMax / 1000) or powerMax
        if (powerText) then
            powerText = ("%s/%s"):format(powerText, text)
        else
            powerText = text
        end
    end

    if (Gladdy.db.powerPercentage) then
        if (powerText) then
            powerText = ("%s (%d%%)"):format(powerText, powerPercentage)
        else
            powerText = ("%d%%"):format(powerPercentage)
        end
    end

    if (powerType == 1) then
        powerBar.energy:SetStatusBarColor(1, 0, 0, 1)
    elseif (powerType == 3) then
        powerBar.energy:SetStatusBarColor(1, 1, 0, 1)
    else
        powerBar.energy:SetStatusBarColor(.18, .44, .75, 1)
    end

    powerBar.powerText:SetText(powerText)
    powerBar.energy:SetValue(powerPercentage)
end

function Powerbar:UNIT_DEATH(unit)
    local powerBar = self.frames[unit]
    if (not powerBar) then
        return
    end

    powerBar.energy:SetValue(0)
    powerBar.powerText:SetText("0%")
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
            Gladdy.options.args.Powerbar.args.powerBarBorderSize.max = Gladdy.db.powerBarHeight/2
            if Gladdy.db.powerBarBorderSize > Gladdy.db.powerBarHeight/2 then
                Gladdy.db.powerBarBorderSize = Gladdy.db.powerBarHeight/2
            end
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Powerbar:GetOptions()
    return {
        headerPowerbar = {
            type = "header",
            name = L["Power Bar"],
            order = 2,
        },
        powerBarHeight = option({
            type = "range",
            name = L["Bar height"],
            desc = L["Height of the bar"],
            order = 3,
            min = 0,
            max = 50,
            step = 1,
        }),
        powerBarTexture = option({
            type = "select",
            name = L["Bar texture"],
            desc = L["Texture of the bar"],
            order = 4,
            dialogControl = "LSM30_Statusbar",
            values = AceGUIWidgetLSMlists.statusbar,
        }),
        powerBarBgColor = Gladdy:colorOption({
            type = "color",
            name = L["Background color"],
            desc = L["Color of the status bar background"],
            order = 5,
            hasAlpha = true,
        }),
        headerFont = {
            type = "header",
            name = L["Font"],
            order = 10,
        },
        powerBarFont = option({
            type = "select",
            name = L["Font"],
            desc = L["Font of the bar"],
            order = 11,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        powerBarFontColor = Gladdy:colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the text"],
            order = 12,
            hasAlpha = true,
        }),
        powerBarFontSize = option({
            type = "range",
            name = L["Font size"],
            desc = L["Size of the text"],
            order = 13,
            min = 1,
            max = 20,
        }),
        headerBorder = {
            type = "header",
            name = L["Border"],
            order = 20,
        },
        powerBarBorder= option({
            type = "select",
            name = L["Border style"],
            order = 21,
            values = Gladdy:GetBorderStyles()
        }),
        powerBarBorderSize = option({
            type = "range",
            name = L["Border size"],
            desc = L["Size of the border"],
            order = 22,
            min = 0.5,
            max = Gladdy.db.powerBarHeight/2,
            step = 0.5,
        }),
        powerBarBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Border color"],
            desc = L["Color of the border"],
            order = 23,
            hasAlpha = true,
        }),
        headerPowerValues = {
            type = "header",
            name = L["Power Values"],
            order = 30,
        },
        powerActual = option({
            type = "toggle",
            name = L["Show the actual power"],
            desc = L["Show the actual power on the power bar"],
            order = 31,
        }),
        powerMax = option({
            type = "toggle",
            name = L["Show max power"],
            desc = L["Show max power on the power bar"],
            order = 32,
        }),
        powerPercentage = option({
            type = "toggle",
            name = L["Show power percentage"],
            desc = L["Show power percentage on the power bar"],
            order = 33,
        }),
    }
end