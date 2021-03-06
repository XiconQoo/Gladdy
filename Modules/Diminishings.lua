local max = math.max
local select = select
local pairs,unpack = pairs, unpack

local drDuration = 18

local GetSpellInfo = GetSpellInfo
local CreateFrame = CreateFrame
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local DRData = LibStub("DRData-1.0")
local L = Gladdy.L
local Diminishings = Gladdy:NewModule("Diminishings", nil, {
    drFont = "DorisPP",
    drFontColor = { r = 1, g = 1, b = 0, a = 1 },
    drFontScale = 1,
    drCooldownPos = "RIGHT",
    drXOffset = 0,
    drYOffset = 0,
    drIconSize = 36,
    drEnabled = true,
    drBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss",
    drBorderColor = { r = 1, g = 1, b = 1, a = 1 },
    drDisableCircle = false,
    drCooldownAlpha = 1,
    drBorderColorsEnabled = true,
    drIconPadding = 1,
    drHalfColor = {r = 1, g = 1, b = 0, a = 1 },
    drQuarterColor = {r = 1, g = 0.7, b = 0, a = 1 },
    drNullColor = {r = 1, g = 0, b = 0, a = 1 },
    drWidthFactor = 1,
})

local function getDiminishColor(dr)
    if dr == 0.5 then
        return Gladdy.db.drHalfColor.r, Gladdy.db.drHalfColor.g, Gladdy.db.drHalfColor.b, Gladdy.db.drHalfColor.a
    elseif dr == 0.25 then
        return Gladdy.db.drQuarterColor.r, Gladdy.db.drQuarterColor.g, Gladdy.db.drQuarterColor.b, Gladdy.db.drQuarterColor.a
    else
        return Gladdy.db.drNullColor.r, Gladdy.db.drNullColor.g, Gladdy.db.drNullColor.b, Gladdy.db.drNullColor.a
    end
end

local function StyleActionButton(f)
    local name = f:GetName()
    local button = _G[name]
    local icon = _G[name .. "Icon"]
    local normalTex = _G[name .. "NormalTexture"]
    local cooldown = _G[name .. "Cooldown"]

    normalTex:SetHeight(button:GetHeight())
    normalTex:SetWidth(button:GetWidth())
    normalTex:SetPoint("CENTER")
    normalTex:SetVertexColor(0, 0 , 0, 0)

    if Gladdy.db.drBorderStyle == "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss" then
        f.border:SetTexture("Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp")
    else
        f.border:SetTexture(Gladdy.db.drBorderStyle)
    end

    icon:SetTexCoord(.1, .9, .1, .9)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
end

function Diminishings:OnEvent(event, ...)
    self[event](self, ...)
end

function Diminishings:Initialise()
    self.frames = {}
    self:RegisterMessage("UNIT_DEATH", "ResetUnit")
    self:SetScript("OnEvent", Diminishings.OnEvent)
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Diminishings:COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName, spellSchool, auraType = select(1, ...);
    local destUnit = Gladdy.guids[destGUID]
    if eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_REFRESH" and destUnit then
        self:Fade(destUnit, spellName, spellID)
    end
end

