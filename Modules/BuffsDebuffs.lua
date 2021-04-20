local GetSpellInfo = GetSpellInfo
local CreateFrame = CreateFrame
local GetTime = GetTime
local select, tonumber, ceil, type, tremove, tinsert, pairs, strmatch, tostring, error = select, tonumber, ceil, type, tremove, tinsert, pairs, string.match, tostring, error
local bit_band = bit.band
local auraTypeColor = { }
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local UnitBuff, UnitDebuff, GetSpellLink = UnitBuff, UnitDebuff, GetSpellLink
auraTypeColor["none"]     = { r = 0.80, g = 0, b = 0 , a = 1}
auraTypeColor["magic"]    = { r = 0.20, g = 0.60, b = 1.00, a = 1}
auraTypeColor["curse"]    = { r = 0.60, g = 0.00, b = 1.00, a = 1 }
auraTypeColor["disease"]  = { r = 0.60, g = 0.40, b = 0, a = 1 }
auraTypeColor["poison"]   = { r = 0.00, g = 0.60, b = 0, a = 1 }
auraTypeColor["immune"]   = { r = 1.00, g = 0.02, b = 0.99, a = 1 }
auraTypeColor[""] = auraTypeColor["none"]

---------------------------
-- Queue implementation
---------------------------
local MAX_CL_BUFFER_TIME = 1.2
local Queue = {}
function Queue.new(name)
    return {first = 0, last = -1, name = name}
