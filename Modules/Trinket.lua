local pairs = pairs

local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
Trinket = Gladdy:NewModule("Trinket", nil, {
    trinketFont = "DorisPP",
    trinketEnabled = true,
    --trinketDisableOmniCC = true,
    trinketPos = "RIGHT",
    trinketBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    trinketBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    trinketDisableCircle = false,
})
LibStub("AceComm-3.0"):Embed(Trinket)

function Trinket:Initialise()
    self.frames = {}

    self:RegisterMessage("JOINED_ARENA")
end

function Trinket:CreateFrame(unit)
    local trinket = Gladdy.buttons[unit].trinketButton
    trinket.texture = trinket:CreateTexture(nil, "BACKGROUND")
    trinket.texture:SetAllPoints(trinket)
    trinket.texture:SetTexture("Interface\\Icons\\INV_Jewelry_TrinketPVP_02")

    trinket.cooldown = CreateFrame("Cooldown", nil, trinket, "CooldownFrameTemplate")
    trinket.cooldown.noCooldownCount = true --Gladdy.db.trinketDisableOmniCC

    trinket.cooldownFrame = CreateFrame("Frame", nil, trinket)
    trinket.cooldownFrame:ClearAllPoints()
    trinket.cooldownFrame:SetPoint("TOPLEFT", trinket, "TOPLEFT")
    trinket.cooldownFrame:SetPoint("BOTTOMRIGHT", trinket, "BOTTOMRIGHT")

    trinket.cooldownFont = trinket.cooldownFrame:CreateFontString(nil, "OVERLAY")
    trinket.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), 20, "OUTLINE")
    trinket.cooldownFont:SetAllPoints(trinket.cooldown)

    trinket.borderFrame = CreateFrame("Frame", nil, trinket)
    trinket.borderFrame:SetAllPoints(trinket)
    trinket.texture.overlay = trinket.borderFrame:CreateTexture(nil, "OVERLAY")
    trinket.texture.overlay:SetAllPoints(trinket)
    trinket.texture.overlay:SetTexture(Gladdy.db.trinketBorderStyle)

    local function formatTimer(num, numDecimalPlaces)
        return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
    end

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
                self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), 20, "OUTLINE")
            elseif timeLeft < 60 and timeLeft >= 21 then
                -- between 60s and 21s (green)
                self.cooldownFont:SetTextColor(0.7, 1, 0)
                self.cooldownFont:SetText(timeLeft)
                self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), 30, "OUTLINE")
            elseif timeLeft < 20.9 and timeLeft >= 11 then
                -- between 20s and 11s (green)
                self.cooldownFont:SetTextColor(0, 1, 0)
                self.cooldownFont:SetText(timeLeft)
                self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), 30, "OUTLINE")
            elseif timeLeftMilliSec <= 10 and timeLeftMilliSec >= 5 then
                -- between 10s and 5s (orange)
                self.cooldownFont:SetTextColor(1, 0.7, 0)
                self.cooldownFont:SetFormattedText("%.1f", timeLeftMilliSec)
                self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), 30, "OUTLINE")
            elseif timeLeftMilliSec < 5 and timeLeftMilliSec > 0 then
                -- between 5s and 1s (red)
                self.cooldownFont:SetTextColor(1, 0, 0)
                self.cooldownFont:SetFormattedText("%.1f", timeLeftMilliSec)
                self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), 30, "OUTLINE")
            else
                self.cooldownFont:SetText("")
            end
        end
    end)

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
    trinket.cooldown:ClearAllPoints()
    trinket.cooldown:SetPoint("CENTER", trinket, "CENTER")
    trinket.cooldown.noCooldownCount = true -- Gladdy.db.trinketDisableOmniCC

    trinket.texture:ClearAllPoints()
    trinket.texture:SetAllPoints(trinket)

    trinket.texture.overlay:SetTexture(Gladdy.db.trinketBorderStyle)
    trinket.texture.overlay:SetVertexColor(Gladdy.db.trinketBorderColor.r, Gladdy.db.trinketBorderColor.g, Gladdy.db.trinketBorderColor.b, Gladdy.db.trinketBorderColor.a)

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
    trinket.cooldownFont:SetText("")
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
    if not Gladdy.db.trinketDisableCircle then trinket.cooldown:SetCooldown(GetTime(), 120) end
end

function Trinket:GetOptions()
    return {
        trinketEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Enable trinket icon"],
            order = 2,
        }),
        trinketDisableCircle = Gladdy:option({
            type = "toggle",
            name = L["No Cooldown Circle"],
            order = 3,
        }),
        trinketFont = Gladdy:option({
            type = "select",
            name = L["Font"],
            desc = L["Font of the cooldown"],
            order = 4,
            dialogControl = "LSM30_Font",
            values = AceGUIWidgetLSMlists.font,
        }),
        --[[trinketDisableOmniCC = Gladdy:option({
            type = "toggle",
            name = L["No OmniCC"],
            desc = L["Disable cooldown timers by addons (reload UI to take effect)"],
            order = 3,
        }),--]]
        trinketPos = Gladdy:option({
            type = "select",
            name = L["Trinket position"],
            desc = L["This changes positions of the trinket"],
            order = 5,
            values = {
                ["LEFT"] = L["Left"],
                ["RIGHT"] = L["Right"],
            },
        }),
        trinketBorderStyle = Gladdy:option({
            type = "select",
            name = L["Border style"],
            order = 6,
            values = Gladdy:GetIconStyles()
        }),
        trinketBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Border color"],
            desc = L["Color of the border"],
            order = 7,
            hasAlpha = true,
        }),
    }
end