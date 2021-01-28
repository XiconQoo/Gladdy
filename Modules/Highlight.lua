local pairs = pairs

local CreateFrame = CreateFrame

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Highlight = Gladdy:NewModule("Highlight", nil, {
    highlightBorderSize = 3,
    targetBorderColor = { r = 1, g = 0.8, b = 0, a = 1 },
    focusBorderColor = { r = 1, g = 0, b = 0, a = 1 },
    leaderBorderColor = { r = 0, g = 1, b = 0, a = 1 },
    highlight = true,
    targetBorder = true,
    focusBorder = true,
    leaderBorder = true,
})

function Highlight:CreateFrame(unit)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    local healthBar = Gladdy.modules.Healthbar.frames[unit]

    local targetBorder = CreateFrame("Frame", nil, button)
    targetBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = Gladdy.db.highlightBorderSize })
    targetBorder:SetFrameStrata("HIGH")
    targetBorder:Hide()

    local focusBorder = CreateFrame("Frame", nil, button)
    focusBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = Gladdy.db.highlightBorderSize })
    focusBorder:SetFrameStrata("LOW")
    focusBorder:Hide()

    local leaderBorder = CreateFrame("Frame", nil, button)
    leaderBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = Gladdy.db.highlightBorderSize })
    leaderBorder:SetFrameStrata("MEDIUM")
    leaderBorder:Hide()

    local highlight = healthBar:CreateTexture(nil, "OVERLAY")
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.5)
    highlight:ClearAllPoints()
    highlight:SetAllPoints(healthBar)
    highlight:Hide()

    button.targetBorder = targetBorder
    button.focusBorder = focusBorder
    button.leaderBorder = leaderBorder
    button.highlight = highlight
end

function Highlight:UpdateFrame(unit)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    local borderSize = Gladdy.db.highlightBorderSize
    local iconSize = Gladdy.db.healthBarHeight + Gladdy.db.powerBarHeight
    local width = Gladdy.db.barWidth + borderSize * 2
    local height = iconSize + borderSize * 2

    button.targetBorder:SetWidth(width)
    button.targetBorder:SetHeight(height)
    button.targetBorder:ClearAllPoints()
    button.targetBorder:SetPoint("TOP", button.healthBar, "TOP", 0, borderSize)
    button.targetBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = borderSize })
    button.targetBorder:SetBackdropBorderColor(Gladdy.db.targetBorderColor.r, Gladdy.db.targetBorderColor.g, Gladdy.db.targetBorderColor.b, Gladdy.db.targetBorderColor.a)

    button.focusBorder:SetWidth(width)
    button.focusBorder:SetHeight(height)
    button.focusBorder:ClearAllPoints()
    button.focusBorder:SetPoint("TOP", button.healthBar, "TOP", 0, borderSize)
    button.focusBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = borderSize })
    button.focusBorder:SetBackdropBorderColor(Gladdy.db.focusBorderColor.r, Gladdy.db.focusBorderColor.g, Gladdy.db.focusBorderColor.b, Gladdy.db.focusBorderColor.a)

    button.leaderBorder:SetWidth(width)
    button.leaderBorder:SetHeight(height)
    button.leaderBorder:ClearAllPoints()
    button.leaderBorder:SetPoint("TOP", button.healthBar, "TOP", 0, borderSize)
    button.leaderBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = borderSize })
    button.leaderBorder:SetBackdropBorderColor(Gladdy.db.leaderBorderColor.r, Gladdy.db.leaderBorderColor.g, Gladdy.db.leaderBorderColor.b, Gladdy.db.leaderBorderColor.a)
end

function Highlight:ResetUnit(unit)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    button.targetBorder:Hide()
    button.focusBorder:Hide()
    button.leaderBorder:Hide()
    button.highlight:Hide()
end

function Highlight:Test(unit)
    if (unit == "arena1") then
        self:Toggle(unit, "focus", true)
    elseif (unit == "arena2") then
        self:Toggle(unit, "target", true)
    elseif (unit == "arena4") then
        self:Toggle(unit, "leader", true)
    end
end

function Highlight:Toggle(unit, frame, show)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    if (frame == "target") then
        if (Gladdy.db.targetBorder and show) then
            button.targetBorder:Show()
        else
            button.targetBorder:Hide()
        end

        if (Gladdy.db.highlight and show) then
            button.highlight:Show()
        else
            button.highlight:Hide()
        end
    elseif (frame == "focus") then
        if (Gladdy.db.focusBorder and show) then
            button.focusBorder:Show()
        else
            button.focusBorder:Hide()
        end
    elseif (frame == "leader") then
        if (Gladdy.db.leaderBorder and show) then
            button.leaderBorder:Show()
        else
            button.leaderBorder:Hide()
        end
    end
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
        set = function(info, r, g, b, a)
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

function Highlight:GetOptions()
    return {
        highlightBorderSize = {
            type = "range",
            name = L["Border size"],
            desc = L["Border size"],
            order = 2,
            min = 1,
            max = 10,
            step = 1,
        },
        targetBorderColor = colorOption({
            type = "color",
            name = L["Target border color"],
            desc = L["Color of the selected targets border"],
            order = 3,
        }),
        focusBorderColor = colorOption({
            type = "color",
            name = L["Focus border color"],
            desc = L["Color of the focus border"],
            order = 4,
        }),
        leaderBorderColor = colorOption({
            type = "color",
            name = L["Raid leader border color"],
            desc = L["Color of the raid leader border"],
            order = 5,
        }),
        highlight = option({
            type = "toggle",
            name = L["Highlight target"],
            desc = L["Toggle if the selected target should be highlighted"],
            order = 6,
        }),
        targetBorder = option({
            type = "toggle",
            name = L["Show border around target"],
            desc = L["Toggle if a border should be shown around the selected target"],
            order = 7,
        }),
        focusBorder = option({
            type = "toggle",
            name = L["Show border around focus"],
            desc = L["Toggle of a border should be shown around the current focus"],
            order = 9,
        }),
        leaderBorder = option({
            type = "toggle",
            name = L["Show border around raid leader"],
            desc = L["Toggle if a border should be shown around the raid leader"],
            order = 9,
        }),
    }
end