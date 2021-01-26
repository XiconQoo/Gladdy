local unpack = unpack

local CLASS_BUTTONS = CLASS_BUTTONS

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Classicon = Gladdy:NewModule("Classicon", 80, {
    classIconPos = "LEFT"
})

function Classicon:Initialise()
    self.frames = {}

    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("UNIT_DEATH")
end

function Classicon:CreateFrame(unit)
    local classIcon = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    classIcon:SetFrameStrata("LOW")
    classIcon.texture = classIcon:CreateTexture(nil, "BACKGROUND")
    classIcon.texture:SetAllPoints(classIcon)
    classIcon:ClearAllPoints()
    if( Gladdy.db.classIconPos == "RIGHT" ) then
	    classIcon:SetPoint("TOPLEFT", Gladdy.buttons[unit].healthBar, "TOPRIGHT", 2, 2)
	else
		classIcon:SetPoint("TOPRIGHT", Gladdy.buttons[unit].healthBar, "TOPLEFT", -2, 2)
    end

    classIcon.border = CreateFrame("Frame", nil, classIcon)
    classIcon.border:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                           edgeSize = 24})
    classIcon.border:SetPoint("CENTER", classIcon, "CENTER", 0, 0)

    Gladdy.buttons[unit].classIcon = classIcon
    self.frames[unit] = classIcon
end

function Classicon:UpdateFrame(unit)
    local classIcon = self.frames[unit]
    if (not classIcon) then return end

    local iconSize = Gladdy.db.healthBarHeight + Gladdy.db.powerBarHeight

    classIcon:SetWidth(iconSize - iconSize*0.1)
    classIcon:SetHeight(iconSize)
    classIcon:ClearAllPoints()
    if( Gladdy.db.classIconPos == "LEFT" ) then
	    classIcon:SetPoint("TOPRIGHT", Gladdy.buttons[unit].healthBar, "TOPLEFT", -Gladdy.db.padding, 2)
	else
		classIcon:SetPoint("TOPLEFT", Gladdy.buttons[unit], "TOPRIGHT", Gladdy.db.padding, 2)
    end
    classIcon:SetFrameStrata("LOW")
    classIcon:SetFrameLevel(1)

    classIcon.texture:ClearAllPoints()
    classIcon.texture:SetAllPoints(classIcon)

    classIcon.border:SetWidth((iconSize - iconSize*0.1))
    classIcon.border:SetHeight(iconSize)
    classIcon.border:SetFrameStrata("LOW")
    classIcon.border:SetFrameLevel(2)
    classIcon.border:ClearAllPoints()
    classIcon.border:SetPoint("CENTER", classIcon, "CENTER", 0, 0)
    classIcon.border:SetBackdropBorderColor(0, 0, 0, 1)
end

function Classicon:Test(unit)
    self:ENEMY_SPOTTED(unit)
end

function Classicon:ResetUnit(unit)
    local classIcon = self.frames[unit]
    if (not classIcon) then return end

    classIcon.texture:SetTexture("")
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

function Classicon:GetOptions()
    return {
    	classIconPos = option({
            type = "select",
            name = L["Icon position"],
            desc = L["This changes positions with trinket"],
            order = 2,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        })
    }
end

local function getClassIcon(class)
    -- see https://wow.gamepedia.com/Class_icon
    local classIcon = "Interface\\Icons\\"
    if class == "DRUID" then
        return classIcon.."inv_misc_monsterclaw_04"
    elseif class == "HUNTER" then
        return classIcon.."inv_weapon_bow_07"
    elseif class == "MAGE" then
        return classIcon.."inv_staff_13"
    elseif class == "PALADIN" then
        return classIcon.."inv_hammer_01"
    elseif class == "PRIEST" then
        return classIcon.."inv_staff_30"
    elseif class == "ROGUE" then
        return classIcon.."inv_throwingknife_04"
    elseif class == "SHAMAN" then
        return classIcon.."inv_jewelry_talisman_04"
    elseif class == "WARLOCK" then
        return classIcon.."spell_nature_drowsy"
    elseif class == "WARRIOR" then
        return classIcon.."inv_sword_27"
    end
end

function Classicon:ENEMY_SPOTTED(unit)
    local classIcon = self.frames[unit]
    if (not classIcon) then return end

    classIcon.texture:SetTexture(getClassIcon(Gladdy.buttons[unit].class))
    --classIcon.texture:SetTexCoord(unpack(CLASS_BUTTONS[Gladdy.buttons[unit].class]))
    classIcon.texture:SetAllPoints(classIcon)
end