local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AceGUIWidgetLSMlists = AceGUIWidgetLSMlists
local WorldFrame = WorldFrame
local select = select
local pairs = pairs

local knownNameplates = {}
local unitsToCheck = {}
local function generateUnitsToCheck()
    local function targettarget(unit, max)
        for i=1, max do
            local index
            if max == 1 then index = "" else index = i end
            unitsToCheck[unit .. index] = true
            unitsToCheck[unit .. index .. "pet"] = true
            unitsToCheck[unit .. index .. "pettarget"] = true
            unitsToCheck[unit .. index .. "target"] = true
            unitsToCheck[unit .. index .. "targetpet"] = true
            unitsToCheck[unit .. index .. "targetpettarget"] = true
            unitsToCheck[unit .. index .. "targettarget"] = true
            unitsToCheck[unit .. index .. "targettargetpet"] = true
            unitsToCheck[unit .. index .. "targettargetpettarget"] = true
        end
    end
    targettarget("raid", 15) -- typical BG size
    targettarget("party", 4)
    targettarget("target", 1)
    targettarget("focus", 1)
    targettarget("mouseover", 1)
    targettarget("player", 1)
end

---------------------------------------------------

-- Core

---------------------------------------------------

local PlateCastBar = Gladdy:NewModule("PlateCastBar", nil, {
    --module
    npCastbarsEnable = true,
    npCastbarGuess = false,
    --castbar
    npCastbarsTexture = "Smooth",
    npCastbarsWidth = 105,
    npCastbarsHeight = 17,
    npCastbarsPointX = 0,
    npCastbarsPointY = -5,
    npCastbarsBarColor = { r = 1, g = 0.8, b = 0.2, a = 1 },
    npCastbarsBgColor = { r = 0, g = 0, b = 0, a = 0.8 },
    --icon
    npCastbarsIconSize = 20,
    npCastbarsIconPos = "LEFT",
    --flags
    npCastbarsEnableIcon = true,
    npCastbarsEnableTimer = true,
    npCastbarsEnableSpell = true,
    --font
    npCastbarsFont = "DorisPP",
    npCastbarsFontColor = {r = 1, g = 1, b = 1, a = 1},
    npCastbarsFontSize = 9,
    npCastbarsTimerFormat = "LEFT",
    --borders
    npCastbarsBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\UI-Tooltip-Border_round_selfmade",
    npCastbarsBorderColor = {r = 0, g = 0, b = 0, a = 1},
    npCastbarsIconStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    npCastbarsIconColor = {r = 0, g = 0, b = 0, a = 1},
    npCastbarsBorderSize = 8,

})
LibStub("AceHook-3.0"):Embed(PlateCastBar)
LibStub("AceTimer-3.0"):Embed(PlateCastBar)

function PlateCastBar:Initialise()
    generateUnitsToCheck()
    self.unitCastBars = {}
    self.numChildren = 0
    self:CastBars_Create()
    self:SetScript("OnUpdate", self.Update)
    self.Aloft = IsAddOnLoaded("Aloft")
    self.SoHighPlates = IsAddOnLoaded("SoHighPlates")
    self.ElvUI = IsAddOnLoaded("ElvUI")
    self.ShaguPlates = IsAddOnLoaded("ShaguPlates-tbc") or IsAddOnLoaded("ShaguPlates")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", function (self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            self.numChildren = 0
            knownNameplates = {}
        end
    end)
end

---------------------------------------------------

-- PlateCastBar nameplate functions

---------------------------------------------------

local function getName(namePlate)
    local name, parent
    if PlateCastBar.Aloft then
        if namePlate.aloftData then
            name = namePlate.aloftData.name
            parent = namePlate.aloftData.healthBar
        end
    elseif PlateCastBar.SoHighPlates then
        if namePlate.oldname or namePlate.name then
            name = (namePlate.oldname and namePlate.oldname:GetText()) or (namePlate.name and namePlate.name:GetText())
            parent = namePlate.container
        end
    else
        if PlateCastBar.ElvUI then
            if namePlate.UnitFrame then
                name = namePlate.UnitFrame.oldName:GetText()
                parent = namePlate.container
            end
        end
        if not name then
            local hpborder, _, _, _, nameRegion1, nameRegion2 = namePlate:GetRegions()
            if strmatch(nameRegion1:GetText(), "%d") then
                name = nameRegion2:GetText()
            else
                name = nameRegion1:GetText()
            end
            parent = hpborder
        end
    end
    return name, parent
end

