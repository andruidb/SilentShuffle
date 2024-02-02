-- Initialization
local addonName = "SilentShuffle"
local silentShuffleTitle = "|cff00ff88Silent Shuffle|r"
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local AddonVersion = GetAddOnMetadata(addonName, "Version")
local setChatDisabled = C_SocialRestrictions.SetChatDisabled
local IsRatedSoloShuffle = C_PvP.IsRatedSoloShuffle
local IsInInstance = IsInInstance

-- Print welcome message
local welcomeMsg = "%s: Silent Shuffle version |cff00e5ff%s|r loaded successfully"
print(string.format(welcomeMsg, silentShuffleTitle, AddonVersion))

-- Event handler function
local function EventHandler(self, event, ...)
    local _, instanceType = IsInInstance()
    print("eventHandler started")
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        print("eventHandler called")
        if instanceType == "none" then
            self:OnArenaLeave()
        elseif instanceType == "arena" then
            self:OnArenaJoin()
        end
    end 
end

-- Create event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", EventHandler)

-- Function to handle arena join
function eventFrame:OnArenaJoin()
    if IsRatedSoloShuffle() == false then
        return
    end
    setChatDisabled(true)
    print(silentShuffleTitle .. ": In Shuffle - Chat Disabled")
end

-- Function to handle arena leave
function eventFrame:OnArenaLeave()
    if IsRatedSoloShuffle() == true then
        return
    end
    setChatDisabled(false)
    print(silentShuffleTitle .. ": Not in Shuffle - Chat Enabled")
end

-- Create Addon Panel
local silentShufflePanel = CreateFrame("Frame", "SilentShufflePanel", UIParent)
silentShufflePanel.name = "SilentShuffle"
InterfaceOptions_AddCategory(silentShufflePanel)
