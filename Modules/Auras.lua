local pairs = pairs

local GetSpellInfo = GetSpellInfo
local CreateFrame = CreateFrame

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Auras = Gladdy:NewModule("Auras", nil, {
    auraFont = "DorisPP",
    auraFontSize = 20,
    auraFontColor = { r = 1, g = 1, b = 0, a = 1 },
    auraBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    auraBuffBorderColor = { r = 1, g = 0, b = 0, a = 1 },
    auraDebuffBorderColor = { r = 0, g = 1, b = 0, a = 1 },
    auraDisableCircle = false,
})

function Auras:Initialise()
    self.frames = {}

    self.auras = self:GetAuraList()

    self:RegisterMessage("AURA_GAIN")
    self:RegisterMessage("AURA_FADE")
    self:RegisterMessage("UNIT_DEATH", "AURA_FADE")
end

function Auras:CreateFrame(unit)
    local auraFrame = CreateFrame("Frame", nil, Gladdy.modules.Classicon.frames[unit])
    auraFrame:SetFrameStrata("MEDIUM")
    auraFrame:SetFrameLevel(3)

    auraFrame.cooldown = CreateFrame("Cooldown", nil, auraFrame, "CooldownFrameTemplate")
    auraFrame.cooldown.noCooldownCount = true
    auraFrame.cooldown:SetFrameStrata("MEDIUM")
    auraFrame.cooldown:SetFrameLevel(4)

    auraFrame.cooldownFrame = CreateFrame("Frame", nil, auraFrame)
    auraFrame.cooldownFrame:ClearAllPoints()
    auraFrame.cooldownFrame:SetPoint("TOPLEFT", auraFrame, "TOPLEFT")
    auraFrame.cooldownFrame:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT")
    auraFrame.cooldownFrame:SetFrameStrata("MEDIUM")
    auraFrame.cooldownFrame:SetFrameLevel(5)

    auraFrame.icon = auraFrame:CreateTexture(nil, "BACKGROUND")
    auraFrame.icon:SetAllPoints(auraFrame)

    auraFrame.icon.overlay = auraFrame.cooldownFrame:CreateTexture(nil, "OVERLAY")
    auraFrame.icon.overlay:SetAllPoints(auraFrame)
    auraFrame.icon.overlay:SetTexture(Gladdy.db.buttonBorderStyle)

    local classIcon = Gladdy.modules.Classicon.frames[unit]
    auraFrame:ClearAllPoints()
    auraFrame:SetAllPoints(classIcon)
    auraFrame:SetScript("OnUpdate", function(self, elapsed)
        if (self.active) then
            if (self.timeLeft <= 0) then
                Auras:AURA_FADE(unit)
            else
                self.timeLeft = self.timeLeft - elapsed
                self.text:SetFormattedText("%.1f", self.timeLeft)
            end
        end
    end)


    auraFrame.text = auraFrame.cooldownFrame:CreateFontString(nil, "OVERLAY")
    auraFrame.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), 20, "OUTLINE")
    auraFrame.text:SetTextColor(Gladdy.db.auraFontColor.r, Gladdy.db.auraFontColor.g, Gladdy.db.auraFontColor.b, Gladdy.db.auraFontColor.a)
    auraFrame.text:SetShadowOffset(1, -1)
    auraFrame.text:SetShadowColor(0, 0, 0, 1)
    auraFrame.text:SetJustifyH("CENTER")
    auraFrame.text:SetPoint("CENTER")

    self.frames[unit] = auraFrame
    self:ResetUnit(unit)
end

function Auras:UpdateFrame(unit)
    local auraFrame = self.frames[unit]
    if (not auraFrame) then
        return
    end

    local classIcon = Gladdy.modules.Classicon.frames[unit]

    auraFrame:SetWidth(classIcon:GetWidth())
    auraFrame:SetHeight(classIcon:GetHeight())
    auraFrame:SetAllPoints(classIcon)

    auraFrame.cooldown:SetWidth(classIcon:GetWidth() - classIcon:GetWidth()/16)
    auraFrame.cooldown:SetHeight(classIcon:GetHeight() - classIcon:GetHeight()/16)
    auraFrame.cooldown:ClearAllPoints()
    auraFrame.cooldown:SetPoint("CENTER", auraFrame, "CENTER")

    auraFrame.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), Gladdy.db.auraFontSize)
    auraFrame.text:SetTextColor(Gladdy.db.auraFontColor.r, Gladdy.db.auraFontColor.g, Gladdy.db.auraFontColor.b, Gladdy.db.auraFontColor.a)

    auraFrame.icon.overlay:SetTexture(Gladdy.db.auraBorderStyle)
    if auraFrame.track and auraFrame.track == "debuff" then
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.auraDebuffBorderColor.r, Gladdy.db.auraDebuffBorderColor.g, Gladdy.db.auraDebuffBorderColor.b, Gladdy.db.auraDebuffBorderColor.a)
    elseif auraFrame.track and auraFrame.track == "buff" then
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.auraBuffBorderColor.r, Gladdy.db.auraBuffBorderColor.g, Gladdy.db.auraBuffBorderColor.b, Gladdy.db.auraBuffBorderColor.a)
    else
        auraFrame.icon.overlay:SetVertexColor(0, 0, 0, 1)
    end
