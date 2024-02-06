-- Load AceAddon, AceConsole, AceEvent, AceGUI, and AceConfig libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")

-- Create a new AceAddon instance
local SilentShuffle = AceAddon:NewAddon("SilentShuffle", "AceConsole-3.0", "AceEvent-3.0")

-- Define addon metadata
local silentShuffleTitle = "|cff00ff88Silent Shuffle|r"
local AddonVersion = C_AddOns.GetAddOnMetadata("SilentShuffle", "Version")

-- Variables for chat control
local setChatDisabled = C_SocialRestrictions.SetChatDisabled
local IsRatedSoloShuffle = C_PvP.IsRatedSoloShuffle

-- Variables for instance checking
local IsInInstance = IsInInstance

-- Print welcome message
local welcomeMsg = "%s: Silent Shuffle version |cff00e5ff%s|r loaded successfully"
print(string.format(welcomeMsg, silentShuffleTitle, AddonVersion))

-- Function to handle enabling the addon
function SilentShuffle:EnableAddon()
    print(silentShuffleTitle .. ": Addon Enabled")
end

-- Function to handle disabling the addon
function SilentShuffle:DisableAddon()
    print(silentShuffleTitle .. ": Addon Disabled")
end

-- Function to handle arena join
function SilentShuffle:OnArenaJoin()
    if IsRatedSoloShuffle() == false then
        return
    elseif self.db.profile.enabled then
        setChatDisabled(true)
        print(silentShuffleTitle .. ": In Shuffle - Chat Disabled")
    end
end

-- Function to handle arena leave
function SilentShuffle:OnArenaLeave()
    if IsRatedSoloShuffle() == false then
        return
    elseif self.db.profile.enabled then
        setChatDisabled(false)
        print(silentShuffleTitle .. ": Not in Shuffle - Chat Enabled")
    end
end

-- Function to open the configuration GUI
function SilentShuffle:OpenConfig()
    AceConfigDialog:Open("SilentShuffle")
end

-- Function to initialize the addon
function SilentShuffle:OnInitialize()
    -- Set up AceConfig
    self:RegisterChatCommand("ssconfig", "OpenConfig")
    self:SetConfigHandler()

    -- Set up saved variables
    self.db = LibStub("AceDB-3.0"):New("SilentShuffleDB", { profile = { enabled = true } }, true)

    -- Check if saved variables exist, if not, set default values
    if self.db.profile.enabled == nil then
        self.db.profile.enabled = true
    end

    print(silentShuffleTitle .. ": Initialized")

    -- Register events
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "EventHandler")
end

-- Set up the configuration handler for AceConfig
function SilentShuffle:SetConfigHandler()
    local options = {
        type = "group",
        args = {
            enable = {
                type = "toggle",
                name = "Enable Silent Shuffle",
                desc = "Enable or disable Silent Shuffle",
                get = function() return self.db.profile.enabled end,
                set = function(_, val)
                    self.db.profile.enabled = val
                    if val then
                        self:EnableAddon()
                    else
                        self:DisableAddon()
                    end
                end,
            },
        },
    }

    AceConfig:RegisterOptionsTable("SilentShuffle", options)
    AceConfigDialog:AddToBlizOptions("SilentShuffle", "Silent Shuffle")
end

-- Event handler function
function SilentShuffle:EventHandler(_, event, ...)
    local _, currentInstanceType = IsInInstance()
    if event == "ZONE_CHANGED_NEW_AREA" then
        if self.db.profile.enabled then
            if currentInstanceType == "arena" then
                self:OnArenaJoin()
            elseif currentInstanceType ~= "arena" and self.currentInstanceType == "arena" then
                self:OnArenaLeave()
            end
        end

        self.currentInstanceType = currentInstanceType
    end
end
