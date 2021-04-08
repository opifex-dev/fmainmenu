FMainMenu.Lang = FMainMenu.Lang || {}
FMainMenu.LangPresets = FMainMenu.LangPresets || {}
-- IGNORE ABOVE CODE

local prefix = "en"
local fancyName = "English"

FMainMenu.LangPresets[prefix] = {}
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

FMainMenu.LangPresets[prefix].ConfigLeaveMenu = "Please exit the main menu before opening the coonfiguration tool."
FMainMenu.LangPresets[prefix].ConfigUnsavedChanges = "The current property is changed but unsaved,\n        would you like to discard changes?"
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

FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupPropName = "Camera Setup"
FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupPropDesc = "Allows you to set where the camera\nwill exist in the world"
FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupPosLabel = "Position (Current Map): "
FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupAngLabel = "Orientation (Current Map): "
FMainMenu.LangPresets[prefix].ConfigPropertiesCameraSetupCaptureLabel = "Capture Current Location"

FMainMenu.LangPresets[prefix].ConfigPropertiesEverySpawnPropName = "Every Spawn"
FMainMenu.LangPresets[prefix].ConfigPropertiesEverySpawnPropDesc = "Whether the menu should appear on\nevery spawn or only once"
FMainMenu.LangPresets[prefix].ConfigPropertiesEverySpawnLabel = "Every Spawn: "

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

-- IGNORE BELOW CODE
FMainMenu.languageLookup[prefix] = fancyName
FMainMenu.languageReverseLookup[fancyName] = prefix