local FMainMenu = FMainMenu
local FayLib = FayLib

FMainMenu.Lang = FMainMenu.Lang || {}

-- localized global calls
local net_Receive = net.Receive
local net_ReadInt = net.ReadInt
local net_ReadBool = net.ReadBool
local gui_EnableScreenClicker = gui.EnableScreenClicker
local timer_Create = timer.Create
local FAdmin = FAdmin
local net_Start = net.Start
local net_SendToServer = net.SendToServer
local ScrW = ScrW
local ScrH = ScrH
local surface_PlaySound = surface.PlaySound
local ipairs = ipairs
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
local timer_Remove = timer.Remove

-- variables related to below functionality
local closePanelGlobal = ""
local musicStation = ""
local oneTimeFlag = false
local varTable = {false}
local addonName = "fmainmenu"
local musicPlaying = false
local scoreboardShowTable = {}

--Used to sync server menu state with client
net_Receive( "FMainMenu_VarChange", function( len )
	local varID = net_ReadInt(4)
	varTable[varID] = net_ReadBool()
end )

-- returns whether or not the gamemode is murder
local function isServerGMMurder()
	return GAMEMODE && GAMEMODE.Name == "MURDER"
end

-- disables every spawn if gamemode is murder
local function everySpawnMurderCheck()
	if isServerGMMurder() && FMainMenu.EverySpawn then
		FMainMenu.EverySpawn = false
		FMainMenu.Log(FMainMenu.GetPhrase("LogMurderEverySpawn"), false)
	end
end

-- returns whether or not the gamemode is zombie survival
local function isServerGMZombieSurvival()
	return GAMEMODE && GAMEMODE.Name == "Zombie Survival"
end

-- disables every spawn if gamemode is zombie survival
local function everySpawnZombieSurvivalCheck()
	if isServerGMZombieSurvival() && FMainMenu.EverySpawn then
		FMainMenu.EverySpawn = false
		FMainMenu.Log(FMainMenu.GetPhrase("LogZSEverySpawn"), false)
	end
end

-- returns whether or not the gamemode is prop hunt
local function isServerGMPropHunt()
	return GAMEMODE && GAMEMODE.Name == "Prop Hunt"
end

-- disables every spawn if gamemode is prop hunt
local function everySpawnPropHuntCheck()
	if isServerGMPropHunt() && FMainMenu.EverySpawn then
		FMainMenu.EverySpawn = false
		FMainMenu.Log(FMainMenu.GetPhrase("LogPropHuntEverySpawn"), false)
	end
end

--Config Refresh Handler
local function refreshMM()
	FMainMenu.RefreshDetect = false

	-- check for Murder gamemode
	everySpawnMurderCheck()
end

-- Force Kills active background music
local function killMusicStation()
	timer_Remove("FMainMenu_Music_Fade")
	timer_Remove("FMainMenu_Music_Kill")
	musicStation:Stop()
	musicStation = ""
end

-- Stops actively playing background music
local function stopMusicStation()
	if FayLib.IGC.GetSharedKey(addonName, "musicFade") > 0 then
		local fadetime = 10 * FayLib.IGC.GetSharedKey(addonName, "musicFade")
		local curVol = FayLib.IGC.GetSharedKey(addonName, "musicVolume")
		local volSub = curVol / fadetime

		-- fade out based on configured time
		timer_Create("FMainMenu_Music_Fade", 0.1, fadetime, function()
			curVol = curVol - volSub

			if curVol < 0 then
				curVol = 0
			end

			if musicStation != "" then
				musicStation:SetVolume(curVol)
			end
		end)

		-- kill music channel after fade complete
		timer_Create("FMainMenu_Music_Kill", FayLib.IGC.GetSharedKey(addonName, "musicFade") + 1, 1, function()
			if musicStation != "" then
				killMusicStation()
			end
		end)
	else
		killMusicStation()
	end
end

