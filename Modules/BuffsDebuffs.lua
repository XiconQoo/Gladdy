local GetSpellInfo = GetSpellInfo
local CreateFrame = CreateFrame
local GetTime = GetTime
local select, tonumber, ceil = select, tonumber, ceil

local Gladdy = LibStub("Gladdy")
local LibAuraDurations = LibStub("LibAuraDurations-1.0")
local spellDurations = LibAuraDurations.spells
local L = Gladdy.L
local defaultTrackedDebuffs = select(2, Gladdy:GetDebuffs())
local BuffsDebuffs = Gladdy:NewModule("BuffsDebuffs", nil, {
    buffsEnabled = true,
    buffsIconSize = 20,
    buffsDisableCircle = false,
    buffsCooldownAlpha = 1,
    buffsFont = "DorisPP",
    buffsFontScale = 1,
    buffsFontColor = {r = 0, g = 0, b = 0, a = 1},
    buffsCooldownPos = "TOP",
    buffsXOffset = 0,
    buffsYOffset = 0,
    buffsBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss",
    buffsBorderColor = {r = 0, g = 0, b = 0, a = 1},
    trackedDebuffs = defaultTrackedDebuffs
})

function BuffsDebuffs:OnEvent(event, ...)
    self[event](self, ...)
end

function BuffsDebuffs:Initialise()
    self.frames = {}
    self.spells = {}
    self.icons = {}
    self.trackedCC = {}
    self.framePool = {}

    --self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    --self:RegisterEvent("UNIT_AURA")
    self:RegisterMessage("JOINED_ARENA")
    self:SetScript("OnEvent", BuffsDebuffs.OnEvent)
end

function BuffsDebuffs:JOINED_ARENA()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function BuffsDebuffs:Reset()
    for k2 in pairs(Gladdy.buttons) do
        self:RemoveAuras(k2)
    end
    for i=1,#self.framePool do
        self.framePool[i]:Hide()
    end
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local function getDebuffDuration(spellID)
    local duration
    if spellDurations[spellID].pvpduration then
        duration = spellDurations[spellID].pvpduration
    elseif type(spellDurations[spellID].duration) == "function" then
        duration = spellDurations[spellID].duration(spellID)
    elseif type(spellDurations[spellID].duration) == "number" then
        if spellDurations[spellID].duration ~= LibAuraDurations.INFINITY then
            duration = spellDurations[spellID].duration
        end
    end
    return duration
end

