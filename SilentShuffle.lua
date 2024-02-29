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
local IsChatDisabled = C_SocialRestrictions.IsChatDisabled
local IsRatedSoloShuffle = C_PvP.IsRatedSoloShuffle
local IsRatedArena = C_PvP.IsRatedArena
local IsSkirmish = C_PvP.IsArena

local chatSettingsMemory
local enableRatedArena
local enableSkirmish


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

-- Function to log debug messages
function SilentShuffle:DebugLog(message)
    if self.db.profile.debug then
        print(silentShuffleTitle .. ": " .. message)
    end
end

function SetLastMatchType(matchType)
   lastMatchType = matchType
end

function GetLastMatchType()
    return lastMatchType
end

-- Function to handle arena join
function SilentShuffle:OnArenaJoin()
    self:DebugLog("Joined Arena, Checking if it's Shuffle")
    if not IsRatedSoloShuffle() and not IsRatedArena and not IsSkirmish then
        self:DebugLog("Protecting conditions not met")
        return
    end
    if IsRatedSoloShuffle() then
        if IsChatDisabled() == true and chatSettingsMemory == true then
            print(silentShuffleTitle .. ": In Shuffle - Chat was already Disabled")
        else
            setChatDisabled(true)
            print(silentShuffleTitle .. ": In Shuffle - Chat Disabled")
        end
        SetLastMatchType("SoloShuffle")
        self:DebugLog("Last Match Type is".. lastMatchType)
    elseif IsRatedArena() and self.db.profile.enableRatedArena then
        if IsChatDisabled() == true and chatSettingsMemory == true then
            print(silentShuffleTitle .. ": In Rated Arena - Chat was already Disabled")
        else
            setChatDisabled(true)
            print(silentShuffleTitle .. ": In Rated Arena - Chat Disabled")
        end
        SetLastMatchType("RatedArena")
        self:DebugLog("Last Match Type is".. lastMatchType)
    elseif IsSkirmish() and self.db.profile.enableSkirmish then
        if IsChatDisabled() == true and chatSettingsMemory == true then
            print(silentShuffleTitle .. ": In Skirmish Arena - Chat was already Disabled")
        else
            setChatDisabled(true)
            print(silentShuffleTitle .. ": In Skirmish Arena - Chat Disabled")
        end
        SetLastMatchType("SkirmishArena")
        self:DebugLog("Last Match Type is".. lastMatchType)
    end
end

-- Function to handle arena leave
function SilentShuffle:OnArenaLeave()
    self:DebugLog("Left Arena, Checking arena type")
    local lastMatch = GetLastMatchType()
    if IsRatedSoloShuffle() == true or IsRatedArena() == true or IsSkirmish() == true then
        self:DebugLog("Protective conditions are not met")
        return
    end
    if lastMatch == "SoloShuffle" then
        setChatDisabled(chatSettingsMemory)
        print(silentShuffleTitle .. ": Not in Shuffle - Chat restored to previous settings")
    elseif lastMatch == "RatedArena" then
        setChatDisabled(chatSettingsMemory)
        print(silentShuffleTitle .. ": Not in Rated Arena - Chat restored to previous settings")
    elseif lastMatch == "SkirmishArena" then
        setChatDisabled(chatSettingsMemory)
        print(silentShuffleTitle .. ": Not in Skirmish Arena - Chat restored to previous settings")
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

    if self.db.profile.enableRatedArena == nil then
        self.db.profile.enableRatedArena = false
    end

    if self.db.profile.enableSkirmish == nil then
        self.db.profile.enableSkirmish = false
    end

     chatSettingsMemory = IsChatDisabled()

    self:DebugLog("Initialized")

    if self.db.profile.enabled then
        print(silentShuffleTitle..": Addon Enabled")
    elseif not self.db.profile.enabled then
        print(silentShuffleTitle..": Addon Disabled")
    end

    -- Register events
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "EventHandler")
    self:RegisterEvent("PLAYER_LOGOUT", "LogoutHandler")
end

-- Set up the configuration handler for AceConfig
-- Function to set up the configuration handler for AceConfig
function SilentShuffle:SetConfigHandler()
    local options = {
        type = "group",
        inline = false,
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
                order = 1,
            },
            debug = {
                type = "toggle",
                name = "Enable Debug",
                desc = "Enable or disable debug messages",
                get = function() return self.db.profile.debug end,
                set = function(_, val)
                    self.db.profile.debug = val
                end,
                order = 30,  -- Adjust order as needed
            },
            enableRatedArena = {
                type = "toggle",
                name = "Enable Rated Arena",
                desc = "Enable or disable functionality for Rated Arena",
                get = function() return self.db.profile.enableRatedArena end,
                set = function(_, val)
                    self.db.profile.enableRatedArena = val
                end,
                order = 10,  -- Adjust order as needed
            },
            enableSkirmish = {
                type = "toggle",
                name = "Enable Skirmish",
                desc = "Enable or disable functionality for Skirmish",
                get = function() return self.db.profile.enableSkirmish end,
                set = function(_, val)
                    self.db.profile.enableSkirmish = val
                end,
                order = 20,  -- Adjust order as needed
            },
        },
    }

    AceConfig:RegisterOptionsTable("SilentShuffle", options)
    AceConfigDialog:AddToBlizOptions("SilentShuffle", "Silent Shuffle")
end

-- Event handler function
function SilentShuffle:EventHandler()
    local _, currentInstanceType = IsInInstance()
    if not self.db.profile.enabled then
        self:DebugLog("You disabled the addon from the menu")
         return
    end
    self:DebugLog("Zone Changed..")        
    if self.db.profile.enabled then
        if currentInstanceType == "arena" then
            self:DebugLog(currentInstanceType)
            self:OnArenaJoin()
         elseif currentInstanceType ~= "arena" and self.currentInstanceType == "arena" then
            self:DebugLog("Arena leaving")
            self:OnArenaLeave()
        elseif currentInstanceType == "none" then
            self:DebugLog("Current Instance Type is "..currentInstanceType)
        end
    end
    self.currentInstanceType = currentInstanceType
    self:DebugLog("self.currentInstanceType After updating: "..self.currentInstanceType.." vs. currentInstanceType "..currentInstanceType)
end

-- Logout handler function to restore the value of Chat Disabled obtained during previous login/reload
function SilentShuffle:LogoutHandler()
    setChatDisabled(chatSettingsMemory)
end