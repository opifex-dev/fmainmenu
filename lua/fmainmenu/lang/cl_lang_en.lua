local FMainMenu = FMainMenu

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

FMainMenu.LangPresets[prefix] = {} -- ignore this line
local translationList = FMainMenu.LangPresets[prefix] -- ignore this line

translationList.WelcomerFrameTitle = "Welcome To The Server"
translationList.DisconnectFrameTitle = "Confirm Disconnect"
translationList.DisconnectConfirmText = "Are you sure you would like to disconnect?"
translationList.DisconnectConfirmYesText = "Yes"
translationList.DisconnectConfirmNoText = "No"
translationList.LogNoCamPos = "A camera position does not exist for this map! Someone with access to the config must set the camera position!"
translationList.LogNoCamAng = "A camera angle does not exist for this map! Someone with access to the config must set the camera orientation!"
translationList.LogNoAdvSpawnPos = "An advanced spawn position does not exist for this map! Someone with access to the config must set the intended position!"
translationList.PlayButtonText = "Play"
translationList.DisconnectButtonText = "Disconnect"
translationList.LogHelperHeader = "The following lines will print a formatted version of your position and angles. You may copy and paste them into your config as needed."
translationList.LogPosHead = "Position: "
translationList.LogAngHead = "Angles: "
translationList.TTTRoundStarted = "The TTT round has started, so you have been kicked out of the main menu."
translationList.MurderRoundStarted = "The Murder round has started, so you have been kicked out of the main menu."
translationList.ZSRoundStarted = "The Zombie Survival round has started, so you have been kicked out of the main menu."
translationList.PropHuntRoundStarted = "The Zombie Survival round has started, so you have been kicked out of the main menu."
translationList.LogMurderEverySpawn = "EverySpawn is not supported in Murder, so it has been disabled."
translationList.LogZSEverySpawn = "EverySpawn is not supported in Zombie Survival, so it has been disabled."
translationList.LogPropHuntEverySpawn = "EverySpawn is not supported in Prop Hunt, so it has been disabled."

translationList.ConfigCommonValueDisabled = "Disabled"
translationList.ConfigCommonValueEnabled = "Enabled"
translationList.ConfigCommonValueYes = "Yes"
translationList.ConfigCommonValueNo = "No"
translationList.ConfigCommonValueX = "X: "
translationList.ConfigCommonValueY = "Y: "
translationList.ConfigCommonValueZ = "Z: "
translationList.ConfigCommonValueAllowed = "Allowed"
translationList.ConfigCommonValueDenied = "Denied"
translationList.ConfigCommonValueClose = "Close"
translationList.ConfigCommonValueCancel = "Cancel"

translationList.ConfigLeaveMenu = "Please exit the main menu before opening the coonfiguration tool."
translationList.ConfigUnsavedChanges = "The current property is changed but unsaved,\n        would you like to discard changes?"
translationList.ConfigUnsavedChangesHeader = "Unsaved Changes!"
translationList.ConfigPropertiesWindowTitle = "FMainMenu - Property Editor"
translationList.ConfigPropertiesNoneSelected = "No Property Selected"
translationList.ConfigPropertiesSelectorTitle = "FMainMenu - Property Selector"
translationList.ConfigPropertiesSavePropButton = "Save Property"
translationList.ConfigPropertiesRevertPropButton = "Revert Changes"
translationList.ConfigPropertiesCategoriesCamera = "Camera"
translationList.ConfigPropertiesCategoriesMenu = "Menu"
translationList.ConfigPropertiesCategoriesHooks = "Hook Functionality"
translationList.ConfigPropertiesCategoriesDerma = "Derma Style"
translationList.ConfigPropertiesCategoriesAccess = "Config Access"
translationList.ConfigPropertiesCategoriesAdvanced = "Advanced"
translationList.ConfigTopBarHeaderText = "FMainMenu Config Editor"
translationList.ConfigTopBarExitText = "Exit"