end
function Queue.pushleft (list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end
function Queue.pushright (list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
end
function Queue.popleft (list)
    local first = list.first
    if first > list.last then error("list is empty") end
    local value = list[first]
    list[first] = nil        -- to allow garbage collection
    list.first = first + 1
    return value
end
function Queue.peekleft(list)
    local first = list.first
    if first > list.last then error("list is empty") end
    return list[first]
end
function Queue.peekleftwithoffset(list, offset)
    local first = list.first + offset
    if first > list.last then error("invalid offset") end
    return list[first]
end
function Queue.popright (list)
    local last = list.last
    if list.first > last then error("list is empty") end
    local value = list[last]
    list[last] = nil         -- to allow garbage collection
    list.last = last - 1
    return value
end
function Queue.peekright(list)
    local last = list.last
    if list.first > last then error("list is empty") end
    return list[last]
end
function Queue.peekrightwithoffset(list, offset)
    local last = list.last - offset
    if list.first > last then error("invalid offset") end
    return list[last]
end
function Queue.size(list)
    return list.last - list.first + 1
end
function Queue.reduce(list, timestamp, maxTimeDifference)
    while Queue.size(list) > 0 do
        if timestamp - Queue.peekleft(list).timestamp > maxTimeDifference then
            Queue.popleft(list)
        else
            break
        end
    end
end

---------------------------
-- Module init
---------------------------

local Gladdy = LibStub("Gladdy")
local LibAuraDurations = LibStub("LibAuraDurations-1.0")
local DRData = LibStub("DRData-1.0")
local spellDurations = LibAuraDurations.spells
local L = Gladdy.L
local defaultTrackedDebuffs = select(2, Gladdy:GetDebuffs())
local BuffsDebuffs = Gladdy:NewModule("BuffsDebuffs", nil, {
    buffsEnabled = true,
    buffsIconSize = 30,
    buffsDisableCircle = false,
    buffsCooldownAlpha = 1,
    buffsFont = "DorisPP",
    buffsFontScale = 1,
    buffsFontColor = {r = 1, g = 1, b = 0, a = 1},
    buffsDynamicColor = true,
    buffsCooldownPos = "TOP",
    buffsCooldownGrowDirection = "RIGHT",
    buffsXOffset = 0,
    buffsYOffset = 0,
    buffsBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_squared_blp",
    buffsBorderColor = {r = 1, g = 1, b = 1, a = 1},
    trackedDebuffs = defaultTrackedDebuffs,
    buffsBorderColorCurse = auraTypeColor["curse"],
    buffsBorderColorMagic = auraTypeColor["magic"],
    buffsBorderColorPoison = auraTypeColor["poison"],
    buffsBorderColorPhysical = auraTypeColor["none"],
    buffsBorderColorImmune = auraTypeColor["immune"],
    buffsBorderColorDisease = auraTypeColor["disease"],
})

local spellSchoolToOptionValueTable
local function spellSchoolToOptionValue(spellSchool)
    return spellSchoolToOptionValueTable[spellSchool].r,
        spellSchoolToOptionValueTable[spellSchool].g,
        spellSchoolToOptionValueTable[spellSchool].b,
        spellSchoolToOptionValueTable[spellSchool].a
end

function BuffsDebuffs:OnEvent(event, ...)
    self[event](self, ...)
end

function BuffsDebuffs:Initialise()
    self.frames = {}
    self.spells = {}
    self.icons = {}
    self.trackedCC = {}
    self.framePool = {}
    self:RegisterMessage("JOINED_ARENA")
    self:SetScript("OnEvent", BuffsDebuffs.OnEvent)
    spellSchoolToOptionValueTable = {
        curse = Gladdy.db.buffsBorderColorCurse,
        magic = Gladdy.db.buffsBorderColorMagic,
        poison = Gladdy.db.buffsBorderColorPoison,
        physical = Gladdy.db.buffsBorderColorPhysical,
        immune = Gladdy.db.buffsBorderColorImmune,
        disease = Gladdy.db.buffsBorderColorDisease,
    }
end

function BuffsDebuffs:JOINED_ARENA()
    if Gladdy.db.buffsEnabled then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

function BuffsDebuffs:Reset()
    for unit in pairs(Gladdy.buttons) do
        self:RemoveAuras(unit)
    end
    for i=1,#self.framePool do
        self.framePool[i]:Hide()
    end
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function BuffsDebuffs:Test(unit)
    if Gladdy.db.buffsEnabled then
        if unit == "arena1" or unit == "arena3" then
            self:AddOrRefreshAura(unit, 1943, AURA_TYPE_DEBUFF, 10, 10, 1,"physical")
            self:AddOrRefreshAura(unit, 18647, AURA_TYPE_DEBUFF, 10, 10,1, "immune")
            self:AddOrRefreshAura(unit, 27218, AURA_TYPE_DEBUFF, 24, 20,1, "curse")
            self:AddOrRefreshAura(unit, 27216, AURA_TYPE_DEBUFF, 18, 18,1, "magic")
            self:AddOrRefreshAura(unit, 27189, AURA_TYPE_DEBUFF, 12, 12,5, "poison")
        elseif unit == "arena2" then
            self:AddOrRefreshAura(unit, 1943, AURA_TYPE_DEBUFF, 10, 10, 1, "physical")
            self:AddOrRefreshAura(unit, 1, AURA_TYPE_DEBUFF, 20, 20,5, "poison")
        end
    end
end

---------------------------
-- Debuff handlers
---------------------------

function BuffsDebuffs:GetDebuffDuration(spellID, destUnit)
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
    if self.frames[destUnit][DRData:GetSpellCategory(spellID)] then
        duration = duration * self.frames[destUnit][DRData:GetSpellCategory(spellID)].diminished
    end
    return duration
end

function BuffsDebuffs:DiminishAuraFade(spellID, destUnit)
    local drCat = DRData:GetSpellCategory(spellID)
    if drCat then
        if( not self.frames[destUnit][drCat] ) then
            self.frames[destUnit][drCat] = { reset = 0, diminished = 1.0 }
        end
        local time = GetTime()
        local tracked = self.frames[destUnit][drCat]
        tracked.reset = time + DRData:GetResetTime()
        tracked.diminished = DRData:NextDR(tracked.diminished)
    end
end

function BuffsDebuffs:DiminishAuraApplied(spellID, destUnit)
    local drCat = DRData:GetSpellCategory(spellID)
    if drCat then
        -- See if we should reset it back to undiminished
        local tracked = self.frames[destUnit][drCat]
        if( tracked and tracked.reset <= GetTime() ) then
            tracked.diminished = 1.0
        end
    end
end

local CAST_SUCCESS_queue = Queue.new("CAST_SUCCESS")
local SPELL_DAMAGE_queue = Queue.new("SPELL_DAMAGE")
local SWING_DAMAGE_queue = Queue.new("SWING_DAMAGE")
local function findSourceGUID(event, spellid, destGUID)
    local list
    if event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_START" then -- "SPELL_CAST_START" is fired on Corruption, although it's an instant cast when skilled
        list = CAST_SUCCESS_queue
    elseif event == "SPELL_DAMAGE" then
        list = SPELL_DAMAGE_queue
    elseif event == "SWING_DAMAGE" then
        list = SWING_DAMAGE_queue
        spellid = nil
    end
    for i=0,Queue.size(list)-1 do
        local entry = Queue.peekrightwithoffset(list, i)
        if spellid then
            if event == "SPELL_CAST_START" then
                if spellid == entry.spellID then
                    entry.spellID = "nil" -- remove from list
                    return entry.srcGUID
                end
            else
                if spellid == entry.spellID and tostring(entry.destGUID) == tostring(destGUID) then
                    entry.spellID = "nil"  -- remove from list
                    return entry.srcGUID
                end
            end
        elseif tostring(entry.destGUID) == tostring(destGUID) then
            return entry.srcGUID
        end
    end
    return nil
end
local function getSourceGUID(spellID, destinationGUID)
    if spellDurations[spellID].stacking then
        if spellDurations[spellID].preEvent then
            local sourceGUID
            if (type(spellDurations[spellID].preEvent) == "table") then
                for i=1,#spellDurations[spellID].preEvent do
                    if (type(spellDurations[spellID].preEvent[i]) == "table") then
                        sourceGUID = findSourceGUID(spellDurations[spellID].preEvent[i].event, spellDurations[spellID].preEvent[i].spellID, destinationGUID)
                    else
                        sourceGUID = findSourceGUID(spellDurations[spellID].preEvent[i], spellID, destinationGUID)
                    end

                    if sourceGUID then
                        return sourceGUID
                    end
                end
            else
                sourceGUID = findSourceGUID(spellDurations[spellID].preEvent, spellID, destinationGUID)
            end
            if sourceGUID then
                return sourceGUID
            end
        end
        return nil
    else
        return "NONE"
    end
end
function BuffsDebuffs:COMBAT_LOG_EVENT_UNFILTERED(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destinationGUID, destName, destFlags, spellID, spellName, spellSchool, auraType, amount, ...)
    local destUnit = Gladdy.guids[destinationGUID]
    local srcUnit = Gladdy.guids[sourceGUID]
    local isFriendlyUnit = bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
    if (eventType == "SPELL_CAST_SUCCESS" or "SPELL_CAST_START") and isFriendlyUnit and spellDurations[spellID] then
        Queue.reduce(CAST_SUCCESS_queue, timestamp, MAX_CL_BUFFER_TIME)
        Queue.pushright(CAST_SUCCESS_queue, { spellName = spellName, spellID = spellID, timestamp = timestamp, srcGUID = sourceGUID, destGUID = destinationGUID})
    elseif eventType == "SPELL_DAMAGE" and isFriendlyUnit and (spellDurations[spellID] or spellID == 5940) then -- Shiv deadly poison
        Queue.reduce(SPELL_DAMAGE_queue, timestamp, MAX_CL_BUFFER_TIME)
        Queue.pushright(SPELL_DAMAGE_queue, { spellName = spellName, spellID = spellID, timestamp = timestamp, srcGUID = sourceGUID, destGUID = destinationGUID})
    elseif eventType == "SWING_DAMAGE" and isFriendlyUnit then
        Queue.reduce(SWING_DAMAGE_queue, timestamp, MAX_CL_BUFFER_TIME)
        Queue.pushright(SWING_DAMAGE_queue, { spellName = spellName, spellID = spellID, timestamp = timestamp, srcGUID = sourceGUID, destGUID = destinationGUID})
    end

    if not destUnit or srcUnit then return end
    local Auras = Gladdy.modules.Auras
    spellName = (spellID == 31117 or spellID ==  43523) and "Unstable Affliction Silence" or spellName
    local aura = Auras.auras[spellName]

    local duration
    if not aura and Gladdy.eventGrps[eventType] == "BUFF" and spellDurations[spellID] and Gladdy.db.trackedDebuffs[spellName] then
        local auraSourceGUID = getSourceGUID(spellID, destinationGUID)
        if auraType == AURA_TYPE_DEBUFF and auraSourceGUID then
            self:DiminishAuraApplied(spellID, destUnit)
            duration = self:GetDebuffDuration(spellID, destUnit)
            self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF, duration, duration, amount, spellDurations[spellID].buffType, auraSourceGUID)
        else
            if spellID == 45438 or spellID == 642 then --IceBlock, Bubble
                self:RemoveAuras(destUnit)
            end
        end
    elseif not aura and Gladdy.eventGrps[eventType] == "REFRESH" and spellDurations[spellID] and Gladdy.db.trackedDebuffs[spellName] then
        local auraSourceGUID = getSourceGUID(spellID, destinationGUID)
        if auraType == AURA_TYPE_DEBUFF and auraSourceGUID then
            self:DiminishAuraFade(spellID, destUnit)
            duration = self:GetDebuffDuration(spellID, destUnit)
            self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF, duration, duration, nil, spellDurations[spellID].buffType, auraSourceGUID)
        else

        end
    elseif (Gladdy.eventGrps[eventType] == "FADE") and spellDurations[spellID] and Gladdy.db.trackedDebuffs[spellName] then
        local auraSourceGUID = getSourceGUID(spellID, destinationGUID)
        if auraType == AURA_TYPE_DEBUFF then
            self:DiminishAuraFade(spellID, destUnit)
            self:DEBUFF_FADE(eventType, destUnit, spellID, spellName, amount, auraSourceGUID == "NONE" and "NONE" or sourceGUID)
        else
            self:BUFF_FADE(eventType, destUnit, spellID, amount, sourceGUID)
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
            local spellID = tonumber(strmatch(spellLink, "spell:(%d+)"))
            if not Auras.auras[name] and spellID and (not Gladdy.bufflibEnabled and expTime or Gladdy.bufflibEnabled and expTime and isMine)  then
                --self:DEBUFF_GAIN("UnitDebuff", button.unit, spellID, stacks, duration, expTime)
            end
        end
        index = index + 1
    end
