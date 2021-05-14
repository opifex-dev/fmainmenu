FMainMenu.Lang = FMainMenu.Lang || {}
FMainMenu.LangPresets = FMainMenu.LangPresets || {}
-- IGNORE ABOVE CODE

--[[
STEPS TO CREATE LANGUAGE:
1. Edit these two values to fit your language. (prefix can just be a short code for the language, while fancyName is the full language name that will appear to users) 
2. Edit the many strings below to fit your language 
3, Drop the file into the language folder and restart the server 
4, The language will now be added as an option in the config editor under the "Language" property.
5. If you would like to contribute to the addon by having your translation be distributed along with the addon, send Fay a message on gmodstore or elsewhere.
]]--
local prefix = "en"
local fancyName = "English"

FMainMenu.LangPresets[prefix] = {} -- ignore this one line

FMainMenu.LangPresets[prefix].WelcomerFrameTitle = "First Join Welcomer"
FMainMenu.LangPresets[prefix].DisconnectFrameTitle = "Confirm Disconnect"
FMainMenu.LangPresets[prefix].DisconnectConfirmText = "Are you sure you would like to disconnect?"
FMainMenu.LangPresets[prefix].DisconnectConfirmYesText = "Yes"
FMainMenu.LangPresets[prefix].DisconnectConfirmNoText = "No"
FMainMenu.LangPresets[prefix].LogNoCamPos = "A camera position does not exist for this map!"
FMainMenu.LangPresets[prefix].LogNoCamAng = "A camera angle does not exist for this map!"
FMainMenu.LangPresets[prefix].LogNoAdvSpawnPos = "An advanced spawn position does not exist for this map!"
FMainMenu.LangPresets[prefix].PlayButtonText = "Play"
FMainMenu.LangPresets[prefix].DisconnectButtonText = "Disconnect"
FMainMenu.LangPresets[prefix].LogHelperHeader = "The following lines will print a formatted version of your position and angles. You may copy and paste them into your config as needed."
FMainMenu.LangPresets[prefix].LogPosHead = "Position: "
FMainMenu.LangPresets[prefix].LogAngHead = "Angles: "
FMainMenu.LangPresets[prefix].TTTRoundStarted = "The TTT round has started, so you have been kicked out of the main menu."
FMainMenu.LangPresets[prefix].MurderRoundStarted = "The Murder round has started, so you have been kicked out of the main menu."
FMainMenu.LangPresets[prefix].LogMurderEverySpawn = "EverySpawn is not supported in Murder, so it has been disabled."

FMainMenu.LangPresets[prefix].ConfigCommonValueDisabled = "Disabled"
FMainMenu.LangPresets[prefix].ConfigCommonValueEnabled = "Enabled"
FMainMenu.LangPresets[prefix].ConfigCommonValueYes = "Yes"
FMainMenu.LangPresets[prefix].ConfigCommonValueNo = "No"
FMainMenu.LangPresets[prefix].ConfigCommonValueX = "X: "
FMainMenu.LangPresets[prefix].ConfigCommonValueY = "Y: "
FMainMenu.LangPresets[prefix].ConfigCommonValueZ = "Z: "

