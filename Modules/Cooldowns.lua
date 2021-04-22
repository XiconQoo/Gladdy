local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local Cooldown = Gladdy:NewModule("Cooldown", nil, {
    cooldownFont = "DorisPP",
    cooldownFontScale = 1,
    cooldownFontColor = { r = 1, g = 1, b = 0, a = 1 },
    cooldown = true,
    cooldownYPos = "TOP",
    cooldownXPos = "LEFT",
    cooldownYOffset = 0,
    cooldownXOffset = 0,
    cooldownSize = 30,
    cooldownIconPadding = 1,
    cooldownMaxIconsPerLine = 9,
    cooldownBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss",
    cooldownBorderColor = { r = 1, g = 1, b = 1, a = 1 },
    cooldownDisableCircle = false,
    cooldownCooldownAlpha = 1
})

function Cooldown:Test(unit)
    if Gladdy.db.cooldown then
        local button = Gladdy.buttons[unit]
        button.spellCooldownFrame:Show()
        button.lastCooldownSpell = 1
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
            if Gladdy.db.cooldownYPos == "LEFT" then
                Gladdy.db.cooldownXPos = "RIGHT"
            elseif Gladdy.db.cooldownYPos == "RIGHT" then
                Gladdy.db.cooldownXPos = "LEFT"
            end
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Cooldown:GetOptions()
    return {
        headerCooldown = {
            type = "header",
            name = L["Cooldown"],
            order = 2,
        },
        cooldown = Gladdy:option({
            type = "toggle",
            name = L["Enable"],
            desc = L["Enabled cooldown module"],
            order = 2,
        }),
        headerCooldownFrame = {
            type = "header",
            name = L["Frame"],
            order = 3,
        },
        cooldownSize = Gladdy:option({
            type = "range",
            name = L["Cooldown size"],
            desc = L["Size of each cd icon"],
            order = 4,
            min = 5,
            max = (Gladdy.db.healthBarHeight + Gladdy.db.castBarHeight + Gladdy.db.powerBarHeight + Gladdy.db.bottomMargin) / 2,
        }),
        cooldownIconPadding = Gladdy:option({
            type = "range",
            name = L["Icon Padding"],
            desc = L["Space between Icons"],
            order = 5,
            min = 0,
            max = 10,
            step = 0.1,
        }),
        cooldownMaxIconsPerLine = Gladdy:option({
            type = "range",
            name = L["Max Icons per row"],
            order = 6,
            min = 3,
            max = 14,
            step = 1,
        }),
        cooldownDisableCircle = Gladdy:option({
            type = "toggle",
            name = L["No Cooldown Circle"],
            order = 7,
        }),
        cooldownCooldownAlpha = Gladdy:option({
            type = "range",
            name = L["Cooldown circle alpha"],
            min = 0,
            max = 1,
            step = 0.1,
            order = 8,
        }),
        headerFont = {
            type = "header",
            name = L["Font"],
            order = 10,
        },
        cooldownFont = Gladdy:option({
            type = "select",
            name = L["Font"],
            desc = L["Font of the cooldown"],
            order = 11,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        cooldownFontScale = Gladdy:option({
            type = "range",
            name = L["Font scale"],
            desc = L["Scale of the font"],
            order = 12,
            min = 0.1,
            max = 2,
            step = 0.1,
        }),
        cooldownFontColor = Gladdy:colorOption({
            type = "color",
            name = L["Font color"],
            desc = L["Color of the text"],
            order = 13,
            hasAlpha = true,
        }),
        headerPosition = {
            type = "header",
            name = L["Position"],
            order = 20,
        },
        cooldownYPos = option({
            type = "select",
            name = L["Position"],
            desc = L["Position of the cooldown icons"],
            order = 21,
            values = {
                ["TOP"] = L["Top"],
                ["BOTTOM"] = L["Bottom"],
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        cooldownXPos = Gladdy:option({
            type = "select",
            name = L["Position"],
            desc = L["Position of the cooldown icons"],
            order = 22,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        cooldownXOffset = Gladdy:option({
            type = "range",
            name = L["Horizontal offset"],
            order = 23,
            min = -400,
            max = 400,
            step = 0.1,
        }),
        cooldownYOffset = Gladdy:option({
            type = "range",
            name = L["Vertical offset"],
            order = 24,
            min = -400,
            max = 400,
            step = 0.1,
        }),
        headerBorder = {
            type = "header",
            name = L["Border"],
            order = 30,
        },
        cooldownBorderStyle = Gladdy:option({
            type = "select",
            name = L["Border style"],
            order = 31,
            values = Gladdy:GetIconStyles()
        }),
        cooldownBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Border color"],
            desc = L["Color of the border"],
            order = 32,
            hasAlpha = true,
        }),
    }
end

function Gladdy:UpdateTestCooldowns(i)
    local unit = "arena" .. i
    local button = Gladdy.buttons[unit]

    if (button.testSpec and button.testSpec == Gladdy.testData[unit].testSpec) then
        button.lastCooldownSpell = 1
        Gladdy:UpdateCooldowns(button)
        button.spec = ""
        Gladdy:DetectSpec(unit, button.testSpec)

        -- use class spells
        for k, v in pairs(self.cooldownSpells[button.class]) do
            --k is spellId
            Gladdy:CooldownUsed(unit, button.class, k, nil)
        end
        -- use race spells
        for k, v in pairs(self.cooldownSpells[button.race]) do
            Gladdy:CooldownUsed(unit, button.race, k, nil)
        end
    end
end

function Gladdy:GetCooldownList()
    return {
        -- Spell Name			   Cooldown[, Spec]
        -- Mage
        ["MAGE"] = {
            [1953] = 15, -- Blink
            --[122] 	= 22,    -- Frost Nova
			--[12051] = 480, --Evocation
            [2139] = 24, -- Counterspell
            [45438] = { cd = 300, [L["Frost"]] = 240, }, -- Ice Block
            [12472] = { cd = 180, spec = L["Frost"], }, -- Icy Veins
            [31687] = { cd = 180, spec = L["Frost"], }, -- Summon Water Elemental
            [12043] = { cd = 180, spec = L["Arcane"], }, -- Presence of Mind
            [11129] = { cd = 180, spec = L["Fire"] }, -- Combustion
            [120] = { cd = 10,
                      sharedCD = {
                          [31661] = true, -- Cone of Cold
                      }, spec = L["Fire"] }, -- Dragon's Breath
            [31661] = { cd = 20,
                        sharedCD = {
                            [120] = true, -- Cone of Cold
                        }, spec = L["Fire"] }, -- Dragon's Breath
            [12042] = { cd = 180, spec = L["Arcane"], }, -- Arcane Power
            [11958] = { cd = 384, spec = L["Frost"], -- Coldsnap
                        resetCD = {
                            [12472] = true,
                            [45438] = true,
                            [31687] = true,
                        },
            },
        },

        -- Priest
        ["PRIEST"] = {
            [10890] = { cd = 27, [L["Shadow"]] = 23, }, -- Psychic Scream
            [15487] = { cd = 45, spec = L["Shadow"], }, -- Silence
            [10060] = { cd = 180, spec = L["Discipline"], }, -- Power Infusion
            [33206] = { cd = 120, spec = L["Discipline"], }, -- Pain Suppression
			[34433] = 300, -- Shadowfiend
        },

        -- Druid
        ["DRUID"] = {
            [22812] = 60, -- Barkskin
            [29166] = 360, -- Innervate
            [8983] = 60, -- Bash
            [16689] = 60, -- Natures Grasp
            [17116] = { cd = 180, spec = L["Restoration"], }, -- Natures Swiftness
            [33831] = { cd = 180, spec = L["Balance"], }, -- Force of Nature
        },

        -- Shaman
        ["SHAMAN"] = {
            [8042] = { cd = 6, -- Earth Shock
                       sharedCD = {
                           [8056] = true, -- Frost Shock
                           [8050] = true, -- Flame Shock
                       },
            },
            [30823] = { cd = 120, spec = L["Enhancement"], }, -- Shamanistic Rage
            [16166] = { cd = 180, spec = L["Elemental"], }, -- Elemental Mastery
            [16188] = { cd = 180, spec = L["Restoration"], }, -- Natures Swiftness
            [16190] = { cd = 300, spec = L["Restoration"], }, -- Mana Tide Totem
        },

        -- Paladin
        ["PALADIN"] = {
            [10278] = 180, -- Blessing of Protection
            [1044] = 25, -- Blessing of Freedom
            [10308] = { cd = 60, [L["Retribution"]] = 40, }, -- Hammer of Justice
            [642] = { cd = 300, -- Divine Shield
                      sharedCD = {
                          cd = 60, -- no actual shared CD but debuff
                          [31884] = true,
                      },
            },
            [31884] = { cd = 180, spec = L["Retribution"], -- Avenging Wrath
                        sharedCD = {
                            cd = 60,
                            [642] = true,
                        },
            },
            [20066] = { cd = 60, spec = L["Retribution"], }, -- Repentance
            [31842] = { cd = 180, spec = L["Holy"], }, -- Divine Illumination
            [31935] = { cd = 30, spec = L["Protection"], }, -- Avengers Shield

        },

        -- Warlock
        ["WARLOCK"] = {
            [17928] = 40, -- Howl of Terror
            [27223] = 120, -- Death Coil
            --[19647] 	= { cd = 24 },	-- Spell Lock; how will I handle pet spells?
            [30414] = { cd = 20, spec = L["Destruction"], }, -- Shadowfury
            [17877] = { cd = 15, spec = L["Destruction"], }, -- Shadowburn
            [18708] = { cd = 900, spec = L["Demonology"], }, -- Feldom
        },

        -- Warrior
        ["WARRIOR"] = {
            --[[6552] 	= { cd = 10,                              -- Pummel
               sharedCD = {
                  [72] = true,
               },
            },
            [72] 	   = { cd = 12,                              -- Shield Bash
               sharedCD = {
                  [6552] = true,
               },
            }, ]]
            --[23920] 	= 10,    -- Spell Reflection
            [3411] = 30, -- Intervene
            [676] = 60, -- Disarm
            [5246] = 180, -- Intimidating Shout
            --[2565] 	= 60,    -- Shield Block
            [12292] = { cd = 180, spec = L["Arms"], }, -- Death Wish
            [12975] = { cd = 180, spec = L["Protection"], }, -- Last Stand
            [12809] = { cd = 30, spec = L["Protection"], }, -- Concussion Blow

        },

        -- Hunter
        ["HUNTER"] = {
            [19503] = 30, -- Scatter Shot
            [19263] = 300, -- Deterrence; not on BM but can't do 2 specs
            [14311] = { cd = 30, -- Freezing Trap
                        sharedCD = {
                            [13809] = true, -- Frost Trap
                            [34600] = true, -- Snake Trap
                        },
            },
            [13809] = { cd = 30, -- Frost Trap
                        sharedCD = {
                            [14311] = true, -- Freezing Trap
                            [34600] = true, -- Snake Trap
                        },
            },
            [34600] = { cd = 30, -- Snake Trap
                        sharedCD = {
                            [14311] = true, -- Freezing Trap
                            [13809] = true, -- Frost Trap
                        },
            },
            [34490] = { cd = 20, spec = L["Marksmanship"], }, -- Silencing Shot
            [19386] = { cd = 60, spec = L["Survival"], }, -- Wyvern Sting
            [19577] = { cd = 60, spec = L["Beast Mastery"], }, -- Intimidation
            [38373] = { cd = 120, spec = L["Beast Mastery"], }, -- The Beast Within
        },

        -- Rogue
        ["ROGUE"] = {
            --[1766] 	= 10,    -- Kick
            --[8643] 	= 20,    -- Kidney Shot
            [31224] = 60, -- Cloak of Shadow
            [26889] = { cd = 300, [L["Subtlety"]] = 180, }, -- Vanish
            [2094] = { cd = 180, [L["Subtlety"]] = 90, }, -- Blind
            [11305] = { cd = 300, [L["Combat"]] = 180, }, -- Sprint
            [26669] = { cd = 300, [L["Combat"]] = 180, }, -- Evasion
            [14177] = { cd = 180, spec = L["Assassination"], }, -- Cold Blood
            [13750] = { cd = 300, spec = L["Combat"], }, -- Adrenaline Rush
            [13877] = { cd = 120, spec = L["Combat"], }, -- Blade Flurry
            [36554] = { cd = 30, spec = L["Subtlety"], }, -- Shadowstep
            [14185] = { cd = 600, spec = L["Subtlety"], -- Preparation
                        resetCD = {
                            [26669] = true,
                            [11305] = true,
                            [26889] = true,
                            [14177] = true,
                            [36554] = true,
                        },
            },
        },
        ["Scourge"] = {
            [7744] = 120, -- Will of the Forsaken
        },
        ["BloodElf"] = {
            [28730] = 120, -- Arcane Torrent
        },
        ["Tauren"] = {
            [20549] = 120, -- War Stomp
        },
        ["Orc"] = {

        },
        ["Troll"] = {

        },
        ["NightElf"] = {
            [2651] = { cd = 180, spec = L["Discipline"], }, -- Elune's Grace
            [10797] = { cd = 30, spec = L["Discipline"], }, -- Star Shards
        },
        ["Draenei"] = {
            [32548] = { cd = 300, spec = L["Discipline"], }, -- Hymn of Hope
        },
        ["Human"] = {
            [13908] = { cd = 600, spec = L["Discipline"], }, -- Desperate Prayer
        },
        ["Gnome"] = {
            [20589] = 105, -- Escape Artist
        },
        ["Dwarf"] = {
            [20594] = 180, -- Stoneform
            [13908] = { cd = 600, spec = L["Discipline"], }, -- Desperate Prayer
        },
    }
end