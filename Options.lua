local tonumber = tonumber
local type = type
local pairs = pairs
local tinsert = table.insert
local tsort = table.sort

local InterfaceOptionsFrame_OpenToFrame = InterfaceOptionsFrame_OpenToFrame

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

Gladdy.defaults = {
    profile = {
        locked = false,
        x = 0,
        y = 0,
        growUp = false,
        frameScale = 1,
        padding = 3,
        frameColor = { r = 0, g = 0, b = 0, a = .4 },
        barWidth = 180,
        bottomMargin = 10,
    },
}

SLASH_GLADDY1 = "/gladdy"
SlashCmdList["GLADDY"] = function(msg)
    if (msg == "test2") then
        Gladdy:ToggleFrame(2)
        Gladdy:UpdateTestCooldowns(1)
        Gladdy:UpdateTestCooldowns(2)
    elseif (msg == "test5") then
        Gladdy:ToggleFrame(5)
        Gladdy:UpdateTestCooldowns(1)
        Gladdy:UpdateTestCooldowns(2)
        Gladdy:UpdateTestCooldowns(3)
        --Gladdy:UpdateTestCooldowns(4)
        --Gladdy:UpdateTestCooldowns(5)
    elseif (msg:find("test")) then
        Gladdy:ToggleFrame(3)
        Gladdy:UpdateTestCooldowns(1)
        Gladdy:UpdateTestCooldowns(2)
        Gladdy:UpdateTestCooldowns(3)
    elseif (msg == "ui" or msg == "options" or msg == "config") then
        Gladdy:ShowOptions()
    elseif (msg == "reset") then
        Gladdy.dbi:ResetProfile()
    elseif (msg == "hide") then
        Gladdy:Reset()
        Gladdy:HideFrame()
    else
        Gladdy:Print(L["Valid slash commands are:"])
        Gladdy:Print("/gladdy ui")
        Gladdy:Print("/gladdy test2-5")
        Gladdy:Print("/gladdy hide")
        Gladdy:Print("/gladdy reset")
    end
end