local srcGUID
local desGUID
local lastSpellID
local lastSpellName
function BuffsDebuffs:COMBAT_LOG_EVENT_UNFILTERED(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destinationGUID, destName, destFlags, spellID, spellName, spellSchool, auraType, amount, ...)
    local destUnit = Gladdy.guids[destinationGUID]
    local srcUnit = Gladdy.guids[sourceGUID]
    Gladdy:Print(eventType)
    if not destUnit or srcUnit then return end

    local Auras = Gladdy.modules.Auras
    spellName = (spellID == 31117 or spellID ==  43523) and "Unstable Affliction Silence" or spellName
    local aura = Auras.auras[spellName]

    if eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_HEAL" then
        srcGUID = sourceGUID
        desGUID = destinationGUID
        lastSpellID = spellID
        lastSpellName = spellName
    end

    local duration
    if Gladdy.eventGrps[eventType] == "BUFF" then
        if not aura and auraType == AURA_TYPE_DEBUFF and spellDurations[spellID] and Gladdy.db.trackedDebuffs[tostring(spellID)] then
            duration = getDebuffDuration(spellID)
            self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF, duration, duration, amount)
            --self:SendMessage(auraType .. "_GAIN", eventType, destUnit, spellID, amount)
        else
            if spellID == 45438 or spellID == 642 then --IceBlock, Bubble
                self:RemoveAuras(destUnit)
            end
        end
    elseif Gladdy.eventGrps[eventType] == "REFRESH" then
        if not aura and auraType == AURA_TYPE_DEBUFF and spellDurations[spellID] and Gladdy.db.trackedDebuffs[tostring(spellID)] then
            duration = getDebuffDuration(spellID)
            self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF, duration, duration, amount)
        else

        end
    elseif Gladdy.eventGrps[eventType] == "FADE" then
        if auraType == AURA_TYPE_DEBUFF then
            self:DEBUFF_FADE(eventType, destUnit, spellID, amount)
        else
            self:BUFF_FADE(eventType, destUnit, spellID, amount)
        end
    end

    if (destUnit and (eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" or eventType == "PARTY_KILL")) then
        self:RemoveAuras(destUnit)
    end
end

function BuffsDebuffs:UNIT_AURA(uid)
    local button = Gladdy:GetButton(uid)
    if (not button) then
        return
    end
    --self:RemoveAuras(button.unit)

    local Auras = Gladdy.modules.Auras
    local index = 1
    while (true) do
        local name, _, icon, _, _, expTime = UnitBuff(uid, index)
        if (not name) then
            break
        end

        if (Auras.auras[name] and Auras.auras[name].priority >= (Auras.frames[button.unit].priority or 0)) then

        end

        index = index + 1
    end

    index = 1
    while (true) do
        local name, rank, icon, stacks, _, duration, expTime, isMine = UnitDebuff(uid, index)
        if (not name) then
            break
        end

        local spellLink = GetSpellLink(name, rank)
        if spellLink then
            local spellID = tonumber(string.match(spellLink, "spell:(%d+)"))
            if not Auras.auras[name] and spellID and (not Gladdy.bufflibEnabled and expTime or Gladdy.bufflibEnabled and expTime and isMine)  then
                --self:DEBUFF_GAIN("UnitDebuff", button.unit, spellID, stacks, duration, expTime)
            end
        end
        index = index + 1
    end
end

function BuffsDebuffs:CreateFrame(unit)
    local buffFrame = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    buffFrame:SetHeight(1)
    buffFrame:SetWidth(1)
    buffFrame:SetPoint("BOTTOMLEFT", Gladdy.buttons[unit].healthBar, "TOPLEFT", 0, Gladdy.db.highlightBorderSize + Gladdy.db.padding)
    self.frames[unit] = buffFrame
    self.frames[unit].auras = {[AURA_TYPE_DEBUFF] = {}, [AURA_TYPE_BUFF] = {}}
end

function BuffsDebuffs:UpdateFrame(unit)
    self.frames[unit]:ClearAllPoints()
    self.frames[unit]:SetPoint("BOTTOMRIGHT", Gladdy.buttons[unit].healthBar, "TOPLEFT", 0, Gladdy.db.highlightBorderSize + Gladdy.db.padding)
    for i=1, #self.frames[unit].auras[AURA_TYPE_BUFF] do
        self.frames[unit].auras[AURA_TYPE_BUFF][i]:SetWidth(Gladdy.db.buffsIconSize)
        self.frames[unit].auras[AURA_TYPE_BUFF][i]:SetHeight(Gladdy.db.buffsIconSize)
    end
    for i=1, #self.frames[unit].auras[AURA_TYPE_DEBUFF] do
        self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:SetWidth(Gladdy.db.buffsIconSize)
        self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:SetHeight(Gladdy.db.buffsIconSize)
    end
end



function BuffsDebuffs:Test(unit)
    if unit == "arena1" then
        self:AddOrRefreshAura(unit, 1943, AURA_TYPE_DEBUFF, 10, 10)
        self:AddOrRefreshAura(unit, 1, AURA_TYPE_DEBUFF, 20, 20)
    end
end

function GladdyTest()
    BuffsDebuffs:AddOrRefreshAura("arena1",  1943, AURA_TYPE_DEBUFF, 10, 10)
    BuffsDebuffs:AddOrRefreshAura("arena2",  1943, AURA_TYPE_DEBUFF, 10, 5)
    BuffsDebuffs:AddOrRefreshAura("arena2",  1943, AURA_TYPE_DEBUFF, 10, 7)
    BuffsDebuffs:AddOrRefreshAura("arena2", 1, AURA_TYPE_DEBUFF, 20, 20)
end

function GladdyReset()
    BuffsDebuffs:Reset()
end

function BuffsDebuffs:DEBUFF_GAIN(eventType, destUnit, spellID, stacks, duration, timeLeft)
    if eventType == "SPELL_AURA_APPLIED_DOSE" or eventType == "SPELL_PERIODIC_AURA_APPLIED_DOSE" then
        self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF, nil, nil, stacks)
    elseif eventType == "UnitDebuff" then
        self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF, duration, timeLeft, stacks)
    else
        self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF)
    end
