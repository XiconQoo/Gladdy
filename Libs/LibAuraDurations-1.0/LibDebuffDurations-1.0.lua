local spells = {}
local spellNameToID = {}
local INFINITY = math.huge

local LibAuraDurations = LibStub:NewLibrary("LibAuraDurations-1.0", 1)
LibAuraDurations.INFINITY = INFINITY
local function Spell(id, opts, class)
    if not opts or not class then
        return
    end

    local lastRankID
    if type(id) == "table" then
        local clones = id
        lastRankID = clones[#clones]
    else
        lastRankID = id
    end

    local spellName = GetSpellInfo(lastRankID)
    if not spellName then
        return
    end
    spellNameToID[spellName] = {id = id , class = class}

    if type(id) == "table" then
        for _, spellID in ipairs(id) do
            spells[spellID] = opts
        end
    else
        spells[id] = opts
    end
end

local function getClassSpells(class)
    local classSpells = {}
    for k,v in pairs(spellNameToID) do
        if v.class == class then
            tinsert(classSpells, {name = k, id = v.id})
        end
    end
    return classSpells
end
LibAuraDurations.GetClassSpells = getClassSpells

------------------
-- GLOBAL
------------------

Spell({ 2479 }, { duration = 30 }, "GLOBAL") -- Honorless Target
Spell({ 1604 }, { duration = 4 }, "GLOBAL") -- Common Daze
Spell({ 11196 }, { duration = 60 }, "GLOBAL") -- Recently Bandaged

Spell({ 13099, 13138, 16566 }, {
    duration = function(spellID)
        if spellID == 13138 then return 20 -- backfire
        elseif spellID == 16566 then return 30 -- backfire
        else return 10 end
    end
}, "GLOBAL") -- Net-o-Matic

Spell({ 23451 }, { duration = 10 }, "GLOBAL") -- Battleground speed buff
Spell({ 23493 }, { duration = 10 }, "GLOBAL") -- Battleground heal buff
Spell({ 23505 }, { duration = 60 }, "GLOBAL") -- Battleground damage buff
Spell({ 4068 }, { duration = 3 }, "GLOBAL") -- Iron Grenade
Spell({ 19769 }, { duration = 3 }, "GLOBAL") -- Thorium Grenade
Spell({ 1090 }, { duration = 30 }, "GLOBAL") -- Magic Dust
Spell({ 13327 }, { duration = 30 }, "GLOBAL") -- Reckless Charge
Spell({ 26740, 13181 }, { duration = 20 }, "GLOBAL") -- Mind Control Cap + Backfire
Spell({ 6727 }, { duration = 30 }, "GLOBAL") -- Violet Tragan
Spell({ 5134 }, { duration = 10 }, "GLOBAL") -- Flash Bomb
Spell({ 13237 }, { duration = 3 }, "GLOBAL") -- Goblin Mortar trinket

-------------
-- PRIEST
-------------
Spell({ 2943, 19249, 19251, 19252, 19253, 19254, 25460 }, { duration = 120, buffType = "Curse" }, "PRIEST") -- Touch of Weakness Effect
Spell({ 6788 }, { duration = 15 }, "PRIEST") -- Weakened Soul
Spell({ 15487 }, { duration = 5, buffType = "Magic" }, "PRIEST") -- Silence
Spell({ 10797, 19296, 19299, 19302, 19303, 19304, 19305, 25446 }, { duration = 6, stacking = true, buffType = "Magic" }, "PRIEST") -- starshards
Spell({ 2944, 19276, 19277, 19278, 19279, 19280, 25467 }, { duration = 24, stacking = true , buffType = "Disease"}, "PRIEST") --devouring plague
Spell({ 453, 8192, 10953, 25596 }, { duration = 15 }, "PRIEST") -- mind soothe
Spell({ 14914, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 25384 }, { duration = 10, stacking = true, buffType = "Magic"}, "PRIEST") -- Holy Fire, stacking?
Spell({ 589, 594, 970, 992, 2767, 10892, 10893, 10894, 25367, 25368 }, { stacking = true, duration = 18 , buffType = "Magic"}, "PRIEST") -- SW:P
Spell({ 15258 } ,{ duration = 15, buffType = "Magic" }, "PRIEST") -- Shadow Vulnerability (Shadow Weaving Talent Effect)
Spell({ 15286 } ,{ duration = 60, buffType = "Magic" }, "PRIEST") -- Vampiric Embrace
Spell({ 15407, 17311, 17312, 17313, 17314, 18807, 25387 }, { duration = 3, buffType = "Magic" }, "PRIEST") -- Mind Flay
Spell({ 605, 10911, 10912 }, {  duration = 60, buffType = "Magic" }, "PRIEST") -- Mind Control
Spell({ 8122, 8124, 10888, 10890 }, { buffType = "Magic", duration = 8 }, "PRIEST") -- Psychic Scream
Spell({ 15269 }, {duration = 3, buffType = "Magic"}, "PRIEST")

---------------
-- DRUID
---------------
Spell({ 33786 }, {duration = 6, buffType = "Immune"}, "DRUID")
Spell({ 19975 }, { duration = 12, pvpduration = 10, buffType = "Magic" }, "DRUID") -- Nature's Grasp root TODO
Spell({ 19675 }, { duration = 4 }, "DRUID") -- Feral Charge
Spell({ 339, 1062, 5195, 5196, 9852, 9853, 26989 }, {
    pvpduration = 10,
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 339 then return 12
        elseif spellID == 1062 then return 15
        elseif spellID == 5195 then return 18
        elseif spellID == 5196 then return 21
        elseif spellID == 9852 then return 24
        else return 27 end
    end
}, "DRUID") -- Entangling Roots
Spell({ 770, 778, 9749, 9907, 26993 }, { duration = 40, buffType = "Magic"  }, "DRUID") -- Faerie Fire
Spell({ 16857, 17390, 17391, 17392, 27011 }, { duration = 40, buffType = "Magic"  }, "DRUID") -- Faerie Fire (Feral)
Spell({ 2637, 18657, 18658 }, {
    pvpduration = 10, buffType = "Magic",
    duration = function(spellID)
        if spellID == 2637 then return 20
        elseif spellID == 18657 then return 30
        else return 40 end
    end
}, "DRUID") -- Hibernate
Spell({ 99, 1735, 9490, 9747, 9898, 26998 }, { duration = 30, buffType = "Physical" }, "DRUID") -- Demoralizing Roar
Spell({ 5209 }, { duration = 6, buffType = "Physical"  }, "DRUID") -- Challenging Roar
Spell({ 6795 }, { duration = 3, stacking = true, buffType = "Physical" }, "DRUID") -- Taunt
Spell({ 16922 }, { duration = 3, buffType = "Physical" }, "DRUID") -- Imp Starfire Stun
Spell({ 9005, 9823, 9827, 27006 }, { duration = 3, buffType = "Physical" }, "DRUID") -- Pounce
Spell({ 9007, 9824, 9826, 27007 }, { duration = 18, buffType = "Physical", stacking = true, }, "DRUID") -- Pounce Bleed
Spell({ 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835, 26987, 26988 }, {
    stacking = true,
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 8921 then return 9
        else return 12 end
    end
}, "DRUID") -- Moonfire
Spell({ 1822, 1823, 1824, 9904, 27003 }, { duration = 9, stacking = true, buffType = "Physical" }, "DRUID") -- Rake
Spell({ 1079, 9492, 9493, 9752, 9894, 9896, 27008 }, { duration = 12, stacking = true, buffType = "Physical" }, "DRUID") -- Rip
Spell({ 5570, 24974, 24975, 24976, 24977, 27013 }, { duration = 12, stacking = true, buffType = "Magic" }, "DRUID") -- Insect Swarm

-------------
-- WARRIOR
-------------
Spell({ 29703 }, {duration = 6, buffType = "Physical"}, "WARRIOR") -- Dazed
Spell({ 12294, 21551, 21552, 21553, 25248, 30330 }, { duration = 10, buffType = "Physical" }, "WARRIOR") -- Mortal Strike
Spell({72, 1671, 1672, 29704}, { duration = 6, buffType = "Physical" }, "WARRIOR") -- Shield Bash
Spell({ 18498 }, { duration = 3, buffType = "Physical" }, "WARRIOR") -- Improved Shield Bash
Spell({ 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208 }, {
    stacking = true,
    buffType = "Physical",
    duration = function(spellID)
        if spellID == 772 then return 9
        elseif spellID == 6546 then return 12
        elseif spellID == 6547 then return 15
        elseif spellID == 6548 then return 18
        else return 21 end
    end
}, "WARRIOR") -- Rend
Spell({ 12721 }, { duration = 12, stacking = true, buffType = "Physical" }, "WARRIOR") -- Deep Wounds
Spell({ 1715, 7372, 7373, 25212 }, { duration = 15, pvpduration = 10, buffType = "Physical" }, "WARRIOR") -- Hamstring
Spell({ 23694 } , { duration = 5, buffType = "Physical" }, "WARRIOR") -- Improved Hamstring
Spell({ 6343, 8198, 8204, 8205, 11580, 11581, 25264 }, {
    buffType = "Physical",
    duration = function(spellID)
        if spellID == 6343 then return 10
        elseif spellID == 8198 then return 14
        elseif spellID == 8204 then return 18
        elseif spellID == 8205 then return 22
        elseif spellID == 11580 then return 26
        else return 30 end
    end
}, "WARRIOR") -- Thunder Clap
Spell({ 694, 7400, 7402, 20559, 20560 }, { duration = 6, buffType = "Physical", }, "WARRIOR") -- Mocking Blow
Spell({ 1161 } ,{ duration = 6, buffType = "Physical", }, "WARRIOR") -- Challenging Shout
Spell({ 355 } ,{ duration = 3, stacking = true, buffType = "Physical", }, "WARRIOR") -- Taunt
Spell({ 1160, 6190, 11554, 11555, 11556, 25202, 25203 }, { duration = 45, buffType = "Physical" }, "WARRIOR") -- Demoralizing Shout, varies
Spell({ 5246 }, { duration = 8, buffType = "Physical" }, "WARRIOR") -- Intimidating Shout Fear
Spell({ 676 } ,{ duration = 10, buffType = "Physical" }, "WARRIOR") -- Disarm, varies
Spell({ 12798 } , { duration = 3, buffType = "Physical" }, "WARRIOR") -- Imp Revenge Stun
Spell({ 7386, 7405, 8380, 11596, 11597, 25225, buffType = "Physical" }, { duration = 30 }, "WARRIOR") -- Sunder Armor
Spell({ 12809 } ,{ duration = 5, buffType = "Physical" }, "WARRIOR") -- Concussion Blow
Spell({ 7922 }, { duration = 1, buffType = "Physical" }, "WARRIOR") -- Charge Stun
Spell({ 5530 }, { duration = 3, buffType = "Physical"}, "WARRIOR") -- Mace Stun Effect (Mace Specialization)

--------------
-- ROGUE
--------------

Spell({ 16511, 17347, 17348, 26864 }, { duration = 15, buffType = "Physical" }, "ROGUE") -- Hemorrhage
Spell({ 3409, 11201 }, { duration = 12, buffType = "Poison" }, "ROGUE") -- Crippling Poison
Spell({ 13218, 13222, 13223, 13224, 27189 }, { duration = 15, buffType = "Poison" }, "ROGUE") -- Wound Poison 43461(R5),27189(R5),27188(R5),13227(R4),13224(R4),13226(R3),13223(R3),13225(R2),13222(R2),13220(R1),13219(R1),13218(R1),39665,36974,30984
Spell({ 2818, 2819, 11353, 11354, 25349, 26968, 27187 }, { duration = 12, stacking = true, buffType = "Poison" }, "ROGUE") -- Deadly Poison
Spell({ 5760, 8692, 11398 }, {
    duration = function(spellID)
        if spellID == 5760 then return 10
        elseif spellID == 8692 then return 12
        else return 14 end
    end,
    buffType = "Poison"
}, "ROGUE") -- Mind-numbing Poison
Spell({ 18425 }, { duration = 2, buffType = "Physical" }, "ROGUE") -- Improved Kick Silence
Spell({ 1833 }, { duration = 4, buffType = "Physical" }, "ROGUE") -- Cheap Shot
Spell({ 2070, 6770, 11297 }, {
    pvpduration = 10,
    duration = function(spellID)
        if spellID == 6770 then return 25 -- yes, Rank 1 spell id is 6770 actually
        elseif spellID == 2070 then return 35
        else return 45 end
    end
}, "ROGUE") -- Sap
Spell({ 2094 } , { duration = 10, buffType = "Physical" }, "ROGUE") -- Blind
Spell({ 8647, 8649, 8650, 11197, 11198, 26866 }, { duration = 30, buffType = "Physical" }, "ROGUE") -- Expose Armor
Spell({ 703, 8631, 8632, 8633, 11289, 11290, 26839, 26884 }, { duration = 18, buffType = "Physical" }, "ROGUE") -- Garrote
Spell({ 1330 }, { duration = 3, buffType = "Physical"}, "ROGUE")-- Garrote - Silence
Spell({ 408, 8643 }, {
    buffType = "Physical",
    duration = function(spellID, isSrcPlayer, comboPoints)
        local duration = spellID == 8643 and 1 or 0 -- if Rank 2, add 1s
        if isSrcPlayer then
            return duration + comboPoints
        else
            return duration + 5 -- just assume 5cp i guess
        end
    end
}, "ROGUE") -- Kidney Shot TODO
Spell({ 1943, 8639, 8640, 11273, 11274, 11275, 26867 }, {
    buffType = "Physical",
    stacking = true,
    duration = function(spellID, isSrcPlayer, comboPoints)
       if isSrcPlayer then
           return (6 + comboPoints*2)
       else
           return 16
       end
    end
}, "ROGUE") -- Rupture
Spell({ 1776, 1777, 8629, 11285, 11286, 38764 }, {
    buffType = "Physical",
    duration = 4--[[function(spellID, isSrcPlayer)
        if isSrcPlayer then
            return 4 + 0.5*Talent(13741, 13793, 13792)
        else
            return 5.5
        end
    end--]]
}, "ROGUE") -- Gouge
Spell({ 14251 } , { duration = 6, buffType = "Physical", }, "ROGUE") -- Riposte (disarm)

------------
-- WARLOCK
------------
Spell({ 32386 }, {duration = INFINITY, buffType = "Magic"}, "WARLOCK") -- Shadow Embrace
Spell({ 710, 18647 } ,{
    buffType = "Immune",
    pvpduration = 10,
    duration = function(spellID)
        if spellID == 710 then return 20
        else return 30 end
    end,
}, "WARLOCK") -- Banish
Spell( {348, 707, 1094, 2941, 11665, 11667, 11668, 25309, 27215 }, {duration = 15, buffType = "Magic"}, "WARLOCK") -- Immolate
Spell({ 24259 } ,{ duration = 3, buffType = "Magic" }, "WARLOCK") -- Spell Lock Silence
Spell({ 27243 } ,{ duration = 18, buffType = "Magic" }, "WARLOCK") -- Seed of Corruption
Spell( {689, 699, 709, 7651, 11699, 11700, 27219, 27220 }, {duration = 5, buffType = "Magic"}, "WARLOCK") -- Drain Life
Spell( {5138, 6226, 11703, 11704, 27221, 30908 }, {duration = 5, buffType = "Magic"}, "WARLOCK") -- Drain Mana
Spell( {1120, 8288, 8289, 11675, 27217 }, {duration = 15, buffType = "Magic"}, "WARLOCK") -- Drain Soul
Spell( {18265, 18879, 18880, 18881, 27264, 30911}, {duration = 30, buffType = "Magic"}, "WARLOCK") -- Siphon Life
Spell( {172, 6222, 6223, 7648, 11671, 11672, 25311, 27216 }, {
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 172 then return 12
        elseif spellID == 6222 then return 15
        else return 18 end
    end,
}, "WARLOCK") -- Corruption
Spell( {980, 1014, 6217, 11711, 11712, 11713, 27218 }, {duration = 24, buffType = "Curse"}, "WARLOCK") -- Curse of Agony
Spell( 18223, {duration = 12, buffType = "Curse"}) -- Curse of Exhaustion
Spell( {704, 7658, 7659, 11717, 27226 }, {duration = 120, buffType = "Curse"}, "WARLOCK") -- Curse of Recklessness
Spell( {1490, 11721, 11722, 27228 }, {duration = 120, buffType = "Curse"}, "WARLOCK") -- Curse of the Elements
Spell( {1714, 11719 }, {duration = 30, pvpduration = 12, buffType = "Curse"}, "WARLOCK") -- Curse of Tongues
Spell( {702, 1108, 6205, 7646, 11707, 11708, 27224, 30909 }, {duration = 120, buffType = "Curse"}, "WARLOCK") -- Curse of Weakness
Spell( {603, 30910 }, {duration = 60, buffType = "Curse"}, "WARLOCK") -- Curse of Doom
Spell( {6789, 17925, 17926, 27223 }, {duration = 3, buffType = "Magic"}, "WARLOCK") -- Death Coil
Spell( {5782, 6213, 6215 }, {
    buffType = "Magic",
    pvpduration = 10,
    duration = function(spellID)
        if spellID == 5782 then return 10
        elseif spellID == 6213 then return 15
        else return 20 end
    end
}, "WARLOCK") -- Fear
Spell( {5484, 17928 }, {
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 5484 then return 6
        else return 8 end
    end
}, "WARLOCK") -- Howl of Terror
Spell({ 6358 }, { pvpduration = 10, duration = 15, buffType = "Magic" }, "WARLOCK") -- Seduction
Spell({ 18093 } ,{ duration = 3, buffType = "Physical" }, "WARLOCK") -- Pyroclasm
Spell({ 17877, 18867, 18868, 18869, 18870, 18871, 27263, 30546 }, { duration = 5, buffType = "None" }, "WARLOCK") -- Shadowburn Debuff

---------------
-- SHAMAN
---------------

Spell({ 17364 } ,{ duration = 12, buffType = "Magic" }, "SHAMAN") -- Stormstrike
Spell({ 8056, 8058, 10472, 10473, 25464 }, { duration = 8, buffType = "Magic" }, "SHAMAN") -- Frost Shock
Spell({ 8050, 8052, 8053, 10447, 10448, 29228, 25457 }, { duration = 12, stacking = true, buffType = "Magic" }, "SHAMAN") -- Flame Shock
Spell({ 8034, 8037, 10458, 16352, 16353, 25501 }, { duration = 8, buffType = "Magic" }, "SHAMAN") -- Frostbrand Attack
Spell({ 3600 } ,{ duration = 5, buffType = "Magic" }, "SHAMAN") -- Earthbind Totem

--------------
-- PALADIN
--------------

Spell({ 20066 }, { duration = 6, buffType = "Magic" }, "PALADIN") -- Repentance
Spell({ 2878, 5627, 5627 }, {
    pvpduration = 10,
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 2878 then return 10
        elseif spellID == 5627 then return 15
        else return 20 end
    end
}, "PALADIN") -- Turn Undead

Spell({ 21183, 20188, 20300, 20301, 20302, 20303, 27159 }, { duration = 10 }, "PALADIN") -- Judgement of the Crusader
Spell({ 20185, 20344, 20345, 20346 }, {
    buffType = "Magic",
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local talents = 10*Talent(20359, 20360, 20361)
            return 10+talents
        else
            return 10
        end
    end
}, "PALADIN") -- Judgement of Light
Spell({ 20186, 20354, 20355 }, {
    buffType = "Magic",
    duration = function(spellID, isSrcPlayer)
        if isSrcPlayer then
            local talents = 10*Talent(20359, 20360, 20361)
            return 10+talents
        else
            return 10
        end
    end
}, "PALADIN") -- Judgement of Wisdom
Spell({20184, 31896}, { duration = 20, buffType = "Magic", }, "PALADIN") -- Judgement of Justice

Spell({ 853, 5588, 5589, 10308 }, {
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 853 then return 3
        elseif spellID == 5588 then return 4
        elseif spellID == 5589 then return 5
        else return 6 end
    end
}, "PALADIN") -- Hammer of Justice

Spell({ 20170 } ,{ duration = 2, buffType = "Physical", }, "PALADIN") -- Seal of Justice stun

-------------
-- HUNTER
-------------

Spell( {19434, 20900, 20901, 20902, 20903, 20904}, {duration = 10, buffType = "Pysical"}, "HUNTER") -- Aimed Shot
Spell({ 1130, 14323, 14324, 14325 }, { duration = 120, buffType = "Magic", }, "HUNTER") -- Hunter's Mark
Spell({ 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295, 27016 }, { duration = 15, stacking = true, buffType = "Poison", }, "HUNTER") -- Serpent Sting
Spell({ 34490 }, {duration = 3, buffType = "Magic" }, "HUNTER") -- Silencing Shot
Spell({ 3043 }, { duration = 20, buffType = "Poison", }, "HUNTER") -- Scorpid Sting
Spell({ 3034, 14279, 14280, 27018 }, { duration = 8, buffType = "Poison", }, "HUNTER") -- Viper Sting
Spell({ 19386, 24132, 24133, 27068 }, { duration = 12, buffType = "Poison", }, "HUNTER") -- Wyvern Sting
Spell({ 24131, 24134, 24135, 27069 }, { duration = 12, buffType = "Poison", }, "HUNTER") -- Wyvern Sting Dot
Spell({ 1513, 14326, 14327 }, {
    buffType = "Magic",
    pvpduration = 10,
    duration = function(spellID)
        if spellID == 1513 then return 10
        elseif spellID == 14326 then return 15
        else return 20 end
    end
}, "HUNTER") -- Scare Beast

Spell({ 19229 }, { duration = 5, buffType = "Pysical", }, "HUNTER") -- Wing Clip Root
Spell({ 19306, 20909, 20910 }, { duration = 5, buffType = "Pysical"}, "HUNTER") -- Counterattack
Spell({ 13812, 14314, 14315, 27026 }, { duration = 20, stacking = true, buffType = "Magic" }, "HUNTER") -- Explosive Trap
Spell({ 13797, 14298, 14299, 14300, 14301, 27024 }, { duration = 15, stacking = true, buffType = "Magic" }, "HUNTER") -- Immolation Trap
Spell({ 3355, 14308, 14309 }, { -- TODO
    pvpduration = 12, -- with clever traps
    buffType = "Magic",
    duration = function(spellID, isSrcPlayer)
        local mul = 1
        if isSrcPlayer then
            mul = mul + 0.15*Talent(19239, 19245) -- Clever Traps
        end
        if spellID == 3355 then return 10*mul
        elseif spellID == 14308 then return 15*mul
        else return 20*mul end
    end
}, "HUNTER") -- Freezing Trap
Spell({ 19503 }, { duration = 4, buffType = "Pysical" }, "HUNTER") -- Scatter Shot
Spell({ 2974, 14267, 14268 }, { duration = 10, buffType = "Pysical" }, "HUNTER") -- Wing Clip
Spell({ 5116 }, { duration = 4, buffType = "Pysical" }, "HUNTER") -- Concussive Shot
Spell({ 19410 }, { duration = 3, buffType = "Pysical" }, "HUNTER") -- Conc Stun
Spell({ 24394 }, { duration = 3, buffType = "Pysical" }, "HUNTER") -- Intimidation
Spell({ 15571 }, { duration = 4, buffType = "Pysical" }, "HUNTER") -- Daze from Aspect
Spell({ 19185 }, { duration = 4, buffType = "Pysical" }, "HUNTER") -- Entrapment
Spell({ 25999 }, { duration = 1, buffType = "Pysical" }, "HUNTER") -- Boar Charge

-------------
-- MAGE
-------------

Spell({ 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306, 27070 }, {
    stacking = true,
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 133 then return 4
        elseif spellID == 143 then return 6
        elseif spellID == 145 then return 6
        else return 8 end
    end
}, "MAGE") -- Fireball
Spell({ 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809, 27132, 33938 }, { duration = 12, stacking = true, buffType = "Magic" }, "MAGE") -- Pyroblast

Spell({ 18469 }, { duration = 4, buffType = "Magic" }, "MAGE") -- Imp CS Silence
Spell({ 118, 12824, 12825, 12826 }, {
    pvpduration = 10,
    buffType = "Magic",
    duration = function(spellID)
        if spellID == 118 then return 20
        elseif spellID == 12824 then return 30
        elseif spellID == 12825 then return 40
        else return 50 end
    end
}, "MAGE") -- Polymorph
Spell({ 12355 } , { duration = 2, buffType = "Physical" }, "MAGE") -- Impact
Spell({ 12654 }, { duration = 4, buffType = "Magic" }, "MAGE") -- Ignite
Spell({ 22959 }, { duration = 30, buffType = "Magic" }, "MAGE") -- Fire Vulnerability
Spell({ 12579 }, { duration = 15, buffType = "Magic" }, "MAGE") -- Winter's Chill
Spell({ 11113, 13018, 13019, 13020, 13021, 27133, 33933 }, { duration = 6, buffType = "Physical" }, "MAGE") -- Blast Wave
--Spell({ 2120, 2121, 8422, 8423, 10215, 10216, 27086 }, { duration = 8, stacking = true, buffType = "Physical" }) -- Flamestrike
Spell({ 120, 8492, 10159, 10160, 10161, 27087 }, {
    duration = function(spellID, isFrost)
        local permafrost = isFrost and 3 or 0
        return 8 + permafrost
    end,
    buffType = "Magic"
}, "MAGE") -- Cone of Cold
Spell({ 12484, 12485, 12486 }, { duration = 4.5 }) -- Improved Blizzard (Chilled) 1.5s + 3 sec permafrost
Spell({6136, 7321, 18101, 20005, 16927, 15850, 31257}, {
    duration = function(spellID, isFrost)
        local permafrost = isFrost and 3 or 0
        return 5 + permafrost
    end,
    buffType = "Magic"
}, "MAGE") -- Frost/Ice Armor (Chilled) -- Chilled - 12486(R3),12485(R2),18101(R1),12484(R1),7321(R1),6136(R1),31257,20005,16927,15850
Spell({ 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 27072, 38697 }, {
    duration = function(spellID, isFrost)
        local permafrost = isFrost and 3 or 0
        if spellID == 116 then return 5 + permafrost
        elseif spellID == 205 then return 6 + permafrost
        elseif spellID == 837 then return 6 + permafrost
        elseif spellID == 7322 then return 7 + permafrost
        elseif spellID == 8406 then return 7 + permafrost
        elseif spellID == 8407 then return 8 + permafrost
        elseif spellID == 8408 then return 8 + permafrost
        else return 9 + permafrost end
    end,
    buffType = "Magic"
}, "MAGE") -- Frostbolt
Spell({ 12494 }, { duration = 5, buffType = "Magic" }, "MAGE") -- Frostbite
Spell({ 122, 865, 6131, 10230 }, { duration = 8, buffType = "Magic" }, "MAGE") -- Frost Nova


LibAuraDurations.spells = spells
LibAuraDurations.spellNameToID = spellNameToID