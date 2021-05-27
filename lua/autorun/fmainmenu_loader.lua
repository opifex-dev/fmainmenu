FMainMenu = FMainMenu || {}

local print = print
local include = include
local AddCSLuaFile = AddCSLuaFile
local file_Find = file.Find
local pairs = pairs

--Basic Logger Function
function FMainMenu.Log(msg, warning)
	local newMSG = "[FMainMenu] "
	if warning then
		newMSG = newMSG .. "(WARN) "
	end
	print(newMSG .. msg)
end

--Basic localization system
function FMainMenu.GetPhrase(phraseName)
	if FMainMenu.Lang != nil && FMainMenu.LangPresets != nil && FMainMenu.LangPresets["en"] != nil then
		if FMainMenu.Lang[phraseName] != nil then
			return FMainMenu.Lang[phraseName]
		end

		-- Fallback to english if phrase not found in current language
		if FMainMenu.LangPresets["en"][phraseName] != nil then
			FMainMenu.Log("Failed to fetch language phrase \"" .. phraseName .. "\"! The language specified in your config does not contain the requested phrase. This could be due to multiple things, but is most likely the result of an incomplete translation.", true)
			return FMainMenu.LangPresets["en"][phraseName]
		end
	end

	FMainMenu.Log("Failed to fetch language! This should never happen, please contact Fay!", true)
	return "FMainMenu Language Error"
end

FMainMenu.Log("Begin Load", false)

--Load required lua files in proper order
if SERVER then
	include( "fmainmenu/config/sv_configsync.lua" )
	AddCSLuaFile( "fmainmenu/config/cl_configsync.lua" )
	AddCSLuaFile("vgui/cl_fmainmenu_config.lua")
	AddCSLuaFile( "vgui/cl_fmainmenu_mmenu.lua" )
	AddCSLuaFile( "fmainmenu/config/cl_configmenu.lua" )
	AddCSLuaFile("fmainmenu/cl_mainmenu_panels.lua")
	include( "fmainmenu/sv_mainmenu.lua" )
	AddCSLuaFile( "fmainmenu/cl_mainmenu.lua" )

	AddCSLuaFile( "fmainmenu/config/cl_confighelper.lua" )
	AddCSLuaFile( "fmainmenu/config/cl_configpanels.lua" )
	AddCSLuaFile( "fmainmenu/config/cl_configpreview.lua" )
	local files = file_Find("fmainmenu/config/modules/*.lua", "LUA")
	for _, f in pairs(files) do
		AddCSLuaFile("fmainmenu/config/modules/" .. f)
	end
else
	include( "fmainmenu/config/cl_configsync.lua" )
	include("vgui/cl_fmainmenu_config.lua")
	include("vgui/cl_fmainmenu_mmenu.lua")
	include("fmainmenu/cl_mainmenu_panels.lua")
	include( "fmainmenu/cl_mainmenu.lua" )
	include( "fmainmenu/config/cl_configmenu.lua" )
end

FMainMenu.Log("Load Complete", false)