function Diminishings:CreateFrame(unit)
    local drFrame = CreateFrame("Frame", nil, Gladdy.buttons[unit])

    for i = 1, 16 do
        local icon = CreateFrame("CheckButton", "GladdyDr" .. unit .. "Icon" .. i, drFrame, "ActionButtonTemplate")
        icon:SetAlpha(0)
        icon:EnableMouse(false)
        icon:SetFrameStrata("BACKGROUND")
        icon.texture = _G[icon:GetName() .. "Icon"]
        icon:SetScript("OnUpdate", function(self, elapsed)
            if (self.active) then
                if (self.timeLeft <= 0) then
                    if (self.factor == drFrame.tracked[self.dr]) then
                        drFrame.tracked[self.dr] = 0
                    end

                    self.active = false
                    self.dr = nil
                    self.diminishing = 1.0
                    self.texture:SetTexture("")
                    self.text:SetText("")
                    self:SetAlpha(0)
                    Diminishings:Positionate(unit)
                else
                    self.timeLeft = self.timeLeft - elapsed
                    if self.timeLeft >=5 then
                        self.timeText:SetFormattedText("%d", self.timeLeft)
                    else
                        self.timeText:SetFormattedText("%.1f", self.timeLeft)
                    end
                end
            end
        end)

        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown.noCooldownCount = true --Gladdy.db.trinketDisableOmniCC

        icon.cooldownFrame = CreateFrame("Frame", nil, icon)
        icon.cooldownFrame:ClearAllPoints()
        icon.cooldownFrame:SetPoint("TOPLEFT", icon, "TOPLEFT")
        icon.cooldownFrame:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")

        --icon.overlay = CreateFrame("Frame", nil, icon)
        --icon.overlay:SetAllPoints(icon)
        icon.border = icon.cooldownFrame:CreateTexture(nil, "OVERLAY")
        icon.border:SetTexture("Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp")
        icon.border:SetAllPoints(icon)

        icon.text = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.text:SetDrawLayer("OVERLAY")
        icon.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), 10, "OUTLINE")
        icon.text:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)
        icon.text:SetShadowOffset(1, -1)
        icon.text:SetShadowColor(0, 0, 0, 1)
        icon.text:SetJustifyH("CENTER")
        icon.text:SetPoint("CENTER")

        icon.timeText = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.timeText:SetDrawLayer("OVERLAY")
        icon.timeText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), 10, "OUTLINE")
        icon.timeText:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)
        icon.timeText:SetShadowOffset(1, -1)
        icon.timeText:SetShadowColor(0, 0, 0, 1)
        icon.timeText:SetJustifyH("CENTER")
        icon.timeText:SetPoint("CENTER", icon, "CENTER", 0, 1)

        icon.diminishing = 1

        drFrame["icon" .. i] = icon
    end

    drFrame.tracked = {}
    Gladdy.buttons[unit].drFrame = drFrame
    self.frames[unit] = drFrame
    self:ResetUnit(unit)
end

function Diminishings:UpdateFrame(unit)
    local drFrame = self.frames[unit]
    if (not drFrame) then
        return
    end

    if (Gladdy.db.drEnabled == false) then
        drFrame:Hide()
        return
    else
        drFrame:Show()
    end

    drFrame:ClearAllPoints()
    local horizontalMargin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
    local verticalMargin = -(Gladdy.db.powerBarHeight)/2
    if (Gladdy.db.drCooldownPos == "LEFT") then
        if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
            horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor) + Gladdy.db.padding
            if (Gladdy.db.classIconPos == "LEFT") then
                horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor) + Gladdy.db.padding
            end
        elseif (Gladdy.db.classIconPos == "LEFT") then
            horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor) + Gladdy.db.padding
            if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
                horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor) + Gladdy.db.padding
            end
        end
        if (Gladdy.db.castBarPos == "LEFT") then
            verticalMargin = verticalMargin -
                    (((Gladdy.db.castBarHeight < Gladdy.db.castBarIconSize) and Gladdy.db.castBarIconSize
                            or Gladdy.db.castBarHeight)/2 + Gladdy.db.padding/2)
        end
        if (Gladdy.db.cooldownYPos == "LEFT" and Gladdy.db.cooldown) then
            verticalMargin = verticalMargin - (Gladdy.db.cooldownSize/2 + Gladdy.db.padding/2)
        end
        if (Gladdy.db.buffsCooldownPos == "LEFT" and Gladdy.db.buffsEnabled) then
            verticalMargin = verticalMargin - (Gladdy.db.buffsIconSize/2 + Gladdy.db.padding/2)
        end
        drFrame:SetPoint("RIGHT", Gladdy.buttons[unit].healthBar, "LEFT", -horizontalMargin + Gladdy.db.drXOffset, Gladdy.db.drYOffset + verticalMargin)
    end
    if (Gladdy.db.drCooldownPos == "RIGHT") then
        if (Gladdy.db.trinketPos == "RIGHT" and Gladdy.db.trinketEnabled) then
            horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor) + Gladdy.db.padding
            if (Gladdy.db.classIconPos == "RIGHT") then
                horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor) + Gladdy.db.padding
            end
        elseif (Gladdy.db.classIconPos == "RIGHT") then
            horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor) + Gladdy.db.padding
            if (Gladdy.db.trinketPos == "RIGHT" and Gladdy.db.trinketEnabled) then
                horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor) + Gladdy.db.padding
            end
        end
        if (Gladdy.db.castBarPos == "RIGHT") then
            verticalMargin = verticalMargin -
                    (((Gladdy.db.castBarHeight < Gladdy.db.castBarIconSize) and Gladdy.db.castBarIconSize
                            or Gladdy.db.castBarHeight)/2 + Gladdy.db.padding/2)
        end
        if (Gladdy.db.cooldownYPos == "RIGHT" and Gladdy.db.cooldown) then
            verticalMargin = verticalMargin - (Gladdy.db.cooldownSize/2 + Gladdy.db.padding/2)
        end
        if (Gladdy.db.buffsCooldownPos == "RIGHT" and Gladdy.db.buffsEnabled) then
            verticalMargin = verticalMargin - (Gladdy.db.buffsIconSize/2 + Gladdy.db.padding/2)
        end
        drFrame:SetPoint("LEFT", Gladdy.buttons[unit].healthBar, "RIGHT", horizontalMargin + Gladdy.db.drXOffset, Gladdy.db.drYOffset + verticalMargin)
    end

    drFrame:SetWidth(Gladdy.db.drIconSize * 16)
    drFrame:SetHeight(Gladdy.db.drIconSize)

    for i = 1, 16 do
        local icon = drFrame["icon" .. i]

        icon:SetWidth(Gladdy.db.drIconSize * Gladdy.db.drWidthFactor)
        icon:SetHeight(Gladdy.db.drIconSize)

        icon.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), (Gladdy.db.drIconSize/2 - 1) * Gladdy.db.drFontScale, "OUTLINE")
        icon.text:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)
        icon.timeText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), (Gladdy.db.drIconSize/2 - 1) * Gladdy.db.drFontScale, "OUTLINE")
        icon.timeText:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)

        if Gladdy.db.drDisableCircle then
            icon.cooldown:SetAlpha(0)
        else
            icon.cooldown:SetAlpha(Gladdy.db.drCooldownAlpha)
        end

        if Gladdy.db.drBorderColorsEnabled then
            icon.border:SetVertexColor(getDiminishColor(icon.diminishing))
        else
            icon.border:SetVertexColor(Gladdy.db.drBorderColor.r, Gladdy.db.drBorderColor.g, Gladdy.db.drBorderColor.b, Gladdy.db.drBorderColor.a)
        end

        icon:ClearAllPoints()
        if (Gladdy.db.drCooldownPos == "LEFT") then
            if (i == 1) then
                icon:SetPoint("TOPRIGHT")
            else
                icon:SetPoint("RIGHT", drFrame["icon" .. (i - 1)], "LEFT", -Gladdy.db.drIconPadding, 0)
            end
        else
            if (i == 1) then
                icon:SetPoint("TOPLEFT")
            else
                icon:SetPoint("LEFT", drFrame["icon" .. (i - 1)], "RIGHT", Gladdy.db.drIconPadding, 0)
            end
        end

        StyleActionButton(icon)
    end
