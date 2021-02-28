local tonumber = tonumber
local pairs = pairs

local CreateFrame = CreateFrame
local UIParent = UIParent
local InCombatLockdown = InCombatLockdown

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

Gladdy.BUTTON_DEFAULTS = {
    name = "",
    guid = "",
    raceLoc = "",
    classLoc = "",
    class = "",
    health = "",
    healthMax = 0,
    power = 0,
    powerMax = 0,
    powerType = 0,
    spec = "",
    spells = {},
    ns = false,
    nf = false,
    pom = false,
    fd = false,
    damaged = 0,
    click = false,
}

function Gladdy:CreateFrame()
    --self.db = self.dbi.profile ??
    self.frame = CreateFrame("Frame", "GladdyFrame", UIParent)

    self.frame:SetClampedToScreen(true)
    self.frame:EnableMouse(true)
    self.frame:SetMovable(true)
    self.frame:RegisterForDrag("LeftButton")

    self.frame:SetScript("OnDragStart", function(f)
        if (not InCombatLockdown() and not self.db.locked) then
            f:StartMoving()
        end
    end)
    self.frame:SetScript("OnDragStop", function(f)
        if (not InCombatLockdown()) then
            f:StopMovingOrSizing()

            local scale = f:GetEffectiveScale()
            self.db.x = f:GetLeft() * scale
            self.db.y = (self.db.growUp and f:GetBottom() or f:GetTop()) * scale
        end
    end)

    self.anchor = CreateFrame("Button", "GladdyAnchor", self.frame)
    self.anchor:SetHeight(20)
    self.anchor:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16 })
    self.anchor:SetBackdropColor(0, 0, 0, 1)
    self.anchor:SetClampedToScreen(true)
    self.anchor:EnableMouse(true)
    self.anchor:SetMovable(true)
    self.anchor:RegisterForDrag("LeftButton")
    self.anchor:RegisterForClicks("RightButtonUp")
    self.anchor:SetScript("OnDragStart", function()
        if (not InCombatLockdown() and not self.db.locked) then
            self.frame:StartMoving()
        end
    end)
    self.anchor:SetScript("OnDragStop", function()
        if (not InCombatLockdown()) then
            self.frame:StopMovingOrSizing()

            local scale = self.frame:GetEffectiveScale()
            self.db.x = self.frame:GetLeft() * scale
            self.db.y = (self.db.growUp and self.frame:GetBottom() or self.frame:GetTop()) * scale
        end
    end)
    self.anchor:SetScript("OnClick", function()
        if (not InCombatLockdown()) then
            self:ShowOptions()
        end
    end)

    self.anchor.text = self.anchor:CreateFontString("GladdyAnchorText", "ARTWORK", "GameFontHighlightSmall")
    self.anchor.text:SetText(L["Gladdy - drag to move"])
    self.anchor.text:SetPoint("CENTER")

    self.anchor.button = CreateFrame("Button", "GladdyAnchorButton", self.anchor, "UIPanelCloseButton")
    self.anchor.button:SetWidth(20)
    self.anchor.button:SetHeight(20)
    self.anchor.button:SetPoint("RIGHT", self.anchor, "RIGHT", 2, 0)
    self.anchor.button:SetScript("OnClick", function(_, _, down)
        if (not down) then
            self.db.locked = true
            self:UpdateFrame()
        end
    end)

    if (self.db.locked) then
        self.anchor:Hide()
    end

    self.frame:Hide()
end

local function StyleActionButton(f)
    local name = f:GetName()
    local button = _G[name]
    local icon = _G[name .. "Icon"]
    local normalTex = _G[name .. "NormalTexture"]
    local cooldown = _G[name .. "Cooldown"]

    normalTex:SetHeight(button:GetHeight())
    normalTex:SetWidth(button:GetWidth())
    normalTex:SetPoint("CENTER")

    cooldown:SetAlpha(Gladdy.db.cooldownCooldownAlpha)

    button:SetNormalTexture(Gladdy.db.cooldownBorderStyle)
    normalTex:SetVertexColor(Gladdy.db.cooldownBorderColor.r, Gladdy.db.cooldownBorderColor.g, Gladdy.db.cooldownBorderColor.b, Gladdy.db.cooldownBorderColor.a)

    icon:SetTexCoord(.1, .9, .1, .9)
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
end

