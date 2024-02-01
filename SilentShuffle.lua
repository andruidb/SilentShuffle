--Initial Version on 29 January 2024

-- Initialization
local addonName = "SilentShuffle"
local silentShuffleTitle = "|cff00ff88Silent Shuffle|r"
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local AddonVersion = GetAddOnMetadata(addonName, "Version")
local setChatDisabled = C_SocialRestrictions.SetChatDisabled
local IsRatedSoloShuffle = C_PvP.IsRatedSoloShuffle

--print(silentShuffleTitle..": Silent Shuffle version".. versionNumber.. "successfully loaded")
local welcomeMsg = "%s: Silent Shuffle version |cff00e5ff%s|r successfully loaded"
print(string.format(welcomeMsg, silentShuffleTitle, AddonVersion))
--To be Implemented
-- * When entering Solo Shuffle, the disable chat command should be executed
-- * When leaving Solo Shuffle, the enable chat command should be executed - Done
-- * Messages need to indicate successful execution of each state
-- * Option to turn off the addon functions in game with a toggle command/UI box
-- * Extra option: Disable Barrens chat :D





local silentShufflePanel = ...

-- Create Addon Panel
silentShufflePanel = {}

silentShufflePanel.panel = CreateFrame("Frame", "SilentShufflePanel", UIParent);
silentShufflePanel.panel.name = "SilentShuffle";
InterfaceOptions_AddCategory(silentShufflePanel.panel);

-- Toggle the chat based on status if the player is in Solo Shuffle
local function toggleChat()
    if IsRatedSoloShuffle() then
        setChatDisabled(true)
        print(silentShuffleTitle..": In Shuffle - Chat Disabled")
    else
        setChatDisabled(false)
        print(silentShuffleTitle..": Not in Shuffle - Chat Enabled")
       -- print("Chat enabled - not in Solo Shuffle -- ".. isInShuffle())
    end
end

toggleChat()