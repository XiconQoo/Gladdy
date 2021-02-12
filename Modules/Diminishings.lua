local max = math.max
local select = select
local pairs = pairs

local drDuration = 18

local GetSpellInfo = GetSpellInfo
local CreateFrame = CreateFrame
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Diminishings = Gladdy:NewModule("Diminishings", nil, {
    drFont = "DorisPP",
    drFontColor = { r = 1, g = 1, b = 0, a = 1 },
    drFontScale = 1,
    drCooldownPos = "RIGHT",
    drIconSize = 36,
    drEnabled = true,
    drEnableCooldown = true,
    drBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss",
    drBorderColor = { r = 1, g = 1, b = 1, a = 1 },
    drDisableCircle = false
})

local function StyleActionButton(f)
    local name = f:GetName()
    local button = _G[name]
    local icon = _G[name .. "Icon"]
    local normalTex = _G[name .. "NormalTexture"]

    normalTex:SetHeight(button:GetHeight())
    normalTex:SetWidth(button:GetWidth())
    normalTex:SetPoint("CENTER")

    button:SetNormalTexture(Gladdy.db.drBorderStyle)
    normalTex:SetVertexColor(Gladdy.db.drBorderColor.r, Gladdy.db.drBorderColor.g, Gladdy.db.drBorderColor.b, Gladdy.db.drBorderColor.a)

    icon:SetTexCoord(.1, .9, .1, .9)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
end

function Diminishings:OnEvent(event, ...)
    self[event](self, ...)
end

function Diminishings:Initialise()
    self.frames = {}
    self.spells = {}
    self.icons = {}

    local spells = self:GetDRList()
    for k, v in pairs(spells) do
        local name, _, icon = GetSpellInfo(k)
        self.spells[name] = v
        self.icons[name] = icon
    end

    self:RegisterMessage("UNIT_DEATH", "ResetUnit")
    self:SetScript("OnEvent", Diminishings.OnEvent)
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Diminishings:COMBAT_LOG_EVENT_UNFILTERED(...)
    local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName, spellSchool, auraType = select(1, ...);
    local destUnit = Gladdy.guids[destGUID]
    if eventType == "SPELL_AURA_REMOVED" and destUnit then
        self:Fade(destUnit, spellName)
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
                    self.texture:SetTexture("")
                    self.text:SetText("")
                    self:SetAlpha(0)

                    Diminishings:Positionate(unit)
                else
                    self.timeLeft = self.timeLeft - elapsed
                    self.timeText:SetFormattedText("%d", self.timeLeft + 1)
                end
            end
        end)

        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown.noCooldownCount = true --Gladdy.db.trinketDisableOmniCC

        icon.cooldownFrame = CreateFrame("Frame", nil, icon)
        icon.cooldownFrame:ClearAllPoints()
        icon.cooldownFrame:SetPoint("TOPLEFT", icon, "TOPLEFT")
        icon.cooldownFrame:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")

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
        icon.timeText:SetPoint("CENTER")

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
    end

    drFrame:ClearAllPoints()
    local margin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
    if (Gladdy.db.drCooldownPos == "LEFT") then
        if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
            if (Gladdy.db.castBarPos == "LEFT") then
                drFrame:SetPoint("BOTTOMRIGHT", Gladdy.buttons[unit].trinketButton, "BOTTOMLEFT", -Gladdy.db.padding, 0)
            else
                drFrame:SetPoint("RIGHT", Gladdy.buttons[unit].trinketButton, "LEFT", -Gladdy.db.padding, 0)
            end
        else
            if Gladdy.db.classIconPos == "LEFT" then
                if (Gladdy.db.castBarPos == "LEFT") then
                    drFrame:SetPoint("BOTTOMRIGHT", Gladdy.buttons[unit].classIcon, "BOTTOMLEFT", -Gladdy.db.padding, 0)
                else
                    drFrame:SetPoint("RIGHT", Gladdy.buttons[unit].classIcon, "LEFT", -Gladdy.db.padding, 0)
                end
            else
                if (Gladdy.db.castBarPos == "LEFT") then
                    drFrame:SetPoint("BOTTOMRIGHT", Gladdy.buttons[unit].powerBar, "BOTTOMLEFT", -Gladdy.db.padding, 0)
                else
                    drFrame:SetPoint("RIGHT", Gladdy.buttons[unit].healthBar, "LEFT", -margin, 0)
                end
            end
        end
    end
    if (Gladdy.db.drCooldownPos == "RIGHT") then
        if (Gladdy.db.trinketPos == "RIGHT" and Gladdy.db.trinketEnabled) then
            if (Gladdy.db.castBarPos == "RIGHT") then
                drFrame:SetPoint("BOTTOMLEFT", Gladdy.buttons[unit].trinketButton, "BOTTOMRIGHT", Gladdy.db.padding, 0)
            else
                drFrame:SetPoint("LEFT", Gladdy.buttons[unit].trinketButton, "RIGHT", Gladdy.db.padding, 0)
            end
        else
            if Gladdy.db.classIconPos == "RIGHT" then
                if (Gladdy.db.castBarPos == "RIGHT") then
                    drFrame:SetPoint("BOTTOMLEFT", Gladdy.buttons[unit].classIcon, "BOTTOMRIGHT", Gladdy.db.padding, 0)
                else
                    drFrame:SetPoint("LEFT", Gladdy.buttons[unit].classIcon, "RIGHT", Gladdy.db.padding, 0)
                end
            else
                if (Gladdy.db.castBarPos == "RIGHT") then
                    drFrame:SetPoint("BOTTOMLEFT", Gladdy.buttons[unit].powerBar, "BOTTOMRIGHT", Gladdy.db.padding, 0)
                else
                    drFrame:SetPoint("LEFT", Gladdy.buttons[unit].healthBar, "RIGHT", margin, 0)
                end
            end
        end
    end

    drFrame:SetWidth(Gladdy.db.drIconSize * 16)
    drFrame:SetHeight(Gladdy.db.drIconSize)

    for i = 1, 16 do
        local icon = drFrame["icon" .. i]

        icon:SetWidth(Gladdy.db.drIconSize)
        icon:SetHeight(Gladdy.db.drIconSize)

        icon.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), (Gladdy.db.drIconSize/2 - 1) * Gladdy.db.drFontScale, "OUTLINE")
        icon.text:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)
        icon.timeText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), (Gladdy.db.drIconSize/2 - 1) * Gladdy.db.drFontScale, "OUTLINE")
        icon.timeText:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)

        icon:ClearAllPoints()
        if (Gladdy.db.drCooldownPos == "LEFT") then
            if (i == 1) then
                icon:SetPoint("TOPRIGHT")
            else
                icon:SetPoint("RIGHT", drFrame["icon" .. (i - 1)], "LEFT")
            end
        else
            if (i == 1) then
                icon:SetPoint("TOPLEFT")
            else
                icon:SetPoint("LEFT", drFrame["icon" .. (i - 1)], "RIGHT")
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
    local spells = { 33786, 118, 8643, 8983 }

    for i = 1, 4 do
        local spell = GetSpellInfo(spells[i])
        self:Fade(unit, spell)
    end