function Gladdy:UpdateFrame()

    if (not self.frame) then
        self:CreateFrame()
    end
    local teamSize = self.curBracket or 0

    local iconSize = self.db.healthBarHeight
    local margin = 0
    local width = self.db.barWidth + self.db.padding * 2 + 5
    local height = self.db.healthBarHeight * teamSize + margin * (teamSize - 1) + self.db.padding * 2 + 5
    local extraBarWidth = 0
    local extraBarHeight = 0

    -- Powerbar
    iconSize = iconSize + self.db.powerBarHeight
    margin = margin + self.db.powerBarHeight
    height = height + self.db.powerBarHeight * teamSize
    extraBarHeight = extraBarHeight + self.db.powerBarHeight

    -- Cooldown
    margin = margin + self.db.padding + self.db.highlightBorderSize
    height = height

    if self.db.cooldownYPos == "TOP" or self.db.cooldownYPos == "BOTTOM" then
        margin = margin + self.db.cooldownSize
        height = height + self.db.cooldownSize * teamSize
    end

    -- Classicon
    width = width + iconSize
    extraBarWidth = extraBarWidth + iconSize

    -- Trinket
    width = width + iconSize

    self.frame:SetScale(self.db.frameScale)
    self.frame:SetWidth(width)
    self.frame:SetHeight(height)
    --self.frame:SetBackdropColor(self.db.frameColor.r, self.db.frameColor.g, self.db.frameColor.b, self.db.frameColor.a)
    self.frame:ClearAllPoints()
    if (self.db.x == 0 and self.db.y == 0) then
        self.frame:SetPoint("CENTER")
    else
        local scale = self.frame:GetEffectiveScale()
        if (self.db.growUp) then
            self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.x / scale, self.db.y / scale)
        else
            self.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.x / scale, self.db.y / scale)
        end
    end

    self.anchor:SetWidth(width)
    self.anchor:ClearAllPoints()
    if (self.db.growUp) then
        self.anchor:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT")
    else
        self.anchor:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT")
    end

    if (self.db.locked) then
        self.anchor:Hide()
        self.anchor:Hide()
    else
        self.anchor:Show()
    end

    for i = 1, teamSize do
        local button = self.buttons["arena" .. i]
        button:SetWidth(self.db.barWidth + extraBarWidth)
        button:SetHeight(self.db.healthBarHeight)
        button.secure:SetWidth(self.db.barWidth + extraBarWidth)
        button.secure:SetHeight(self.db.healthBarHeight + extraBarHeight)

        button:ClearAllPoints()
        button.secure:ClearAllPoints()
        if (self.db.growUp) then
            if (i == 1) then
                button:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", self.db.padding + 2, self.db.padding)
                button.secure:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", self.db.padding + 2, self.db.padding)
            else
                button:SetPoint("BOTTOMLEFT", self.buttons["arena" .. (i - 1)], "TOPLEFT", 0, margin + self.db.bottomMargin)
                button.secure:SetPoint("BOTTOMLEFT", self.buttons["arena" .. (i - 1)], "TOPLEFT", 0, margin + self.db.bottomMargin)
            end
        else
            if (i == 1) then
                button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.db.padding + 2, -self.db.padding)
                button.secure:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.db.padding + 2, -self.db.padding)
            else
                button:SetPoint("TOPLEFT", self.buttons["arena" .. (i - 1)], "BOTTOMLEFT", 0, -margin - self.db.bottomMargin)
                button.secure:SetPoint("TOPLEFT", self.buttons["arena" .. (i - 1)], "BOTTOMLEFT", 0, -margin - self.db.bottomMargin)
            end
        end

        -- Cooldown frame
        if (self.db.cooldown) then
            button.spellCooldownFrame:ClearAllPoints()
            local verticalMargin = -(Gladdy.db.powerBarHeight)/2
            if self.db.cooldownYPos == "TOP" then
                if self.db.cooldownXPos == "RIGHT" then
                    button.spellCooldownFrame:SetPoint("BOTTOMRIGHT", button.healthBar, "TOPRIGHT", Gladdy.db.cooldownXOffset, self.db.highlightBorderSize + Gladdy.db.cooldownYOffset) -- needs to be properly anchored after trinket
                else
                    button.spellCooldownFrame:SetPoint("BOTTOMLEFT", button.healthBar, "TOPLEFT", Gladdy.db.cooldownXOffset, self.db.highlightBorderSize + Gladdy.db.cooldownYOffset)
                end
            elseif self.db.cooldownYPos == "BOTTOM" then
                if self.db.cooldownXPos == "RIGHT" then
                    button.spellCooldownFrame:SetPoint("TOPRIGHT", button.powerBar, "BOTTOMRIGHT", Gladdy.db.cooldownXOffset, -self.db.highlightBorderSize + Gladdy.db.cooldownYOffset) -- needs to be properly anchored after trinket
                else
                    button.spellCooldownFrame:SetPoint("TOPLEFT", button.powerBar, "BOTTOMLEFT", Gladdy.db.cooldownXOffset, -self.db.highlightBorderSize + Gladdy.db.cooldownYOffset)
                end
            elseif self.db.cooldownYPos == "LEFT" then
                local horizontalMargin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
                if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
                    horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize - Gladdy.db.trinketSize * 0.1) + Gladdy.db.padding
                    if (Gladdy.db.classIconPos == "LEFT") then
                        horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize - Gladdy.db.classIconSize * 0.1) + Gladdy.db.padding
                    end
                elseif (Gladdy.db.classIconPos == "LEFT") then
                    horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize - Gladdy.db.classIconSize * 0.1) + Gladdy.db.padding
                    if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
                        horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize - Gladdy.db.trinketSize * 0.1) + Gladdy.db.padding
                    end
                end
                if (Gladdy.db.drCooldownPos == "LEFT" and Gladdy.db.drEnabled) then
                    verticalMargin = verticalMargin + Gladdy.db.drIconSize/2 + Gladdy.db.padding/2
                end
                if (Gladdy.db.castBarPos == "LEFT") then
                    verticalMargin = verticalMargin +
                            ((Gladdy.db.castBarHeight < Gladdy.db.castBarIconSize) and Gladdy.db.castBarIconSize
                                    or Gladdy.db.castBarHeight)/2 + Gladdy.db.padding/2
                end
                button.spellCooldownFrame:SetPoint("RIGHT", button.healthBar, "LEFT", -horizontalMargin + Gladdy.db.cooldownXOffset, Gladdy.db.cooldownYOffset + verticalMargin)
            elseif self.db.cooldownYPos == "RIGHT" then
                verticalMargin = -(Gladdy.db.powerBarHeight)/2
                local horizontalMargin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
                if (Gladdy.db.trinketPos == "RIGHT" and Gladdy.db.trinketEnabled) then
                    horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize - Gladdy.db.trinketSize * 0.1) + Gladdy.db.padding
                    if (Gladdy.db.classIconPos == "RIGHT") then
                        horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize - Gladdy.db.classIconSize * 0.1) + Gladdy.db.padding
                    end
                elseif (Gladdy.db.classIconPos == "RIGHT") then
                    horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize - Gladdy.db.classIconSize * 0.1) + Gladdy.db.padding
                    if (Gladdy.db.trinketPos == "RIGHT" and Gladdy.db.trinketEnabled) then
                        horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize - Gladdy.db.trinketSize * 0.1) + Gladdy.db.padding
                    end
                end
                if (Gladdy.db.drCooldownPos == "RIGHT" and Gladdy.db.drEnabled) then
                    verticalMargin = verticalMargin + Gladdy.db.drIconSize/2 + Gladdy.db.padding/2
                end
                if (Gladdy.db.castBarPos == "RIGHT") then
                    verticalMargin = verticalMargin +
                            ((Gladdy.db.castBarHeight < Gladdy.db.castBarIconSize) and Gladdy.db.castBarIconSize
                                    or Gladdy.db.castBarHeight)/2 + Gladdy.db.padding/2
                end
                button.spellCooldownFrame:SetPoint("LEFT", button.healthBar, "RIGHT", horizontalMargin + Gladdy.db.cooldownXOffset, Gladdy.db.cooldownYOffset + verticalMargin)
            end
            button.spellCooldownFrame:SetHeight(self.db.cooldownSize)
            button.spellCooldownFrame:SetWidth(1)
            button.spellCooldownFrame:Show()
            -- Update each cooldown icon
            local o = 1
            for j = 1, 14 do
                local icon = button.spellCooldownFrame["icon" .. j]
                icon:SetHeight(self.db.cooldownSize)
                icon:SetWidth(self.db.cooldownSize)
                icon.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.cooldownFont), self.db.cooldownSize / 2 * Gladdy.db.cooldownFontScale, "OUTLINE")
                icon.cooldownFont:SetTextColor(Gladdy.db.cooldownFontColor.r, Gladdy.db.cooldownFontColor.g, Gladdy.db.cooldownFontColor.b, Gladdy.db.cooldownFontColor.a)
                icon:ClearAllPoints()
                if (self.db.cooldownXPos == "RIGHT") then
                    if (j == 1) then
                        icon:SetPoint("RIGHT", button.spellCooldownFrame, "RIGHT", 0, 0)
                    elseif (mod(j-1,Gladdy.db.cooldownMaxIconsPerLine) == 0) then
                        if (self.db.cooldownYPos == "BOTTOM") then
                            icon:SetPoint("TOP", button.spellCooldownFrame["icon" .. o], "BOTTOM", 0, -1)
                        else
                            icon:SetPoint("BOTTOM", button.spellCooldownFrame["icon" .. o], "TOP", 0, 1)
                        end
                        o = o + tonumber(Gladdy.db.cooldownMaxIconsPerLine)
                    else
                        icon:SetPoint("RIGHT", button.spellCooldownFrame["icon" .. j - 1], "LEFT", -1, 0)
                    end
                end
                if (self.db.cooldownXPos == "LEFT") then
                    if (j == 1) then
                        icon:SetPoint("LEFT", button.spellCooldownFrame, "LEFT", 0, 0)
                    elseif (mod(j-1,Gladdy.db.cooldownMaxIconsPerLine) == 0) then
                        if (self.db.cooldownYPos == "BOTTOM") then
                            icon:SetPoint("TOP", button.spellCooldownFrame["icon" .. o], "BOTTOM", 0, -1)
                        else
                            icon:SetPoint("BOTTOM", button.spellCooldownFrame["icon" .. o], "TOP", 0, 1)
                        end
                        o = o + tonumber(Gladdy.db.cooldownMaxIconsPerLine)
                    else
                        icon:SetPoint("LEFT", button.spellCooldownFrame["icon" .. j - 1], "RIGHT", 1, 0)
                    end
                end

                if (icon.active) then
                    icon.active = false
                    icon.cooldown:SetCooldown(GetTime(), 0)
                    icon.cooldownFont:SetText("")
                    icon:SetScript("OnUpdate", nil)
                end
                icon.spellId = nil
                icon:SetAlpha(1)
                icon.texture:SetTexture("Interface\\Icons\\Spell_Holy_PainSupression")
                StyleActionButton(icon)

                if (not self.frame.testing) then
                    icon:Hide()
                else
                    icon:Show()
                end
            end
            button.spellCooldownFrame:Show()
        else
            button.spellCooldownFrame:Hide()
        end
        for k, v in self:IterModules() do
            self:Call(v, "UpdateFrame", button.unit)
        end
        Gladdy:UpdateTestCooldowns(i)
    end
    Gladdy.modules["PlateCastBar"]:UpdateFrame()
