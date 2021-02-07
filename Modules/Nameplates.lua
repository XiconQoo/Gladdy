local select = select
local pairs = pairs
local WorldFrame = WorldFrame
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
    -- Elemental
    [select(1, GetSpellInfo(3599))] = {id = 3599,texture = select(3, GetSpellInfo(3599)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Searing Totem
    [select(1, GetSpellInfo(8227))] = {id = 8227,texture = select(3, GetSpellInfo(8227)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Flametongue Totem
    [select(1, GetSpellInfo(2484))] = {id = 2484,texture = select(3, GetSpellInfo(2484)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Earthbind Totem
    [select(1, GetSpellInfo(5730))] = {id = 5730,texture = select(3, GetSpellInfo(5730)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Stoneclaw Totem
    [select(1, GetSpellInfo(1535))] = {id = 1535,texture = select(3, GetSpellInfo(1535)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Fire Nova Totem
    [select(1, GetSpellInfo(8190))] = {id = 8190,texture = select(3, GetSpellInfo(8190)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Magma Totem
    [select(1, GetSpellInfo(30706))] = {id = 30706,texture = select(3, GetSpellInfo(30706)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Totem of Wrath
    [select(1, GetSpellInfo(32982))] = {id = 32982,texture = select(3, GetSpellInfo(32982)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Fire Elemental Totem
    -- Enhancement
    [select(1, GetSpellInfo(8071))] = {id = 8071,texture = select(3, GetSpellInfo(8071)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Stoneskin Totem
    [select(1, GetSpellInfo(33663))] = {id = 33663,texture = select(3, GetSpellInfo(33663)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Earth Elemental Totem
    [select(1, GetSpellInfo(8075))] = {id = 8075,texture = select(3, GetSpellInfo(8075)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Strength of Earth Totem
    [select(1, GetSpellInfo(8181))] = {id = 8181,texture = select(3, GetSpellInfo(8181)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Frost Resistance Totem
    [select(1, GetSpellInfo(8184))] = {id = 8184,texture = select(3, GetSpellInfo(8184)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Fire Resistance Totem
    [select(1, GetSpellInfo(8177))] = {id = 8177,texture = select(3, GetSpellInfo(8177)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Grounding Totem
    [select(1, GetSpellInfo(8835))] = {id = 8835,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_InvisibilityTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Grace of Air Totem
    [select(1, GetSpellInfo(10595))] = {id = 10595,texture = select(3, GetSpellInfo(10595)), color = {r = 0, g = 0, b = 0, a = 1}}, -- Nature Resistance Totem
    [select(1, GetSpellInfo(8512))] = {id = 8512,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_Windfury_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Windfury Totem
    [select(1, GetSpellInfo(6495))] = {id = 6495, texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_RemoveCurse_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Sentry Totem
    [select(1, GetSpellInfo(15107))] = {id = 15107,texture = select(3, GetSpellInfo(15107)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Windwall Totem
    [select(1, GetSpellInfo(3738))] = {id = 3738,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_SlowingTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Wrath of Air Totem
    -- Restoration
    [select(1, GetSpellInfo(8143))] = {id = 8143,texture = select(3, GetSpellInfo(8143)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Tremor Totem
    [select(1, GetSpellInfo(5394))] = {id = 5394,texture = select(3, GetSpellInfo(5394)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Healing Stream Totem
    [select(1, GetSpellInfo(8166))] = {id = 8166,texture = select(3, GetSpellInfo(8166)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Poison Cleansing Totem
    [select(1, GetSpellInfo(5675))] = {id = 5675,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_ManaRegenTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Mana Spring Totem
    [select(1, GetSpellInfo(8170))] = {id = 8170,texture = select(3, GetSpellInfo(8170)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Disease Cleansing Totem
    [select(1, GetSpellInfo(16190))] = {id = 16190,texture = select(3, GetSpellInfo(16190)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Mana Tide Totem
    [select(1, GetSpellInfo(25908))] = {id = 25908,texture = "Interface\\Icons\\INV_Staff_07", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true}, -- Tranquil Air Totem
}

local function GetTotemColorDefaultOptions()
    local defaultDB = {}
    local options = {}
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
            order = i,
            name = "",
            inline = true,
            type = "group",
            args = {
                desc = {
                    order = 1,
                    name = format("|T%s:20|t %s", indexedList[i].texture, indexedList[i].name),
                    type = "toggle",
                    --image = indexedList[i].texture,
                    width = "1",
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
                    width = "half",
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

local totems = {
    ["Nameplates"] = {}
}

---------------------------------------------------

-- Core

---------------------------------------------------

local Nameplates = Gladdy:NewModule("Nameplates", nil, {
    npTotems = true,
    npCastbars = true,
    npCastbarGuess = false,
    npCastbarsFont = "DorisPP",
    npCastbarsFontColor = {r = 1, g = 1, b = 1, a = 1},
    npCastBarTexture = "Smooth",
    npTotemPlatesBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    npTotemPlatesSize = 40,
    npTotemPlatesAlpha = 0.9,
    npTotemColors = select(1, GetTotemColorDefaultOptions())
})

LibStub("AceHook-3.0"):Embed(Nameplates)
LibStub("AceTimer-3.0"):Embed(Nameplates)

function Nameplates:Initialise()
    self.numChildren = 0
    self:SetScript("OnUpdate", self.Update)
    Nameplates.Aloft = IsAddOnLoaded("Aloft")
    Nameplates.SoHighPlates = IsAddOnLoaded("SoHighPlates")
    Nameplates.ElvUI = IsAddOnLoaded("ElvUI")
    Nameplates.ShaguPlates = IsAddOnLoaded("ShaguPlates-tbc") or IsAddOnLoaded("ShaguPlates")
end

function Nameplates:Reset()
    self:CancelAllTimers()
    self:UnhookAll()
    self.numChildren = 0
end

---------------------------------------------------

-- Nameplate functions

---------------------------------------------------

local function getName(namePlate)
    local name
    local addon
    local _, _, _, _, nameRegion1, _, nameRegion2 = namePlate:GetRegions()
    if Nameplates.Aloft then
        if namePlate.aloftData then
            name = namePlate.aloftData.name
            addon = ALOFT
        end
    elseif Nameplates.SoHighPlates then
        if namePlate.oldname or namePlate.name then
            name = (namePlate.oldname and namePlate.oldname:GetText()) or (namePlate.name and namePlate.name:GetText())
            addon = SOHIGHPLATES
        end
    else
        if Nameplates.ElvUI then
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
    if Nameplates.ShaguPlates then
        addon = SHAGUPLATES
    end
    return name, addon
end

local updateInterval, lastUpdate, num, frame, region, name, totemName, addon = .001, 0
function Nameplates:Update(elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate > updateInterval then
        if NAMEPLATES_ON then
            num = WorldFrame:GetNumChildren()
            for i = 1, num do
                frame = select(i, WorldFrame:GetChildren())
                region = frame:GetRegions()
                if (frame:GetNumRegions() > 2 and frame:GetNumChildren() >= 1) then
                    if frame:IsVisible() then
                        name, addon = getName(frame)
                        if name then
                            totemName = select(1, string.match(name, totemPattern)) or name
                            if totemName then
                                totems["Nameplates"][frame] = true
                                self:SkinTotems(frame)
                            end
                        end
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
        nameplate:SetFrameStrata(alpha == 1 and "LOW" or "BACKGROUND")
        local aloftData = nameplate.aloftData
        aloftData.healthBar:SetAlpha(alpha)
        if aloftData.healthTextRegion then aloftData.healthTextRegion:SetAlpha(alpha) end
        aloftData.backdropFrame:SetAlpha(alpha)
        aloftData.highlightRegion:SetAlpha(alpha)
        aloftData.nameTextRegion:SetAlpha(alpha)
        aloftData.levelTextRegion:SetAlpha(alpha)
        aloftData.bossIconRegion:SetAlpha(alpha)
    elseif (addonName == SOHIGHPLATES) then
        nameplate.background:SetAlpha(alpha)
        nameplate.container:SetAlpha(alpha)
        nameplate.health:SetAlpha(alpha)
        nameplate.health.percent:SetAlpha(alpha)
        nameplate.level:SetAlpha(alpha)
        nameplate.name:SetAlpha(alpha)
    elseif (addonName == ELVUI) then
        if alpha == 1 then
            nameplate.UnitFrame:Show()
        else
            nameplate.UnitFrame:Hide()
        end
    elseif (addonName == SHAGUPLATES) then
        local _,_,shaguPlate = nameplate:GetChildren()
        if shaguPlate and shaguPlate.original then
            shaguPlate.health:SetAlpha(alpha)
            shaguPlate.name:SetAlpha(alpha)
            shaguPlate.glow:SetAlpha(alpha)
            shaguPlate.level:SetAlpha(alpha)
        end
    end
end

local function UpdateNameplate(healthBar)
    local nameplate = healthBar:GetParent()
    local totemTexture = totemData[totemName]

    if (addon == BLIZZ
            or addon == ALOFT
            or addon == ELVUI
            or addon == SOHIGHPLATES and GetCVar('_sNpTotem') ~= '1'
            or addon == SHAGUPLATES and ShaguPlates_config.nameplates.totemicons ~= "1")
            and Gladdy.db.npTotems then
        if (totemTexture and Gladdy.db.npTotemColors["totem" .. totemData[totemName].id].enabled) then
            nameplateSetAlpha(nameplate, 0.01, addon)

            if not nameplate.totem then
                nameplate.totem = nameplate:CreateTexture(nil, "BACKGROUND")
                nameplate.totem:ClearAllPoints()
                nameplate.totem:SetPoint("CENTER", nameplate, "CENTER", 0, 0)
                nameplate.totem.border = nameplate:CreateTexture(nil, "BORDER")
            else
                nameplate.totem:Show()
                nameplate.totem.border:Show()
            end

            -- set alpha
            if (UnitExists("target") and nameplate:GetAlpha() < 1) then
                nameplate:SetAlpha(Gladdy.db.npTotemPlatesAlpha)
                nameplate.totem:SetAlpha(Gladdy.db.npTotemPlatesAlpha)
                nameplate.totem.border:SetAlpha(Gladdy.db.npTotemPlatesAlpha)
            else
                nameplate:SetAlpha(1)
                nameplate.totem:SetAlpha(1)
                nameplate.totem.border:SetAlpha(1)
            end

            nameplate.totem:SetTexture(totemTexture.texture)
            nameplate.totem:SetWidth(Gladdy.db.npTotemPlatesSize)
            nameplate.totem:SetHeight(Gladdy.db.npTotemPlatesSize)
            nameplate.totem.border:SetTexture(Gladdy.db.npTotemPlatesBorderStyle)
            nameplate.totem.border:SetVertexColor(Gladdy.db.npTotemColors["totem" .. totemData[totemName].id].color.r,
                    Gladdy.db.npTotemColors["totem" .. totemData[totemName].id].color.g,
                    Gladdy.db.npTotemColors["totem" .. totemData[totemName].id].color.b,
                    Gladdy.db.npTotemColors["totem" .. totemData[totemName].id].color.a)
            nameplate.totem.border:ClearAllPoints()
            nameplate.totem.border:SetPoint("TOPLEFT", nameplate.totem, "TOPLEFT")
            nameplate.totem.border:SetPoint("BOTTOMRIGHT", nameplate.totem, "BOTTOMRIGHT")
        else
            nameplateSetAlpha(nameplate, 1, addon)
            if nameplate.totem then
                nameplate.totem:Hide()
                nameplate.totem.border:Hide()
            end
        end
    else
        if nameplate.totem then
            nameplate.totem:Hide()
            nameplate.totem.border:Hide()
        end
    end
end

function Nameplates:SkinTotems(plate)
    local HealthBar = plate:GetChildren()
    HealthBar:SetScript("OnShow", UpdateNameplate)
    HealthBar:SetScript("OnSizeChanged", UpdateNameplate)
    UpdateNameplate(HealthBar)
    totems["Nameplates"][plate] = true
end

function Nameplates:HookTotems(...)
    for index = 1, select('#', ...) do
        local plate = select(index, ...)
        local regions = plate:GetRegions()
        if (not totems["Nameplates"][plate]
                and not plate:GetName()
                and regions and regions:GetObjectType() == "Texture"
                and regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border") then
            self:SkinTotems(plate)
            plate.region = regions
        end
    end
end

---------------------------------------------------

-- Interface options

---------------------------------------------------

function Nameplates:GetOptions()
    return {
        npTotems = Gladdy:option({
            type = "toggle",
            name = L["Totem icons on/off"],
            desc = L["Turns totem icons instead of nameplates on or off. (Requires reload)"],
            order = 2,
        }),
        npCastbars = Gladdy:option({
            type = "toggle",
            name = L["Castbars on/off"],
            desc = L["Turns castbars of nameplates on or off. (Requires reload)"],
            order = 3,
        }),
        npCastbarGuess = Gladdy:option({
            type = "toggle",
            name = L["Castbar guesses on/off"],
            desc = L["If disabled, castbars will stop as soon as you lose your 'unit', e.g. mouseover or your party targeting someone else."
                    .. "\nDisable this, if you see castbars, even though the player isn't casting."],
            order = 4,
        }),
        npCastBarTexture = Gladdy:option({
            type = "select",
            name = L["Bar texture"],
            desc = L["Texture of the bar"],
            order = 5,
            dialogControl = "LSM30_Statusbar",
            values = AceGUIWidgetLSMlists.statusbar, --Gladdy.LSM:Fetch("statusbar", Gladdy.db.powerBarTexture)
        }),
        npCastbarsFont = Gladdy:option({
            type = "select",
            name = L["Bar font"],
            desc = L["Font of the status text"],
            order = 6,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        npCastbarsFontColor = Gladdy:colorOption({
            type = "color",
            name = L["Font color"],
            order = 7,
            hasAlpha = true,
        }),
        npTotemPlatesSize = Gladdy:option({
            type = "range",
            name = L["Totem size"],
            desc = L["Size of totem icons"],
            order = 8,
            min = 20,
            max = 100,
            step = 1,
        }),
        npTotemPlatesBorderStyle = Gladdy:option({
            type = "select",
            name = L["Totem icon border style"],
            order = 9,
            values = Gladdy:GetIconStyles()
        }),
        npTotemPlatesAlpha = Gladdy:option({
            type = "range",
            name = L["Totem alpha"],
            desc = L["Alpha of totem icons"],
            order = 11,
            min = 0.1,
            max = 0.9,
            step = 0.01,
        }),
        npAllTotemColors = {
            type = "color",
            name = L["All totem border color"],
            order = 12,
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
            order = 13,
            name = "Customize Totems",
            type = "group",
            childGroups = "simple",
            args = select(2, Gladdy:GetTotemColors())
        },
    }
end