end

function Auras:ResetUnit(unit)
    self:AURA_FADE(unit)
end

function Auras:Test(unit)
    local aura, _, icon

    if (unit == "arena1") then
        aura, _, icon = GetSpellInfo(12826)
    elseif (unit == "arena4") then
        aura, _, icon = GetSpellInfo(6770)
    elseif (unit == "arena3") then
        aura, _, icon = GetSpellInfo(31224)
    end

    if (aura) then
        self:AURA_GAIN(unit, aura, icon, self.auras[aura].duration, self.auras[aura].priority)
        --self:AURA_FADE(unit)
    end
end

--[[local rand = 0
function TestAura()
    if rand == 5 then
        rand = 0
    end
    local aura, _, icon = GetSpellInfo(12826)
    if rand == 0 then
        Auras:AURA_GAIN("arena1", aura, icon, Auras.auras[aura].duration, Auras.auras[aura].priority)
    end
    aura, _, icon = GetSpellInfo(6770)
    if rand == 1 then
        Auras:AURA_GAIN("arena1", aura, icon, Auras.auras[aura].duration, Auras.auras[aura].priority)
    end
    if rand == 2 then
        Auras:AURA_GAIN("arena1", aura, icon, 2, Auras.auras[aura].priority)
    end
    aura, _, icon = GetSpellInfo(31224)
    if rand == 3 then
        Auras:AURA_GAIN("arena1", aura, icon, Auras.auras[aura].duration, Auras.auras[aura].priority)
    end
    aura, _, icon = GetSpellInfo(33786)
    if rand == 4 then
        Auras:AURA_GAIN("arena1", aura, icon, Auras.auras[aura].duration, Auras.auras[aura].priority)
    end
    rand = rand + 1
end--]]

function Auras:AURA_GAIN(unit, aura, icon, duration, priority)
    local auraFrame = self.frames[unit]
    if (not auraFrame) then
        return
    end

    if (auraFrame.priority and auraFrame.priority > priority) then
        return
    end

    if not auraFrame.startTime or not auraFrame.active then
        -- was not active and new aura
        auraFrame.startTime = GetTime()
        auraFrame.endTime = GetTime() + duration
    end

    if (auraFrame.name and auraFrame.name ~= aura) then
        -- was active but new aura
        auraFrame.startTime = GetTime()
        auraFrame.endTime = GetTime() + duration
    end

    if (auraFrame.name and auraFrame.name == aura) then
        -- same aura as before, check if new endTime in margin of 100ms
        if GetTime() + duration - 0.1 > auraFrame.endTime or GetTime() + duration + 0.1 < auraFrame.endTime then
            auraFrame.startTime = GetTime()
            auraFrame.endTime = GetTime() + duration
        end
    end

    auraFrame.name = aura
    auraFrame.timeLeft = duration
    auraFrame.priority = priority
    auraFrame.icon:SetTexture(icon)
    auraFrame.track = self.auras[aura].track
    auraFrame.active = true
    auraFrame.icon.overlay:SetTexture(Gladdy.db.auraBorderStyle)
    auraFrame.cooldownFrame:Show()
    if auraFrame.track and auraFrame.track == "debuff" then
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.auraDebuffBorderColor.r, Gladdy.db.auraDebuffBorderColor.g, Gladdy.db.auraDebuffBorderColor.b, Gladdy.db.auraDebuffBorderColor.a)
    elseif auraFrame.track and auraFrame.track == "buff" then
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.auraBuffBorderColor.r, Gladdy.db.auraBuffBorderColor.g, Gladdy.db.auraBuffBorderColor.b, Gladdy.db.auraBuffBorderColor.a)
    else
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.frameBorderColor.r, Gladdy.db.frameBorderColor.g, Gladdy.db.frameBorderColor.b, Gladdy.db.frameBorderColor.a)
    end
    if not Gladdy.db.auraDisableCircle then auraFrame.cooldown:SetCooldown(auraFrame.startTime, auraFrame.endTime - auraFrame.startTime) end
end

