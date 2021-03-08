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

hook.Add("IGCSharedConfigReady", "FMainMenu_IGSCR", function()
	FMainMenu.EverySpawn = FayLib.IGC.GetSharedKey(addonName, "EverySpawn")
	FMainMenu.firstJoinSeed = FayLib.IGC.GetSharedKey(addonName, "firstJoinSeed")
	
	if string.lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting")) == "en" then
		include( "fmainmenu/lang/cl_lang_"..string.lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))..".lua" )
	else -- assume English if no valid code given
		include( "fmainmenu/lang/cl_lang_en.lua" )
	end
	
	hook.Run("FMainMenu_OpenMenuInitial")
end)

FMainMenu.RefreshDetect = true
hook.Add("IGCConfigUpdate", "FMainMenu_IGCCU", function(addonName)
	if FayLib.IGC.IsSharedReady() then
		FMainMenu.EverySpawn = FayLib.IGC.GetSharedKey(addonName, "EverySpawn")
		FMainMenu.firstJoinSeed = FayLib.IGC.GetSharedKey(addonName, "firstJoinSeed")
		
		if string.lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting")) == "en" then
			include( "fmainmenu/lang/cl_lang_"..string.lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))..".lua" )
		else -- assume English if no valid code given
			include( "fmainmenu/lang/cl_lang_en.lua" )
		end
	end
	
	FMainMenu.RefreshDetect = true
end)