end

function Gladdy:HideFrame()
    if (self.frame) then
        self.frame:Hide()
    end

    self:UnregisterAllEvents()
    self:CancelAllTimers()
    self:UnregisterAllComm()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Gladdy:ToggleFrame(i)
    self:Reset()

    if (self.frame and self.frame:IsShown() and i == self.curBracket) then
        self:HideFrame()
    else
        self:UnregisterAllEvents()
        self.curBracket = i

        if (not self.frame) then
            self:CreateFrame()
        end

        self:Test()
        self:UpdateFrame()
        self.frame:Show()
    end
end

function Gladdy:CreateButton(i)
    if (not self.frame) then
        self:CreateFrame()
    end

    local button = CreateFrame("Frame", "GladdyButtonFrame" .. i, self.frame)
    button:SetAlpha(0)

    -- Trinket presser
    local trinketButton = CreateFrame("Button", "GladdyTrinketButton" .. i, button, "SecureActionButtonTemplate")
    trinketButton:RegisterForClicks("AnyUp")
    trinketButton:SetAttribute("*type*", "macro")
    --trinketButton:SetAttribute("macrotext1", string.format("/script Gladdy:TrinketUsed(\"%s\")", "arena" .. i))
    -- Is there a way to NOT use a global function?
    trinketButton:SetAttribute("macrotext1", string.format("/script Trinket:Used(\"%s\")", "arena" .. i))

    -- Cooldown frame
    local spellCooldownFrame = CreateFrame("Frame", nil, button)
    for x = 1, 14 do
        local icon = CreateFrame("CheckButton", "GladdyButton" .. i .. "SpellCooldownFrame" .. x, spellCooldownFrame, "ActionButtonTemplate")
        icon:EnableMouse(false)
        icon.texture = _G[icon:GetName() .. "Icon"]
        icon.cooldown = _G[icon:GetName() .. "Cooldown"]
        icon.cooldown:SetReverse(false)
        icon.cooldown.noCooldownCount = true --Gladdy.db.trinketDisableOmniCC
        icon.cooldownFrame = CreateFrame("Frame", nil, icon)
        icon.cooldownFrame:ClearAllPoints()
        icon.cooldownFrame:SetPoint("TOPLEFT", icon, "TOPLEFT")
        icon.cooldownFrame:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")
        icon.cooldownFont = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.cooldownFont), self.db.cooldownSize / 2  * Gladdy.db.cooldownFontScale, "OUTLINE")
        icon.cooldownFont:SetTextColor(Gladdy.db.cooldownFontColor.r, Gladdy.db.cooldownFontColor.g, Gladdy.db.cooldownFontColor.b, Gladdy.db.cooldownFontColor.a)
        icon.cooldownFont:SetAllPoints(icon)

        spellCooldownFrame["icon" .. x] = icon
    end

    local secure = CreateFrame("Button", "GladdyButton" .. i, button, "SecureActionButtonTemplate")
    secure:RegisterForClicks("AnyUp")
    secure:SetAttribute("*type*", "macro")

    button.id = i
    button.unit = "arena" .. i
    button.secure = secure
    button.trinketButton = trinketButton
    button.spellCooldownFrame = spellCooldownFrame

    for k, v in pairs(self.BUTTON_DEFAULTS) do
        button[k] = v
    end

    self.buttons[button.unit] = button

    for k, v in self:IterModules() do
        self:Call(v, "CreateFrame", button.unit)
    end
end