--[[
!!!WARNING!!!

Addon configuration is handled in-game
By default, any superadmin can edit the configuration by executing fmainmenu_config in the console or !fmconfig in the chat
Do not edit anything below

If you want to read through the file anyways to see what's going on, then have fun.

!!!WARNING!!!
]]--

local addonName = "fmainmenu" --easy reference instead of copy-pasting over and over



-- STEP 1 - configuration value definitions and defaults
-- Camera Settings
FayLib.IGC.DefineKey(addonName, "CameraPosition", {
	["gm_flatgrass"] = Vector(-1286.149658, 1187.535156, -11371.772461),
	["gm_construct"] = Vector(-3209.8747558594, 2191.6071777344, 560.40161132813),
	["rp_downtown_v4c_v2"] = Vector(-1405.6032714844, 884.40338134766, -40.81294631958),
}, false)
FayLib.IGC.DefineKey(addonName, "CameraAngle", {
	["gm_flatgrass"] = Angle(42.586422, -40.820980, 0.000000),
	["gm_construct"] = Angle(16.977416992188, -34.643817901611, 0),
	["rp_downtown_v4c_v2"] = Angle(27.0013256073, -54.60368347168, 0),
}, false)
FayLib.IGC.DefineKey(addonName, "EverySpawn", true, true)
FayLib.IGC.DefineKey(addonName, "AdvancedSpawn", false, false)
FayLib.IGC.DefineKey(addonName, "AdvancedSpawnPos", {
	["gm_flatgrass"] = Vector(-172.215729, -24.837690, -12064.818359),
	["gm_construct"] = Vector(-3558.0554199219, 2432.1877441406, 689.60815429688),
	["rp_downtown_v4c_v2"] = Vector(-1405.6032714844, 884.40338134766, -40.81294631958),
}, false)
FayLib.IGC.DefineKey(addonName, "HearOtherPlayers", true, false)
FayLib.IGC.DefineKey(addonName, "PlayerVoiceDistance", 360000, false)

-- Main Menu Screen Layout Settings
FayLib.IGC.DefineKey(addonName, "LangSetting", "en", true)
FayLib.IGC.DefineKey(addonName, "GarrysModStyle", false, true)
FayLib.IGC.DefineKey(addonName, "logoIsText", true, true)
FayLib.IGC.DefineKey(addonName, "logoContent", "My Amazing Server", true)
FayLib.IGC.DefineKey(addonName, "BackgroundColorTint", Color(0,0,55,0), true)
FayLib.IGC.DefineKey(addonName, "BackgroundBlurAmount", 1, true)
FayLib.IGC.DefineKey(addonName, "showChangeLog", true, true)
FayLib.IGC.DefineKey(addonName, "changeLogMoveToBottom", false, true)
FayLib.IGC.DefineKey(addonName, "changeLogText", [[
Example Update

- Added new playermodels

PLANNED FOR UPDATE 2:
- New Map!
- More Cars
]], true)
FayLib.IGC.DefineKey(addonName, "musicToggle", 0, true)
FayLib.IGC.DefineKey(addonName, "musicLooping", true, true)
FayLib.IGC.DefineKey(addonName, "musicVolume", 0.1, true)
FayLib.IGC.DefineKey(addonName, "musicFade", 3, true)
FayLib.IGC.DefineKey(addonName, "musicContent", "https://www.dropbox.com/s/nc0qbdn8xp5wmrx/Quantum.mp3?dl=1", true)
FayLib.IGC.DefineKey(addonName, "firstJoinWelcome", false, true)
FayLib.IGC.DefineKey(addonName, "firstJoinText", "Welcome to the server! Please read the rules before playing.", true)
FayLib.IGC.DefineKey(addonName, "firstJoinURLText", "View Rules", true)
FayLib.IGC.DefineKey(addonName, "firstJoinURL", "https://youtu.be/oHg5SJYRHA0", true)
FayLib.IGC.DefineKey(addonName, "dcButton", true, true)
FayLib.IGC.DefineKey(addonName, "URLButtons", {
	{
		Text = "Content Pack",
		URL = "Workshop Link Here",
	},
	{
		Text = "Discord",
		URL = "Discord Link Here",
	},
}, true)

-- Sandbox Hook Settings
FayLib.IGC.DefineKey(addonName, "SandboxCanSpawnAnything", false, false)

-- DarkRP Hook Settings
FayLib.IGC.DefineKey(addonName, "DarkRPCanBuy", false, false)
FayLib.IGC.DefineKey(addonName, "DarkRPCanChatSound", false, false)
FayLib.IGC.DefineKey(addonName, "DarkRPCanUse", false, false)
FayLib.IGC.DefineKey(addonName, "DarkRPCanUsePocket", false, false)
FayLib.IGC.DefineKey(addonName, "DarkRPCanDropWeapon", false, false)
FayLib.IGC.DefineKey(addonName, "DarkRPCanReqHits", false, false)
FayLib.IGC.DefineKey(addonName, "DarkRPCanReqWarrants", false, false)

