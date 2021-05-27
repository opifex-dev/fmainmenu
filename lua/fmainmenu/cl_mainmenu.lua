local net_Receive = net.Receive
local net_ReadInt = net.ReadInt
local net_ReadBool = net.ReadBool
local FMainMenu = FMainMenu
local hook_Remove = hook.Remove
local DarkRP = DarkRP
local gui_EnableScreenClicker = gui.EnableScreenClicker
local FayLib = FayLib
local timer_Create = timer.Create
local timer_Simple = timer.Simple
local FAdmin = FAdmin
local net_Start = net.Start
local net_SendToServer = net.SendToServer
local ScrW = ScrW
local ScrH = ScrH
local surface_PlaySound = surface.PlaySound
local ipairs = ipairs
local string_Explode = string.Explode
local sound_PlayFile = sound.PlayFile
local IsValid = IsValid
local sound_PlayURL = sound.PlayURL
local string_Replace = string.Replace
local game_GetIPAddress = game.GetIPAddress
local file_CreateDir = file.CreateDir
local file_Exists = file.Exists
local vgui_GetWorldPanel = vgui.GetWorldPanel
local string_find = string.find
local string_sub = string.sub
local net_ReadString = net.ReadString
local LocalPlayer = LocalPlayer
local gameevent_Listen = gameevent.Listen
local Player = Player
local hook_Add = hook.Add

FMainMenu.Lang = FMainMenu.Lang || {}

local closePanelGlobal = ""
local musicStation = ""
local oneTimeFlag = false
local varTable = {false}
local addonName = "fmainmenu"

--Used to sync server menu state with client
net_Receive( "FMainMenu_VarChange", function( len )
	local varID = net_ReadInt(4)
	varTable[varID] = net_ReadBool()
end )

--Config Refresh Handler
local function refreshMM()
	FMainMenu.RefreshDetect = false

	-- check for Murder gamemode
	if GAMEMODE && GAMEMODE.RoundStage != nil && GAMEMODE.LootCollected != nil && GAMEMODE.RoundSettings != nil && FMainMenu.EverySpawn then
		FMainMenu.EverySpawn = false
		FMainMenu.Log(FMainMenu.GetPhrase("LogMurderEverySpawn"), false)
	end
end

