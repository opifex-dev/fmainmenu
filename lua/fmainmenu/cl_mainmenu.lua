local FMainMenu = FMainMenu
local FayLib = FayLib

FMainMenu.Lang = FMainMenu.Lang || {}

local isPlyReady = false

local jobLookup = {
	[1] = {
		["NAME"] = "VISITOR",
		["DESC"] = "Be unemployed.",
		["DIFF"] = "Easy",
		["JOB"] = "TEAM_VISITOR",
		["JOBTITLE"] = "Visitor",
	},
	[2] = {
		["NAME"] = "PLANT JANITOR",
		["DESC"] = "A low responsibility job that lets you explore the facility.",
		["DIFF"] = "Easy",
		["JOB"] = "TEAM_WORKER_JANITOR",
		["JOBTITLE"] = "Plant Janitor",
	},
	[3] = {
		["NAME"] = "PLANT MECHANIC",
		["DESC"] = "Do various facility-related repair work.",
		["DIFF"] = "Easy",
		["JOB"] = "TEAM_WORKER_MECHANIC",
		["JOBTITLE"] = "Plant Mechanic",
	},
	[4] = {
		["NAME"] = "PLANT SECURITY",
		["DESC"] = "Do various facility-related security work.",
		["DIFF"] = "Medium",
		["JOB"] = "TEAM_SECURITY_CADET",
		["JOBTITLE"] = "Plant Security",
	},
	[5] = {
		["NAME"] = "PLANT OPERATOR",
		["DESC"] = "Do various facility-related operational work.",
		["DIFF"] = "Medium",
		["JOB"] = "TEAM_WORKER_ENGINEER",
		["JOBTITLE"] = "Plant Operator",
	},
	[6] = {
		["NAME"] = "SCIENTIST",
		["DESC"] = "Do various facility-related research.",
		["DIFF"] = "Hard",
		["JOB"] = "TEAM_SCIENTIST_INTERN",
		["JOBTITLE"] = "Scientist",
	},
}

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
		hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
		DarkRP.openF1Menu()
		hook.Add("Think","FMainMenu_DarkRPThink", function()
			DarkRP.closeF4Menu()
			DarkRP.closeF1Menu()
		end)
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
	closePanelGlobal = function(jobTitle)
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

		-- Reinstate DarkRP Scoreboard if needed
		if DarkRP && FAdmin then
			hook.Add("ScoreboardShow", "FAdmin_scoreboard", function()
				if FAdmin.GlobalSetting.FAdmin || OverrideScoreboard:GetBool() then -- Don't show scoreboard when FAdmin is not installed on server
					return FAdmin.ScoreBoard.ShowScoreBoard()
				end
			end)
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
			if jobTitle ~= nil then
				net.WriteBool(true)
				net.WriteString(jobTitle)
			else
				net.WriteBool(false)
			end
		net_SendToServer()

		closePanelGlobal = ""
	end

	local function classSelect()
		local blocker = PPRP.Derma.CreateDPanel(nil, ScrW(), ScrH(), false )
		blocker:SetDrawBackground( false )
		blocker:ClearPaint()
		blocker:Background(Color(0,0,0,0))
		local bChung = 1080/2.5
		local troubleFrame = PPRP.Derma.CreateDFrame("Job Selection", nil, 1920/3, bChung	)
		troubleFrame:Center()
		troubleFrame:ShowCloseButton( false )
		troubleFrame:SetDraggable( false )
		local initTroublePanel = PPRP.Derma.CreateDPanel(troubleFrame, 1920/3-15, bChung-25, false )
		initTroublePanel:SetPos(5, 15)
		initTroublePanel.Paint = function()
			surface.SetDrawColor(55,55,55,255)
			surface.DrawRect( 5, 15, 1920/3-5, bChung-15 )
			surface.SetDrawColor( 100, 100, 100, 255 )
			surface.DrawLine( 2*(1920/3)/3-1, 15, 2*(1920/3)/3-1, bChung )
			surface.DrawLine( 2*(1920/3)/3, 15, 2*(1920/3)/3, bChung )
			surface.DrawLine( 2*(1920/3)/3+1, 15, 2*(1920/3)/3+1, bChung )
		end
		local leftText = PPRP.Derma.CreateDLabel(initTroublePanel, 2*(1920/3)/3-11, bChung-5, false, "Select A Starter Job")
		leftText:SetFont("Trebuchet24")
		leftText:SetPos(10, 20)
		leftText:SetTextColor( Color(200,200,200,255) )
		leftText:SetContentAlignment( 8 )
		local PageCounterT = PPRP.Derma.CreateDLabel(initTroublePanel, (1920/3-15)/3-20, 20	, false, "Visitor")
		PageCounterT:SetFont("HudHintTextLarge")
		PageCounterT:SetPos((2*(1920/3)/3)+10, bChung/3 + 20)
		PageCounterT:SetTextColor( Color(200,200,200,255) )
		PageCounterT:SetContentAlignment( 5 )
		local PageCounterB = PPRP.Derma.CreateDLabel(initTroublePanel, (1920/3-15)/3-20, 20	, false, "Easy")
		PageCounterB:SetFont("HudHintTextLarge")
		PageCounterB:SetPos((2*(1920/3)/3)+10, bChung/3 + 85)
		PageCounterB:SetTextColor( Color(200,200,200,255) )
		PageCounterB:SetContentAlignment( 5 )
		local bOffset = 0
		local curSelect = 1
		for i=1,#jobLookup do
			local firstButton = PPRP.Derma.CreateDButton(initTroublePanel, (2*(1920/3)/3)-20, 50, jobLookup[i]["NAME"].."\n\n"..jobLookup[i]["DESC"], "Removes the inserted fuel from this cell.")
			firstButton:SetPos(10+3, (1080/25)+10 + bOffset)
			firstButton:SetWrap(true)
			firstButton:SetFont("HudHintTextLarge")
			firstButton:SetTextColor( Color(200,200,200,255) )
			firstButton:SetContentAlignment( 7 )
			firstButton:ClearPaint():Background(Color(40,40,40,255))
			firstButton:SetTextInset( 3, 3 )
			firstButton.DoClick = function()
				surface.PlaySound("garrysmod/ui_click.wav")
				curSelect = i
				PageCounterT:SetText(jobLookup[curSelect]["JOBTITLE"])
				PageCounterB:SetText(jobLookup[curSelect]["DIFF"])
			end
			bOffset = bOffset + 1080/20 + 5
		end
		local PageCounter = PPRP.Derma.CreateDLabel(initTroublePanel, (1920/3-15)/3-20, 20, false, "Selected Job:")
		PageCounter:SetFont("HudHintTextLarge")
		PageCounter:SetPos((2*(1920/3)/3)+10, bChung/3)
		PageCounter:SetTextColor( Color(200,200,200,255) )
		PageCounter:SetContentAlignment( 5 )
		PageCounter = PPRP.Derma.CreateDLabel(initTroublePanel, (1920/3-15)/3-20, 20, false, "Job Difficulty:")
		PageCounter:SetFont("HudHintTextLarge")
		PageCounter:SetPos((2*(1920/3)/3)+10, bChung/3 + 65)
		PageCounter:SetTextColor( Color(200,200,200,255) )
		PageCounter:SetContentAlignment( 5 )
		local firstButton = PPRP.Derma.CreateDButton(initTroublePanel, ((1920/3)/3)/2-20, ScrH()/40, "Cancel", "Removes the inserted fuel from this cell.")
		firstButton:SetPos((2*(1920/3)/3)+5+3, (bChung-25)-(ScrH()/40)-5)
		firstButton:SetFont("HudHintTextLarge")
		firstButton:SetTextColor( Color(200,200,200,255) )
		firstButton:FillHover()
		firstButton:SetContentAlignment( 5 )
		firstButton:ClearPaint():Background(Color(40,40,40,255))
		firstButton.DoClick = function()
			surface.PlaySound("garrysmod/ui_click.wav")
			troubleFrame:Close()
			blocker:Remove()
		end
		secondButton = PPRP.Derma.CreateDButton(initTroublePanel, ((1920/3)/3)/2-20, ScrH()/40, "Play", "Removes the inserted fuel from this cell.")
		secondButton:SetPos((1920/3)-5-10-5-(((1920/3)/3)/2-20), (bChung-25)-(ScrH()/40)-5)
		secondButton:SetFont("HudHintTextLarge")
		secondButton:SetTextColor( Color(200,200,200,255) )
		secondButton:FillHover()
		secondButton:SetContentAlignment( 5 )
		secondButton:ClearPaint():Background(Color(40,40,40,255))
		secondButton.DoClick = function()
			surface.PlaySound("garrysmod/ui_click.wav")
			closePanelGlobal(jobLookup[curSelect]["JOB"])
			troubleFrame:Remove()
			blocker:Remove()
		end
	end

	--DarkRP Support
	if DarkRP then
		hook.Add( "OnPlayerChangedTeam", "FMainMenu_OPCT", function()
			closePanelGlobal()
		end )
	end

	FMainMenu.Panels.SetupBasics()

	--Positioning for menu items
	local xPos = 1920 * 0.05 * (ScrW() / 1920)
	local normalSize = 192 * (ScrW() / 1920)
	if FayLib.IGC.GetSharedKey(addonName, "logoIsText") then
		normalSize = FayLib.IGC.GetSharedKey(addonName, "logoFontSize")
	end

	local curYPos = (ScrH() * 0.5) - 32
	if FayLib.IGC.GetSharedKey(addonName, "GarrysModStyle") then
		local additive = 64 * (ScrH() / 1080)
		if FayLib.IGC.GetSharedKey(addonName, "logoIsText") then
			additive = 104 * (ScrH() / 1080)
		else
			if FayLib.IGC.GetSharedKey(addonName, "logoImageKeppAspectRatio") then
				normalSize = 192 * FayLib.IGC.GetSharedKey(addonName, "logoImageScaleAL") * (ScrH() / 1080)
			else
				normalSize = 192 * FayLib.IGC.GetSharedKey(addonName, "logoImageScaleY") * (ScrH() / 1080)
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
			classSelect()
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

	-- Troubleshooter
	if not file.Exists( "pprp_remastered/init_troubleshoot_flag.txt", "DATA" ) then
		local blocker = PPRP.Derma.CreateDPanel(nil, ScrW(), ScrH(), false )
		blocker:SetDrawBackground( false )
		blocker:ClearPaint()
		blocker:Background(Color(0,0,0,0))
		local initSTR = ""
		if first then
			initSTR = "Initial Join "
		end
		local troubleFrame = PPRP.Derma.CreateDFrame("Troubleshooter", nil, ScrW()/3, ScrH()/3	)
		troubleFrame:Center()
		troubleFrame:ShowCloseButton( false )
		troubleFrame:SetDraggable( false )
		local initTroublePanel = PPRP.Derma.CreateDPanel(troubleFrame, ScrW()/3-15, ScrH()/3-25, false )
		initTroublePanel:SetPos(5, 15)
		initTroublePanel.Paint = function()
			surface.SetDrawColor(55,55,55,255)
			surface.DrawRect( 5, 15, ScrW()/3-5, ScrH()/3-15 )
			surface.SetDrawColor( 100, 100, 100, 255 )
			surface.DrawLine( 2*(ScrW()/3)/3-1, 15, 2*(ScrW()/3)/3-1, ScrH()/3 )
			surface.DrawLine( 2*(ScrW()/3)/3, 15, 2*(ScrW()/3)/3, ScrH()/3 )
			surface.DrawLine( 2*(ScrW()/3)/3+1, 15, 2*(ScrW()/3)/3+1, ScrH()/3 )
		end
		local firstSTR = ""
		if first then
			firstSTR = "We've noticed that the troubleshooter hasn't been run on this client yet! "
		end
		local secondSTR = "if you have decided against using the troubleshooter, you can close it by clicking the \"Cancel\" button."
		if first then
			secondSTR = "if you would like to skip the troubleshooter and get right into the game, click the \"Cancel\" button.\n\nNOTE: If you decide to cancel the troubleshooter, it will no longer open."
		end
		local leftText = PPRP.Derma.CreateDLabel(initTroublePanel, 2*(ScrW()/3)/3-11, ScrH()/3-5, false, firstSTR.."This troubleshooter is designed to allow for the best experience possible while playing Power Plant Roleplay.\n\nIf you would like to get started, simply click the \"Next\" button to proceed.\n\nAlternatively, "..secondSTR)
		leftText:SetFont("HudHintTextLarge")
		leftText:SetPos(10, 20)
		leftText:SetTextColor( Color(200,200,200,255) )
		leftText:SetWrap( true )
		leftText:SetContentAlignment( 7 )
		local PageCounter = PPRP.Derma.CreateDLabel(initTroublePanel, ScrW()/3-20, 20	, false, "")
		PageCounter:SetFont("HudHintTextLarge")
		PageCounter:SetPos(0, 15)
		PageCounter:SetTextColor( Color(200,200,200,255) )
		PageCounter:SetContentAlignment( 6 )
		local firstButton = PPRP.Derma.CreateDButton(initTroublePanel, ((ScrW()/3)/3)/2-20, ScrH()/40, "Cancel", "Removes the inserted fuel from this cell.")
		firstButton:SetPos((2*(ScrW()/3)/3)+5+3, (ScrH()/3-25)-(ScrH()/40)-5)
		firstButton:SetFont("HudHintTextLarge")
		firstButton:SetTextColor( Color(200,200,200,255) )
		firstButton:FillHover()
		firstButton:SetContentAlignment( 5 )
		firstButton:ClearPaint():Background(Color(40,40,40,255))
		firstButton.DoClick = function()
			surface.PlaySound("garrysmod/ui_click.wav")
			file.Write("pprp_remastered/init_troubleshoot_flag.txt", "true")
			troubleFrame:Close()
			blocker:Remove()
		end
		secondButton = PPRP.Derma.CreateDButton(initTroublePanel, ((ScrW()/3)/3)/2-20, ScrH()/40, "Next", "Removes the inserted fuel from this cell.")
		secondButton:SetPos((ScrW()/3)-5-10-5-(((ScrW()/3)/3)/2-20), (ScrH()/3-25)-(ScrH()/40)-5)
		secondButton:SetFont("HudHintTextLarge")
		secondButton:SetTextColor( Color(200,200,200,255) )
		secondButton:FillHover()
		secondButton:SetContentAlignment( 5 )
		secondButton:ClearPaint():Background(Color(40,40,40,255))
		secondButton.DoClick = function()
			surface.PlaySound("garrysmod/ui_click.wav")
			leftText:SetText("MAT_SPECULAR\n\nThe command \"mat_specular\" is a setting used by the engine to determine whether it should render cubemap reflections on reflective surfaces. It is much cheaper on the engine than, say, a mirror or a body of reflective water (which are not affected by cubemaps or \"mat_specular\").\n\nThis map does not contain any built cubemaps, meaning you may see purple checkerboard textures reflected behind some surfaces. To prevent this, we suggest allowing the troubleshooter to disable cubemap reflections.\n\nWould you like to allow the troubleshooter to disable cubemap reflections? (\"mat_specular 0\")\n\nClick \"Accept\" to allow, or \"Deny\" to skip this suggested fix.\n\nNOTE: when \"mat_specular\" is changed, it may trigger a material reload. This may cause the game to freeze for a certain amount of time (10-30 seconds).")
			firstButton:SetText("Deny")
			secondButton:SetText("Accept")
			PageCounter:SetText("1/3")
			
			local function nextPageOne()
				leftText:SetText("CONTENT PACK\n\nPower Plant Roleplay, like many roleplay servers, relies on players downloading custom content to enjoy it to the fullest.\n\nWhile many clients have downloaded the required files automatically while joining, you will not be able to place any custom props unless you manually subscribe to it. In some cases, clients may also fail to mount the required addons that were downloaded automatically. For this reason, we recommend that all players manually subscribe to the content pack regardless.\n\nClick \"Accept\" to open the content pack page on the Garry's Mod Workshop, or \"Deny\" to skip this suggested fix.\n\nNOTE: when the content pack is fully downloaded, you will likely have to restart the game one or two times for it to properly mount. You will have to do this manually.")
				PageCounter:SetText("2/3")
				
				local function nextPageTwo()
					surface.PlaySound("garrysmod/save_load4.wav")
					file.Write("pprp_remastered/init_troubleshoot_flag.txt", "true")
					firstButton:Remove()
					secondButton:SetText("Close")
					local thirdSTR = ""
					if first then
						thirdSTR = "You are now ready to play Power Plant Roleplay."
					end
					leftText:SetText("The troubleshooter is complete!\n\n"..thirdSTR.."Press the \"Close\" button to return to the menu.")
					PageCounter:SetText("3/3")
					
					local function nextPageTwo()
						troubleFrame:Close()
						blocker:Remove()
					end
					
					secondButton.DoClick = function()
						surface.PlaySound("garrysmod/ui_click.wav")
						nextPageTwo()
					end
				end
				
				firstButton.DoClick = function()
					surface.PlaySound("garrysmod/ui_click.wav")
					nextPageTwo()
				end
				secondButton.DoClick = function()
					surface.PlaySound("garrysmod/ui_click.wav")
					gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=2163326110" )
					nextPageTwo()
				end
			end
			
			firstButton.DoClick = function()
				surface.PlaySound("garrysmod/ui_click.wav")
				nextPageOne()
			end
			secondButton.DoClick = function()
				surface.PlaySound("garrysmod/ui_click.wav")
				RunConsoleCommand("mat_specular","0")
				nextPageOne()
			end
		end
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

	local blocker = PPRP.Derma.CreateDPanel(nil, ScrW(), ScrH(), false )
	blocker:ClearPaint()
	blocker:Background(Color(0,0,0,255))

	local FadeText = PPRP.Derma.CreateDLabel(blocker, ScrW(), ScrH(), false, "Fay & The Opifex Network")
	FadeText:SetPos(0,-30)
	FadeText:SetFont("DermaLarge")
	FadeText:SetTextColor( Color(200,200,200,255) )
	FadeText:SetContentAlignment( 5 )
	local FadeTextTwo = PPRP.Derma.CreateDLabel(blocker, ScrW(), ScrH(), false, "Present...")

	FadeTextTwo:SetPos(0,30)
	FadeTextTwo:SetFont("DermaLarge")
	FadeTextTwo:SetTextColor( Color(200,200,200,255) )
	FadeTextTwo:SetContentAlignment( 5 )

	local fade = 255
	timer.Create("fmainmenu_fade_checker", 0.5, 0, function()
		if isPlyReady then
			timer.Remove("fmainmenu_fade_checker")

			timer.Simple(5, function() 
				timer.Create("main_menu_fade", 0.01, 255/5, function()
					fade = fade - 5
					FadeText:SetTextColor(Color(200,200,200,fade))
					FadeTextTwo:SetTextColor(Color(200,200,200,fade))
					blocker:ClearPaint()
					blocker:Background(Color(0,0,0,fade))
					if fade <= 0 then
						FadeText:Remove()
						blocker:Remove()
						gui.EnableScreenClicker( true )
						if zfs then
							zfs.ClosePurchase_Cancel()
						end
					end
				end)
			end)
		end
	end)
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
	isPlyReady = true

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