local pairs = pairs

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
Trinket = Gladdy:NewModule("Trinket", nil, {
    trinketEnabled = true,
    --trinketDisableOmniCC = true,
    trinketPos = "RIGHT"
})
LibStub("AceComm-3.0"):Embed(Trinket)

function Trinket:Initialise()
    self.frames = {}

    self:RegisterMessage("JOINED_ARENA")
end

function Trinket:CreateFrame(unit)
    local trinket = Gladdy.buttons[unit].trinketButton
    trinket.texture = trinket:CreateTexture(nil, "ARTWORK")
    trinket.texture:SetAllPoints(trinket)
    trinket.texture:SetTexture("Interface\\Icons\\INV_Jewelry_TrinketPVP_02")

    local function formatTimer(num, numDecimalPlaces)
        return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
    end

    --trinket.frame = CreateFrame("Frame", nil, Gladdy.buttons[unit])

    trinket:SetScript("OnUpdate", function(self, elapsed)
        if (self.active) then
            if (self.timeLeft <= 0) then
                self.active = false
                Gladdy:SendMessage("TRINKET_READY", unit)
            else
                self.timeLeft = self.timeLeft - elapsed
            end

            local timeLeft = ceil(self.timeLeft)
            local timeLeftMilliSec = formatTimer(self.timeLeft, 1)

            if timeLeft >= 60 then
                -- more than 1 minute
                self.cooldownFont:SetTextColor(1, 1, 0)
                self.cooldownFont:SetText(floor(timeLeft / 60) .. ":" .. string.format("%02.f", floor(timeLeft - floor(timeLeft / 60) * 60)))
                self.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 20, "OUTLINE")
            elseif timeLeft < 60 and timeLeft >= 21 then
                -- between 60s and 21s (green)
                self.cooldownFont:SetTextColor(0.7, 1, 0)
                self.cooldownFont:SetText(timeLeft)
                self.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 30, "OUTLINE")
            elseif timeLeft < 20.9 and timeLeft >= 11 then
                -- between 20s and 11s (green)
                self.cooldownFont:SetTextColor(0, 1, 0)
                self.cooldownFont:SetText(timeLeft)
                self.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 30, "OUTLINE")
            elseif timeLeftMilliSec <= 10 and timeLeftMilliSec >= 5 then
                -- between 10s and 5s (orange)
                self.cooldownFont:SetTextColor(1, 0.7, 0)
                self.cooldownFont:SetFormattedText("%.1f", timeLeftMilliSec)
                self.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 30, "OUTLINE")
            elseif timeLeftMilliSec < 5 and timeLeftMilliSec > 0 then
                -- between 5s and 1s (red)
                self.cooldownFont:SetTextColor(1, 0, 0)
                self.cooldownFont:SetFormattedText("%.1f", timeLeftMilliSec)
                self.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 30, "OUTLINE")
            else
                self.cooldownFont:SetText("")
            end
        end
    end)

    trinket.cooldown = CreateFrame("Cooldown", nil, trinket, "CooldownFrameTemplate")
    trinket.cooldown.noCooldownCount = true --Gladdy.db.trinketDisableOmniCC
    trinket.cooldownFont = trinket.cooldown:CreateFontString(nil, "OVERLAY")
    trinket.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 20, "OUTLINE")
    trinket.cooldownFont:SetAllPoints(trinket.cooldown)

    trinket.border = CreateFrame("Frame", nil, trinket)
    trinket.border:SetBackdrop({ edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
                                 edgeSize = 24 })
    trinket.border:SetPoint("CENTER", trinket, "CENTER", 0, 0)

    self.frames[unit] = trinket
end

function Trinket:UpdateFrame(unit)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end

    local classIcon = Gladdy.modules.Classicon.frames[unit]
    local width, height = classIcon:GetWidth(), classIcon:GetHeight()

    trinket:SetWidth(width)
    trinket:SetHeight(height)
    trinket.cooldown:SetWidth(width - 4)
    trinket.cooldown:SetHeight(height - 4)

    trinket.border:SetWidth(width)
    trinket.border:SetHeight(height)

    --trinket.border:ClearAllPoints()
    trinket.border:SetBackdropBorderColor(0, 0, 0, 1)

    trinket:ClearAllPoints()
    local margin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
    if (Gladdy.db.classIconPos == "LEFT") then
        if (Gladdy.db.trinketPos == "RIGHT") then
            trinket:SetPoint("TOPLEFT", Gladdy.buttons[unit].healthBar, "TOPRIGHT", margin, 2)
        else
            trinket:SetPoint("TOPRIGHT", Gladdy.buttons[unit].classIcon, "TOPLEFT", -Gladdy.db.padding, 0)
        end

    else
        if (Gladdy.db.trinketPos == "RIGHT") then
            trinket:SetPoint("TOPLEFT", Gladdy.buttons[unit].classIcon, "TOPRIGHT", Gladdy.db.padding, 0)
        else
            trinket:SetPoint("TOPRIGHT", Gladdy.buttons[unit].healthBar, "TOPLEFT", -margin, 2)
        end
    end
    trinket.texture:ClearAllPoints()
    trinket.texture:SetAllPoints(trinket)

    trinket.cooldown:ClearAllPoints()
    trinket.cooldown:SetPoint("CENTER", trinket, "CENTER")
    trinket.cooldown.noCooldownCount = true -- Gladdy.db.trinketDisableOmniCC

    if (Gladdy.db.trinketEnabled == false) then
        trinket:Hide()
    else
        trinket:Show()
    end
end

function Trinket:Reset()
    self:UnregisterComm("GladdyTrinketUsed")
end

function Trinket:ResetUnit(unit)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end

    trinket.timeLeft = nil
    trinket.active = false
    trinket.cooldown:SetCooldown(GetTime(), 0)
end

function Trinket:Test(unit)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end

    if (unit == "arena3" or unit == "arena4") then
        self:Used(unit)
    end
end

function Trinket:JOINED_ARENA()
    self:RegisterComm("GladdyTrinketUsed")
end

function Trinket:OnCommReceived(prefix, guid)
    guid = string.lower(guid)
    if (prefix == "GladdyTrinketUsed") then
        for k, v in pairs(Gladdy.buttons) do
            local vguid = string.lower(v.guid)
            if (vguid == guid) then
                self:Used(k)
                break
            end
        end
    end
end

function Trinket:Used(unit)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end

    Gladdy:SendMessage("TRINKET_USED", unit)

    trinket.timeLeft = 120
    trinket.active = true
    trinket.cooldown:SetCooldown(GetTime(), 120)
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
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Trinket:GetOptions()
    return {
        trinketEnabled = option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Enable trinket icon"],
            order = 2,
        }),
        --[[trinketDisableOmniCC = option({
            type = "toggle",
            name = L["No OmniCC"],
            desc = L["Disable cooldown timers by addons (reload UI to take effect)"],
            order = 3,
        }),--]]
        trinketPos = option({
            type = "select",
            name = L["Trinket position"],
            desc = L["This changes positions of the trinket"],
            order = 4,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        })
    }
end