translationList.ConfigSoundSelectorWindowTitle = "Sound Selector"
translationList.ConfigSoundSelectorChooseButtonText = "Confirm"
translationList.ConfigSoundSelectorPlayButtonText = "Play"
translationList.ConfigSoundSelectorStopButtonText = "Stop"
translationList.ConfigSoundSelectorWindowSelectionHeader = "Currently Selected: "
translationList.ConfigSoundSelectorVolumeLabel = "Volume:"

translationList.ConfigPropertiesCameraSetupPropName = "Camera Setup"
translationList.ConfigPropertiesCameraSetupPropDesc = "Allows you to set where the camera\nwill exist in the world"
translationList.ConfigPropertiesCameraSetupPosLabel = "Position (Current Map): "
translationList.ConfigPropertiesCameraSetupAngLabel = "Orientation (Current Map): "
translationList.ConfigPropertiesCameraSetupCaptureLabel = "Capture Current Location"

translationList.ConfigPropertiesEverySpawnPropName = "Menu Frequency"
translationList.ConfigPropertiesEverySpawnPropDesc = "Whether the menu should appear on\nevery spawn or only once"
translationList.ConfigPropertiesEverySpawnLabel = "Menu Frequency: "
translationList.ConfigPropertiesEverySpawnOptionOne = "Every Spawn"
translationList.ConfigPropertiesEverySpawnOptionTwo = "First Spawn"

translationList.ConfigPropertiesHearOtherPlayersPropName = "Hear Other Players"
translationList.ConfigPropertiesHearOtherPlayersPropDesc = "Whether the player should hear\nother players talking from the menu"
translationList.ConfigPropertiesHearOtherPlayersLabel = "Hear Other Players: "
translationList.ConfigPropertiesHearOtherPlayersDistanceLabel = "Max Distance: "

translationList.ConfigPropertiesLanguagePropName = "Language"
translationList.ConfigPropertiesLanguagePropDesc = "Choose what language static GUIs use.\nOnly applies to newly opened GUIs."
translationList.ConfigPropertiesLanguageLabel = "Language: "

translationList.ConfigPropertiesGMODStylePropName = "Title/Logo Positioning"
translationList.ConfigPropertiesGMODStylePropDesc = "Whether the menu title/logo should\nappear in the center-left or top-left."
translationList.ConfigPropertiesGMODStyleLabel = "Menu Position: "
translationList.ConfigPropertiesGMODStyleSelectOne = "Top-Left"
translationList.ConfigPropertiesGMODStyleSelectTwo = "Center-Left"

translationList.ConfigPropertiesLogoPropName = "Title/Logo Content"
translationList.ConfigPropertiesLogoPropDesc = "Whether the menu title should be an\nimage or text."
translationList.ConfigPropertiesLogoLabel = "Logo Type: "
translationList.ConfigPropertiesLogoSelectOne = "Text"
translationList.ConfigPropertiesLogoSelectTwo = "Image"
translationList.ConfigPropertiesLogoContentLabel = "Text / Image Link: "

translationList.ConfigPropertiesBackgroundPropName = "Background Effects"
translationList.ConfigPropertiesBackgroundPropDesc = "Alter the blur and tint of the camera\nview. WARNING: EXPENSIVE!"
translationList.ConfigPropertiesBackgroundBlurLabel = "Blur Amount: "
translationList.ConfigPropertiesBackgroundTintLabel = "Tint Color: "

translationList.ConfigPropertiesChangelogPropName = "Changelog"
translationList.ConfigPropertiesChangelogPropDesc = "Edit various setting about the\nchangelog panel."
translationList.ConfigPropertiesChangelogToggleLabel = "Changelog:"
translationList.ConfigPropertiesChangelogSelectOne = "Enabled"
translationList.ConfigPropertiesChangelogSelectTwo = "Disabled"
translationList.ConfigPropertiesChangelogMarginLabel = "Changelog Position:"
translationList.ConfigPropertiesMarginSelectOne = "Top-Right"
translationList.ConfigPropertiesMarginSelectTwo = "Bottom-Right"
translationList.ConfigPropertiesChangelogTextLabel = "Changelog Text:"