end

function BuffsDebuffs:BUFF_GAIN(eventType, destUnit, spellID)

end

function BuffsDebuffs:DEBUFF_FADE(eventType, destUnit, spellID, stacks, duration, timeLeft)
    if eventType == "SPELL_AURA_REMOVED_DOSE" or eventType == "SPELL_PERIODIC_AURA_REMOVED_DOSE" then
        self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF, nil, nil, stacks)
    else
        self:RemoveAura(destUnit, spellID, AURA_TYPE_DEBUFF)
    end
end

function BuffsDebuffs:BUFF_FADE(eventType, destUnit, spellID)

end

function BuffsDebuffs:UNIT_DEATH(destUnit)
    self:RemoveAuras(destUnit)
end

function BuffsDebuffs:AddAura(unit, spellID, type, duration, timeLeft, stacks)
    --Gladdy:Print("AddAura", unit, spellID, type, duration, timeLeft, stacks)
    local aura
    if not self.frames[unit].auras then
        self.frames[unit].auras = {[AURA_TYPE_DEBUFF] = {}, [AURA_TYPE_BUFF] = {}}
    end
    if #self.framePool > 0 then
        aura = tremove(self.framePool, #self.framePool)
        --Gladdy:Print("AddAura", "framepool")
    else
        --Gladdy:Print("AddAura", "CreateFrame")
        aura = CreateFrame("Frame")

        aura.texture = aura:CreateTexture(nil, "BACKGROUND")
        aura.texture:SetAllPoints(aura)
        aura.cooldowncircle = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate")
        aura.cooldowncircle.noCooldownCount = true -- disable OmniCC
        aura.cooldowncircle:SetAllPoints(aura)
        aura.cooldowncircle:SetReverse(true)
        aura.textFrame = CreateFrame("Frame", nil, aura)
        aura.textFrame:SetAllPoints(aura)
        aura.cooldown = aura.textFrame:CreateFontString(nil, "OVERLAY")
        aura.cooldown:SetAllPoints(aura)
        aura.cooldown:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.buffsFont), (20/2 - 1) * Gladdy.db.buffsFontScale, "OUTLINE")
        aura.stacks = aura.textFrame:CreateFontString(nil, "OVERLAY")
        aura.stacks:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 0, 1)
        aura.stacks:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.buffsFont), (20/3 - 1) * Gladdy.db.buffsFontScale, "OUTLINE")
    end
    aura:SetHeight(Gladdy.db.buffsIconSize)
    aura:SetWidth(Gladdy.db.buffsIconSize)
    aura:SetParent(self.frames[unit])
    if timeLeft or duration then
        aura.cooldowncircle:SetCooldown(GetTime() - (duration - timeLeft), duration)
    end
    if stacks then
        aura.stacks:SetText(stacks > 1 and stacks or "")
    end
    aura.texture:SetTexture(select(3, GetSpellInfo(spellID)))
    aura.startTime = GetTime()
    aura.endtime = timeLeft and timeLeft + GetTime() or duration and duration + GetTime() or nil
    aura.spellID = spellID
    aura.type = type
    aura.unit = unit
    aura.activeCD = nil

    local iconTimer = function(auraFrame, elapsed)
        if auraFrame.endtime then
            local timeLeftMilliSec = auraFrame.endtime - GetTime()
            local timeLeftSec = ceil(timeLeftMilliSec)
            auraFrame.timeLeft = timeLeftMilliSec
            --auraFrame.cooldowncircle:SetCooldown(auraFrame.startTime, auraFrame.endtime)
            if timeLeftSec >= 60 then
                auraFrame.cooldown:SetTextColor(0.7, 1, 0)
                auraFrame.cooldown:SetFormattedText("%dm", ceil(timeLeftSec / 60))
            elseif timeLeftSec < 60 and timeLeftSec >= 11 then
                --if it's less than 60s
                auraFrame.cooldown:SetTextColor(0.7, 1, 0)
                auraFrame.cooldown:SetFormattedText("%d", timeLeftSec)
            elseif timeLeftSec <= 10 and timeLeftSec >= 5 then
                auraFrame.cooldown:SetTextColor(1, 0.7, 0)
                auraFrame.cooldown:SetFormattedText("%d", timeLeftSec)
            elseif timeLeftSec <= 4 and timeLeftSec >= 3 then
                auraFrame.cooldown:SetTextColor(1, 0, 0)
                auraFrame.cooldown:SetFormattedText("%d", timeLeftSec)
            elseif timeLeftMilliSec <= 3 and timeLeftMilliSec > 0 then
                auraFrame.cooldown:SetTextColor(1, 0, 0)
                auraFrame.cooldown:SetFormattedText("%.1f", timeLeftMilliSec)
            elseif timeLeftMilliSec <= 0 and timeLeftMilliSec > -0.05 then -- 50ms ping max wait for SPELL_AURA_REMOVED event
                auraFrame.cooldown:SetText("")
            else -- fallback in case SPELL_AURA_REMOVED is not fired
                BuffsDebuffs:RemoveAura(auraFrame.unit, auraFrame.spellID, auraFrame.type)
            end
        else
            auraFrame.timeLeft = "undefined"
        end
    end
    aura:SetScript("OnUpdate", iconTimer)
    aura:Show()
    tinsert(self.frames[unit].auras[type], aura)
    --Gladdy:Print("AddAura", #self.frames[unit].auras[type])
end

function BuffsDebuffs:AddOrRefreshAura(unit, spellID, type, duration, timeLeft, stacks)
    for i=1,#self.frames[unit].auras[type] do
        --Gladdy:Print("AddOrRefreshAura", "Iterate", #self.frames[unit].auras[type], spellID, self.frames[unit].auras[type][i].spellID)
        if self.frames[unit].auras[type][i].spellID == spellID then
            --refresh
            --Gladdy:Print("AddOrRefreshAura", "Refresh", unit, spellID, type, duration, timeLeft, stacks)
            if (timeLeft) then
                self.frames[unit].auras[type][i].endtime = GetTime() + timeLeft
                self.frames[unit].auras[type][i].cooldowncircle:SetCooldown(GetTime() - (duration - timeLeft), duration)
            end
            if stacks then
                self.frames[unit].auras[type][i].stacks:SetText(stacks > 1 and stacks or "")
            else
                self.frames[unit].auras[type][i].stacks:SetText("")
            end
            self:UpdateAurasOnUnit(unit)
            return
        end
    end
    --add
    --Gladdy:Print("AddOrRefreshAura", "Add", unit)
    self:AddAura(unit, spellID, type, duration, timeLeft, stacks)
    self:UpdateAurasOnUnit(unit)
end

function BuffsDebuffs:UpdateAurasOnUnit(unit)
    for i=1, #self.frames[unit].auras[AURA_TYPE_BUFF] do
        if i == 1 then
            self.frames[unit].auras[AURA_TYPE_BUFF][i]:ClearAllPoints()
            self.frames[unit].auras[AURA_TYPE_BUFF][i]:SetPoint("BOTTOMLEFT", self.frames[unit], "BOTTOMLEFT")
        else
            self.frames[unit].auras[AURA_TYPE_BUFF][i]:ClearAllPoints()
            self.frames[unit].auras[AURA_TYPE_BUFF][i]:SetPoint("LEFT", self.frames[unit].auras[AURA_TYPE_BUFF][i - 1], "RIGHT")
        end
    end
    for i=1, #self.frames[unit].auras[AURA_TYPE_DEBUFF] do
        if i == 1 then
            self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:ClearAllPoints()
            self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:SetPoint("BOTTOMRIGHT", self.frames[unit], "BOTTOMLEFT")
        else
            self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:ClearAllPoints()
            self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:SetPoint("RIGHT", self.frames[unit].auras[AURA_TYPE_DEBUFF][i - 1], "LEFT")
        end
    end
end

function BuffsDebuffs:RemoveAura(unit, spellID, type)
    if type and unit then
        if self.frames[unit].auras[type] then
            for i=1,#self.frames[unit].auras[type] do
                if self.frames[unit].auras[type][i].spellID == spellID then
                    self.frames[unit].auras[type][i]:Hide()
                    self.frames[unit].auras[type][i]:SetScript("OnUpdate", nil)
                    tinsert(self.framePool, tremove(self.frames[unit].auras[type], i))
                    break
                end
            end
        end
    else
        local found
        local l = {AURA_TYPE_DEBUFF, AURA_TYPE_BUFF}
        for j = 1, #l do
            type = l[j]
            for i=1,#self.frames[unit].auras[type] do
                if self.frames[unit].auras[type][i].spellID == spellID and self.frames[unit].auras[type][i].sourceGUID == sourceGUID then
                    self.frames[unit].auras[type][i]:Hide()
                    self.frames[unit].auras[type][i]:SetScript("OnUpdate", nil)
                    for o = 1, #self.frames[unit].auras[type][GetSpellInfo(spellID)] do
                        if self.frames[unit].auras[type][GetSpellInfo(spellID)][o].sourceGUID == sourceGUID then
                            tremove(self.frames[unit].auras[type][GetSpellInfo(spellID)], o)
                            if (#self.frames[unit].auras[type][GetSpellInfo(spellID)] == 0) then
                                self.frames[unit].auras[type][GetSpellInfo(spellID)] = nil
                            end
                            found = true
                            break
                        end
                    end
                    tinsert(self.framePool, tremove(self.frames[unit].auras[type], i))
                    break
                end
            end
            if found then
                break
            end
        end
    end
    self:UpdateAurasOnUnit(unit)
end

function BuffsDebuffs:RemoveAurasByType(unit, type)
    if self.frames[unit].auras and self.frames[unit].auras[type] then
        local i = #self.frames[unit].auras[type]
        while (i > 0) do
            self.frames[unit].auras[type][i]:Hide()
            self.frames[unit].auras[type][i]:SetScript("OnUpdate", nil)
            tinsert(self.framePool, tremove(self.frames[unit].auras[type], i))
            i = i - 1
        end
        self.frames[unit].auras[type] = {}
    end
end

function BuffsDebuffs:RemoveAuras(unit)
    if unit and self.frames[unit] then
        self:RemoveAurasByType(unit, AURA_TYPE_BUFF)
        self:RemoveAurasByType(unit, AURA_TYPE_DEBUFF)
        self:UpdateAurasOnUnit(unit)
    end
end

------------
-- OPTIONS
------------

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
                ["TOP"] = L["Top"],
                ["BOTTOM"] = L["Bottom"],
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
        spellList = {
            name = "Debuff Lists",
            type = "group",
            order = 11,
            childGroups = "tab",
            args = select(1, Gladdy:GetDebuffs()),
            set = function(info, state)
                local option = info[#info]
                Gladdy.dbi.profile.trackedDebuffs[option] = state
            end,
            get = function(info)
                local option = info[#info]
                return Gladdy.dbi.profile.trackedDebuffs[option]
            end,
        },
    }
end

