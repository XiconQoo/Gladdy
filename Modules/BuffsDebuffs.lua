

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local BuffsDebuffs = Gladdy:NewModule("BuffsDebuffs", nil, {
    buffsEnabled = true,
    buffsBorderColor = {r = 0, g = 0, b = 0, a = 1},
    buffsFontColor = {r = 0, g = 0, b = 0, a = 1},
})

function BuffsDebuffs:OnEvent(event, ...)
    self[event](self, ...)
end

function BuffsDebuffs:Initialise()
    self.frames = {}
    self.spells = {}
    self.icons = {}

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:SetScript("OnEvent", BuffsDebuffs.OnEvent)
end

function BuffsDebuffs:COMBAT_LOG_EVENT_UNFILTERED(...)

end

function BuffsDebuffs:CreateFrame(unit)

end

function BuffsDebuffs:UpdateFrame(unit)

end

function BuffsDebuffs:ResetUnit(unit)

end

function BuffsDebuffs:Test(unit)

end

function BuffsDebuffs:GetOptions()
    return {
        headerDiminishings = {
            type = "header",
            name = L["Buffs and Debuffs"],
            order = 2,
        },
        buffsEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enable"],
            desc = L["Enabled Buffs and Debuffs module"],
            order = 3,
        }),
        buffsIconSize = Gladdy:option({
            type = "range",
            name = L["Icon Size"],
            desc = L["Size of the DR Icons"],
            order = 4,
            min = 5,
            max = 50,
            step = 1,
        }),
        buffsDisableCircle = Gladdy:option({
            type = "toggle",
            name = L["No Cooldown Circle"],
            order = 5,
        }),
        buffsCooldownAlpha = Gladdy:option({
            type = "range",
            name = L["Cooldown circle alpha"],
            min = 0,
            max = 1,
            step = 0.1,
            order = 6,
        }),
        headerFont = {
            type = "header",
            name = L["Font"],
            order = 10,
        },
        buffsFont = Gladdy:option({
            type = "select",
            name = L["Font"],
            desc = L["Font of the cooldown"],
            order = 11,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        buffsFontColor = Gladdy:colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the text"],
            order = 13,
            hasAlpha = true,
        }),
        buffsFontScale = Gladdy:option({
            type = "range",
            name = L["Font scale"],
            desc = L["Scale of the text"],
            order = 12,
            min = 0.1,
            max = 2,
            step = 0.1,
        }),
        headerPosition = {
            type = "header",
            name = L["Position"],
            order = 20,
        },
        buffsCooldownPos = Gladdy:option({
            type = "select",
            name = L["DR Cooldown position"],
            desc = L["Position of the cooldown icons"],
            order = 21,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        buffsXOffset = Gladdy:option({
            type = "range",
            name = L["Horizontal offset"],
            order = 22,
            min = -300,
            max = 300,
            step = 0.1,
        }),
        buffsYOffset = Gladdy:option({
            type = "range",
            name = L["Vertical offset"],
            order = 23,
            min = -300,
            max = 300,
            step = 0.1,
        }),
        headerBorder = {
            type = "header",
            name = L["Border"],
            order = 30,
        },
        buffsBorderStyle = Gladdy:option({
            type = "select",
            name = L["Border style"],
            order = 31,
            values = Gladdy:GetIconStyles()
        }),
        buffsBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Border color"],
            desc = L["Color of the border"],
            order = 32,
            hasAlpha = true,
        }),
    }
end