translationList.ConfigPropertiesMusicPropName = "Background Music"
translationList.ConfigPropertiesMusicPropDesc = "Allows music to play to those in the\nmain menu."
translationList.ConfigPropertiesMusicTypeLabel = "Music Type: "
translationList.ConfigPropertiesMusicTypeOptionOneLabel = "File"
translationList.ConfigPropertiesMusicTypeOptionTwoLabel = "URL"
translationList.ConfigPropertiesMusicLoopLabel = "Looping: "
translationList.ConfigPropertiesMusicVolumeLabel = "Volume (0-1): "
translationList.ConfigPropertiesMusicFadeLabel = "Fade Time (seconds): "
translationList.ConfigPropertiesMusicSelectLabel = "Audio: "
translationList.ConfigPropertiesMusicButtonLabel = "Select Audio File"

translationList.ConfigPropertiesFJWelcomerPropName = "Welcome Screen"
translationList.ConfigPropertiesFJWelcomerPropDesc = "Allows players to receive information\non their first join."
translationList.ConfigPropertiesWelcomerTextLabel = "Welcome Text:"
translationList.ConfigPropertiesWelcomerTypeLabel = "Welcome Screen: "
translationList.ConfigPropertiesWelcomerURLTextLabel = "Button Text: "
translationList.ConfigPropertiesWelcomerURLLabel = "Website URL: "
translationList.ConfigPropertiesWelcomerURLButtonToggleLabel = "Button Opens URL:"

translationList.ConfigPropertiesDisconnectPropName = "Disconnect Button"
translationList.ConfigPropertiesDisconnectPropDesc = "Allows players to easily disconnect\nfrom the main menu."
translationList.ConfigPropertiesDisconnectToggleLabel = "Diconnect Button:"

translationList.ConfigPropertiesURLButtonsPropName = "URL Buttons"
translationList.ConfigPropertiesURLButtonsPropDesc = "Allows players to easily access\nimportant links from the menu."
translationList.ConfigPropertiesURLButtonsEditorButtonLabel = "Edit URL Buttons"
translationList.ConfigURLButtonEditorWindowTitle = "URL Button Editor"
translationList.ConfigURLButtonEditorCloseButtonText = "Close"
translationList.ConfigURLButtonEditorRevertButtonText = "Revert"
translationList.ConfigURLButtonEditorAddButtonText = "Add Button"
translationList.ConfigURLButtonEditorWindowButtonLabel = "Button Label: "
translationList.ConfigURLButtonEditorWindowLinkLabel = "Button Link: "
translationList.ConfigURLButtonEditorWindowDeleteConfirm = "Are you sure you would like to delete this button?"
translationList.ConfigURLButtonEditorWindowRevertConfirm = "Are you sure you would like to revert back to server settings?"

translationList.ConfigPropertiesSandboxHooksPropName = "Sandbox Hooks"
translationList.ConfigPropertiesSandboxHooksPropDesc = "Control what the player can do\nwhile in the main menu."
translationList.ConfigPropertiesSandboxHooksPlayerSpawnEffect = "Spawning Effects: "
translationList.ConfigPropertiesSandboxHooksPlayerSpawnNPC = "Spawning NPCs: "
translationList.ConfigPropertiesSandboxHooksPlayerSpawnProp = "Spawning Props: "
translationList.ConfigPropertiesSandboxHooksPlayerSpawnRagdoll = "Spawning Ragdolls: "
translationList.ConfigPropertiesSandboxHooksPlayerSpawnSENT = "Spawning SENTs: "
translationList.ConfigPropertiesSandboxHooksPlayerSpawnSWEP = "Spawning SWEPs: "
translationList.ConfigPropertiesSandboxHooksPlayerSpawnVehicle = "Spawning Vehicles: "
translationList.ConfigPropertiesSandboxHooksPlayerGiveSWEP = "Giving SWEPs To Self: "