-- common setup code between URL and File based background music
local function musicStationSetup(station)
	if ( IsValid( station ) ) then
		station:EnableLooping(FayLib.IGC.GetSharedKey(addonName, "musicLooping"))
		station:SetVolume(FayLib.IGC.GetSharedKey(addonName, "musicVolume"))
		musicStation = station

		if !musicPlaying then
			stopMusicStation()
		end
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
		DarkRP.openF1Menu()
		hook.Add("Think","FMainMenu_DarkRPThink", function()
			DarkRP.closeF4Menu()
			DarkRP.closeF1Menu()
		end)
	end
	
	-- Stop Scoreboard from showing
	scoreboardShowTable = {}
	for hookName, hookFunc in pairs(hook.GetTable()["ScoreboardShow"]) do
		scoreboardShowTable[hookName] = hookFunc
		hook.Remove("ScoreboardShow", hookName)
	end

	--Zombie Survival Support
	if isServerGMZombieSurvival() then
		GAMEMODE.XPHUD:SetVisible(false)
		GAMEMODE.GameStatePanel:SetVisible(false)
		GAMEMODE.HealthHUD:SetVisible(false)
		GAMEMODE.StatusHUD:SetVisible(false)

		hook.Add("Think","FMainMenu_ZombieSurvivalThink", function()
			if pWorth && pWorth:IsValid() then
				pWorth:Remove()
				pWorth = nil
			end

			if GAMEMODE.SkillWeb && GAMEMODE.SkillWeb:IsValid() then
				GAMEMODE.SkillWeb:Remove()
			end

			if pOptions && pOptions:IsValid() then
				pOptions:Remove()
				pOptions = nil
			end
		end)
	end

	--Prop Hunt support
	if isServerGMPropHunt() then
		RunConsoleCommand( "changeteam", TEAM_SPECTATOR )
	end

	--Creates function that can close panel
	closePanelGlobal = function()
		-- cleanup
		hook.Remove("Think", "FMainMenu_KMV")
		gui_EnableScreenClicker( false )

		-- stop music and fade out, if needed
		musicPlaying = false
		if musicStation != "" then
			stopMusicStation()
		end

		-- destroy main menu GUI panels
		FMainMenu.Panels.Destroy()

		-- Reinstate Scoreboard if needed
		for hookName, hookFunc in pairs(scoreboardShowTable) do
			hook.Add("ScoreboardShow", hookName, hookFunc)
		end

		-- undo Zombie Survival workarounds
		if isServerGMZombieSurvival() then
			GAMEMODE.XPHUD:SetVisible(true)
			GAMEMODE.GameStatePanel:SetVisible(true)
			GAMEMODE.HealthHUD:SetVisible(true)
			GAMEMODE.StatusHUD:SetVisible(true)
			MakepWorth()
		end

		-- undo Prop Hunt workarounds
		if isServerGMPropHunt() then
			timer.Simple(0, function()
				for i = 1, 3 do
					RunConsoleCommand( "spec_mode" )
				end
			end)

			GAMEMODE:ShowTeam()
		end

		-- related hooks
		hook.Remove("Think","FMainMenu_DarkRPThink")
		hook.Remove("Think","FMainMenu_ZombieSurvivalThink")
		hook.Remove( "OnPlayerChangedTeam", "FMainMenu_OPCT")
		hook.Run( "FMainMenu_Client_MenuClosed" )

		-- signal server
		net_Start("FMainMenu_CloseMainMenu")
		net_SendToServer()

		closePanelGlobal = ""
	end

	--DarkRP Support
	if DarkRP then
		hook.Add( "OnPlayerChangedTeam", "FMainMenu_OPCT", function()
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
		else
			if FayLib.IGC.GetSharedKey(addonName, "logoImageKeppAspectRatio") then
				normalSize = 192 * FayLib.IGC.GetSharedKey(addonName, "logoImageScaleAL")
			else
				normalSize = 192 * FayLib.IGC.GetSharedKey(addonName, "logoImageScaleY")
			end
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
		FMainMenu.Panels.CreateChangeLog(FayLib.IGC.GetSharedKey(addonName, "changeLogText"))
	end

	--Music Support
	musicPlaying = false
	if musicStation != "" then
		killMusicStation()
	end

	if FayLib.IGC.GetSharedKey(addonName, "musicToggle") == 1 then
		--file
		musicPlaying = true
		sound_PlayFile( FayLib.IGC.GetSharedKey(addonName, "musicContent") , "noblock", function( station, errCode, errStr )
			musicStationSetup(station)
		end)
	elseif FayLib.IGC.GetSharedKey(addonName, "musicToggle") == 2 then
		--url
		musicPlaying = true
		sound_PlayURL( FayLib.IGC.GetSharedKey(addonName, "musicContent") , "noblock", function( station, errCode, errStr )
			musicStationSetup(station)
		end)
	end

	--Welcomer
	if FMainMenu.firstJoinSeed == false || FMainMenu.firstJoinSeed == "" then
		FMainMenu.firstJoinSeed = string_Replace(string_Replace(string_Replace(game_GetIPAddress() , ".", "") , ":", "") , " ", "")
	end

	file_CreateDir( "fmainmenu/" )
	if !file_Exists( "fmainmenu/" .. FMainMenu.firstJoinSeed .. ".txt", "DATA" ) && FayLib.IGC.GetSharedKey(addonName, "firstJoinWelcome") then
		surface_PlaySound("garrysmod/content_downloaded.wav")
		FMainMenu.Panels.CreateWelcomer()
	end

	--Take care of various things that may occur while main menu is active
	hook.Add( "Think", "FMainMenu_KMV", function()
		--some addons may interfere by disabling the cursor
		gui_EnableScreenClicker( true )

		--Take care of some GUIs that can open and draw on top of the menu
		local VGUIWorld = vgui_GetWorldPanel()

		--Hide Zombie Survival F1 Menu (unlike the other panels, this one stores no global reference for some reason)
		if isServerGMZombieSurvival() then
			for _,panel in ipairs(VGUIWorld:GetChildren()) do
				if panel:GetClassName() == "Panel" && panel.Created != nil then
					for _,subPanel in ipairs(panel:GetChildren()) do
						if subPanel:GetClassName() == "Label" && subPanel:GetFont() == "ZSHUDFont" || subPanel:GetClassName() == "Button" && subPanel:GetFont() == "ZSHUDFontSmall" then
							panel:Remove()
						end
					end
				elseif panel:GetClassName() == "Panel" && panel.ClassTypeButton != nil then
					panel:Remove()
				end
			end
		end

		--Hide DarkRP Votes
		if DarkRP then
			for _,panel in ipairs(VGUIWorld:GetChildren()) do
				if (panel:GetClassName() == "LuaEditablePanel" && panel:GetName() == "DFrame") && (string_find(panel:GetTitle(), string_sub( DarkRP.getPhrase("time", 0), 1, string_find( DarkRP.getPhrase("time", 0), " " ) )) != nil) then
					panel:Close()
				end
			end
		end

		--Hide prop hunt splash screens
		if isServerGMPropHunt() then
			for _,panel in ipairs(VGUIWorld:GetChildren()) do
				if (panel.lblGamemodeName != nil && panel.lblIP != nil  && panel.lblServerName != nil) || panel.lblMain != nil then
					panel:Remove()
				end
			end
		end
	end )
end

-- Let server force main menu to close
net_Receive( "FMainMenu_CloseMainMenu", function( len )
	if closePanelGlobal != "" then
		local message = net_ReadString()
		LocalPlayer():ChatPrint(message)
		FMainMenu.Log(message, false)
		closePanelGlobal()
	end
end )

--Detect Player Spawn
gameevent_Listen( "player_spawn" )
hook.Add("player_spawn", "FMainMenu_PlayerSpawn", function( data )
	if !IsValid(LocalPlayer()) then return end
	if data.userid != LocalPlayer():UserID() then return end
	if Player( data.userid ):IsBot() then return end
	if varTable[1] then varTable[1] = false return end
	if oneTimeFlag && FMainMenu.EverySpawn then
		openMenu()
	end
end)

--Detect First Time Spawn
hook.Add("FMainMenu_OpenMenuInitial", "FMainMenu_IPE", function( )
	-- check for Murder gamemode
	everySpawnMurderCheck()

	-- check for Zombie Survival gamemode
	everySpawnZombieSurvivalCheck()

	-- check for Prop Hunt gamemode
	everySpawnPropHuntCheck()

	oneTimeFlag = true
	openMenu()
end)

--Don't Draw HUD if in menu
hook.Add("HUDShouldDraw", "FMainMenu_HSD", function( name )
	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end)

--Don't show context menu if in menu
hook.Add("ContextMenuOpen", "FMainMenu_CMO", function( name )
	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end)

--Don't show spawn menu if in menu
hook.Add( "SpawnMenuOpen", "FMainMenu_SMO", function()
	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end )

--Don't apply mouse input to player movemenu if in menu
hook.Add("InputMouseApply", "FMainMenu_IMA", function( cmd )
	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		cmd:SetMouseX(0)
		cmd:SetMouseY(0)

		return true
	end
end)

--Don't apply keyboard input to player movement or actions if in menu
hook.Add("PlayerBindPress", "FMainMenu_PBPress", function( ply, bind, pressed )
	if bind != "messagemode" && bind != "messagemode2" && bind != "+showscores" then
		return
	end

	if LocalPlayer():GetNWBool("FMainMenu_InMenu",false) then
		return true
	end
end)