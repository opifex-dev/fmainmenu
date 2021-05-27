--[[
!!!WARNING!!!

Addon configuration is handled in-game
By default, any superadmin can edit the configuration by executing fmainmenu_config in the console or !fmconfig in the chat
Do not edit anything below

If you want to read through the file anyways to see what's going on, then have fun.

!!!WARNING!!!
]]--

local file_Find = file.Find
local pairs = pairs
local include = include
local hook_Add = hook.Add
local FayLib = FayLib
local string_lower = string.lower
local hook_Run = hook.Run

local addonName = "fmainmenu" --easy reference instead of copy-pasting over and over

FMainMenu.EverySpawn = false
FMainMenu.firstJoinSeed = ""

FMainMenu.languageLookup = {}
FMainMenu.languageReverseLookup = {}
local files = file_Find("fmainmenu/lang/*.lua", "LUA")
for _, f in pairs(files) do
	include("fmainmenu/lang/" .. f)
end

-- default lang preset
FMainMenu.Lang = FMainMenu.LangPresets["en"]

-- set initial values needed when shared config is synced for first time
hook_Add("IGCSharedConfigReady", "FMainMenu_IGSCR", function()
	-- every spawn and first join seed
	FMainMenu.EverySpawn = FayLib.IGC.GetSharedKey(addonName, "EverySpawn")
	FMainMenu.firstJoinSeed = FayLib.IGC.GetSharedKey(addonName, "firstJoinSeed")

	-- language
	if FMainMenu.LangPresets[string_lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))] != nil then
		FMainMenu.Lang = FMainMenu.LangPresets[string_lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))]
	end

	hook_Run("FMainMenu_OpenMenuInitial")
end)

FMainMenu.RefreshDetect = true

-- update needed values when config is updated
hook_Add("IGCConfigUpdate", "FMainMenu_IGCCU", function(addonName)
	if FayLib.IGC.IsSharedReady() then
		-- every spawn and first join seed
		FMainMenu.EverySpawn = FayLib.IGC.GetSharedKey(addonName, "EverySpawn")
		FMainMenu.firstJoinSeed = FayLib.IGC.GetSharedKey(addonName, "firstJoinSeed")

		-- language
		if FMainMenu.LangPresets[string_lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))] != nil then
			FMainMenu.Lang = FMainMenu.LangPresets[string_lower(FayLib.IGC.GetSharedKey(addonName, "LangSetting"))]
		else -- assume English if no valid code given
			FMainMenu.Lang = FMainMenu.LangPresets["en"]
		end
	end

	FMainMenu.RefreshDetect = true
end)