-- Derma Style Settings
FayLib.IGC.DefineKey(addonName, "textLogoColor", Color(255,255,255), true)
FayLib.IGC.DefineKey(addonName, "logoFont", "Arial", true)
FayLib.IGC.DefineKey(addonName, "logoFontSize", 108, true)
FayLib.IGC.DefineKey(addonName, "logoOutlineColor", Color(0,0,0), true)
FayLib.IGC.DefineKey(addonName, "logoOutlineThickness", 1, true)
FayLib.IGC.DefineKey(addonName, "logoShadow", false, true)
FayLib.IGC.DefineKey(addonName, "textButtonColor", Color(255,255,255), true)
FayLib.IGC.DefineKey(addonName, "textButtonOutlineColor", Color(0,0,0), true)
FayLib.IGC.DefineKey(addonName, "textButtonOutlineThickness", 0, true)
FayLib.IGC.DefineKey(addonName, "textButtonShadow", true, true)
FayLib.IGC.DefineKey(addonName, "textButtonFont", "Trebuchet24", true)
FayLib.IGC.DefineKey(addonName, "textButtonFontSize", 36, true)
FayLib.IGC.DefineKey(addonName, "textButtonHoverColor", Color(245,245,165), true)
FayLib.IGC.DefineKey(addonName, "textButtonHoverSound", "garrysmod/ui_hover.wav", true)
FayLib.IGC.DefineKey(addonName, "textButtonClickSound", "garrysmod/ui_click.wav", true)
FayLib.IGC.DefineKey(addonName, "commonPanelColor", Color(45,45,45,200), true)
FayLib.IGC.DefineKey(addonName, "commonButtonColor", Color(75,75,75, 255), true)
FayLib.IGC.DefineKey(addonName, "commonTextColor", Color(255,255,255,255), true)

--Configuration GUI Settings
FayLib.IGC.DefineKey(addonName, "configCanEdit", "superadmin", false)

-- Advanced Settings
FayLib.IGC.DefineKey(addonName, "firstJoinSeed", "", true)
FayLib.IGC.DefineKey(addonName, "MenuOverride", false, true)
FayLib.IGC.DefineKey(addonName, "MenuSetup", {
	{
		Type = "Play",
		Content = {
			Text = "Play",
		},
	},
	{
		Type = "Spacer",
		Content = {
		},
	},
	{
		Type = "URL",
		Content = {
			Text = "Discord",
			URL = "https://discord.gg/87rBPFa",
		},
	},
	{
		Type = "URL",
		Content = {
			Text = "Content Pack",
			URL = "https://steamcommunity.com/id/okfay",
		},
	},
	{
		Type = "Spacer",
		Content = {
		},
	},
	{
		Type = "Disconnect",
		Content = {
			Text = "Disconnect",
		},
	},
}, true)



-- STEP 2 - load existing configuration or save new default configuration
FayLib.IGC.LoadConfig(addonName, "config", "fmainmenu")
FMainMenu.EverySpawn = FayLib.IGC.GetKey(addonName, "EverySpawn")

-- Setup CAMI Privs
CAMI.RegisterPrivilege( { Name = "FMainMenu_CanEditMenu",    MinAccess = FayLib.IGC.GetKey(addonName, "configCanEdit") or "superadmin" } )

--Language Loader
FMainMenu.languageLookup = {}
FMainMenu.languageReverseLookup = {}
local files = file.Find("fmainmenu/lang/*.lua", "LUA")
for _, f in pairs(files) do
	include("fmainmenu/lang/"..f)
	AddCSLuaFile("fmainmenu/lang/"..f)
end

if FMainMenu.LangPresets[string.lower(FayLib.IGC.GetKey(addonName, "LangSetting"))] != nil then
	FMainMenu.Lang = FMainMenu.LangPresets[string.lower(FayLib.IGC.GetKey(addonName, "LangSetting"))]
else -- assume English if no valid code given, also reset language var
	FMainMenu.Lang = FMainMenu.LangPresets["en"]
	FayLib.IGC.SetKey(addonName, "LangSetting", "en")
	FayLib.IGC.SaveConfig(addonName, "config", "fmainmenu")
	FayLib.IGC.SyncShared(addonName)
	FMainMenu.Log("Your language configuration was invalid, so it was reset to English", true)
end



-- STEP 3 - deal with anything else relating to editing, saving, and refreshing the config
FMainMenu.RefreshDetect = true
hook.Add("IGCConfigUpdate", "FMainMenu_IGCCU", function(addonName)
	FMainMenu.EverySpawn = FayLib.IGC.GetKey(addonName, "EverySpawn")
	
	-- Language update
	if FMainMenu.LangPresets[string.lower(FayLib.IGC.GetKey(addonName, "LangSetting"))] != nil then
		FMainMenu.Lang = FMainMenu.LangPresets[string.lower(FayLib.IGC.GetKey(addonName, "LangSetting"))]
	else -- assume English if no valid code given, also reset language var
		FMainMenu.Lang = FMainMenu.LangPresets["en"]
		FayLib.IGC.SetKey(addonName, "LangSetting", "en")
		FayLib.IGC.SaveConfig(addonName, "config", "fmainmenu")
		FayLib.IGC.SyncShared(addonName)
		FMainMenu.Log("Your language configuration was invalid, so it was reset to English", true)
	end
	
	FMainMenu.RefreshDetect = true
end)



--[[
-- this will have to be dealt with in the config GUI at config update time

--Dropbox Link Patch
if string.find(FMainMenu.Config.musicContent, "dropbox") != nil then
	FMainMenu.Config.musicContent = string.Replace(FMainMenu.Config.musicContent, "?dl=0", "?dl=1")
end
]]--