end

function Diminishings:Fade(unit, spell)
    local drFrame = self.frames[unit]
    local dr = self.spells[spell]
    if (not drFrame or not dr) then
        return
    end

    for i = 1, 16 do
        local icon = drFrame["icon" .. i]
        if (not icon.active or (icon.dr and icon.dr == dr)) then
            icon.dr = dr
            icon.timeLeft = drDuration
            if not Gladdy.db.drDisableCircle then icon.cooldown:SetCooldown(GetTime(), drDuration) end
            icon.texture:SetTexture(self.icons[spell])
            icon.active = true
            self:Positionate(unit)
            icon:SetAlpha(1)
            break
        end
    end
end

function Positionate()
    Diminishings:Positionate("arena1")
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
                    icon:SetPoint("RIGHT", lastIcon, "LEFT")
                end
            else
                if (not lastIcon) then
                    icon:SetPoint("TOPLEFT")
                else
                    icon:SetPoint("LEFT", lastIcon, "RIGHT")
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
        drDisableCircle = Gladdy:option({
            type = "toggle",
            name = L["No Cooldown Circle"],
            order = 4,
        }),
        drIconSize = Gladdy:option({
            type = "range",
            name = L["Icon Size"],
            desc = L["Size of the DR Icons"],
            order = 5,
            min = 5,
            max = 50,
            step = 1,
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
    }
end

function Diminishings:GetDRList()
    return {
        -- DRUID
        [33786] = "cycloneblind", -- Cyclone
        [18658] = "sleep", -- Hibernate
        [26989] = "root", -- Entangling roots
        [8983] = "stun", -- Bash
        [9005] = "stun", -- Pounce
        [22570] = "disorient", -- Maim

        -- HUNTER
        [14309] = "freezingtrap", -- Freezing Trap
        [19386] = "sleep", -- Wyvern Sting
        [19503] = "scattershot", -- Scatter Shot
        [19577] = "stun", -- Intimidation

        -- MAGE
        [12826] = "disorient", -- Polymorph
        [31661] = "dragonsbreath", -- Dragon's Breath
        [27088] = "root", -- Frost Nova
        [33395] = "root", -- Freeze (Water Elemental)

        -- PALADIN
        [10308] = "stun", -- Hammer of Justice
        [20066] = "repentance", -- Repentance

        -- PRIEST
        [8122] = "fear", -- Phychic Scream
        [44047] = "root", -- Chastise
        [605] = "charm", -- Mind Control

        -- ROGUE
        [6770] = "disorient", -- Sap
        [2094] = "cycloneblind", -- Blind
        [1833] = "stun", -- Cheap Shot
        [8643] = "kidneyshot", -- Kidney Shot
        [1776] = "disorient", -- Gouge

        -- WARLOCK
        [5782] = "fear", -- Fear
        [27223] = "horror", -- Death Coil
        [30283] = "stun", -- Shadowfury
        [6358] = "fear", -- Seduction (Succubus)
        [5484] = "fear", -- Howl of Terror

        -- WARRIOR
        [12809] = "stun", -- Concussion Blow
        [25274] = "stun", -- Intercept Stun
        [5246] = "fear", -- Intimidating Shout

        -- TAUREN
        [20549] = "stun", -- War Stomp
    }
end