function PlateCastBar:UnitCastBar_Create(unit)
    self.unitCastBars["castbar"..unit] = CreateFrame("Frame", nil)
    local CastBar = self.unitCastBars["castbar"..unit]
    CastBar:SetBackdrop({ edgeFile = Gladdy.db.npCastbarsBorderStyle,
                                 edgeSize = Gladdy.db.npCastbarsBorderSize })
    CastBar:SetBackdropBorderColor(Gladdy.db.npCastbarsBorderColor.r, Gladdy.db.npCastbarsBorderColor.g, Gladdy.db.npCastbarsBorderColor.b, Gladdy.db.npCastbarsBorderColor.a)
    CastBar:SetFrameStrata("MEDIUM")
    CastBar:SetPoint("CENTER")
    CastBar:SetWidth(Gladdy.db.npCastbarsWidth);
    CastBar:SetHeight(Gladdy.db.npCastbarsHeight);
    CastBar:SetFrameLevel(1)
    CastBar:Hide()

    CastBar.bar = CreateFrame("StatusBar",nil, CastBar)
    CastBar.bar:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.npCastbarsTexture))
    CastBar.bar:SetStatusBarColor(Gladdy.db.npCastbarsBarColor.r, Gladdy.db.npCastbarsBarColor.g, Gladdy.db.npCastbarsBarColor.b, Gladdy.db.npCastbarsBarColor.a)
    CastBar.bar:SetMinMaxValues(0, 100)
    CastBar.bar:ClearAllPoints()
    CastBar.bar:SetPoint("TOPLEFT", CastBar, "TOPLEFT", (Gladdy.db.npCastbarsBorderSize/7), -(Gladdy.db.npCastbarsBorderSize/7))
    CastBar.bar:SetPoint("BOTTOMRIGHT", CastBar, "BOTTOMRIGHT", -(Gladdy.db.npCastbarsBorderSize/7), (Gladdy.db.npCastbarsBorderSize/7))
    CastBar.bar:SetFrameStrata("MEDIUM")
    CastBar.bar:SetFrameLevel(0)

    CastBar.background = CastBar.bar:CreateTexture(nil, "BACKGROUND");
    CastBar.background:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.npCastbarsTexture))
    CastBar.background:SetVertexColor(Gladdy.db.npCastbarsBgColor.r, Gladdy.db.npCastbarsBgColor.g, Gladdy.db.npCastbarsBgColor.b, Gladdy.db.npCastbarsBgColor.a)
    CastBar.background:SetAllPoints(CastBar.bar)

    CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
    CastBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    CastBar.Spark:SetBlendMode("ADD")
    CastBar.Spark:SetWidth(8)
    CastBar.Spark:SetHeight(Gladdy.db.npCastbarsHeight * 1.8)

    CastBar.spellName = CastBar.bar:CreateFontString(nil)
    CastBar.spellName:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.npCastbarsFont), Gladdy.db.npCastbarsFontSize, "OUTLINE")
    CastBar.spellName:SetPoint("LEFT", CastBar.bar, "LEFT", 2, 0);
    if (Gladdy.db.npCastbarsEnableSpell) then
        CastBar.spellName:Show()
    else
        CastBar.spellName:Hide()
    end

    CastBar.spellTime = CastBar.bar:CreateFontString(nil)
    CastBar.spellTime:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.npCastbarsFont), Gladdy.db.npCastbarsFontSize, "OUTLINE")
    CastBar.spellTime:SetPoint("RIGHT", CastBar.bar, "RIGHT", -2, 0);
    if (Gladdy.db.npCastbarsEnableTimer) then
        CastBar.spellTime:Show()
    else
        CastBar.spellTime:Hide()
    end

    CastBar.icon = CastBar:CreateTexture(nil, "BACKGROUND");
    CastBar.icon:SetHeight(Gladdy.db.npCastbarsIconSize);
    CastBar.icon:SetWidth(Gladdy.db.npCastbarsIconSize);
    if Gladdy.db.npCastbarsIconPos == "LEFT" then
        CastBar.icon:SetPoint("RIGHT", CastBar, Gladdy.db.npCastbarsIconPos, -1, 0)
    else
        CastBar.icon:SetPoint("LEFT", CastBar, Gladdy.db.npCastbarsIconPos, 1, 0)
    end
    CastBar.icon.border = CastBar:CreateTexture(nil, "BORDER")
    CastBar.icon.border:SetTexture(Gladdy.db.npCastbarsIconStyle)
    CastBar.icon.border:SetAllPoints(CastBar.icon)
    CastBar.icon.border:SetVertexColor(Gladdy.db.npCastbarsIconColor.r, Gladdy.db.npCastbarsIconColor.g, Gladdy.db.npCastbarsIconColor.b, Gladdy.db.npCastbarsIconColor.a)
    if (Gladdy.db.npCastbarsEnableIcon) then
        CastBar.icon:Show()
        CastBar.icon.border:Show()
    else
        CastBar.icon:Hide()
        CastBar.icon.border:Hide()
    end
    CastBar:SetScript("OnUpdate", function(self)
        if self.parent and not self.parent:IsVisible() then
            if self.parent.CastBarEnabled == self then
                self.parent.CastBarEnabled = nil
            end
            self.parent = nil
            self:Hide()
        end
    end)