end

---------------------------
-- Frame init
---------------------------

function BuffsDebuffs:CreateFrame(unit)
    local buffFrame = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    buffFrame:SetHeight(Gladdy.db.buffsIconSize)
    buffFrame:SetWidth(1)
    buffFrame:SetPoint("BOTTOMLEFT", Gladdy.buttons[unit].healthBar, "TOPLEFT", 0, Gladdy.db.highlightBorderSize + Gladdy.db.padding)
    self.frames[unit] = buffFrame
    self.frames[unit].auras = {[AURA_TYPE_DEBUFF] = {}, [AURA_TYPE_BUFF] = {}}
end

local function styleIcon(aura)
    aura:SetWidth(Gladdy.db.buffsIconSize)
    aura:SetHeight(Gladdy.db.buffsIconSize)
    aura.cooldowncircle:SetAlpha(Gladdy.db.buffsCooldownAlpha)
    aura.border:SetTexture(Gladdy.db.buffsBorderStyle)
    aura.cooldown:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.buffsFont), (Gladdy.db.buffsIconSize/2 - 1) * Gladdy.db.buffsFontScale, "OUTLINE")
    aura.cooldown:SetTextColor(Gladdy.db.buffsFontColor.r, Gladdy.db.buffsFontColor.g, Gladdy.db.buffsFontColor.b, Gladdy.db.buffsFontColor.a)
    aura.stacks:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.buffsFont), (Gladdy.db.buffsIconSize/3 - 1) * Gladdy.db.buffsFontScale, "OUTLINE")
    aura.stacks:SetTextColor(Gladdy.db.buffsFontColor.r, Gladdy.db.buffsFontColor.g, Gladdy.db.buffsFontColor.b, Gladdy.db.buffsFontColor.a)