end

function Diminishings:ResetUnit(unit)
    local drFrame = self.frames[unit]
    if (not drFrame) then
        return
    end

    drFrame.tracked = {}

    for i = 1, 16 do
        local icon = drFrame["icon" .. i]
        icon.active = false
        icon.timeLeft = 0
        icon.texture:SetTexture("")
        icon.text:SetText("")
        icon.timeText:SetText("")
        icon:SetAlpha(0)
    end
end

function Diminishings:Test(unit)
    if Gladdy.db.drEnabled then
        local spells = { 33786, 118, 8643, 8983 }
        for i = 1, 4 do
            local spell = GetSpellInfo(spells[i])
            if i == 1 then
                self:Fade(unit, spell, spells[i])
            elseif i == 2 then
                self:Fade(unit, spell, spells[i])
                self:Fade(unit, spell, spells[i])
            else
                self:Fade(unit, spell, spells[i])
                self:Fade(unit, spell, spells[i])
                self:Fade(unit, spell, spells[i])
            end
        end
    end
end

function Diminishings:Fade(unit, spell, spellID)
    local drFrame = self.frames[unit]
    local drCat = DRData:GetSpellCategory(spellID)
    if (not drFrame or not drCat) then
        return nil
    end

    local lastIcon
    for i = 1, 16 do
        local icon = drFrame["icon" .. i]
        if (icon.active and icon.dr and icon.dr == drCat) then
            lastIcon = icon
            break
        elseif not icon.active and not lastIcon then
            lastIcon = icon
            lastIcon.diminishing = 1.0
        end
    end
    lastIcon.dr = drCat
    lastIcon.timeLeft = drDuration
    lastIcon.diminishing = DRData:NextDR(lastIcon.diminishing)
    if Gladdy.db.drBorderColorsEnabled then
        lastIcon.border:SetVertexColor(getDiminishColor(lastIcon.diminishing))
    else
        lastIcon.border:SetVertexColor(Gladdy.db.drBorderColor.r, Gladdy.db.drBorderColor.g, Gladdy.db.drBorderColor.b, Gladdy.db.drBorderColor.a)
    end
    lastIcon.cooldown:SetCooldown(GetTime(), drDuration)
    lastIcon.texture:SetTexture(select(3, GetSpellInfo(spellID)))
    lastIcon.active = true
    self:Positionate(unit)
    lastIcon:SetAlpha(1)
    return nil