end

local function UpdateFrame(unit)
    local CastBar = PlateCastBar.unitCastBars["castbar"..unit]
    --bar
    CastBar.bar:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.npCastbarsTexture))
    CastBar.bar:SetStatusBarColor(Gladdy.db.npCastbarsBarColor.r, Gladdy.db.npCastbarsBarColor.g, Gladdy.db.npCastbarsBarColor.b, Gladdy.db.npCastbarsBarColor.a)

    --border
    CastBar:SetWidth(Gladdy.db.npCastbarsWidth)
    CastBar:SetHeight(Gladdy.db.npCastbarsHeight)
    CastBar:SetBackdrop({ edgeFile = Gladdy.db.npCastbarsBorderStyle,
                                 edgeSize = Gladdy.db.npCastbarsBorderSize })
    CastBar:SetBackdropBorderColor(Gladdy.db.npCastbarsBorderColor.r, Gladdy.db.npCastbarsBorderColor.g, Gladdy.db.npCastbarsBorderColor.b, Gladdy.db.npCastbarsBorderColor.a)
    CastBar:ClearAllPoints()

    --background
    CastBar.background:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.npCastbarsTexture))
    CastBar.background:SetVertexColor(Gladdy.db.npCastbarsBgColor.r, Gladdy.db.npCastbarsBgColor.g, Gladdy.db.npCastbarsBgColor.b, Gladdy.db.npCastbarsBgColor.a)

    --font
    CastBar.spellName:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.npCastbarsFont), Gladdy.db.npCastbarsFontSize, "OUTLINE")
    CastBar.spellName:SetTextColor(Gladdy.db.npCastbarsFontColor.r, Gladdy.db.npCastbarsFontColor.g, Gladdy.db.npCastbarsFontColor.b, Gladdy.db.npCastbarsFontColor.a)

    CastBar.spellTime:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.npCastbarsFont), Gladdy.db.npCastbarsFontSize, "OUTLINE")
    CastBar.spellTime:SetTextColor(Gladdy.db.npCastbarsFontColor.r, Gladdy.db.npCastbarsFontColor.g, Gladdy.db.npCastbarsFontColor.b, Gladdy.db.npCastbarsFontColor.a)

    if (Gladdy.db.npCastbarsEnableSpell) then
        CastBar.spellName:Show()
    else
        CastBar.spellName:Hide()
    end
    if (Gladdy.db.npCastbarsEnableTimer) then
        CastBar.spellTime:Show()
    else
        CastBar.spellTime:Hide()
    end

    --icon
    CastBar.icon:SetHeight(Gladdy.db.npCastbarsIconSize)
    CastBar.icon:SetWidth(Gladdy.db.npCastbarsIconSize)
    CastBar.icon:ClearAllPoints()
    if Gladdy.db.npCastbarsIconPos == "LEFT" then
        CastBar.icon:SetPoint("RIGHT", CastBar, Gladdy.db.npCastbarsIconPos, -1, 0)
    else
        CastBar.icon:SetPoint("LEFT", CastBar, Gladdy.db.npCastbarsIconPos, 1, 0)
    end
    CastBar.icon.border:SetTexture(Gladdy.db.npCastbarsIconStyle)
    CastBar.icon.border:SetVertexColor(Gladdy.db.npCastbarsIconColor.r, Gladdy.db.npCastbarsIconColor.g, Gladdy.db.npCastbarsIconColor.b, Gladdy.db.npCastbarsIconColor.a)
    if (Gladdy.db.npCastbarsEnableIcon) then
        CastBar.icon:Show()
        CastBar.icon.border:Show()
    else
        CastBar.icon:Hide()
        CastBar.icon.border:Hide()
    end

    CastBar.Spark:SetHeight(Gladdy.db.npCastbarsHeight * 1.8)