end

function BuffsDebuffs:UpdateFrame(unit)
    self.frames[unit]:SetHeight(Gladdy.db.buffsIconSize)
    self.frames[unit]:ClearAllPoints()
    local horizontalMargin = Gladdy.db.highlightBorderSize
    local verticalMargin = -(Gladdy.db.powerBarHeight)/2
    if Gladdy.db.buffsCooldownPos == "TOP" then
        verticalMargin = horizontalMargin + 1
        if Gladdy.db.cooldownYPos == "TOP" and Gladdy.db.cooldown then
            verticalMargin = verticalMargin + Gladdy.db.cooldownSize
        end
        if Gladdy.db.buffsCooldownGrowDirection == "LEFT" then
            self.frames[unit]:SetPoint("BOTTOMLEFT", Gladdy.buttons[unit].healthBar, "TOPRIGHT", Gladdy.db.buffsXOffset, Gladdy.db.buffsYOffset + verticalMargin)
        else
            self.frames[unit]:SetPoint("BOTTOMRIGHT", Gladdy.buttons[unit].healthBar, "TOPLEFT", Gladdy.db.buffsXOffset, Gladdy.db.buffsYOffset + verticalMargin)
        end
    elseif Gladdy.db.buffsCooldownPos == "BOTTOM" then
        verticalMargin = horizontalMargin + 1
        if Gladdy.db.cooldownYPos == "BOTTOM" and Gladdy.db.cooldown then
            verticalMargin = verticalMargin + Gladdy.db.cooldownSize
        end
        if Gladdy.db.buffsCooldownGrowDirection == "LEFT" then
            self.frames[unit]:SetPoint("TOPLEFT", Gladdy.buttons[unit].powerBar, "BOTTOMRIGHT", Gladdy.db.buffsXOffset, Gladdy.db.buffsYOffset -verticalMargin)
        else
            self.frames[unit]:SetPoint("TOPRIGHT", Gladdy.buttons[unit].powerBar, "BOTTOMLEFT", Gladdy.db.buffsXOffset, Gladdy.db.buffsYOffset -verticalMargin)
        end
    elseif Gladdy.db.buffsCooldownPos == "LEFT" then
        horizontalMargin = horizontalMargin - 1 + Gladdy.db.padding
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
        if (Gladdy.db.drCooldownPos == "LEFT" and Gladdy.db.drEnabled) then
            verticalMargin = verticalMargin + Gladdy.db.drIconSize/2 + Gladdy.db.padding/2
        end
        if (Gladdy.db.castBarPos == "LEFT") then
            verticalMargin = verticalMargin -
                    (((Gladdy.db.castBarHeight < Gladdy.db.castBarIconSize) and Gladdy.db.castBarIconSize
                            or Gladdy.db.castBarHeight)/2 + Gladdy.db.padding/2)
        end
        if (Gladdy.db.cooldownYPos == "LEFT" and Gladdy.db.cooldown) then
            verticalMargin = verticalMargin + (Gladdy.db.buffsIconSize/2 + Gladdy.db.padding/2)
        end
        self.frames[unit]:SetPoint("RIGHT", Gladdy.buttons[unit].healthBar, "LEFT", -horizontalMargin + Gladdy.db.buffsXOffset, Gladdy.db.buffsYOffset + verticalMargin)
    elseif Gladdy.db.buffsCooldownPos == "RIGHT" then
        horizontalMargin = horizontalMargin - 1 + Gladdy.db.padding
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
        if (Gladdy.db.drCooldownPos == "RIGHT" and Gladdy.db.drEnabled) then
            verticalMargin = verticalMargin + Gladdy.db.drIconSize/2 + Gladdy.db.padding/2
        end
        if (Gladdy.db.castBarPos == "RIGHT") then
            verticalMargin = verticalMargin -
                    (((Gladdy.db.castBarHeight < Gladdy.db.castBarIconSize) and Gladdy.db.castBarIconSize
                            or Gladdy.db.castBarHeight)/2 + Gladdy.db.padding/2)
        end
        if (Gladdy.db.cooldownYPos == "RIGHT" and Gladdy.db.cooldown) then
            verticalMargin = verticalMargin + (Gladdy.db.buffsIconSize/2 + Gladdy.db.padding/2)
        end
        self.frames[unit]:SetPoint("LEFT", Gladdy.buttons[unit].healthBar, "RIGHT", horizontalMargin + Gladdy.db.buffsXOffset, Gladdy.db.buffsYOffset + verticalMargin)
    end
    for i=1, #self.frames[unit].auras[AURA_TYPE_BUFF] do
        styleIcon(self.frames[unit].auras[AURA_TYPE_BUFF][i])
    end
    for i=1, #self.frames[unit].auras[AURA_TYPE_DEBUFF] do
        styleIcon(self.frames[unit].auras[AURA_TYPE_DEBUFF][i])
    end
    for i=1, #self.framePool do
        styleIcon(self.framePool[i])
    end
    self:UpdateAurasOnUnit(unit)