local function getOpt(info)
    local key = info.arg or info[#info]
    return Gladdy.dbi.profile[key]
end
local function setOpt(info, value)
    local key = info.arg or info[#info]
    Gladdy.dbi.profile[key] = value
    Gladdy:UpdateFrame()
end
local function getColorOpt(info)
    local key = info.arg or info[#info]
    return Gladdy.dbi.profile[key].r, Gladdy.dbi.profile[key].g, Gladdy.dbi.profile[key].b, Gladdy.dbi.profile[key].a
end
local function setColorOpt(info, r, g, b, a)
    local key = info.arg or info[#info]
    Gladdy.dbi.profile[key].r, Gladdy.dbi.profile[key].g, Gladdy.dbi.profile[key].b, Gladdy.dbi.profile[key].a = r, g, b, a
    Gladdy:UpdateFrame()
end

function Gladdy:SetupModule(name, module, order)
    self.options.args[name] = {
        type = "group",
        name = L[name],
        desc = L[name .. " settings"],
        order = order,
        args = {},
    }

    local options = module:GetOptions()

    if (type(options) == "table") then
        self.options.args[name].args = options
        self.options.args[name].args.reset = {
            type = "execute",
            name = L["Reset module"],
            desc = L["Reset module to defaults"],
            order = 1,
            func = function()
                for k, v in pairs(module.defaults) do
                    self.dbi.profile[k] = v
                end

                Gladdy:UpdateFrame()
                Gladdy:SetupModule(name, module, order) -- For example click names are not reset by default
            end
        }
    else
        self.options.args[name].args.nothing = {
            type = "description",
            name = L["No settings"],
            desc = L["Module has no settings"],
            order = 1,
        }
    end
end

local function pairsByKeys(t)
    local a = {}
    for k in pairs(t) do
        tinsert(a, k)
    end
    tsort(a)

    local i = 0
    return function()
        i = i + 1

        if (a[i] ~= nil) then
            return a[i], t[a[i]]
        else
            return nil
        end
    end
end

function Gladdy:SetupOptions()
    self.options = {
        type = "group",
        name = "Gladdy",
        plugins = {},
        get = getOpt,
        set = setOpt,
        args = {
            general = {
                type = "group",
                name = L["General"],
                desc = L["General settings"],
                order = 1,
                args = {
                    locked = {
                        type = "toggle",
                        name = L["Lock frame"],
                        desc = L["Toggle if frame can be moved"],
                        order = 1,
                    },
                    growUp = {
                        type = "toggle",
                        name = L["Grow frame upwards"],
                        desc = L["If enabled the frame will grow upwards instead of downwards"],
                        order = 2,
                    },
                    frameScale = {
                        type = "range",
                        name = L["Frame scale"],
                        desc = L["Scale of the frame"],
                        order = 3,
                        min = .1,
                        max = 2,
                        step = .1,
                    },
                    padding = {
                        type = "range",
                        name = L["Frame padding"],
                        desc = L["Padding of the frame"],
                        order = 4,
                        min = 0,
                        max = 20,
                        step = 1,
                    },
                    frameColor = {
                        type = "color",
                        name = L["Frame color"],
                        desc = L["Color of the frame"],
                        order = 5,
                        hasAlpha = true,
                        get = getColorOpt,
                        set = setColorOpt,
                    },
                    barWidth = {
                        type = "range",
                        name = L["Bar width"],
                        desc = L["Width of the bars"],
                        order = 6,
                        min = 10,
                        max = 500,
                        step = 5,
                    },
                    bottomMargin = {
                        type = "range",
                        name = L["Bottom margin"],
                        desc = L["Margin between each button"],
                        order = 7,
                        min = 0,
                        max = 50,
                        step = 1,
                    },
                    buttonBorderStyle = {
                        type = "select",
                        name = L["Icon border style"],
                        desc = L["This changes the border style of all icons"],
                        order = 8,
                        values = Gladdy:GetIconStyles(),
                        get = function(info)
                            if (Gladdy.db.classIconBorderStyle == Gladdy.db.trinketBorderStyle
                                    and Gladdy.db.classIconBorderStyle == Gladdy.db.castBarIconStyle
                                    and Gladdy.db.classIconBorderStyle == Gladdy.db.auraBorderStyle) then
                                return Gladdy.db.classIconBorderStyle
                            else
                                return ""
                            end
                        end,
                        set = function(info, value)
                            Gladdy.db.classIconBorderStyle = value
                            Gladdy.db.trinketBorderStyle = value
                            Gladdy.db.castBarIconStyle = value
                            Gladdy.db.auraBorderStyle = value
                            Gladdy:UpdateFrame()
                        end,
                    },
                    buttonBorderColor = {
                        type = "color",
                        name = L["Icon border color"],
                        desc = L["This changes the border color of all icons"],
                        order = 9,
                        hasAlpha = true,
                        get = function(info)
                            local a = Gladdy.db.classIconBorderColor
                            local b = Gladdy.db.trinketBorderColor
                            local c = Gladdy.db.castBarIconColor
                            if (a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a and a.r == c.r and a.g == c.g and a.b == c.b and a.a == c.a) then
                                return a.r, a.g, a.b, a.a
                            else
                                return { r = 0, g = 0, b = 0, a = 0 }
                            end
                        end,
                        set = function(info, r, g, b, a)
                            local rgb = {r = r, g = g, b = b, a = a}
                            Gladdy.db.classIconBorderColor = rgb
                            Gladdy.db.trinketBorderColor = rgb
                            Gladdy.db.castBarIconColor = rgb
                            Gladdy:UpdateFrame()
                        end,
                    },
                    frameBorderStyle = {
                        type = "select",
                        name = L["Statusbar border style"],
                        desc = L["This changes the border style of all statusbar frames"],
                        order = 10,
                        values = Gladdy:GetBorderStyles(),
                        get = function(info)
                            if (Gladdy.db.healthBarBorder == Gladdy.db.powerBarBorder and Gladdy.db.healthBarBorder == Gladdy.db.castBarBorderStyle) then
                                return Gladdy.db.healthBarBorder
                            else
                                return ""
                            end
                        end,
                        set = function(info, value)
                            Gladdy.db.healthBarBorder = value
                            Gladdy.db.powerBarBorder = value
                            Gladdy.db.castBarBorderStyle = value
                            Gladdy:UpdateFrame()
                        end,
                    },
                    frameBorderColor = {
                        type = "color",
                        name = L["Statusbar border color"],
                        desc = L["This changes the border color of all statusbar frames"],
                        order = 11,
                        hasAlpha = true,
                        get = function(info)
                            local a = Gladdy.db.castBarBorderColor
                            local b = Gladdy.db.healthBarBorderColor
                            local c = Gladdy.db.powerBarBorderColor
                            if (a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a and a.r == c.r and a.g == c.g and a.b == c.b and a.a == c.a) then
                                return a.r, a.g, a.b, a.a
                            else
                                return { r = 0, g = 0, b = 0, a = 0 }
                            end
                        end,
                        set = function(info, r, g, b, a)
                            local rgb = {r = r, g = g, b = b, a = a}
                            Gladdy.db.castBarBorderColor = rgb
                            Gladdy.db.healthBarBorderColor = rgb
                            Gladdy.db.powerBarBorderColor = rgb
                            Gladdy:UpdateFrame()
                        end,
                    },
                },
            },
        },
    }

    local order = 2
    for k, v in pairsByKeys(self.modules) do
        self:SetupModule(k, v, order)
        order = order + 1
    end

    self.options.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.dbi) }
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Gladdy", self.options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Gladdy", "Gladdy")
end

function Gladdy:ShowOptions()
    InterfaceOptionsFrame_OpenToFrame("Gladdy")
end