FMainMenu = FMainMenu || {}

--Basic Logger Function
function FMainMenu.Log(msg, warning)
	local newMSG = "[FMainMenu] "
	if warning then
		newMSG = newMSG.."(WARN) "
	end
	print(newMSG..msg)
end

FMainMenu.Log("Begin Load", false)

--Load required lua files in proper order
if SERVER then
	include( "fmainmenu/sv_configsync.lua" ) 
	AddCSLuaFile( "fmainmenu/cl_configsync.lua" ) 
	AddCSLuaFile("vgui/cl_fmainmenu_config.lua")
	AddCSLuaFile( "vgui/cl_fmainmenu_mmenu.lua" ) 
	AddCSLuaFile( "fmainmenu/cl_configmenu.lua" ) 
	AddCSLuaFile("fmainmenu/cl_mainmenu_panels.lua")
	include( "fmainmenu/sv_mainmenu.lua" )
	AddCSLuaFile( "fmainmenu/cl_mainmenu.lua" )
else
	include( "fmainmenu/cl_configsync.lua" ) 
	include("vgui/cl_fmainmenu_config.lua")
	include("vgui/cl_fmainmenu_mmenu.lua")
	include( "fmainmenu/cl_configmenu.lua" ) 
	include("fmainmenu/cl_mainmenu_panels.lua")
	include( "fmainmenu/cl_mainmenu.lua" )
end

FMainMenu.Log("Load Complete", false)