end

---------------------------
-- Frame handlers
---------------------------

function BuffsDebuffs:UpdateAurasOnUnit(unit)
    for i=1, #self.frames[unit].auras[AURA_TYPE_BUFF] do
        if i == 1 then
            self.frames[unit].auras[AURA_TYPE_BUFF][i]:ClearAllPoints()
            self.frames[unit].auras[AURA_TYPE_BUFF][i]:SetPoint("BOTTOMLEFT", self.frames[unit], "BOTTOMLEFT")
        else
            if Gladdy.db.buffsCooldownGrowDirection == "LEFT" then
                self.frames[unit].auras[AURA_TYPE_BUFF][i]:ClearAllPoints()
                self.frames[unit].auras[AURA_TYPE_BUFF][i]:SetPoint("RIGHT", self.frames[unit].auras[AURA_TYPE_BUFF][i - 1], "LEFT", -1, 0)
            else
                self.frames[unit].auras[AURA_TYPE_BUFF][i]:ClearAllPoints()
                self.frames[unit].auras[AURA_TYPE_BUFF][i]:SetPoint("LEFT", self.frames[unit].auras[AURA_TYPE_BUFF][i - 1], "RIGHT", 1, 0)
            end
        end
    end
    for i=1, #self.frames[unit].auras[AURA_TYPE_DEBUFF] do
        if i == 1 then
            if Gladdy.db.buffsCooldownGrowDirection == "LEFT" then
                self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:ClearAllPoints()
                self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:SetPoint("RIGHT", self.frames[unit], "LEFT")
            else
                self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:ClearAllPoints()
                self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:SetPoint("LEFT", self.frames[unit], "RIGHT")
            end
        else
            if Gladdy.db.buffsCooldownGrowDirection == "LEFT" then
                self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:ClearAllPoints()
                self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:SetPoint("RIGHT", self.frames[unit].auras[AURA_TYPE_DEBUFF][i - 1], "LEFT", -1, 0)
            else
                self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:ClearAllPoints()
                self.frames[unit].auras[AURA_TYPE_DEBUFF][i]:SetPoint("LEFT", self.frames[unit].auras[AURA_TYPE_DEBUFF][i - 1], "RIGHT", 1, 0)
            end
        end
    end