--Opens GUI portion of menu
local function openMenu()
	--Config Refresh Detect
	if FMainMenu.RefreshDetect then
		refreshMM()
	end

	--DarkRP Support
	if DarkRP then
		hook_Remove("ScoreboardShow", "FAdmin_scoreboard")
		DarkRP.openF1Menu()
		hook_Add("Think","FMainMenu_DarkRPThink", function()
			DarkRP.closeF4Menu()
			DarkRP.closeF1Menu()
		end)
	end

	--Creates function that can close panel
	function closePanelGlobal()
		-- cleanup
		hook.Remove("Think", "FMainMenu_KMV")
		gui_EnableScreenClicker( false )

		-- stop music and fade out, if needed
		if musicStation != "" then
			if FayLib.IGC.GetSharedKey(addonName, "musicFade") > 0 then
				local fadetime = 10 * FayLib.IGC.GetSharedKey(addonName, "musicFade")
				local curVol = FayLib.IGC.GetSharedKey(addonName, "musicVolume")
				local volSub = curVol / fadetime
				timer_Create("FMainMenu_Music_Fade", 0.1, fadetime, function()
					curVol = curVol - volSub
					if curVol < 0 then
						curVol = 0
					end
					if musicStation != "" then
						musicStation:SetVolume(curVol)
					end
				end)
				timer_Simple(FayLib.IGC.GetSharedKey(addonName, "musicFade") + 1, function()
					if musicStation != "" then
						musicStation:Stop()
						musicStation = ""
					end
				end)
			else
				musicStation:Stop()
				musicStation = ""
			end
		end

		-- destroy main menu GUI panels
		FMainMenu.Panels.Destroy()

		-- Reinstate DarkRP Scoreboard if needed
		if DarkRP && FAdmin then
			hook_Add("ScoreboardShow", "FAdmin_scoreboard", function()
				if FAdmin.GlobalSetting.FAdmin || OverrideScoreboard:GetBool() then -- Don't show scoreboard when FAdmin is not installed on server
					return FAdmin.ScoreBoard.ShowScoreBoard()
				end
			end)
		end

		-- related hooks
		hook.Remove("Think","FMainMenu_DarkRPThink")
		hook.Remove( "OnPlayerChangedTeam", "FMainMenu_OPCT")
		hook.Run( "FMainMenu_Client_MenuClosed" )

		-- signal server
		net_Start("FMainMenu_CloseMainMenu")
		net_SendToServer()

		closePanelGlobal = ""
	end

	--DarkRP Support
	if DarkRP then
		hook_Add( "OnPlayerChangedTeam", "FMainMenu_OPCT", function()
			closePanelGlobal()
		end )
	end

	FMainMenu.Panels.SetupBasics()

	--Positioning for menu items
	local xPos = ScrW() * 0.05
	local normalSize = 192
	if FayLib.IGC.GetSharedKey(addonName, "logoIsText") then
		normalSize = FayLib.IGC.GetSharedKey(addonName, "logoFontSize")
	end

	local curYPos = (ScrH() * 0.5) - 32
	if FayLib.IGC.GetSharedKey(addonName, "GarrysModStyle") then
		local additive = 64
		if FayLib.IGC.GetSharedKey(addonName, "logoIsText") then
			additive = 104
		end
		curYPos = additive + normalSize
	end

	--Modules for Menu Override
	local modules = {
		["Play"] = function(Content)
			local playButton = FMainMenu.Panels.CreateButton(Content.Text)
			playButton:SetPos(xPos, curYPos)
			curYPos = curYPos + FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize") + 12
			playButton.DoClick = function()
				surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonClickSound"))
				closePanelGlobal()
			end
		end,
		["URL"] = function(Content)
			local urlButton = FMainMenu.Panels.CreateURLButton(Content.Text, Content.URL)
			urlButton:SetPos(xPos, curYPos)
			curYPos = curYPos + FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize") + 12
		end,
		["Disconnect"] = function(Content)
			local quitButton = FMainMenu.Panels.CreateButton(Content.Text)
			quitButton:SetPos(xPos, curYPos)
			curYPos = curYPos + FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize") + 12
			quitButton.DoClick = function()
				surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonClickSound"))
				FMainMenu.Panels.CreateConfirmDC()
			end
		end,
		["Spacer"] = function(Content)
			curYPos = curYPos + ( (2 / 3) * FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"))
		end,
	}

	--Create Menu Buttons
	if FayLib.IGC.GetSharedKey(addonName, "MenuOverride") then
		for _,entry in ipairs(FayLib.IGC.GetSharedKey(addonName, "MenuSetup")) do
			modules[entry.Type](entry.Content)
		end
	else
		local playButton = FMainMenu.Panels.CreateButton(FMainMenu.GetPhrase("PlayButtonText"))
		playButton:SetPos(xPos, curYPos)
		curYPos = curYPos + FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize") + 36
		playButton.DoClick = function()
			surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonClickSound"))
			closePanelGlobal()
		end

		for _,btn in ipairs(FayLib.IGC.GetSharedKey(addonName, "URLButtons")) do
			local urlButton = FMainMenu.Panels.CreateURLButton(btn.Text, btn.URL)
			urlButton:SetPos(xPos, curYPos)
			curYPos = curYPos + FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize") + 12
		end

		if FayLib.IGC.GetSharedKey(addonName, "URLButtons") then
			curYPos = curYPos + 24
		end

		if FayLib.IGC.GetSharedKey(addonName, "dcButton") then
			if #FayLib.IGC.GetSharedKey(addonName, "URLButtons") == 0 then
				curYPos = curYPos - 36
			end
			local quitButton = FMainMenu.Panels.CreateButton(FMainMenu.GetPhrase("DisconnectButtonText"))
			quitButton:SetPos(xPos, curYPos)
			quitButton.DoClick = function()
				surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonClickSound"))
				FMainMenu.Panels.CreateConfirmDC()
			end
		end
	end

	--Changelog
	if FayLib.IGC.GetSharedKey(addonName, "showChangeLog") then
		local finalLog = ""
		local cLExplode = string_Explode("\n", FayLib.IGC.GetSharedKey(addonName, "changeLogText"))
		for _,v in ipairs(cLExplode) do
			finalLog = finalLog .. v .. "\n"
		end
		FMainMenu.Panels.CreateChangeLog(finalLog)
	end

	--Music Support
	if musicStation != "" then
		musicStation:Stop()
		musicStation = ""
	end

	if FayLib.IGC.GetSharedKey(addonName, "musicToggle") == 1 then
		--file
		sound_PlayFile( FayLib.IGC.GetSharedKey(addonName, "musicContent") , "noblock", function( station, errCode, errStr )
			if ( IsValid( station ) ) then
				station:EnableLooping(FayLib.IGC.GetSharedKey(addonName, "musicLooping"))
				station:SetVolume(FayLib.IGC.GetSharedKey(addonName, "musicVolume"))
				musicStation = station
			end
		end)
	elseif FayLib.IGC.GetSharedKey(addonName, "musicToggle") == 2 then
		--url
		sound_PlayURL( FayLib.IGC.GetSharedKey(addonName, "musicContent") , "noblock", function( station, errCode, errStr )
			if ( IsValid( station ) ) then
				station:EnableLooping(FayLib.IGC.GetSharedKey(addonName, "musicLooping"))
				station:SetVolume(FayLib.IGC.GetSharedKey(addonName, "musicVolume"))
				musicStation = station
			end
		end)
	end

	--Welcomer
	if FMainMenu.firstJoinSeed == false || FMainMenu.firstJoinSeed == "" then
		FMainMenu.firstJoinSeed = string_Replace(string_Replace(string_Replace(game_GetIPAddress() , ".", "") , ":", "") , " ", "")
	end

	file_CreateDir( "fmainmenu/" )
	if !file_Exists( "fmainmenu/" .. FMainMenu.firstJoinSeed .. ".txt", "DATA" ) && FayLib.IGC.GetSharedKey(addonName, "firstJoinWelcome") then
		FMainMenu.Panels.CreateWelcomer()
	end

	--Take care of various things that may occur while main menu is active
	hook_Add( "Think", "FMainMenu_KMV", function()
		--some addons may interfere by disabling the cursor
		gui_EnableScreenClicker( true )

		--Take care of some GUIs that can open and draw on top of the menu
		local VGUIWorld = vgui_GetWorldPanel()
		--Hide DarkRP Votes
		if DarkRP then
			for _,panel in ipairs(VGUIWorld:GetChildren()) do
				if (panel:GetClassName() == "LuaEditablePanel" && panel:GetName() == "DFrame") && (string_find(panel:GetTitle(), string_sub( DarkRP.getPhrase("time", 0), 1, string_find( DarkRP.getPhrase("time", 0), " " ) )) != nil) then
					panel:Close()
				end
			end
		end
	end )
end

-- Let server force main menu to close
net_Receive( "FMainMenu_CloseMainMenu", function( len, ply )
	if closePanelGlobal != "" then
		local message = net_ReadString()
		LocalPlayer():ChatPrint(message)
		FMainMenu.Log(message, false)
		closePanelGlobal()
	end
end )

--Detect Player Spawn
gameevent_Listen( "player_spawn" )
hook_Add("player_spawn", "FMainMenu_PlayerSpawn", function( data )
	if data.userid != LocalPlayer():UserID() then return end
	if Player( data.userid ):IsBot() then return end
	if varTable[1] then varTable[1] = false return end
	if oneTimeFlag && FMainMenu.EverySpawn then
		openMenu()
	end
end)

--Detect First Time Spawn
hook_Add("FMainMenu_OpenMenuInitial", "FMainMenu_IPE", function( )
	-- check for Murder gamemode
	if GAMEMODE && GAMEMODE.RoundStage != nil && GAMEMODE.LootCollected != nil && GAMEMODE.RoundSettings != nil && FMainMenu.EverySpawn then
		FMainMenu.EverySpawn = false
		FMainMenu.Log(FMainMenu.GetPhrase("LogMurderEverySpawn"), false)
	end

	oneTimeFlag = true
	openMenu()
end)

--Don't Draw HUD if in menu
hook_Add("HUDShouldDraw", "FMainMenu_HSD", function( name )
	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end)

--Don't show context menu if in menu
hook_Add("ContextMenuOpen", "FMainMenu_CMO", function( name )
	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end)

--Don't show spawn menu if in menu
hook_Add( "SpawnMenuOpen", "FMainMenu_SMO", function()
	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end )

--Don't apply mouse input to player movemenu if in menu
hook_Add("InputMouseApply", "FMainMenu_IMA", function( cmd )
	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		cmd:SetMouseX(0)
		cmd:SetMouseY(0)

		return true
	end
end)

--Don't apply keyboard input to player movement or actions if in menu
hook_Add("PlayerBindPress", "FMainMenu_PBPress", function( ply, bind, pressed )
	if bind != "messagemode" && bind != "messagemode2" && bind != "+showscores" then
		return
	end

	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		return true
	end
end)