translationList.ConfigPropertiesDarkRPHooksPropName = "DarkRP Hooks"
translationList.ConfigPropertiesDarkRPHooksPropDesc = "Control what the player can do\nwhile in the main menu."
translationList.ConfigPropertiesDarkRPHooksCanBuy = "Buying Items: "
translationList.ConfigPropertiesDarkRPHooksCanChatSound = "Chat Sounds: "
translationList.ConfigPropertiesDarkRPHooksCanUse = "Using Entities: "
translationList.ConfigPropertiesDarkRPHooksCanUsePocket = "Using Pocket: "
translationList.ConfigPropertiesDarkRPHooksCanDropWeapon = "Dropping Weapons: "
translationList.ConfigPropertiesDarkRPHooksCanReqHits = "Requesting Hits: "
translationList.ConfigPropertiesDarkRPHooksCanReqWarrants = "Requesting Warrants: "

translationList.ConfigPropertiesDermaFont = "Font: "
translationList.ConfigPropertiesDermaFontSize = "Font Size: "
translationList.ConfigPropertiesDermaOutlineThickness = "Outline Thickness: "
translationList.ConfigPropertiesDermaFontShadow = "Text Shadow: "
translationList.ConfigPropertiesDermaTextColor = "Text Color: "
translationList.ConfigPropertiesDermaOutlineColor = "Outline Color: "

translationList.ConfigPropertiesLogoDermaPropName = "Logo Style"
translationList.ConfigPropertiesLogoDermaPropDesc = "Control how various aspects of\nthe logo are styled."

translationList.ConfigPropertiesTextButtonDermaPropName = "Text Button Style"
translationList.ConfigPropertiesTextButtonDermaPropDesc = "Control how various aspects of\nthe buttons are styled."
translationList.ConfigPropertiesTextButtonDermaHoverColor = "Text Color When Hovered:"
translationList.ConfigPropertiesTextButtonDermaHoverSound = "Sound When Hovered:"
translationList.ConfigPropertiesTextButtonDermaClickSound = "Sound When Clicked:"

translationList.ConfigPropertiesFrameDermaPropName = "Derma Frame Style"
translationList.ConfigPropertiesFrameDermaPropDesc = "Control how various aspects of\nthe derma frames are styled."
translationList.ConfigPropertiesFrameDermaFrameColor = "Frame Color: "
translationList.ConfigPropertiesFrameDermaFrameBevel = "Frame Bevel: "

translationList.ConfigPropertiesPanelDermaPropName = "Derma Panel Style"
translationList.ConfigPropertiesPanelDermaPropDesc = "Control how various aspects of\nthe derma panels are styled."
translationList.ConfigPropertiesPanelDermaPanelColor = "Panel Color: "

translationList.ConfigPropertiesButtonDermaPropName = "Derma Button Style"
translationList.ConfigPropertiesButtonDermaPropDesc = "Control how various aspects of\nthe derma buttons are styled."
translationList.ConfigPropertiesButtonDermaButtonColor = "Button Color: "

translationList.ConfigPropertiesTextDermaPropName = "Derma Text Style"
translationList.ConfigPropertiesTextDermaPropDesc = "Control how various aspects of\nthe derma labels are styled."
translationList.ConfigPropertiesTextDermaTextColor = "Text Color: "

translationList.ConfigPropertiesScrollPanelDermaPropName = "Derma Scroll Panel Style"
translationList.ConfigPropertiesScrollPanelDermaPropDesc = "Control how various aspects of\nthe derma scroll panels are styled."
translationList.ConfigPropertiesScrollPanelDermaBarColor = "Scroll Bar Color: "
translationList.ConfigPropertiesScrollPanelDermaGripColor = "Scroll Grip Color: "
translationList.ConfigPropertiesScrollPanelDermaButtonColor = "Scroll Button Color: "