function Auras:AURA_FADE(unit)
    local auraFrame = self.frames[unit]
    if (not auraFrame) then
        return
    end
    if auraFrame.active then
        auraFrame.cooldown:SetCooldown(GetTime(), 0)
    end
    auraFrame.active = false
    auraFrame.name = nil
    auraFrame.timeLeft = 0
    auraFrame.priority = nil
    auraFrame.startTime = nil
    auraFrame.endTime = nil
    auraFrame.icon:SetTexture("")
    auraFrame.text:SetText("")
    auraFrame.icon.overlay:SetTexture("")
    auraFrame.cooldownFrame:Hide()
end

function Auras:GetOptions()
    return {
        auraDisableCircle = Gladdy:option({
            type = "toggle",
            name = L["Disable Cooldown Circle"],
            order = 2,
        }),
        auraFont = Gladdy:option({
            type = "select",
            name = L["Font"],
            desc = L["Font of the cooldown"],
            order = 3,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        auraFontSize = Gladdy:option({
            type = "range",
            name = L["Font size"],
            desc = L["Size of the text"],
            order = 4,
            min = 1,
            max = 20,
        }),
        auraFontColor = Gladdy:colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the text"],
            order = 5,
            hasAlpha = true,
        }),
        auraBorderStyle = Gladdy:option({
            type = "select",
            name = L["Border style"],
            order = 6,
            values = Gladdy:GetIconStyles()
        }),
        auraBuffBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Buff color"],
            desc = L["Color of the text"],
            order = 7,
            hasAlpha = true,
        }),
        auraDebuffBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Debuff color"],
            desc = L["Color of the text"],
            order = 8,
            hasAlpha = true,
        }),
    }
end

