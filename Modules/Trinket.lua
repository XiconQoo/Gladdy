local pairs = pairs

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
Trinket = Gladdy:NewModule("Trinket", nil, {
    trinketEnabled = true,
    trinketDisableOmniCC = true
})
LibStub("AceComm-3.0"):Embed(Trinket)

function Trinket:Initialise()
    self.frames = {}

    self:RegisterMessage("JOINED_ARENA")
end

function Trinket:CreateFrame(unit)
    local trinket = Gladdy.buttons[unit]:CreateTexture(nil, "ARTWORK")
    trinket:SetTexture("Interface\\Icons\\INV_Jewelry_TrinketPVP_02")

    local function formatTimer(num, numDecimalPlaces)
        return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
    end

    trinket.frame = CreateFrame("Frame", nil, Gladdy.buttons[unit])

    trinket.frame:SetScript("OnUpdate", function(self, elapsed)
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
                trinket.frame.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 20, "OUTLINE")
            elseif timeLeft < 60 and timeLeft >= 21 then
                -- between 60s and 21s (green)
                self.cooldownFont:SetTextColor(0.7, 1, 0)
                self.cooldownFont:SetText(timeLeft)
                trinket.frame.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 30, "OUTLINE")
            elseif timeLeft < 20.9 and timeLeft >= 11 then
                -- between 20s and 11s (green)
                self.cooldownFont:SetTextColor(0, 1, 0)
                self.cooldownFont:SetText(timeLeft)
                trinket.frame.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 30, "OUTLINE")
            elseif timeLeftMilliSec <= 10 and timeLeftMilliSec >= 5 then
                -- between 10s and 5s (orange)
                self.cooldownFont:SetTextColor(1, 0.7, 0)
                self.cooldownFont:SetFormattedText("%.1f", timeLeftMilliSec)
                trinket.frame.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 30, "OUTLINE")
            elseif timeLeftMilliSec < 5 and timeLeftMilliSec > 0 then
                -- between 5s and 1s (red)
                self.cooldownFont:SetTextColor(1, 0, 0)
                self.cooldownFont:SetFormattedText("%.1f", timeLeftMilliSec)
                trinket.frame.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 30, "OUTLINE")
            else
                self.cooldownFont:SetText("")
            end
        end
    end)

    trinket.cooldown = CreateFrame("Cooldown", nil, Gladdy.buttons[unit], "CooldownFrameTemplate")
    trinket.cooldown.noCooldownCount = Gladdy.db.trinketDisableOmniCC
    trinket.frame.cooldownFont = trinket.cooldown:CreateFontString(nil, "OVERLAY")
    trinket.frame.cooldownFont:SetFont("Fonts\\FRIZQT__.ttf", 20, "OUTLINE")
    trinket.frame.cooldownFont:SetAllPoints(trinket.cooldown)

    self.frames[unit] = trinket
end

function Trinket:UpdateFrame(unit)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end

    local classIcon = Gladdy.modules.Classicon.frames[unit]

    trinket:SetWidth(classIcon:GetWidth())
    trinket:SetHeight(classIcon:GetHeight())
    trinket.cooldown:SetWidth(classIcon:GetWidth())
    trinket.cooldown:SetHeight(classIcon:GetWidth())

    trinket:ClearAllPoints()
    if (Gladdy.db.classIconPos == "LEFT") then
        trinket:SetPoint("TOPLEFT", Gladdy.buttons[unit], "TOPRIGHT", 72, 2)
    else
        trinket:SetPoint("TOPLEFT", Gladdy.buttons[unit], "TOPLEFT", 250, 2)
    end
    trinket.cooldown:ClearAllPoints()
    trinket.cooldown:SetAllPoints(trinket)
    trinket.cooldown.noCooldownCount = Gladdy.db.trinketDisableOmniCC

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

    trinket.frame.timeLeft = nil
    trinket.frame.active = false
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

    trinket.frame.timeLeft = 120
    trinket.frame.active = true
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
        trinketDisableOmniCC = option({
            type = "toggle",
            name = L["No OmniCC"],
            desc = L["Disable cooldown timers by addons (reload UI to take effect)"],
            order = 3,
        }),
    }
end