end

function PlateCastBar:CastBars_Create()
    for k, v in pairs(unitsToCheck) do
        PlateCastBar:UnitCastBar_Create(k)
    end
end

function PlateCastBar:UpdateFrame()
    for k, v in pairs(unitsToCheck) do
        UpdateFrame(k)
    end
end

local function keepCastbar(unit)
    local CastBar = PlateCastBar.unitCastBars["castbar"..unit]

    if (Gladdy.db.npCastbarGuess == false) then
        CastBar.castTime = nil
        CastBar.parent.CastBarEnabled = nil
        CastBar:SetAlpha(0)
        CastBar:Hide()
        return
    end

    if CastBar.isChannelling then
        CastBar.castTime = CastBar.endTime - GetTime()
    else
        CastBar.castTime = GetTime() - CastBar.startTime
    end
    CastBar.bar:SetValue(CastBar.castTime)

    local sparkPosition = ((CastBar.castTime - CastBar.startTime) / (CastBar.maxCastTime - CastBar.startTime)) * (Gladdy.db.npCastbarsWidth - (Gladdy.db.npCastbarsBorderSize/7)*2);
    if ( sparkPosition < 0 ) then
        sparkPosition = 0
    end
    CastBar.Spark:SetPoint("CENTER", CastBar.bar, "LEFT", sparkPosition, 0)


    if CastBar.castTime and CastBar.castTime < CastBar.maxCastTime then

        local total = string.format("%.2f", CastBar.maxCastTime)
        local left = string.format("%.1f", CastBar.castTime)

        if (Gladdy.db.npCastbarsTimerFormat == "LEFT") then
            CastBar.spellTime:SetText(left)
        elseif (Gladdy.db.npCastbarsTimerFormat == "TOTAL") then
            CastBar.spellTime:SetText(total)
        elseif (Gladdy.db.npCastbarsTimerFormat == "BOTH") then
            CastBar.spellTime:SetText(left .. " / " .. total)
        end
        -- in case nameplate with matching name isn't found, hide castbar
        local found = false
        for plate, _ in pairs(knownNameplates) do
            if (plate:IsVisible() and (not plate.CastBarEnabled or plate.CastBarEnabled == CastBar)) then
                local name, parent = getName(plate)
                if name and name == CastBar.name then
                    found = true
                    CastBar:SetPoint("TOP", parent, "BOTTOM", Gladdy.db.npCastbarsPointX, Gladdy.db.npCastbarsPointY)
                    CastBar.parent = plate
                    plate.CastBarEnabled = CastBar
                    break
                end
            end
        end
        if not found then
            CastBar:SetAlpha(0)
            CastBar:Hide()
        end
    elseif CastBar.castTime and CastBar.castTime > CastBar.maxCastTime then
        CastBar.castTime = nil
        CastBar.parent.CastBarEnabled = nil
        CastBar:SetAlpha(0)
        CastBar:Hide()
    end
end

local function keepCastbars()
    for unit, v in pairs(unitsToCheck) do
        -- double check that fallback function is only used if no info is pulled for unit
        if PlateCastBar.unitCastBars["castbar"..unit].castTime
                and (PlateCastBar.unitCastBars["castbar"..unit].isChannelling and not UnitChannelInfo(unit)
                or not PlateCastBar.unitCastBars["castbar"..unit].isChannelling and not UnitCastingInfo(unit)) then
            keepCastbar(unit)
        end
    end
end

