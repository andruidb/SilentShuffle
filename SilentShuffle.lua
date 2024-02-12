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
local chatSettingsMemory

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

-- Function to handle arena join
function SilentShuffle:OnArenaJoin()
    self:DebugLog("Joined Arena, Checking if it's Shuffle")
    if IsRatedSoloShuffle() == false then
        return
    else 
        if IsChatDisabled() == true and chatSettingsMemory == true then
            print(silentShuffleTitle .. ": In Shuffle - Chat was already Disabled")
        else
            setChatDisabled(true)
            print(silentShuffleTitle .. ": In Shuffle - Chat Disabled")
        end
    end
end

-- Function to handle arena leave
function SilentShuffle:OnArenaLeave()
    self:DebugLog("Left Arena, Checking if was Shuffle")
    if IsRatedSoloShuffle() == true then
        return
    else
        setChatDisabled(chatSettingsMemory)
        print(silentShuffleTitle .. ": Not in Shuffle - Chat restored to previous settings")
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

     chatSettingsMemory = IsChatDisabled()

    print(silentShuffleTitle .. ": Initialized")

    if self.db.profile.enabled then
        print(silentShuffleTitle..": Addon Enabled")
    elseif not self.db.profile.enabled then
        print(silentShuffleTitle..": Addon Disabled")
    end

    -- Register events
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "EventHandler")
end

-- Set up the configuration handler for AceConfig
-- Function to set up the configuration handler for AceConfig
function SilentShuffle:SetConfigHandler()
    local options = {
        type = "group",
        name = "Silent Shuffle",
        inline = true,
        args = {
            mainGroup = {
                type = "group",
                name = silentShuffleTitle,
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
                            order = 2,
                        },
                            -- Add more debug options if needed
                    },
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
        self:DebugLog(silentShuffleTitle..": You disabled the addon from the menu ")
         return
    end
    self:DebugLog("Zone Changed..")        
    if self.db.profile.enabled then
        if currentInstanceType == "arena" then
            self:DebugLog(currentInstanceType)
            self:OnArenaJoin()
         elseif currentInstanceType ~= "arena" and self.currentInstanceType == "arena" then
            self:DebugLog("self.currentInstanceType Before leaving arena updating: "..self.currentInstanceType.." vs. currentInstanceType "..currentInstanceType)
            self:DebugLog("leaving arena instance")
            self:OnArenaLeave()
        elseif currentInstanceType == "none" then
            self:DebugLog("Current Instance Type is "..currentInstanceType)
        end
    end
    self.currentInstanceType = currentInstanceType
    self:DebugLog("self.currentInstanceType After updating: "..self.currentInstanceType.." vs. currentInstanceType "..currentInstanceType)
end