translationList.ConfigPropertiesConfigAccessPropName = "Config Access"
translationList.ConfigPropertiesConfigAccessPropDesc = "Control who can view and edit\nthe fmainmenu configuration."
translationList.ConfigPropertiesConfigAccessToggleLabel = "Config Access Group: "
translationList.ConfigPropertiesConfigAccessCAMILabel = "NOTE: This setting can have different\neffects depending on your admin mod."

translationList.ConfigPropertiesAdvancedGeneralInfoButtonLabel = "Get Information"

translationList.ConfigPropertiesAdvancedSpawnPropName = "Advanced Spawn"
translationList.ConfigPropertiesAdvancedSpawnPropDesc = "Whether the advanced spawn system\nshould be used"
translationList.ConfigPropertiesAdvancedSpawnOptLabel = "Advanced Spawn: "
translationList.ConfigPropertiesAdvancedSpawnPosLabel = "Position (Current Map): "
translationList.ConfigPropertiesAdvancedSpawnCaptureLabel = "Capture Current Location"
translationList.ConfigPropertiesAdvancedSpawnInfoLabel = "For more information on advanced\nspawn, click the button below"
translationList.ConfigPropertiesAdvancedSpawnInfo = "In Garry's Mod, soundscapes in a map can only be triggered when the player is physically in that part of the map. Advanced Spawn works by physically moving the player to the specified location.\n\nWARNING: This will result in the player no longer physically existing in the world until they press the play button. Please take this into consideration when deciding whether to enable this feature or not. This WILL break some aspects of certain gamemodes."
translationList.ConfigPropertiesAdvancedSpawnInfoWindowTitle = "Advanced Spawn Information"

translationList.ConfigPropertiesConfigFirstJoinSeedPropName = "First Join Seed"
translationList.ConfigPropertiesConfigFirstJoinSeedPropDesc = "Control how the first join seed\ndetects who has viewed it."
translationList.ConfigPropertiesConfigFirstJoinSeedBoxLabel = "First Join Seed: "
translationList.ConfigPropertiesFirstJoinSeedInfoLabel = "For more information on the first\njoin seed, click the button below"
translationList.ConfigPropertiesFirstJoinSeedInfo = "To detect when a player has gone through the \"Welcome Screen\" dialog, a file is created with a name based on the IP of the server. This allows multiple servers to have this addon without conflicts.\nIn cases when an IP might not be available, such as in peer-to-peer servers, the \"First Join Seed\" property should be set to something unique so as to not conflict with other servers.\n\nHaving the property be blank will cause the addon to use normal IP-based naming procedures."
translationList.ConfigPropertiesFirstJoinSeedInfoWindowTitle = "First Join Seed Information"

translationList.ConfigPropertiesMenuOverridePropName = "Custom Layout"
translationList.ConfigPropertiesMenuOverridePropDesc = "Control how the menu buttons are\nlaid out."
translationList.ConfigPropertiesMenuOverrideOptLabel = "Custom Layout: "
translationList.ConfigPropertiesMenuSetupEditorButtonLabel = "Edit Layout"
translationList.ConfigPropertiesMenuOverrideInfoLabel = "For more information on custom\nlayouts, click the button below"
translationList.ConfigPropertiesMenuOverrideInfo = "Custom layouts allow servers to have more control over the placement of buttons under the logo.\n\nWhen enabled, the \"Disconnect Button\" and \"URL Buttons\" properties will be ignored."
translationList.ConfigPropertiesMenuOverrideInfoWindowTitle = "Custom Layout Information"
translationList.ConfigMenuSetupEditorWindowTitle = "Menu Layout Editor"
translationList.ConfigMenuSetupEditorTypePlay = "Play Button"
translationList.ConfigMenuSetupEditorTypeSpacer = "Spacer"
translationList.ConfigMenuSetupEditorTypeURL = "URL Button"
translationList.ConfigMenuSetupEditorTypeDisconnect = "Disconnect Button"
translationList.ConfigMenuSetupEditorWindowChooseTypeLabel = "Choose Button Type"

-- IGNORE BELOW CODE
FMainMenu.languageLookup[prefix] = fancyName
FMainMenu.languageReverseLookup[fancyName] = prefix