local function createCastbars()
    -- decide whether castbar should be showing or not
    if Gladdy.db.npCastbarsEnable then
        for frame, _ in pairs(knownNameplates) do
            if frame:IsVisible() then
                for unit, _ in pairs(unitsToCheck) do
                    local name,parent = getName(frame)
                    local CastBar = PlateCastBar.unitCastBars["castbar"..unit]

                    -- cast detected, display castbar
                    if (name and name == UnitName(unit) and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) then
                        if (not frame.CastBarEnabled or frame.CastBarEnabled == CastBar) then --prevent double castbars
                            local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill
                            if (UnitChannelInfo(unit)) then
                                CastBar.isChannelling = true
                                name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit)
                            else
                                CastBar.isChannelling = false
                                name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit)
                            end

                            if (string.len(name) > 12) then
                                name = (string.sub(name, 1, 12) .. ".. ")
                            end

                            CastBar.spellName:SetText(name)
                            CastBar.icon:SetTexture(texture)

                            if endTime / 1000 ~= CastBar.endTime then
                                CastBar.startTime = startTime/1000
                                CastBar.endTime = endTime/1000
                                CastBar.maxCastTime = CastBar.endTime - CastBar.startTime
                                if CastBar.isChannelling then
                                    CastBar.castTime = CastBar.endTime - GetTime()
                                else
                                    CastBar.castTime = 0
                                end
                                CastBar.bar:SetMinMaxValues(0, CastBar.maxCastTime)
                            end
                            if CastBar.isChannelling then
                                CastBar.castTime = CastBar.endTime - GetTime()
                            else
                                CastBar.castTime = GetTime() - CastBar.startTime
                            end
                            CastBar.bar:SetValue(CastBar.castTime)
                            local sparkPosition = ((CastBar.castTime) / (CastBar.maxCastTime)) * (Gladdy.db.npCastbarsWidth - (Gladdy.db.npCastbarsBorderSize/7)*2);
                            if ( sparkPosition < 0 ) then
                                sparkPosition = 0
                            end
                            CastBar.Spark:SetPoint("CENTER", CastBar.bar, "LEFT", sparkPosition, 0)

                            CastBar.name = UnitName(unit)
                            CastBar:SetAlpha(1)
                            CastBar:SetPoint("TOP", parent, "BOTTOM", Gladdy.db.npCastbarsPointX, Gladdy.db.npCastbarsPointY)
                            CastBar:Show()
                            CastBar.parent = frame

                            local total = string.format("%.2f", CastBar.maxCastTime)
                            local left = string.format("%.1f", CastBar.castTime)
                            if (Gladdy.db.npCastbarsTimerFormat == "LEFT") then
                                CastBar.spellTime:SetText(left)
                            elseif (Gladdy.db.npCastbarsTimerFormat == "TOTAL") then
                                CastBar.spellTime:SetText(total)
                            elseif (Gladdy.db.npCastbarsTimerFormat == "BOTH") then
                                CastBar.spellTime:SetText(left .. " / " .. total)
                            end
                            frame.CastBarEnabled = CastBar
                        end
                        -- hide castbar if unit stops casting
                    elseif (name == UnitName(unit) and (not UnitCastingInfo(unit) or not UnitChannelInfo(unit))) then
                        frame.CastBarEnabled = nil
                        CastBar:SetAlpha(0)
                        CastBar:Hide()
                    end
                end
            end
        end
        --fallback function in case no casting information was found but we still want to display progress on the bar
        keepCastbars()
    else
        for unit, v in pairs(unitsToCheck) do
            PlateCastBar.unitCastBars["castbar"..unit]:Hide()
        end
    end
end

function PlateCastBar:HookFrames(...)
    for index = 1, select('#', ...) do
        local frame = select(index, ...)
        if (frame:GetNumRegions() > 2 and frame:GetNumChildren() >= 1) then
            knownNameplates[frame] = true
        end
    end
end

function PlateCastBar:Update()
    if (WorldFrame:GetNumChildren() ~= self.numChildren) then
        self.numChildren = WorldFrame:GetNumChildren()
        self:HookFrames(WorldFrame:GetChildren())
    end
    createCastbars()
end

---------------------------------------------------

-- PlateCastBar options

---------------------------------------------------

