local select, pairs = select, pairs
local WorldFrame, UnitExists = WorldFrame, UnitExists
local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

---------------------------------------------------

-- Constants

---------------------------------------------------

local BLIZZ = "BLIZZ"
local ALOFT = "ALOFT"
local SOHIGHPLATES = "SOHIGHPLATES"
local ELVUI = "ELVUI"
local SHAGUPLATES = "SHAGUPLATES"
local PLATES = "PLATES"
local totemData = {
    -- Fire
    [string.lower("Searing Totem")] = {id = 3599,texture = select(3, GetSpellInfo(3599)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Searing Totem
    [string.lower("Flametongue Totem")] = {id = 8227,texture = select(3, GetSpellInfo(8227)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Flametongue Totem
    [string.lower("Magma Totem")] = {id = 8190,texture = select(3, GetSpellInfo(8190)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Magma Totem
    [string.lower("Fire Nova Totem")] = {id = 1535,texture = select(3, GetSpellInfo(1535)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Nova Totem
    [string.lower("Totem of Wrath")] = {id = 30706,texture = select(3, GetSpellInfo(30706)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 1}, -- Totem of Wrath
    [string.lower("Fire Elemental Totem")] = {id = 32982,texture = select(3, GetSpellInfo(32982)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Elemental Totem
    [string.lower("Frost Resistance Totem")] = {id = 8181,texture = select(3, GetSpellInfo(8181)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Frost Resistance Totem
    -- Water
    [string.lower("Fire Resistance Totem")] = {id = 8184,texture = select(3, GetSpellInfo(8184)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Resistance Totem
    [string.lower("Poison Cleansing Totem")] = {id = 8166,texture = select(3, GetSpellInfo(8166)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Poison Cleansing Totem
    [string.lower("Disease Cleansing Totem")] = {id = 8170,texture = select(3, GetSpellInfo(8170)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Disease Cleansing Totem
    [string.lower("Healing Stream Totem")] = {id = 5394,texture = select(3, GetSpellInfo(5394)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Healing Stream Totem
    [string.lower("Mana Tide Totem")] = {id = 16190,texture = select(3, GetSpellInfo(16190)), color = {r = 0.078, g = 0.9, b = 0.16, a = 1}, enabled = true, priority = 3}, -- Mana Tide Totem
    [string.lower("Mana Spring Totem")] = {id = 5675,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_ManaRegenTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 1}, -- Mana Spring Totem
    -- Earth
    [string.lower("Earthbind Totem")] = {id = 2484,texture = select(3, GetSpellInfo(2484)), color = {r = 0.5, g = 0.5, b = 0.5, a = 1}, enabled = true, priority = 1}, -- Earthbind Totem
    [string.lower("Stoneclaw Totem")] = {id = 5730,texture = select(3, GetSpellInfo(5730)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Stoneclaw Totem
    [string.lower("Stoneskin Totem")] = {id = 8071,texture = select(3, GetSpellInfo(8071)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Stoneskin Totem
    [string.lower("Strength of Earth Totem")] = {id = 8075,texture = select(3, GetSpellInfo(8075)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Strength of Earth Totem
    [string.lower("Earth Elemental Totem")] = {id = 33663,texture = select(3, GetSpellInfo(33663)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Earth Elemental Totem
    [string.lower("Tremor Totem")] = {id = 8143,texture = select(3, GetSpellInfo(8143)), color = {r = 1, g = 0.9, b = 0.1, a = 1}, enabled = true, priority = 3}, -- Tremor Totem
    -- Air
    [string.lower("Grounding Totem")] = {id = 8177,texture = select(3, GetSpellInfo(8177)), color = {r = 0, g = 0.53, b = 0.92, a = 1}, enabled = true, priority = 3}, -- Grounding Totem
    [string.lower("Grace of Air Totem")] = {id = 8835,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_InvisibilityTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Grace of Air Totem
    [string.lower("Nature Resistance Totem")] = {id = 10595,texture = select(3, GetSpellInfo(10595)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Nature Resistance Totem
    [string.lower("Windfury Totem")] = {id = 8512,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_Windfury_edit", color = {r = 0.96, g = 0, b = 0.07, a = 1}, enabled = true, priority = 2}, -- Windfury Totem
    [string.lower("Sentry Totem")] = {id = 6495, texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_RemoveCurse_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Sentry Totem
    [string.lower("Windwall Totem")] = {id = 15107,texture = select(3, GetSpellInfo(15107)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Windwall Totem
    [string.lower("Wrath of Air Totem")] = {id = 3738,texture = "Interface\\AddOns\\Gladdy\\Images\\Totems\\Spell_Nature_SlowingTotem_edit", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Wrath of Air Totem
    [string.lower("Tranquil Air Totem")] = {id = 25908,texture = "Interface\\Icons\\INV_Staff_07", color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Tranquil Air Totem
}
local localizedTotemData = {
    ["default"] = {
        [string.lower(select(1, GetSpellInfo(3599)))] = totemData[string.lower("Searing Totem")], -- Searing Totem
        [string.lower(select(1, GetSpellInfo(8227)))] = totemData[string.lower("Flametongue Totem")], -- Flametongue Totem
        [string.lower(select(1, GetSpellInfo(8190)))] = totemData[string.lower("Magma Totem")], -- Magma Totem
        [string.lower(select(1, GetSpellInfo(1535)))] = totemData[string.lower("Fire Nova Totem")], -- Fire Nova Totem
        [string.lower(select(1, GetSpellInfo(30706)))] = totemData[string.lower("Totem of Wrath")], -- Totem of Wrath
        [string.lower(select(1, GetSpellInfo(32982)))] = totemData[string.lower("Fire Elemental Totem")], -- Fire Elemental Totem
        [string.lower(select(1, GetSpellInfo(8181)))] = totemData[string.lower("Frost Resistance Totem")], -- Frost Resistance Totem
        -- Water
        [string.lower(select(1, GetSpellInfo(8184)))] = totemData[string.lower("Fire Resistance Totem")], -- Fire Resistance Totem
        [string.lower(select(1, GetSpellInfo(8166)))] = totemData[string.lower("Poison Cleansing Totem")], -- Poison Cleansing Totem
        [string.lower(select(1, GetSpellInfo(8170)))] = totemData[string.lower("Disease Cleansing Totem")], -- Disease Cleansing Totem
        [string.lower(select(1, GetSpellInfo(5394)))] = totemData[string.lower("Healing Stream Totem")], -- Healing Stream Totem
        [string.lower(select(1, GetSpellInfo(16190)))] = totemData[string.lower("Mana Tide Totem")], -- Mana Tide Totem
        [string.lower(select(1, GetSpellInfo(5675)))] = totemData[string.lower("Mana Spring Totem")], -- Mana Spring Totem
        -- Earth
        [string.lower(select(1, GetSpellInfo(2484)))] = totemData[string.lower("Earthbind Totem")], -- Earthbind Totem
        [string.lower(select(1, GetSpellInfo(5730)))] = totemData[string.lower("Stoneclaw Totem")], -- Stoneclaw Totem
        [string.lower(select(1, GetSpellInfo(8071)))] = totemData[string.lower("Stoneskin Totem")], -- Stoneskin Totem
        [string.lower(select(1, GetSpellInfo(8075)))] = totemData[string.lower("Strength of Earth Totem")], -- Strength of Earth Totem
        [string.lower(select(1, GetSpellInfo(33663)))] = totemData[string.lower("Earth Elemental Totem")], -- Earth Elemental Totem
        [string.lower(select(1, GetSpellInfo(8143)))] = totemData[string.lower("Tremor Totem")], -- Tremor Totem
        -- Air
        [string.lower(select(1, GetSpellInfo(8177)))] = totemData[string.lower("Grounding Totem")], -- Grounding Totem
        [string.lower(select(1, GetSpellInfo(8835)))] = totemData[string.lower("Grace of Air Totem")], -- Grace of Air Totem
        [string.lower(select(1, GetSpellInfo(10595)))] = totemData[string.lower("Nature Resistance Totem")], -- Nature Resistance Totem
        [string.lower(select(1, GetSpellInfo(8512)))] = totemData[string.lower("Windfury Totem")], -- Windfury Totem
        [string.lower(select(1, GetSpellInfo(6495)))] = totemData[string.lower("Sentry Totem")], -- Sentry Totem
        [string.lower(select(1, GetSpellInfo(15107)))] = totemData[string.lower("Windwall Totem")], -- Windwall Totem
        [string.lower(select(1, GetSpellInfo(3738)))] = totemData[string.lower("Wrath of Air Totem")], -- Wrath of Air Totem
        [string.lower(select(1, GetSpellInfo(25908)))] = totemData[string.lower("Tranquil Air Totem")], -- Tranquil Air Totem
    },
    ["frFR"] = {
        [string.lower("Totem incendiaire")] = totemData[string.lower("Searing Totem")],
        [string.lower("Totem Langue de feu")] = totemData[string.lower("Flametongue Totem")],
        [string.lower("Totem de lien terrestre")] = totemData[string.lower("Earthbind Totem")],
        [string.lower("Totem de Griffes de pierre")] = totemData[string.lower("Stoneclaw Totem")],
        [string.lower("Totem Nova de feu")] = totemData[string.lower("Fire Nova Totem")],
        [string.lower("Totem de Magma")] = totemData[string.lower("Magma Totem")],
        [string.lower("Totem de courroux")] = totemData[string.lower("Totem of Wrath")],
        [string.lower("Totem d'\195\169lementaire de feu")] = totemData[string.lower("Fire Elemental Totem")],
		[string.lower("Totem d'\195\169l\195\169mentaire de feu")] = totemData[string.lower("Fire Elemental Totem")],
        [string.lower("Totem de Peau de pierre")] = totemData[string.lower("Stoneskin Totem")],
        [string.lower("Totem d'\195\169lementaire de terre")] = totemData[string.lower("Earth Elemental Totem")],
		[string.lower("Totem d'\195\169l\195\169mentaire de terre")] = totemData[string.lower("Earth Elemental Totem")],
        [string.lower("Totem de Force de la Terre")] = totemData[string.lower("Strength of Earth Totem")],
        [string.lower("Totem de r\195\169sistance au Givre")] = totemData[string.lower("Frost Resistance Totem")],
        [string.lower("Totem de r\195\169sistance au Feu")] = totemData[string.lower("Fire Resistance Totem")],
        [string.lower("Totem de Gl\195\168be")] = totemData[string.lower("Grounding Totem")],
        [string.lower("Totem de Gr\195\162ce a\195\169rienne")] = totemData[string.lower("Grace of Air Totem")],
        [string.lower("Totem de R\195\169sistance \195\160 la Nature")] = totemData[string.lower("Nature Resistance Totem")],
        [string.lower("Totem Furie-des-vents")] = totemData[string.lower("Windfury Totem")],
        [string.lower("Totem Sentinelle")] = totemData[string.lower("Sentry Totem")],
        [string.lower("Totem de Mur des vents")] = totemData[string.lower("Windwall Totem")],
        [string.lower("Totem de courroux de l'air")] = totemData[string.lower("Wrath of Air Totem")],
        [string.lower("Totem de S\195\169isme")] = totemData[string.lower("Tremor Totem")],
        [string.lower("Totem gu\195\169risseur")] = totemData[string.lower("Healing Stream Totem")],
        [string.lower("Totem de Purification du poison")] = totemData[string.lower("Poison Cleansing Totem")],
        [string.lower("Totem Fontaine de mana")] = totemData[string.lower("Mana Spring Totem")],
        [string.lower("Totem de Purification des maladies")] = totemData[string.lower("Disease Cleansing Totem")],
        [string.lower("Totem de Vague de mana")] = totemData[string.lower("Mana Tide Totem")],
        [string.lower("Totem de Tranquillit\195\169 de l'air")] = totemData[string.lower("Tranquil Air Totem")],
    }
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
        defaultDB["totem" .. indexedList[i].id] = {color = indexedList[i].color, enabled = indexedList[i].enabled, alpha = 0.6}
        options["totem" .. indexedList[i].id] = {
            order = i+1,
            name = "",
            inline = true,
            type = "group",
            args = {
                desc = {
                    order = 1,
                    name = select(1, GetSpellInfo(indexedList[i].id)),
                    desc = format("|T%s:20|t %s", indexedList[i].texture, select(1, GetSpellInfo(indexedList[i].id))),
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
                alpha = {
                    type = "range",
                    name = L["Alpha"],
                    order = 3,
                    min = 0,
                    max = 1,
                    step = 0.1,
                    get = function(info)
                        return Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].alpha
                    end,
                    set = function(info, value)
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].alpha = value
                    end
                },
            }
        }
    end
    return defaultDB, options, indexedList
end

local function GetTotemOptions()
    local indexedList = select(3, GetTotemColorDefaultOptions())
    local colorList = {}
    for i=1, #indexedList do
        tinsert(colorList, Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id])
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
    npTotemPlatesAlphaAlwaysTargeted = false,
    npTotemColors = select(1, GetTotemColorDefaultOptions())
})

LibStub("AceHook-3.0"):Embed(TotemPlates)
LibStub("AceTimer-3.0"):Embed(TotemPlates)

function TotemPlates:Initialise()
    self.numChildren = 0
    self.knownNameplates = {}
    self:SetScript("OnUpdate", self.Update)
    self.Aloft = IsAddOnLoaded("Aloft")
    self.SoHighPlates = IsAddOnLoaded("SoHighPlates")
    self.ElvUI = IsAddOnLoaded("ElvUI")
    self.ShaguPlates = IsAddOnLoaded("ShaguPlates-tbc") or IsAddOnLoaded("ShaguPlates")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", function (self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            self.numChildren = 0
            self.knownNameplates = {}
        end
    end)
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
        if namePlate.PlatesFrame then
            addon = PLATES
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
        if (WorldFrame:GetNumChildren() ~= self.numChildren) then
            self.numChildren = WorldFrame:GetNumChildren()
            for i = 1, self.numChildren do
                frame = select(i, WorldFrame:GetChildren())
                if (frame:GetNumRegions() > 2 and frame:GetNumChildren() >= 1) then
                    local PlatesFrame = getglobal("Plate" .. i)
                    if PlatesFrame and PlatesFrame.frame == frame then
                        frame.PlatesFrame = PlatesFrame
                    end
                    self.knownNameplates[frame] = true
                end
            end
        end
        for namePlate,_ in pairs(self.knownNameplates) do
            if namePlate:IsVisible() then
                name, addon = getName(namePlate)
                if name and addon then
                    self:SkinTotem(namePlate, name, addon)
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
        if nameplate.oldname then nameplate.oldname:SetAlpha(alpha) end
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
    elseif (addonName == PLATES) then
        if alpha == 1 then
            nameplate.PlatesFrame:Show()
        else
            nameplate.PlatesFrame:Hide()
        end
    end
end

local totemPlateCache = {}
function TotemPlates:SkinTotem(nameplate, nameplateName, addonName)
    local totemName = string.gsub(nameplateName, "^%s+", "")
    totemName = string.gsub(totemName, "%s+$", "")
    totemName = string.gsub(totemName, "%s+[I,V,X]+$", "")
    totemName = string.lower(totemName)
    local totemDataEntry = totemData[totemName] or localizedTotemData["default"][totemName] or localizedTotemData["frFR"][totemName]
    if (addonName == BLIZZ
            or addonName == ALOFT
            or addonName == ELVUI
            or addonName == SOHIGHPLATES and GetCVar('_sNpTotem') ~= '1'
            or addonName == SHAGUPLATES and ShaguPlates_config.nameplates.totemicons ~= "1"
            or addonName == PLATES)
            and Gladdy.db.npTotems then
        if (totemDataEntry and Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].enabled) then
            nameplateSetAlpha(nameplate, 0.01, addonName)

            if not nameplate.gladdyTotemFrame then
                if #totemPlateCache > 0 then
                    nameplate.gladdyTotemFrame = tremove(totemPlateCache, #totemPlateCache)
                else
                    nameplate.gladdyTotemFrame = CreateFrame("Frame", nil)
                    nameplate.gladdyTotemFrame.totemIcon = nameplate.gladdyTotemFrame:CreateTexture(nil, "BACKGROUND")
                    nameplate.gladdyTotemFrame.totemBorder = nameplate.gladdyTotemFrame:CreateTexture(nil, "BORDER")
                end
                nameplate.gladdyTotemFrame:SetFrameStrata("BACKGROUND")
                nameplate.gladdyTotemFrame.parent = nameplate
                nameplate.gladdyTotemFrame:ClearAllPoints()
                nameplate.gladdyTotemFrame:SetPoint("CENTER", nameplate, "CENTER", 0, 0)
                nameplate.gladdyTotemFrame:SetWidth(Gladdy.db.npTotemPlatesSize)
                nameplate.gladdyTotemFrame:SetHeight(Gladdy.db.npTotemPlatesSize)
                nameplate.gladdyTotemFrame.totemIcon:ClearAllPoints()
                nameplate.gladdyTotemFrame.totemIcon:SetPoint("TOPLEFT", nameplate.gladdyTotemFrame, "TOPLEFT")
                nameplate.gladdyTotemFrame.totemIcon:SetPoint("BOTTOMRIGHT", nameplate.gladdyTotemFrame, "BOTTOMRIGHT")
                nameplate.gladdyTotemFrame.totemBorder:ClearAllPoints()
                nameplate.gladdyTotemFrame.totemBorder:SetPoint("TOPLEFT", nameplate.gladdyTotemFrame, "TOPLEFT")
                nameplate.gladdyTotemFrame.totemBorder:SetPoint("BOTTOMRIGHT", nameplate.gladdyTotemFrame, "BOTTOMRIGHT")
                nameplate.gladdyTotemFrame:SetScript("OnUpdate", function(self)
                    if self.parent and not self.parent:IsVisible() then
                        self:Hide()
                    end
                end)
            else
                nameplate.gladdyTotemFrame:Show()
            end

            if (UnitExists("target") and nameplate:GetAlpha() ~= 1) then
                -- target exists and totem is not target
                nameplate:SetAlpha(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].alpha)
                nameplate.gladdyTotemFrame:SetAlpha(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].alpha)
            elseif (UnitExists("target") and nameplate:GetAlpha() == 1 and Gladdy.db.npTotemPlatesAlphaAlwaysTargeted) then
                -- target but apply alpha anyways
                nameplate.gladdyTotemFrame:SetAlpha(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].alpha)
            elseif (UnitExists("target") and nameplate:GetAlpha() == 1) then
                -- target exists and totem is target -> alpha 1
                nameplate.gladdyTotemFrame:SetAlpha(1)
            elseif (not UnitExists("target") and Gladdy.db.npTotemPlatesAlphaAlways) then
                -- no target and option npTotemPlatesAlphaAlways == true
                nameplate.gladdyTotemFrame:SetAlpha(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].alpha)
            else
                -- no target and option npTotemPlatesAlphaAlways == false
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
            nameplate.gladdyTotemFrame.parent = nil
            tinsert(totemPlateCache, nameplate.gladdyTotemFrame)
            nameplate.gladdyTotemFrame = nil
            nameplateSetAlpha(nameplate, 1, addonName)
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
        npTotemPlatesAlphaAlways = Gladdy:option({
            type = "toggle",
            name = L["Apply alpha when no target"],
            desc = L["Always applies alpha, even when you don't have a target. Else it is 1."],
            order = 12,
        }),
        npTotemPlatesAlphaAlwaysTargeted = Gladdy:option({
            type = "toggle",
            name = L["Apply alpha when targeted, else it is 1"],
            desc = L["Always applies alpha, even when you target the totem. Else it is 1."],
            order = 13,
        }),
        npTotemPlatesBorderStyle = Gladdy:option({
            type = "select",
            name = L["Totem icon border style"],
            order = 15,
            values = Gladdy:GetIconStyles()
        }),
        npAllTotemColors = {
            type = "color",
            name = L["All totem border color"],
            order = 16,
            hasAlpha = true,
            get = function(info)
                local colors = GetTotemOptions()
                local color = colors[1].color
                for i=2, #colors do
                    if colors[i].r ~= color.r or colors[i].color.r ~= color.r or colors[i].color.r ~= color.r or colors[i].color.r ~= color.r then
                        return 0, 0, 0, 0
                    end
                end
                return color.r, color.g, color.b, color.a
            end,
            set = function(info, r, g, b, a)
                local colors = GetTotemOptions()
                for i=1, #colors do
                    colors[i].color.r = r
                    colors[i].color.g = g
                    colors[i].color.b = b
                    colors[i].color.a = a
                end
            end,
        },
        npAllTotemAlphas = {
            type = "range",
            name = L["All totem border alphas"],
            min = 0,
            max = 1,
            step = 0.1,
            order = 14,
            get = function(info)
                local alphas = GetTotemOptions()
                for i=2, #alphas do
                    if alphas[i].alpha ~= alphas[1].alpha then
                        return ""
                    end
                end
                return alphas[1].alpha
            end,
            set = function(info, value)
                local alphas = GetTotemOptions()
                for i=1, #alphas do
                    alphas[i].alpha = value
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