FMainMenu.LangPresets[prefix].ConfigLeaveMenu = "Please exit the main menu before opening the coonfiguration tool."
FMainMenu.LangPresets[prefix].ConfigUnsavedChanges = "The current property is changed but unsaved,\n        would you like to discard changes?"
FMainMenu.LangPresets[prefix].ConfigUnsavedChangesHeader = "Unsaved Changes!"
FMainMenu.LangPresets[prefix].ConfigPropertiesWindowTitle = "FMainMenu - Config Properties"
FMainMenu.LangPresets[prefix].ConfigPropertiesNoneSelected = "No Property Selected"
FMainMenu.LangPresets[prefix].ConfigPropertiesSelectorTitle = "FMainMenu - Config Selector"
FMainMenu.LangPresets[prefix].ConfigPropertiesSavePropButton = "Save Property"
FMainMenu.LangPresets[prefix].ConfigPropertiesRevertPropButton = "Revert Changes"
FMainMenu.LangPresets[prefix].ConfigPropertiesCategoriesCamera = "Camera"
FMainMenu.LangPresets[prefix].ConfigPropertiesCategoriesMenu = "Menu"
FMainMenu.LangPresets[prefix].ConfigPropertiesCategoriesHooks = "Hook Functionality"
FMainMenu.LangPresets[prefix].ConfigPropertiesCategoriesDerma = "Derma Style"
FMainMenu.LangPresets[prefix].ConfigPropertiesCategoriesAccess = "Config Access"
FMainMenu.LangPresets[prefix].ConfigPropertiesCategoriesCamera = "Advanced"
FMainMenu.LangPresets[prefix].ConfigTopBarHeaderText = "FMainMenu Config Editor"
FMainMenu.LangPresets[prefix].ConfigTopBarExitText = "Exit"

FMainMenu.LangPresets[prefix].ConfigSoundSelectorWindowTitle = "Sound Selector"
FMainMenu.LangPresets[prefix].ConfigSoundSelectorChooseButtonText = "Confirm"
FMainMenu.LangPresets[prefix].ConfigSoundSelectorPlayButtonText = "Play"
FMainMenu.LangPresets[prefix].ConfigSoundSelectorStopButtonText = "Stop"
FMainMenu.LangPresets[prefix].ConfigSoundSelectorWindowSelectionHeader = "Currently Selected: "
FMainMenu.LangPresets[prefix].ConfigSoundSelectorVolumeLabel = "Volume:"

FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupPropName = "Camera Setup"
FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupPropDesc = "Allows you to set where the camera\nwill exist in the world"
FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupPosLabel = "Position (Current Map): "
FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupAngLabel = "Orientation (Current Map): "
FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupCaptureLabel = "Capture Current Location"

FMainMenu.LangPresets[prefix].ConfigPropertiesEverySpawnPropName = "Menu Frequency"
FMainMenu.LangPresets[prefix].ConfigPropertiesEverySpawnPropDesc = "Whether the menu should appear on\nevery spawn or only once"
FMainMenu.LangPresets[prefix].ConfigPropertiesEverySpawnLabel = "Menu Frequency: "
FMainMenu.LangPresets[prefix].ConfigPropertiesEverySpawnOptionOne = "Every Spawn"
FMainMenu.LangPresets[prefix].ConfigPropertiesEverySpawnOptionTwo = "First Spawn"

FMainMenu.LangPresets[prefix].ConfigPropertiesAdvancedSpawnPropName = "Advanced Spawn"
FMainMenu.LangPresets[prefix].ConfigPropertiesAdvancedSpawnPropDesc = "Whether the advanced spawn system\nshould be used"
FMainMenu.LangPresets[prefix].ConfigPropertiesAdvancedSpawnOptLabel = "Advanced Spawn: "
FMainMenu.LangPresets[prefix].ConfigPropertiesAdvancedSpawnPosLabel = "Position (Current Map): "
FMainMenu.LangPresets[prefix].ConfigPropertiesAdvancedSpawnCaptureLabel = "Capture Current Location"

FMainMenu.LangPresets[prefix].ConfigPropertiesHearOtherPlayersPropName = "Hear Other Players"
FMainMenu.LangPresets[prefix].ConfigPropertiesHearOtherPlayersPropDesc = "Whether the player should hear\nother players talking from the menu"
FMainMenu.LangPresets[prefix].ConfigPropertiesHearOtherPlayersLabel = "Hear Other Players: "
FMainMenu.LangPresets[prefix].ConfigPropertiesHearOtherPlayersDistanceLabel = "Max Distance: "

