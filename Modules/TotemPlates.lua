local select, pairs = select, pairs
local AceGUIWidgetLSMlists = AceGUIWidgetLSMlists
local WorldFrame, UnitExists = WorldFrame, UnitExists
local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

---------------------------------------------------

-- Constants

---------------------------------------------------

local totemPattern = "(.+)%s[I,II,III,IV,V,VI,VII,VIII]"
local BLIZZ = "BLIZZ"
local ALOFT = "ALOFT"
local SOHIGHPLATES = "SOHIGHPLATES"
local ELVUI = "ELVUI"
local SHAGUPLATES = "SHAGUPLATES"
local totemData = {
    -- Fire
    [select(1, GetSpellInfo(3599))] = {id = 3599,texture = select(3, GetSpellInfo(3599)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Searing Totem
    [select(1, GetSpellInfo(8227))] = {id = 8227,texture = select(3, GetSpellInfo(8227)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Flametongue Totem
    [select(1, GetSpellInfo(8190))] = {id = 8190,texture = select(3, GetSpellInfo(8190)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Magma Totem
    [select(1, GetSpellInfo(1535))] = {id = 1535,texture = select(3, GetSpellInfo(1535)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Nova Totem
    [select(1, GetSpellInfo(30706))] = {id = 30706,texture = select(3, GetSpellInfo(30706)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 1}, -- Totem of Wrath
    [select(1, GetSpellInfo(32982))] = {id = 32982,texture = select(3, GetSpellInfo(32982)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Elemental Totem
    [select(1, GetSpellInfo(8181))] = {id = 8181,texture = select(3, GetSpellInfo(8181)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Frost Resistance Totem
    -- Water
    [select(1, GetSpellInfo(8184))] = {id = 8184,texture = select(3, GetSpellInfo(8184)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Resistance Totem
    [select(1, GetSpellInfo(8166))] = {id = 8166,texture = select(3, GetSpellInfo(8166)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Poison Cleansing Totem
    [select(1, GetSpellInfo(8170))] = {id = 8170,texture = select(3, GetSpellInfo(8170)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Disease Cleansing Totem
    [select(1, GetSpellInfo(5394))] = {id = 5394,texture = select(3, GetSpellInfo(5394)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Healing Stream Totem
    [select(1, GetSpellInfo(16190))] = {id = 16190,texture = select(3, GetSpellInfo(16190)), color = {r = 0.078, g = 0.9, b = 0.16, a = 1}, enabled = true, priority = 3}, -- Mana Tide Totem
    [select(1, GetSpellInfo(5675))] = {id = 5675,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_ManaRegenTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 1}, -- Mana Spring Totem
    -- Earth
    [select(1, GetSpellInfo(2484))] = {id = 2484,texture = select(3, GetSpellInfo(2484)), color = {r = 0.5, g = 0.5, b = 0.5, a = 1}, enabled = true, priority = 1}, -- Earthbind Totem
    [select(1, GetSpellInfo(5730))] = {id = 5730,texture = select(3, GetSpellInfo(5730)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Stoneclaw Totem
    [select(1, GetSpellInfo(8071))] = {id = 8071,texture = select(3, GetSpellInfo(8071)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Stoneskin Totem
    [select(1, GetSpellInfo(8075))] = {id = 8075,texture = select(3, GetSpellInfo(8075)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Strength of Earth Totem
    [select(1, GetSpellInfo(33663))] = {id = 33663,texture = select(3, GetSpellInfo(33663)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Earth Elemental Totem
    [select(1, GetSpellInfo(8143))] = {id = 8143,texture = select(3, GetSpellInfo(8143)), color = {r = 1, g = 0.9, b = 0.1, a = 1}, enabled = true, priority = 3}, -- Tremor Totem
    -- Air
    [select(1, GetSpellInfo(8177))] = {id = 8177,texture = select(3, GetSpellInfo(8177)), color = {r = 0, g = 0.53, b = 0.92, a = 1}, enabled = true, priority = 3}, -- Grounding Totem
    [select(1, GetSpellInfo(8835))] = {id = 8835,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_InvisibilityTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Grace of Air Totem
    [select(1, GetSpellInfo(10595))] = {id = 10595,texture = select(3, GetSpellInfo(10595)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Nature Resistance Totem
    [select(1, GetSpellInfo(8512))] = {id = 8512,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_Windfury_edit", color = {r = 0.96, g = 0, b = 0.07, a = 1}, enabled = true, priority = 2}, -- Windfury Totem
    [select(1, GetSpellInfo(6495))] = {id = 6495, texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_RemoveCurse_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Sentry Totem
    [select(1, GetSpellInfo(15107))] = {id = 15107,texture = select(3, GetSpellInfo(15107)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Windwall Totem
    [select(1, GetSpellInfo(3738))] = {id = 3738,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_SlowingTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Wrath of Air Totem
    [select(1, GetSpellInfo(25908))] = {id = 25908,texture = "Interface\\Icons\\INV_Staff_07", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Tranquil Air Totem
    -- fr patch
    ["Totem d'\195\169lementaire de feu"] = {id = 32982,texture = select(3, GetSpellInfo(32982)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Elemental Totem
    ["Totem d'\195\169lementaire de terre"] = {id = 33663,texture = select(3, GetSpellInfo(33663)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Earth Elemental Totem
    ["Totem de Vague de mana"] = {id = 16190,texture = select(3, GetSpellInfo(16190)), color = {r = 0.078, g = 0.9, b = 0.16, a = 1}, enabled = true, priority = 3}, -- Mana Tide Totem
}

local function GetTotemColorDefaultOptions()
    local defaultDB = {}
    local options = {
        headerTotemConfig = {
            type = "header",
            name = L["Totem Config"],
            order = 1,
        },
    }
    local indexedList = {}
    for k,v in pairs(totemData) do
        tinsert(indexedList, {name = k, id = v.id, color = v.color, texture = v.texture, enabled = v.enabled})
    end
    table.sort(indexedList, function (a, b)
        return a.name < b.name
    end)
    for i=1,#indexedList do
        defaultDB["totem" .. indexedList[i].id] = {color = indexedList[i].color, enabled = indexedList[i].enabled}
        options["totem" .. indexedList[i].id] = {
            order = i+1,
            name = "",
            inline = true,
            type = "group",
            args = {
                desc = {
                    order = 1,
                    name = indexedList[i].name,--format("|T%s:20|t %s", indexedList[i].texture, indexedList[i].name),
                    desc = format("|T%s:20|t %s", indexedList[i].texture, indexedList[i].name),
                    type = "toggle",
                    image = indexedList[i].texture,
                    width = "full",
                    get = function(info) return Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].enabled end,
                    set = function(info, value)
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].enabled = value
                        Gladdy:UpdateFrame()
                    end
                },
                color = {
                    type = "color",
                    name = L["Border color"],
                    desc = L["Color of the border"],
                    order = 2,
                    width = "full",
                    hasAlpha = true,
                    get = function(info)
                        local key = info.arg or info[#info]
                        return Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.r,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.g,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.b,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.a
                    end,
                    set = function(info, r, g, b, a)
                        local key = info.arg or info[#info]
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.r,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.g,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.b,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.a = r, g, b, a
                        Gladdy:UpdateFrame()
                    end,
                },
            }
        }
    end
    return defaultDB, options, indexedList
end

local function GetTotemColorOptions()
    local indexedList = select(3, GetTotemColorDefaultOptions())
    local colorList = {}
    for i=1, #indexedList do
        tinsert(colorList, Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color)
    end
    return colorList
end

function Gladdy:GetTotemColors()
    return GetTotemColorDefaultOptions()
end

---------------------------------------------------

-- Core

---------------------------------------------------

local TotemPlates = Gladdy:NewModule("TotemPlates", nil, {
    npTotems = true,
    npTotemPlatesBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    npTotemPlatesSize = 40,
    npTotemPlatesAlpha = 0.6,
    npTotemPlatesAlphaAlways = false,
    npTotemColors = select(1, GetTotemColorDefaultOptions())
})

LibStub("AceHook-3.0"):Embed(TotemPlates)
LibStub("AceTimer-3.0"):Embed(TotemPlates)

function TotemPlates:Initialise()
    self.numChildren = 0
    self:SetScript("OnUpdate", self.Update)
    self.Aloft = IsAddOnLoaded("Aloft")
    self.SoHighPlates = IsAddOnLoaded("SoHighPlates")
    self.ElvUI = IsAddOnLoaded("ElvUI")
    self.ShaguPlates = IsAddOnLoaded("ShaguPlates-tbc") or IsAddOnLoaded("ShaguPlates")
end

function TotemPlates:Reset()
    self:CancelAllTimers()
    self:UnhookAll()
end

---------------------------------------------------

-- Nameplate functions

---------------------------------------------------

local function getName(namePlate)
    local name
    local addon
    local _, _, _, _, nameRegion1, nameRegion2 = namePlate:GetRegions()
    if TotemPlates.Aloft then
        if namePlate.aloftData then
            name = namePlate.aloftData.name
            addon = ALOFT
        end
    elseif TotemPlates.SoHighPlates then
        if namePlate.oldname or namePlate.name then
            name = (namePlate.oldname and namePlate.oldname:GetText()) or (namePlate.name and namePlate.name:GetText())
            addon = SOHIGHPLATES
        end
    else
        if TotemPlates.ElvUI then
            if namePlate.UnitFrame then
                name = namePlate.UnitFrame.oldName:GetText()
                addon = ELVUI
            end
        end
        if not name then
            if strmatch(nameRegion1:GetText(), "%d") then
                name = nameRegion2:GetText()
            else
                name = nameRegion1:GetText()
            end
            addon = BLIZZ
        end
    end
    if TotemPlates.ShaguPlates then
        addon = SHAGUPLATES
    end
    return name, addon
end

local updateInterval, lastUpdate, frame, region, name, addon = .001, 0
function TotemPlates:Update(elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate > updateInterval then
        if NAMEPLATES_ON then
            for i = 1, WorldFrame:GetNumChildren() do
                frame = select(i, WorldFrame:GetChildren())
                region = frame:GetRegions()
                if (frame:GetNumRegions() > 2 and frame:GetNumChildren() >= 1 and frame:IsVisible()) then
                    name, addon = getName(frame)
                    if name and addon then
                        self:SkinTotem(frame, name, addon)
                    end
                end
            end
        end
    end
end

------------ ADDON specific functions -----------------
local function nameplateSetAlpha(nameplate, alpha, addonName)
    if (addonName == BLIZZ) then
        local hpborder, cbborder, cbicon, overlay, oldname, level, bossicon, raidicon = nameplate:GetRegions()
        local healthBar = nameplate:GetChildren()
        overlay:SetAlpha(alpha)
        hpborder:SetAlpha(alpha)
        oldname:SetAlpha(alpha)
        level:SetAlpha(alpha)
        healthBar:SetAlpha(alpha)
    elseif (addonName == ALOFT) then
        local aloftData = nameplate.aloftData
        if alpha == 1 then
            if aloftData.healthBar then
                aloftData.healthBar:Show()
            end
            if Aloft:AcquireDBNamespace("healthText").profile.enable and aloftData.healthTextRegion then
                aloftData.healthTextRegion:Show()
            end
            if Aloft:AcquireDBNamespace("healthText").profile.border ~= "None" and Aloft:AcquireDBNamespace("healthText").profile.backgroundAlpha ~= 0 and aloftData.backdropFrame then
                aloftData.backdropFrame:Show()
            end
            if Aloft:AcquireDBNamespace("nameText").profile.enable and aloftData.nameTextRegion then
                aloftData.nameTextRegion:Show()
            end
            if Aloft:AcquireDBNamespace("levelText").profile.enable and aloftData.levelTextRegion then
                aloftData.levelTextRegion:Show()
            end
        else
            if aloftData.healthBar then
                aloftData.healthBar:Hide()
            end
            if Aloft:AcquireDBNamespace("healthText").profile.enable and aloftData.healthTextRegion then
                aloftData.healthTextRegion:Hide()
            end
            if Aloft:AcquireDBNamespace("healthText").profile.border ~= "None" and Aloft:AcquireDBNamespace("healthText").profile.backgroundAlpha ~= 0 and aloftData.backdropFrame then
                aloftData.backdropFrame:Hide()
            end
            if Aloft:AcquireDBNamespace("nameText").profile.enable and aloftData.nameTextRegion then
                aloftData.nameTextRegion:Hide()
            end
            if Aloft:AcquireDBNamespace("levelText").profile.enable and aloftData.levelTextRegion then
                aloftData.levelTextRegion:Hide()
            end
        end
    elseif (addonName == SOHIGHPLATES) then
        if nameplate.background then nameplate.background:SetAlpha(alpha) end
        if nameplate.container then nameplate.container:SetAlpha(alpha) end
        if nameplate.health then nameplate.health:SetAlpha(alpha) end
        if nameplate.health.percent then nameplate.health.percent:SetAlpha(alpha) end
        if nameplate.level then nameplate.level:SetAlpha(alpha) end
        if nameplate.name then nameplate.name:SetAlpha(alpha) end
        if (alpha == 1) then __sNpCore:ConfigSetValue(nameplate) end
    elseif (addonName == ELVUI) then
        if alpha == 1 then
            nameplate.UnitFrame:Show()
        else
            nameplate.UnitFrame:Hide()
        end
    elseif (addonName == SHAGUPLATES) then
        local _,_,shaguPlate = nameplate:GetChildren()
        if shaguPlate then
            if shaguPlate.health then shaguPlate.health:SetAlpha(alpha) end
            if shaguPlate.name then shaguPlate.name:SetAlpha(alpha) end
            if shaguPlate.glow then shaguPlate.glow:SetAlpha(alpha) end
            if shaguPlate.level then shaguPlate.level:SetAlpha(alpha) end
        end
    end
end

function TotemPlates:SkinTotem(nameplate, nameplateName, addonName)
    local totemName = select(1, string.match(nameplateName, totemPattern)) or nameplateName
    local totemDataEntry = totemData[totemName]
    if (addonName == BLIZZ
            or addonName == ALOFT
            or addonName == ELVUI
            or addonName == SOHIGHPLATES and GetCVar('_sNpTotem') ~= '1'
            or addonName == SHAGUPLATES and ShaguPlates_config.nameplates.totemicons ~= "1")
            and Gladdy.db.npTotems then
        if (totemDataEntry and Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].enabled) then
            nameplateSetAlpha(nameplate, 0.01, addonName)

            if not nameplate.gladdyTotemFrame then
                nameplate.gladdyTotemFrame = CreateFrame("Frame", nil)
                nameplate.gladdyTotemFrame:SetFrameStrata("BACKGROUND")
                nameplate.gladdyTotemFrame.parent = nameplate
                nameplate.gladdyTotemFrame:ClearAllPoints()
                nameplate.gladdyTotemFrame:SetPoint("CENTER", nameplate, "CENTER", 0, 0)
                nameplate.gladdyTotemFrame:SetWidth(Gladdy.db.npTotemPlatesSize)
                nameplate.gladdyTotemFrame:SetHeight(Gladdy.db.npTotemPlatesSize)
                nameplate.gladdyTotemFrame.totemIcon = nameplate.gladdyTotemFrame:CreateTexture(nil, "BACKGROUND")
                nameplate.gladdyTotemFrame.totemIcon:ClearAllPoints()
                nameplate.gladdyTotemFrame.totemIcon:SetPoint("TOPLEFT", nameplate.gladdyTotemFrame, "TOPLEFT")
                nameplate.gladdyTotemFrame.totemIcon:SetPoint("BOTTOMRIGHT", nameplate.gladdyTotemFrame, "BOTTOMRIGHT")
                nameplate.gladdyTotemFrame.totemBorder = nameplate.gladdyTotemFrame:CreateTexture(nil, "BORDER")
                nameplate.gladdyTotemFrame.totemBorder:ClearAllPoints()
                nameplate.gladdyTotemFrame.totemBorder:SetPoint("TOPLEFT", nameplate.gladdyTotemFrame, "TOPLEFT")
                nameplate.gladdyTotemFrame.totemBorder:SetPoint("BOTTOMRIGHT", nameplate.gladdyTotemFrame, "BOTTOMRIGHT")
                nameplate.gladdyTotemFrame:SetScript("OnUpdate", function(self)
                    if not self.parent:IsVisible() then
                        self:Hide()
                    end
                end)
            else
                nameplate.gladdyTotemFrame:Show()
            end

            if (UnitExists("target") and nameplate:GetAlpha() ~= 1) then
                -- target exists and totem is not target
                nameplate:SetAlpha(Gladdy.db.npTotemPlatesAlpha)
                nameplate.gladdyTotemFrame:SetAlpha(Gladdy.db.npTotemPlatesAlpha)
            elseif (UnitExists("target") and nameplate:GetAlpha() == 1) then
                -- target exists and totem is target
                nameplate:SetAlpha(1)
                nameplate.gladdyTotemFrame:SetAlpha(1)
            elseif (not UnitExists("target") and Gladdy.db.npTotemPlatesAlphaAlways) then
                -- no target and option npTotemPlatesAlphaAlways == true
                nameplate:SetAlpha(Gladdy.db.npTotemPlatesAlpha)
                nameplate.gladdyTotemFrame:SetAlpha(Gladdy.db.npTotemPlatesAlpha)
            else
                -- no target
                nameplate.gladdyTotemFrame:SetAlpha(0.95)
            end

            nameplate.gladdyTotemFrame:SetWidth(Gladdy.db.npTotemPlatesSize)
            nameplate.gladdyTotemFrame:SetHeight(Gladdy.db.npTotemPlatesSize)
            nameplate.gladdyTotemFrame:SetFrameLevel(totemDataEntry.priority or 0)
            nameplate.gladdyTotemFrame.totemIcon:SetTexture(totemDataEntry.texture)
            nameplate.gladdyTotemFrame.totemBorder:SetTexture(Gladdy.db.npTotemPlatesBorderStyle)
            nameplate.gladdyTotemFrame.totemBorder:SetVertexColor(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.r,
                    Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.g,
                    Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.b,
                    Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.a)
        else
            nameplateSetAlpha(nameplate, 1, addonName)
            if nameplate.gladdyTotemFrame then
                nameplate.gladdyTotemFrame:Hide()
            end
        end
    else
        if nameplate.gladdyTotemFrame then
            nameplate.gladdyTotemFrame:Hide()
        end
    end
end

---------------------------------------------------

-- Interface options

---------------------------------------------------

function TotemPlates:GetOptions()
    return {
        headerCastbar = {
            type = "header",
            name = L["Totem General"],
            order = 2,
        },
        npTotems = Gladdy:option({
            type = "toggle",
            name = L["Totem icons on/off"],
            desc = L["Turns totem icons instead of nameplates on or off. (Requires reload)"],
            order = 9,
        }),
        npTotemPlatesSize = Gladdy:option({
            type = "range",
            name = L["Totem size"],
            desc = L["Size of totem icons"],
            order = 10,
            min = 20,
            max = 100,
            step = 1,
        }),
        npTotemPlatesAlpha = Gladdy:option({
            type = "range",
            name = L["Totem alpha"],
            desc = L["Alpha of totem icons"],
            order = 11,
            min = 0.1,
            max = 0.95,
            step = 0.01,
        }),
        npTotemPlatesAlphaAlways = Gladdy:option({
            type = "toggle",
            name = L["Always apply alpha"],
            desc = L["Always applies alpha outside of being targeted"],
            order = 12,
        }),
        npTotemPlatesBorderStyle = Gladdy:option({
            type = "select",
            name = L["Totem icon border style"],
            order = 13,
            values = Gladdy:GetIconStyles()
        }),
        npAllTotemColors = {
            type = "color",
            name = L["All totem border color"],
            order = 14,
            hasAlpha = true,
            get = function(info)
                local colors = GetTotemColorOptions()
                local color = colors[1]
                for i=2, #colors do
                    if colors[i].r ~= color.r or colors[i].r ~= color.r or colors[i].r ~= color.r or colors[i].r ~= color.r then
                        return 0, 0, 0, 0
                    end
                end
                return color.r, color.g, color.b, color.a
            end,
            set = function(info, r, g, b, a)
                local colors = GetTotemColorOptions()
                for i=1, #colors do
                    colors[i].r = r
                    colors[i].g = g
                    colors[i].b = b
                    colors[i].a = a
                end
            end,
        },
        npTotemColors = {
            order = 15,
            name = "Customize Totems",
            type = "group",
            childGroups = "simple",
            args = select(2, Gladdy:GetTotemColors())
        },
    }
end