end

function Diminishings:Positionate(unit)
    local drFrame = self.frames[unit]
    if (not drFrame) then
        return
    end

    local lastIcon

    for i = 1, 16 do
        local icon = drFrame["icon" .. i]

        if (icon.active) then
            icon:ClearAllPoints()
            if (Gladdy.db.drCooldownPos == "LEFT") then
                if (not lastIcon) then
                    icon:SetPoint("TOPRIGHT")
                else
                    icon:SetPoint("RIGHT", lastIcon, "LEFT", -Gladdy.db.drIconPadding, 0)
                end
            else
                if (not lastIcon) then
                    icon:SetPoint("TOPLEFT")
                else
                    icon:SetPoint("LEFT", lastIcon, "RIGHT", Gladdy.db.drIconPadding, 0)
                end
            end

            lastIcon = icon
        end
    end
end

function Diminishings:GetOptions()
    return {
        headerDiminishings = {
            type = "header",
            name = L["Diminishings"],
            order = 2,
        },
        drEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enable"],
            desc = L["Enabled DR module"],
            order = 3,
        }),
        headerDiminishingsFrame = {
            type = "header",
            name = L["Frame"],
            order = 4,
        },
        drIconSize = Gladdy:option({
            type = "range",
            name = L["Icon Size"],
            desc = L["Size of the DR Icons"],
            order = 5,
            min = 5,
            max = 50,
            step = 1,
        }),
        drWidthFactor = Gladdy:option({
            type = "range",
            name = L["Icon Width Factor"],
            desc = L["Stretches the icon"],
            order = 6,
            min = 0.5,
            max = 2,
            step = 0.05,
        }),
        drIconPadding = Gladdy:option({
            type = "range",
            name = L["Icon Padding"],
            desc = L["Space between Icons"],
            order = 7,
            min = 0,
            max = 10,
            step = 0.1,
        }),
        drDisableCircle = Gladdy:option({
            type = "toggle",
            name = L["No Cooldown Circle"],
            order = 8,
        }),
        drCooldownAlpha = Gladdy:option({
            type = "range",
            name = L["Cooldown circle alpha"],
            min = 0,
            max = 1,
            step = 0.1,
            order = 9,
        }),
        headerFont = {
            type = "header",
            name = L["Font"],
            order = 10,
        },
        drFont = Gladdy:option({
            type = "select",
            name = L["Font"],
            desc = L["Font of the cooldown"],
            order = 11,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        drFontColor = Gladdy:colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the text"],
            order = 13,
            hasAlpha = true,
        }),
        drFontScale = Gladdy:option({
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
        drCooldownPos = Gladdy:option({
            type = "select",
            name = L["DR Cooldown position"],
            desc = L["Position of the cooldown icons"],
            order = 21,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        drXOffset = Gladdy:option({
            type = "range",
            name = L["Horizontal offset"],
            order = 22,
            min = -400,
            max = 400,
            step = 0.1,
        }),
        drYOffset = Gladdy:option({
            type = "range",
            name = L["Vertical offset"],
            order = 23,
            min = -400,
            max = 400,
            step = 0.1,
        }),
        headerBorder = {
            type = "header",
            name = L["Border"],
            order = 30,
        },
        drBorderStyle = Gladdy:option({
            type = "select",
            name = L["Border style"],
            order = 31,
            values = Gladdy:GetIconStyles()
        }),
        drBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Border color"],
            desc = L["Color of the border"],
            order = 32,
            hasAlpha = true,
        }),
        headerBorder = {
            type = "header",
            name = L["DR Border Colors"],
            order = 40,
        },
        drBorderColorsEnabled = Gladdy:option({
            type = "toggle",
            name = L["Dr Border Colors Enabled"],
            desc = L["Colors borders of DRs in respective DR-color below"],
            order = 41,
            width = "full",
        }),
        drHalfColor = Gladdy:colorOption({
            type = "color",
            name = L["Half"],
            desc = L["Color of the border"],
            order = 42,
            hasAlpha = true,
        }),
        drQuarterColor = Gladdy:colorOption({
            type = "color",
            name = L["Quarter"],
            desc = L["Color of the border"],
            order = 43,
            hasAlpha = true,
        }),
        drNullColor = Gladdy:colorOption({
            type = "color",
            name = L["Immune"],
            desc = L["Color of the border"],
            order = 44,
            hasAlpha = true,
        }),
    }
end