FMainMenu.LangPresets[prefix].ConfigPropertiesLanguagePropName = "Language"
FMainMenu.LangPresets[prefix].ConfigPropertiesLanguagePropDesc = "Choose what language static GUIs use.\nOnly applies to newly opened GUIs."
FMainMenu.LangPresets[prefix].ConfigPropertiesLanguageLabel = "Language: "

FMainMenu.LangPresets[prefix].ConfigPropertiesGMODStylePropName = "Title/Logo Positioning"
FMainMenu.LangPresets[prefix].ConfigPropertiesGMODStylePropDesc = "Whether the menu title/logo should\nappear in the center-left or top-left."
FMainMenu.LangPresets[prefix].ConfigPropertiesGMODStyleLabel = "Menu Position: "
FMainMenu.LangPresets[prefix].ConfigPropertiesGMODStyleSelectOne = "Top-Left"
FMainMenu.LangPresets[prefix].ConfigPropertiesGMODStyleSelectTwo = "Center-Left"

FMainMenu.LangPresets[prefix].ConfigPropertiesLogoPropName = "Title/Logo Content"
FMainMenu.LangPresets[prefix].ConfigPropertiesLogoPropDesc = "Whether the menu title should be an\nimage or text."
FMainMenu.LangPresets[prefix].ConfigPropertiesLogoLabel = "Logo Type: "
FMainMenu.LangPresets[prefix].ConfigPropertiesLogoSelectOne = "Text"
FMainMenu.LangPresets[prefix].ConfigPropertiesLogoSelectTwo = "Image"
FMainMenu.LangPresets[prefix].ConfigPropertiesLogoContentLabel = "Text / Image Link: "

FMainMenu.LangPresets[prefix].ConfigPropertiesBackgroundPropName = "Background Effects"
FMainMenu.LangPresets[prefix].ConfigPropertiesBackgroundPropDesc = "Alter the blur and tint of the camera\nview."
FMainMenu.LangPresets[prefix].ConfigPropertiesBackgroundBlurLabel = "Blur Amount: "
FMainMenu.LangPresets[prefix].ConfigPropertiesBackgroundTintLabel = "Tint Color: "

FMainMenu.LangPresets[prefix].ConfigPropertiesChangelogPropName = "Changelog"
FMainMenu.LangPresets[prefix].ConfigPropertiesChangelogPropDesc = "Edit various setting about the\nchangelog panel."
FMainMenu.LangPresets[prefix].ConfigPropertiesChangelogToggleLabel = "Changelog:"
FMainMenu.LangPresets[prefix].ConfigPropertiesChangelogSelectOne = "Enabled"
FMainMenu.LangPresets[prefix].ConfigPropertiesChangelogSelectTwo = "Disabled"
FMainMenu.LangPresets[prefix].ConfigPropertiesChangelogMarginLabel = "Changelog Position:"
FMainMenu.LangPresets[prefix].ConfigPropertiesMarginSelectOne = "Top-Right"
FMainMenu.LangPresets[prefix].ConfigPropertiesMarginSelectTwo = "Bottom-Right"
FMainMenu.LangPresets[prefix].ConfigPropertiesChangelogTextLabel = "Changelog Text:"

FMainMenu.LangPresets[prefix].ConfigPropertiesMusicPropName = "Background Music"
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicPropDesc = "Allows music to play to those in the\nmain menu."
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicTypeLabel = "Music Type: "
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicTypeOptionOneLabel = "File"
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicTypeOptionTwoLabel = "URL"
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicLoopLabel = "Looping: "
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicVolumeLabel = "Volume (0-1): "
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicFadeLabel = "Fade Time (seconds): "
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicSelectLabel = "Audio: "
FMainMenu.LangPresets[prefix].ConfigPropertiesMusicButtonLabel = "Select Audio File"

-- IGNORE BELOW CODE
FMainMenu.languageLookup[prefix] = fancyName
FMainMenu.languageReverseLookup[fancyName] = prefix