--[[
!!!WARNING!!!

Addon configuration is handled in-game
By default, any superadmin can edit the configuration by executing fmainmenu_config in the console or !fmconfig in the chat
Do not edit anything below

If you want to read through the file anyways to see what's going on, then have fun.

!!!WARNING!!!
]]--

local addonName = "fmainmenu" --easy reference instead of copy-pasting over and over

FMainMenu.EverySpawn = false
FMainMenu.firstJoinSeed = ""

FMainMenu.languageLookup = {}
FMainMenu.languageReverseLookup = {}
local files = file.Find("fmainmenu/lang/*.lua", "LUA")
for _, f in pairs(files) do
	include("fmainmenu/lang/"..f)
end

hook.Add("IGCSharedConfigReady", "FMainMenu_IGSCR", function()
	FMainMenu.EverySpawn = FayLib.IGC.GetSharedKey(addonName, "EverySpawn")
	FMainMenu.firstJoinSeed = FayLib.IGC.GetSharedKey(addonName, "firstJoinSeed")
	
	if FMainMenu.LangPresets[string.lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))] != nil then
		FMainMenu.Lang = FMainMenu.LangPresets[string.lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))]
	else -- assume English if no valid code given
		FMainMenu.Lang = FMainMenu.LangPresets["en"]
	end
	
	hook.Run("FMainMenu_OpenMenuInitial")
end)

FMainMenu.RefreshDetect = true
hook.Add("IGCConfigUpdate", "FMainMenu_IGCCU", function(addonName)
	if FayLib.IGC.IsSharedReady() then
		FMainMenu.EverySpawn = FayLib.IGC.GetSharedKey(addonName, "EverySpawn")
		FMainMenu.firstJoinSeed = FayLib.IGC.GetSharedKey(addonName, "firstJoinSeed")
		
		if FMainMenu.LangPresets[string.lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))] != nil then
			FMainMenu.Lang = FMainMenu.LangPresets[string.lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))]
		else -- assume English if no valid code given
			FMainMenu.Lang = FMainMenu.LangPresets["en"]
		end
	end
	
	FMainMenu.RefreshDetect = true
end)