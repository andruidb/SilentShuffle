<<<<<<< HEAD
--Initial Version on 29 January 2024

-- Initialization
local versionNumber = "|cff00e5ff 1.0 |r"

print("Silent Shuffle version".. versionNumber.. "loaded!")

--To be Implemented
-- * When entering Solo Shuffle, the disable chat command should be executed
-- * When leaving Solo Shuffle, the enable chat command should be executed
-- * Messages need to indicate successful execution of each state
-- * Option to turn off the addon functions in game with a toggle command/UI box

-- Create Addon Panel

local silentShufflePanel = ...

silentShufflePanel = {}

silentShufflePanel.panel = CreateFrame("Frame", "SilentShufflePanel", UIParent);
silentShufflePanel.panel.name = "SilentShufflePanel";
InterfaceOptions_AddCategory(silentShufflePanel.panel);

=======
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
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        local _, instanceType = IsInInstance()
        
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
    if IsRatedSoloShuffle() == false then
        return
    end
    setChatDisabled(false)
    print(silentShuffleTitle .. ": Not in Shuffle - Chat Enabled")
end

-- Create Addon Panel
local silentShufflePanel = {}

silentShufflePanel.panel = CreateFrame("Frame", "SilentShufflePanel", UIParent)
silentShufflePanel.panel.name = "SilentShuffle"
InterfaceOptions_AddCategory(silentShufflePanel.panel)

-- Create title for the panel
local title = silentShufflePanel.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Silent Shuffle Options")

-- Create description for the panel
local desc = silentShufflePanel.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
desc:SetText("Configure Silent Shuffle options below:")

-- Create a checkbox to enable/disable the addon
local enableCheckbox = CreateFrame("CheckButton", "SilentShuffleEnableCheckbox", silentShufflePanel.panel, "InterfaceOptionsCheckButtonTemplate")
enableCheckbox:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
enableCheckbox.Text:SetText("Enable Silent Shuffle")

-- Set the callback for checkbox
enableCheckbox:SetScript("OnClick", function(self)
    if self:GetChecked() then
        print("Silent Shuffle enabled")
        -- Enable your addon logic here
    else
        print("Silent Shuffle disabled")
        -- Disable your addon logic here
    end
end)

-- Function to handle addon enable
function eventFrame:OnEnable()
    print(silentShuffleTitle .. ": Addon Enabled")
    -- Additional code to execute when addon is enabled
end

-- Function to handle addon disable
function eventFrame:OnDisable()
    print(silentShuffleTitle .. ": Addon Disabled")
    -- Additional code to execute when addon is disabled
end

-- Function to update checkbox state based on addon status
function eventFrame:UpdateCheckboxState()
    enableCheckbox:SetChecked(true) -- Modify this based on your addon's current status
end

-- Open addon options when addon panel is clicked
silentShufflePanel.panel:HookScript("OnShow", function(self)
    eventFrame:UpdateCheckboxState()
end)
>>>>>>> 61903d7 (Update pkgmeta.yaml for Azure Pipelines)