end

function BuffsDebuffs:DEBUFF_FADE(eventType, destUnit, spellID, spellName, stacks, sourceGUID)
    if eventType == "SPELL_AURA_REMOVED_DOSE" or eventType == "SPELL_PERIODIC_AURA_REMOVED_DOSE" then
        if spellDurations[spellID] and Gladdy.db.trackedDebuffs[spellName] then
            self:AddOrRefreshAura(destUnit, spellID, AURA_TYPE_DEBUFF, nil, nil, stacks, spellDurations[spellID].buffType, sourceGUID == "NONE" and "NONE")
        end
    else
        self:RemoveAura(destUnit, spellID, AURA_TYPE_DEBUFF)
    end
end

function BuffsDebuffs:BUFF_FADE(eventType, destUnit, spellID)

end

function BuffsDebuffs:UNIT_DEATH(destUnit)
    self:RemoveAuras(destUnit)
end

local function iconTimer(auraFrame, elapsed)
    if auraFrame.endtime ~= "undefined" then
        local timeLeftMilliSec = auraFrame.endtime - GetTime()
        local timeLeftSec = ceil(timeLeftMilliSec)
        auraFrame.timeLeft = timeLeftMilliSec
        --auraFrame.cooldowncircle:SetCooldown(auraFrame.startTime, auraFrame.endtime)
        if timeLeftSec >= 60 then
            if Gladdy.db.buffsDynamicColor then auraFrame.cooldown:SetTextColor(0.7, 1, 0) end
            auraFrame.cooldown:SetFormattedText("%dm", ceil(timeLeftSec / 60))
        elseif timeLeftSec < 60 and timeLeftSec >= 11 then
            --if it's less than 60s
            if Gladdy.db.buffsDynamicColor then auraFrame.cooldown:SetTextColor(0.7, 1, 0) end
            auraFrame.cooldown:SetFormattedText("%d", timeLeftSec)
        elseif timeLeftSec <= 10 and timeLeftSec >= 5 then
            if Gladdy.db.buffsDynamicColor then auraFrame.cooldown:SetTextColor(1, 0.7, 0) end
            auraFrame.cooldown:SetFormattedText("%d", timeLeftSec)
        elseif timeLeftSec <= 4 and timeLeftSec >= 3 then
            if Gladdy.db.buffsDynamicColor then auraFrame.cooldown:SetTextColor(1, 0, 0) end
            auraFrame.cooldown:SetFormattedText("%d", timeLeftSec)
        elseif timeLeftMilliSec <= 3 and timeLeftMilliSec > 0 then
            if Gladdy.db.buffsDynamicColor then auraFrame.cooldown:SetTextColor(1, 0, 0) end
            auraFrame.cooldown:SetFormattedText("%.1f", timeLeftMilliSec)
        elseif timeLeftMilliSec <= 0 and timeLeftMilliSec > -0.05 then -- 50ms ping max wait for SPELL_AURA_REMOVED event
            auraFrame.cooldown:SetText("")
        else -- fallback in case SPELL_AURA_REMOVED is not fired
            BuffsDebuffs:RemoveAura(auraFrame.unit, auraFrame.spellID, auraFrame.type)
        end
    end
end