local function option(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile[key]
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile[key] = value
            Gladdy.options.args.PlateCastBar.args.npCastbarsBorderSize.max = Gladdy.db.npCastbarsHeight/2
            if Gladdy.db.npCastbarsBorderSize > Gladdy.db.npCastbarsHeight/2 then
                Gladdy.db.npCastbarsBorderSize = Gladdy.db.npCastbarsHeight/2
            end
            PlateCastBar:UpdateFrame()
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
            PlateCastBar:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function PlateCastBar:GetOptions()
    return {
        headerCastbar = {
            type = "header",
            name = L["Castbar"],
            order = 2,
        },
        npCastbarsEnable = {
            type = "toggle",
            name = L["Castbars on/off"],
            desc = L["Turns castbars of nameplates on or off."],
            order = 3,
            get = function(info) return Gladdy.db.npCastbarsEnable end,
            set = function(info, value)
                Gladdy.db.npCastbarsEnable = value
                if value then
                    pcall(SetCVar, "ShowVKeyCastbar", 0)
                else
                    pcall(SetCVar, "ShowVKeyCastbar", 1)
                end
            end,
        },
        npCastbarGuess = option({
            type = "toggle",
            name = L["Castbar guesses on/off"],
            desc = L["If disabled, castbars will stop as soon as you lose your 'unit', e.g. mouseover or your party targeting someone else."
                    .. "\nDisable this, if you see castbars, even though the player isn't casting."],
            order = 4,
        }),
        npCastbarsTexture = option({
            type = "select",
            name = L["Bar texture"],
            desc = L["Texture of the bar"],
            order = 5,
            dialogControl = "LSM30_Statusbar",
            values = AceGUIWidgetLSMlists.statusbar, --Gladdy.LSM:Fetch("statusbar", Gladdy.db.powerBarTexture)
        }),
        npCastbarsWidth = option({
            type = "range",
            name = L["Bar width"],
            desc = L["Height of the bar"],
            order = 6,
            min = 1,
            max = 300,
            step = 1,
        }),
        npCastbarsHeight = option({
            type = "range",
            name = L["Bar height"],
            desc = L["Height of the bar"],
            order = 7,
            min = 1,
            max = 50,
            step = 1,
        }),
        npCastbarsBarColor = colorOption({
            type = "color",
            name = L["Bar color"],
            desc = L["Color of the cast bar"],
            order = 8,
            hasAlpha = true,
        }),
        npCastbarsBgColor = colorOption({
            type = "color",
            name = L["Background color"],
            desc = L["Color of the cast bar background"],
            order = 9,
            hasAlpha = true,
        }),
        headerPosition = {
            type = "header",
            name = L["Position"],
            order = 10,
        },
        npCastbarsPointX = option({
            type = "range",
            name = L["Horizontal offset"],
            desc = L["Height of the bar"],
            order = 11,
            min = -100,
            max = 100,
            step = 1,
        }),
        npCastbarsPointY = option({
            type = "range",
            name = L["Vertical offset"],
            desc = L["Height of the bar"],
            order = 12,
            min = -100,
            max = 100,
            step = 1,
        }),
        --Icon
        headerIcon = {
            type = "header",
            name = L["Icon"],
            order = 20,
        },
        npCastbarsEnableIcon = option({
            type = "toggle",
            name = L["Enable icon"],
            order = 21,
        }),
        npCastbarsIconSize = option({
            type = "range",
            name = L["Icon size"],
            desc = L["Height of the bar"],
            order = 22,
            min = 1,
            max = 50,
            step = 1,
        }),
        npCastbarsIconPos = option({
            type = "select",
            name = L["Position"],
            order = 23,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        --Font
        headerFont = {
            type = "header",
            name = L["Font"],
            order = 30,
        },
        npCastbarsEnableSpell = option({
            type = "toggle",
            name = L["Enable spell text"],
            order = 31,
        }),
        npCastbarsEnableTimer = option({
            type = "toggle",
            name = L["Enable timer text"],
            order = 32,
        }),
        npCastbarsFont = option({
            type = "select",
            name = L["Bar font"],
            desc = L["Font of the status text"],
            order = 33,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        npCastbarsFontColor = colorOption({
            type = "color",
            name = L["Font color"],
            order = 34,
            hasAlpha = true,
        }),
        npCastbarsFontSize = option({
            type = "range",
            name = L["Font size"],
            desc = L["Size of the text"],
            order = 35,
            min = 1,
            max = 20,
        }),
        npCastbarsTimerFormat = option({
            type = "select",
            name = L["Position"],
            order = 36,
            values = {
                ["LEFT"] = L["Left"],
                ["TOTAL"] = L["Total"],
                ["BOTH"] = L["Both"],
            },
        }),
        --borders
        headerBorder = {
            type = "header",
            name = L["Borders"],
            order = 40,
        },
        npCastbarsBorderStyle = option({
            type = "select",
            name = L["Status Bar border"],
            order = 41,
            values = Gladdy:GetBorderStyles()
        }),
        npCastbarsBorderSize = option({
            type = "range",
            name = L["Border size"],
            order = 42,
            min = 0.5,
            max = Gladdy.db.npCastbarsHeight/2,
            step = 0.5,
        }),
        npCastbarsBorderColor = colorOption({
            type = "color",
            name = L["Status Bar border color"],
            order = 43,
            hasAlpha = true,
        }),
        npCastbarsIconStyle = option({
            type = "select",
            name = L["Icon border"],
            order = 44,
            values = Gladdy:GetIconStyles(),
        }),
        npCastbarsIconColor = colorOption({
            type = "color",
            name = L["Icon border color"],
            order = 45,
            hasAlpha = true,
        }),
    }
end