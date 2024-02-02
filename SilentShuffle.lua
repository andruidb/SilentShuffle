--Initial Version on 29 January 2024

-- Initialization
local addonName = "SilentShuffle"
local silentShuffleTitle = "|cff00ff88Silent Shuffle|r"
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local AddonVersion = GetAddOnMetadata(addonName, "Version")
local setChatDisabled = C_SocialRestrictions.SetChatDisabled
local IsRatedSoloShuffle = C_PvP.IsRatedSoloShuffle
local IsInInstance = IsInInstance
--local instanceType = instanceType

--print(silentShuffleTitle..": Silent Shuffle version".. versionNumber.. "successfully loaded")
local welcomeMsg = "%s: Silent Shuffle version |cff00e5ff%s|r loaded successfully"
print(string.format(welcomeMsg, silentShuffleTitle, AddonVersion))
--To be Implemented
-- * When entering Solo Shuffle, the disable chat command should be executed
-- * When leaving Solo Shuffle, the enable chat command should be executed - Done
-- * Messages need to indicate successful execution of each state
-- * Option to turn off the addon functions in game with a toggle command/UI box
-- * Extra option: Disable Barrens chat :D


-- Create Event Handlers
local function arenaHandler(self, event, ...)
    print(silentShuffleTitle, "Initialized on Player")
    --self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
   -- self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        local _, instanceType = IsInInstance()
        print("player entered world")
        print("Current instance type:", instanceType)
        
        if instanceType == "none" then
            print("Player is NOT in arena and just entered the world")
            toggleChat()
        elseif instanceType == "arena" then
            print("Player is IN arena and just changed zone")
            toggleChat()
        end
    end 
end

local gameEvents = CreateFrame("Frame")
gameEvents:RegisterEvent("PLAYER_LOGIN")
gameEvents:SetScript("OnEvent", arenaHandler)



local silentShufflePanel = ...

-- Create Addon Panel
silentShufflePanel = {}

silentShufflePanel.panel = CreateFrame("Frame", "SilentShufflePanel", UIParent);
silentShufflePanel.panel.name = "SilentShuffle";
InterfaceOptions_AddCategory(silentShufflePanel.panel);

-- Toggle the chat based on status if the player is in Solo Shuffle
function toggleChat()
    if IsRatedSoloShuffle() then
        setChatDisabled(true)
        print(silentShuffleTitle..": In Shuffle - Chat Disabled")
    else
        setChatDisabled(false)
        print(silentShuffleTitle..": Not in Shuffle - Chat Enabled")
       -- print("Chat enabled - not in Solo Shuffle -- ".. isInShuffle())
    end
end