function BuffsDebuffs:AddAura(unit, spellID, auraType, duration, timeLeft, stacks, spellSchool, sourceGUID)
    local aura
    if not self.frames[unit].auras then
        self.frames[unit].auras = {[AURA_TYPE_DEBUFF] = {}, [AURA_TYPE_BUFF] = {}}
    end
    if #self.framePool > 0 then
        aura = tremove(self.framePool, #self.framePool)
    else
        aura = CreateFrame("Frame")
        aura.texture = aura:CreateTexture(nil, "BACKGROUND")
        aura.texture:SetAllPoints(aura)
        aura.cooldowncircle = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate")
        aura.cooldowncircle.noCooldownCount = true -- disable OmniCC
        aura.cooldowncircle:SetAllPoints(aura)
        aura.cooldowncircle:SetReverse(true)
        aura.overlay = CreateFrame("Frame", nil, aura)
        aura.overlay:SetAllPoints(aura)
        aura.border = aura.overlay:CreateTexture(nil, "OVERLAY")
        aura.border:SetAllPoints(aura)
        aura.cooldown = aura.overlay:CreateFontString(nil, "OVERLAY")
        aura.cooldown:SetAllPoints(aura)
        aura.stacks = aura.overlay:CreateFontString(nil, "OVERLAY")
        aura.stacks:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", 0, 3)
        styleIcon(aura)
    end
    aura:SetParent(self.frames[unit])
    if timeLeft and duration then
        aura.cooldowncircle:SetCooldown(GetTime() - (duration - timeLeft), duration)
        aura.cooldowncircle:Show()
    else
        aura.cooldowncircle:SetCooldown(0, 0)
        aura.cooldowncircle:Hide()
    end
    if stacks then
        aura.stacks:SetText(stacks > 1 and stacks or "")
    end
    aura.texture:SetTexture(select(3, GetSpellInfo(spellID)))
    aura.startTime = GetTime()
    aura.endtime = timeLeft ~= nil and timeLeft + GetTime() or "undefined"
    aura.spellID = spellID
    aura.type = auraType
    aura.unit = unit
    aura.spellSchool = spellSchool
    aura.sourceGUID = sourceGUID
    aura.border:SetVertexColor(spellSchoolToOptionValue(spellSchool))

    aura:SetScript("OnUpdate", iconTimer)
    aura:Show()
    tinsert(self.frames[unit].auras[auraType], aura)
end

function BuffsDebuffs:AddOrRefreshAura(unit, spellID, auraType, duration, timeLeft, stacks, spellSchool, sourceGUID)
    for i=1,#self.frames[unit].auras[auraType] do
        if self.frames[unit].auras[auraType][i].spellID == spellID and self.frames[unit].auras[auraType][i].sourceGUID == sourceGUID then -- refresh
            if (timeLeft) then
                self.frames[unit].auras[auraType][i].endtime = GetTime() + timeLeft
                self.frames[unit].auras[auraType][i].cooldowncircle:SetCooldown(GetTime() - (duration - timeLeft), duration)
                self.frames[unit].auras[auraType][i].cooldowncircle:Show()
            end
            if stacks then
                self.frames[unit].auras[auraType][i].stacks:SetText(stacks > 1 and stacks or "")
            end
            self:UpdateAurasOnUnit(unit)
            return
        end
    end
    --add
    self:AddAura(unit, spellID, auraType, duration, timeLeft, stacks, spellSchool, sourceGUID)
    self:UpdateAurasOnUnit(unit)
end

function BuffsDebuffs:RemoveAura(unit, spellID, auraType, sourceGUID)
    if auraType and unit then
        if self.frames[unit].auras[auraType] then
            for i=1,#self.frames[unit].auras[auraType] do
                local condition = self.frames[unit].auras[auraType][i].spellID == spellID
                if sourceGUID then
                    condition = condition and self.frames[unit].auras[auraType][i].sourceGUID == sourceGUID
                end
                if condition then
                    self.frames[unit].auras[auraType][i].cooldowncircle:SetCooldown(0, 0)
                    self.frames[unit].auras[auraType][i]:Hide()
                    self.frames[unit].auras[auraType][i].stacks:SetText("")
                    self.frames[unit].auras[auraType][i].cooldown:SetText("")
                    self.frames[unit].auras[auraType][i]:SetScript("OnUpdate", nil)
                    tinsert(self.framePool, tremove(self.frames[unit].auras[auraType], i))
                    self:UpdateAurasOnUnit(unit)
                    return
                end
            end
        end
    else
        local found
        local l = {AURA_TYPE_DEBUFF, AURA_TYPE_BUFF}
        for j = 1, #l do
            auraType = l[j]
            for i=1,#self.frames[unit].auras[auraType] do
                if self.frames[unit].auras[auraType][i].spellID == spellID and self.frames[unit].auras[auraType][i].sourceGUID == sourceGUID then
                    self.frames[unit].auras[auraType][i]:Hide()
                    self.frames[unit].auras[auraType][i]:SetScript("OnUpdate", nil)
                    for o = 1, #self.frames[unit].auras[auraType][GetSpellInfo(spellID)] do
                        if self.frames[unit].auras[auraType][GetSpellInfo(spellID)][o].sourceGUID == sourceGUID then
                            tremove(self.frames[unit].auras[auraType][GetSpellInfo(spellID)], o)
                            if (#self.frames[unit].auras[auraType][GetSpellInfo(spellID)] == 0) then
                                self.frames[unit].auras[auraType][GetSpellInfo(spellID)] = nil
                            end
                            found = true
                            break
                        end
                    end
                    tinsert(self.framePool, tremove(self.frames[unit].auras[auraType], i))
                    break
                end
            end
            if found then
                break
            end
        end
    end
end

function BuffsDebuffs:RemoveAurasByType(unit, auraType)
    if self.frames[unit].auras and self.frames[unit].auras[auraType] then
        local i = #self.frames[unit].auras[auraType]
        while (i > 0) do
            self.frames[unit].auras[auraType][i].cooldowncircle:SetCooldown(0, 0)
            self.frames[unit].auras[auraType][i]:Hide()
            self.frames[unit].auras[auraType][i].stacks:SetText("")
            self.frames[unit].auras[auraType][i].cooldown:SetText("")
            self.frames[unit].auras[auraType][i]:SetScript("OnUpdate", nil)
            tinsert(self.framePool, tremove(self.frames[unit].auras[auraType], i))
            i = i - 1
        end
        self.frames[unit].auras[auraType] = {}
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

local function option(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile[key]
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile[key] = value
            if Gladdy.db.buffsCooldownPos == "LEFT" then
                Gladdy.db.buffsCooldownGrowDirection = "LEFT"
            elseif Gladdy.db.buffsCooldownPos == "RIGHT" then
                Gladdy.db.buffsCooldownGrowDirection = "RIGHT"
            end
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function BuffsDebuffs:GetOptions()
    return {
        headerBuffs = {
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
        headerBuffsFrame = {
            type = "header",
            name = L["Frame"],
            order = 4,
        },
        buffsIconSize = Gladdy:option({
            type = "range",
            name = L["Icon Size"],
            desc = L["Size of the DR Icons"],
            order = 5,
            min = 5,
            max = 50,
            step = 1,
        }),
        buffsDisableCircle = Gladdy:option({
            type = "toggle",
            name = L["No Cooldown Circle"],
            order = 6,
        }),
        buffsCooldownAlpha = Gladdy:option({
            type = "range",
            name = L["Cooldown circle alpha"],
            min = 0,
            max = 1,
            step = 0.1,
            order = 7,
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
        buffsFontScale = Gladdy:option({
            type = "range",
            name = L["Font scale"],
            desc = L["Scale of the text"],
            order = 12,
            min = 0.1,
            max = 2,
            step = 0.1,
        }),
        buffsDynamicColor = Gladdy:option({
            type = "toggle",
            name = L["Dynamic Timer Color"],
            desc = L["Show dynamic color on cooldown numbers"],
            order = 13,
        }),
        buffsFontColor = Gladdy:colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the cooldown timer and stacks"],
            order = 14,
            hasAlpha = true,
        }),
        headerPosition = {
            type = "header",
            name = L["Position"],
            order = 20,
        },
        buffsCooldownPos = option({
            type = "select",
            name = L["Aura Position"],
            desc = L["Position of the aura icons"],
            order = 21,
            values = {
                ["TOP"] = L["Top"],
                ["BOTTOM"] = L["Bottom"],
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        buffsCooldownGrowDirection = Gladdy:option({
            type = "select",
            name = L["Grow Direction"],
            desc = L["Grow Direction of the aura icons"],
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
            min = -400,
            max = 400,
            step = 0.1,
        }),
        buffsYOffset = Gladdy:option({
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
        buffsBorderStyle = Gladdy:option({
            type = "select",
            name = L["Border style"],
            order = 31,
            values = Gladdy:GetIconStyles()
        }),
        headerBorder = {
            type = "header",
            name = L["Spell School Colors"],
            order = 40,
        },
        buffsBorderColorCurse = Gladdy:colorOption({
            type = "color",
            name = L["Curse"],
            desc = L["Color of the border"],
            order = 41,
            hasAlpha = true,
        }),
        buffsBorderColorMagic = Gladdy:colorOption({
            type = "color",
            name = L["Magic"],
            desc = L["Color of the border"],
            order = 42,
            hasAlpha = true,
        }),
        buffsBorderColorPoison = Gladdy:colorOption({
            type = "color",
            name = L["Poison"],
            desc = L["Color of the border"],
            order = 43,
            hasAlpha = true,
        }),
        buffsBorderColorPhysical = Gladdy:colorOption({
            type = "color",
            name = L["Physical"],
            desc = L["Color of the border"],
            order = 44,
            hasAlpha = true,
        }),
        buffsBorderColorImmune = Gladdy:colorOption({
            type = "color",
            name = L["Immune"],
            desc = L["Color of the border"],
            order = 45,
            hasAlpha = true,
        }),
        buffsBorderColorDisease = Gladdy:colorOption({
            type = "color",
            name = L["Disease"],
            desc = L["Color of the border"],
            order = 46,
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

