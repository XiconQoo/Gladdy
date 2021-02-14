local pairs = pairs

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
VersionCheck = Gladdy:NewModule("VersionCheck", nil, {
})
LibStub("AceComm-3.0"):Embed(VersionCheck)

function VersionCheck:Initialise()
    self.frames = {}

    self:RegisterMessage("JOINED_ARENA")
end

function VersionCheck:Reset()
    self:UnregisterComm("GladdyVersionCheck")
end

function VersionCheck:JOINED_ARENA()
    self:RegisterComm("GladdyVersionCheck")
end

function VersionCheck:OnCommReceived(prefix, serverVersion)
    local addonVersion = "1"
    if (serverVersion == addonVersion) then
        -- DEFAULT_CHAT_FRAME:AddMessage("GladdyVersionCheck: |cff33ff99Version " .. addonVersion .. " is up to date|r")
    else
        --TODO self version check
        DEFAULT_CHAT_FRAME:AddMessage("GladdyVersionCheck: |cffff0000Current version " .. addonVersion .. " is outdated. Server version: " .. serverVersion .. ".|r")
        DEFAULT_CHAT_FRAME:AddMessage("Please download the latest Gladdy version at:")
        DEFAULT_CHAT_FRAME:AddMessage("https://github.com/SunstriderEmu/GladdyEndless/releases")
    end
end

function VersionCheck:GetOptions()
    return {
    }
end