function Auras:GetAuraList()
    return {
        -- Cyclone
        [GetSpellInfo(33786)] = {
            track = "debuff",
            duration = 6,
            priority = 40,
        },
        -- Hibername
        [GetSpellInfo(18658)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            magic = true,
        },
        -- Entangling Roots
        [GetSpellInfo(26989)] = {
            track = "debuff",
            duration = 10,
            priority = 30,
            onDamage = true,
            magic = true,
            root = true,
        },
        -- Feral Charge
        [GetSpellInfo(16979)] = {
            track = "debuff",
            duration = 4,
            priority = 30,
            root = true,
        },
        -- Bash
        [GetSpellInfo(8983)] = {
            track = "debuff",
            duration = 4,
            priority = 30,
        },
        -- Pounce
        [GetSpellInfo(9005)] = {
            track = "debuff",
            duration = 3,
            priority = 40,
        },
        -- Maim
        [GetSpellInfo(22570)] = {
            track = "debuff",
            duration = 6,
            priority = 40,
            incapacite = true,
        },
        -- Innervate
        [GetSpellInfo(29166)] = {
            track = "buff",
            duration = 20,
            priority = 10,
        },


        -- Freezing Trap Effect
        [GetSpellInfo(14309)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            onDamage = true,
            magic = true,
        },
        -- Wyvern Sting
        [GetSpellInfo(19386)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            onDamage = true,
            poison = true,
            sleep = true,
        },
        -- Scatter Shot
        [GetSpellInfo(19503)] = {
            track = "debuff",
            duration = 4,
            priority = 40,
            onDamage = true,
        },
        -- Silencing Shot
        [GetSpellInfo(34490)] = {
            track = "debuff",
            duration = 3,
            priority = 15,
            magic = true,
        },
        -- Intimidation
        [GetSpellInfo(19577)] = {
            track = "debuff",
            duration = 2,
            priority = 40,
        },
        -- The Beast Within
        [GetSpellInfo(34692)] = {
            track = "buff",
            duration = 18,
            priority = 20,
        },


        -- Polymorph
        [GetSpellInfo(12826)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            onDamage = true,
            magic = true,
        },
        -- Dragon's Breath
        [GetSpellInfo(31661)] = {
            track = "debuff",
            duration = 3,
            priority = 40,
            onDamage = true,
            magic = true,
        },
        -- Frost Nova
        [GetSpellInfo(27088)] = {
            track = "debuff",
            duration = 8,
            priority = 30,
            onDamage = true,
            magic = true,
            root = true,
        },
        -- Freeze (Water Elemental)
        [GetSpellInfo(33395)] = {
            track = "debuff",
            duration = 8,
            priority = 30,
            onDamage = true,
            magic = true,
            root = true,
        },
        -- Counterspell - Silence
        [GetSpellInfo(18469)] = {
            track = "debuff",
            duration = 4,
            priority = 15,
            magic = true,
        },
        -- Ice Block
        [GetSpellInfo(45438)] = {
            track = "buff",
            duration = 10,
            priority = 20,
        },


        -- Hammer of Justice
        [GetSpellInfo(10308)] = {
            track = "debuff",
            duration = 6,
            priority = 40,
            magic = true,
        },
        -- Repentance
        [GetSpellInfo(20066)] = {
            track = "debuff",
            duration = 6,
            priority = 40,
            onDamage = true,
            magic = true,
            incapacite = true,
        },
        -- Blessing of Protection
        [GetSpellInfo(10278)] = {
            track = "buff",
            duration = 10,
            priority = 10,
        },
        -- Blessing of Freedom
        [GetSpellInfo(1044)] = {
            track = "buff",
            duration = 14,
            priority = 10,
        },
        -- Divine Shield
        [GetSpellInfo(642)] = {
            track = "buff",
            duration = 12,
            priority = 20,
        },


        -- Psychic Scream
        [GetSpellInfo(8122)] = {
            track = "debuff",
            duration = 8,
            priority = 40,
            onDamage = true,
            fear = true,
            magic = true,
        },
        -- Chastise
        [GetSpellInfo(44047)] = {
            track = "debuff",
            duration = 8,
            priority = 30,
            root = true,
        },
        -- Mind Control
        [GetSpellInfo(605)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            magic = true,
        },
        -- Silence
        [GetSpellInfo(15487)] = {
            track = "debuff",
            duration = 5,
            priority = 15,
            magic = true,
        },
        -- Pain Suppression
        [GetSpellInfo(33206)] = {
            track = "buff",
            duration = 8,
            priority = 10,
        },


        -- Sap
        [GetSpellInfo(6770)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            onDamage = true,
            incapacite = true,
        },
        -- Blind
        [GetSpellInfo(2094)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            onDamage = true,
        },
        -- Cheap Shot
        [GetSpellInfo(1833)] = {
            track = "debuff",
            duration = 4,
            priority = 40,
        },
        -- Kidney Shot
        [GetSpellInfo(8643)] = {
            track = "debuff",
            duration = 6,
            priority = 40,
        },
        -- Gouge
        [GetSpellInfo(1776)] = {
            track = "debuff",
            duration = 4,
            priority = 40,
            onDamage = true,
            incapacite = true,
        },
        -- Kick - Silence
        [GetSpellInfo(18425)] = {
            track = "debuff",
            duration = 2,
            priority = 15,
        },
        -- Garrote - Silence
        [GetSpellInfo(1330)] = {
            track = "debuff",
            duration = 3,
            priority = 15,
        },
        -- Cloak of Shadows
        [GetSpellInfo(31224)] = {
            track = "buff",
            duration = 5,
            priority = 20,
        },


        -- Fear
        [GetSpellInfo(5782)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            onDamage = true,
            fear = true,
            magic = true,
        },
        -- Death Coil
        [GetSpellInfo(27223)] = {
            track = "debuff",
            duration = 3,
            priority = 40,
        },
        -- Shadowfury
        [GetSpellInfo(30283)] = {
            track = "debuff",
            duration = 2,
            priority = 40,
            magic = true,
        },
        -- Seduction (Succubus)
        [GetSpellInfo(6358)] = {
            track = "debuff",
            duration = 10,
            priority = 40,
            onDamage = true,
            fear = true,
            magic = true,
        },
        -- Howl of Terror
        [GetSpellInfo(5484)] = {
            track = "debuff",
            duration = 8,
            priority = 40,
            onDamage = true,
            fear = true,
            magic = true,
        },
        -- Spell Lock (Felhunter)
        [GetSpellInfo(24259)] = {
            track = "debuff",
            duration = 3,
            priority = 15,
            magic = true,
        },
        -- Unstable Affliction
        [GetSpellInfo(31117)] = {
            track = "debuff",
            duration = 5,
            priority = 15,
            magic = true,
        },


        -- Intimidating Shout
        [GetSpellInfo(5246)] = {
            track = "debuff",
            duration = 8,
            priority = 15,
            onDamage = true,
            fear = true,
        },
        -- Concussion Blow
        [GetSpellInfo(12809)] = {
            track = "debuff",
            duration = 5,
            priority = 40,
        },
        -- Intercept Stun
        [GetSpellInfo(25274)] = {
            track = "debuff",
            duration = 3,
            priority = 40,
        },
        -- Spell Reflection
        [GetSpellInfo(23920)] = {
            track = "buff",
            duration = 5,
            priority = 10,
        },


        -- War Stomp
        [GetSpellInfo(20549)] = {
            track = "debuff",
            duration = 2,
            priority = 40,
        },
        -- Arcane Torrent
        [GetSpellInfo(28730)] = {
            track = "debuff",
            duration = 2,
            priority = 15,
            magic = true,
        },
    }
end