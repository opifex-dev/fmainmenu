local Color = Color
local util_AddNetworkString = util.AddNetworkString
local util_PrecacheModel = util.PrecacheModel
local net_Receive = net.Receive
local FayLib = FayLib
local net_Start = net.Start
local net_WriteInt = net.WriteInt
local net_WriteBool = net.WriteBool
local net_Send = net.Send
local hook_Run = hook.Run
local ents_Create = ents.Create
local game_GetMap = game.GetMap
local Vector = Vector
local FMainMenu = FMainMenu
local Angle = Angle
local FindMetaTable = FindMetaTable
local IsValid = IsValid
local ipairs = ipairs
local player_GetAll = player.GetAll
local timer_Remove = timer.Remove
local timer_Create = timer.Create
local timer_Simple = timer.Simple
local hook_Add = hook.Add
local player_GetHumans = player.GetHumans
local net_WriteString = net.WriteString
local bit_band = bit.band
local bit_bnot = bit.bnot
local CAMI = CAMI
local table_Copy = table.Copy
local pairs = pairs
local net_ReadTable = net.ReadTable
local util_TableToJSON = util.TableToJSON
local net_ReadString = net.ReadString
local util_JSONToTable = util.JSONToTable
local table_GetKeys = table.GetKeys
local type = type

FMainMenu.Lang = FMainMenu.Lang || {}

local cam = ""
local camColor = Color(0,0,0,0)
local invisPlayerColor = Color(255,255,255,0)
local defaultPlayerColor = Color(255, 255, 255, 255)
local addonName = "fmainmenu"

util_AddNetworkString("FMainMenu_CloseMainMenu")
util_AddNetworkString("FMainMenu_VarChange")
util_AddNetworkString("FMainMenu_Config_OpenMenu")
util_AddNetworkString("FMainMenu_Config_ReqVar")
util_AddNetworkString("FMainMenu_Config_UpdateVar")
util_AddNetworkString("FMainMenu_Config_UpdateTempVariable")
util_AddNetworkString("FMainMenu_Config_CloseMenu")

util_PrecacheModel( "models/props_phx/construct/wood/wood_dome360.mdl" )

--Response to player attempting to leave menu
net_Receive( "FMainMenu_CloseMainMenu", function( len, ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) then
		ply:SetNWBool("FMainMenu_InMenu",false)
		ply:UnLock()
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetViewEntity(ply)

		if FayLib.IGC.GetKey(addonName, "AdvancedSpawn") && FayLib.IGC.GetKey(addonName, "AdvancedSpawnPos") then
			ply:SetRenderMode(RENDERMODE_NORMAL)
			ply:SetColor( ply.PreviousFMainMenuColor )
			ply:SetNWBool("FMainMenu_TempSpawn",true)

			if FMainMenu.EverySpawn then
				net_Start("FMainMenu_VarChange")
					net_WriteInt( 1, 4 )
					net_WriteBool( )
				net_Send(ply)
			end

			ply:Spawn()
		end

		hook_Run( "FMainMenu_MenuClosed", ply )
	end
end )

--Sets up physical camera object for players' views to be set to
local function setupCam()
	cam = ents_Create("prop_dynamic")
	cam:SetModel("models/brokenglass_piece.mdl")
	cam:SetRenderMode(RENDERMODE_TRANSCOLOR)
	cam:SetColor(camColor)
	cam:DrawShadow( false )

	local cameraPos = ""
	if FayLib.IGC.GetKey(addonName, "CameraPosition")[game_GetMap()] then
		cameraPos = FayLib.IGC.GetKey(addonName, "CameraPosition")[game_GetMap()] + Vector(0,0,64)
	else
		cameraPos = Vector(-1286.149658, 1187.535156, -11371.772461)
		FMainMenu.Log(FMainMenu.GetPhrase("LogNoCamPos"), true)
	end

	cam:SetPos( cameraPos )

	local cameraAng = ""
	if FayLib.IGC.GetKey(addonName, "CameraAngle")[game_GetMap()] then
		cameraAng = FayLib.IGC.GetKey(addonName, "CameraAngle")[game_GetMap()]
	else
		cameraAng = Angle(42.586422, -40.820980, 0.000000)
		FMainMenu.Log(FMainMenu.GetPhrase("LogNoCamAng"), true)
	end

	cam:SetAngles( cameraAng )

	cam:Spawn()
	cam:Activate()
	cam:SetMoveType(MOVETYPE_NONE)
	cam:SetSolid(SOLID_NONE)
end

--Config Refresh Handler
local function refreshMM()
	FMainMenu.RefreshDetect = false
	cam = ""

	-- check for Murder gamemode
	if GAMEMODE && GAMEMODE.RoundStage != nil && GAMEMODE.RoundCount != nil && FMainMenu.EverySpawn then
		FMainMenu.EverySpawn = false
		FMainMenu.Log(FMainMenu.GetPhrase("LogMurderEverySpawn"), false)
	end
end

--[[
	BEGIN BABYGOD WORKAROUND CODE - DarkRP
]]--
local entMeta = FindMetaTable("Entity")

local oldPlyColor
local function disableBabyGod(ply)
	if !IsValid(ply) || !ply.Babygod then return end

	ply.Babygod = nil
	ply:SetRenderMode(RENDERMODE_NORMAL)
	ply:GodDisable()

	-- Don't reinstate the SetColor function
	-- if there are still players who are babygodded
	local reinstateOldColor = true

	for _, p in ipairs(player_GetAll()) do
		reinstateOldColor = reinstateOldColor && p.Babygod == nil
	end

	if reinstateOldColor then
		entMeta.SetColor = oldPlyColor
		oldPlyColor = nil
	end

	ply:SetColor(ply.babyGodColor || defaultPlayerColor)

	ply.babyGodColor = nil
end

local function enableBabyGod(ply)
	timer_Remove(ply:EntIndex() .. "babygod")

	ply.Babygod = true
	ply:GodEnable()
	ply.babyGodColor = ply:GetColor()
	ply:SetRenderMode(RENDERMODE_TRANSALPHA)

	if !oldPlyColor then
		oldPlyColor = entMeta.SetColor
		entMeta.SetColor = function(p, c, ...)
			if !p.Babygod then return oldPlyColor(p, c, ...) end

			p.babyGodColor = c
			oldPlyColor(p, Color(c.r, c.g, c.b, 100))
		end
	end

	ply:SetColor(ply.babyGodColor)
	timer_Create(ply:EntIndex() .. "babygod", GAMEMODE.Config.babygodtime || 0, 1, fp{disableBabyGod, ply})
end

local function checkDRPBabyGod(ply)
	if DarkRP then
		if GAMEMODE.Config.babygod then
			GAMEMODE.Config.babygod = false
		end

		if (GAMEMODE.Config.babygodtime > 0 && !ply.IsSleeping && !ply.Babygod) && (ply:GetNWBool("FMainMenu_InMenu",false) == false || ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "AdvancedSpawn")) then
			enableBabyGod(ply)
		end
	end
end

--[[
	END BABYGOD WORKAROUND CODE
]]--

--Hand players spawning - open menu and set up player with camera if needed
local function spawnPlayerFunc(ply)
	if FMainMenu.RefreshDetect then
		refreshMM()
	end

	if cam == "" then
		setupCam()
	end

	if ply:GetNWBool("FMainMenu_TempSpawn",false) then
		ply:SetNWBool("FMainMenu_TempSpawn",false)
		return
	end

	ply:SetNWBool("FMainMenu_InMenu",true)
	ply:SetViewEntity( cam )

	if FayLib.IGC.GetKey(addonName, "AdvancedSpawn") then
		ply:StripWeapons()
		ply.PreviousFMainMenuColor = ply:GetColor()
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
		ply:SetColor( invisPlayerColor )

		local pPOS = ""
		if FayLib.IGC.GetKey(addonName, "AdvancedSpawnPos")[game_GetMap()] then
			pPOS = FayLib.IGC.GetKey(addonName, "AdvancedSpawnPos")[game_GetMap()] + Vector(0,0,64)
		else
			pPOS = Vector(-172.215729, -24.837690, -12064.818359)
			FMainMenu.Log(FMainMenu.GetPhrase("LogNoAdvSpawnPos"), true)
		end

		timer_Simple(0,function()
			ply:SetPos(pPOS - Vector(0,0,64))
			timer_Simple(0,function()
				ply:SetMoveType(MOVETYPE_NOCLIP)
			end)
		end)
	else
		ply:DropToFloor()
	end
	timer_Simple(0,function()
		ply:Lock()
	end)
	checkDRPBabyGod(ply)
end

--Detect player first spawn for menu
hook_Add( "PlayerInitialSpawn", "FMainMenu_PIS", function( ply )
	if ply:IsBot() then return end

	ply:SetNWBool("FMainMenu_TempSpawn",false)
	if !FMainMenu.EverySpawn then
		spawnPlayerFunc(ply)
	end
end )

--Detect player spawn for menu
hook_Add( "PlayerSpawn", "FMainMenu_PS", function( ply )
	if ply:IsBot() then return end

	if FMainMenu.EverySpawn then
		spawnPlayerFunc(ply)
	end
end )

--Detect map loaded for camera
hook_Add( "InitPostEntity", "FMainMenu_IPE", function()
	setupCam()

	-- check for Murder gamemode
	if GAMEMODE && GAMEMODE.RoundStage != nil && GAMEMODE.RoundCount != nil then
		local murderTrigger = false

		if FMainMenu.EverySpawn then
			FMainMenu.EverySpawn = false
			FMainMenu.Log(FMainMenu.GetPhrase("LogMurderEverySpawn"), false)
		end

		hook_Add( "Think", "FMainMenu_Murder_Think", function()
			if GAMEMODE:GetRound() == GAMEMODE.Round.Playing && murderCache != GAMEMODE.Round.Playing && !murderTrigger then
				murderTrigger = true
				for _,ply in ipairs(player_GetHumans()) do
					if ply:GetNWBool("FMainMenu_InMenu",false) then
						net_Start("FMainMenu_CloseMainMenu")
							net_WriteString( FMainMenu.GetPhrase("MurderRoundStarted") )
						net_Send(ply)
					end
				end
			elseif GAMEMODE:GetRound() != GAMEMODE.Round.Playing then
				murderTrigger = false
			end
			murderCache = GAMEMODE:GetRound()
		end )
	end
end )

--Detect map cleanup for camera
hook_Add( "PreCleanupMap", "FMainMenu_PreCleanup", function()
	for _,ply in ipairs(player_GetHumans()) do
		if ply:GetNWBool("FMainMenu_InMenu",false) then
			ply:SetViewEntity(ply)
		end
	end
end )

--Re-place camera
hook_Add( "PostCleanupMap", "FMainMenu_PostCleanup", function()
	cam = ""
	setupCam()
	for _,ply in ipairs(player_GetHumans()) do
		if ply:GetNWBool("FMainMenu_InMenu",false) then
			ply:SetViewEntity(cam)
		end
	end
end )

--Prevent player suicide if in menu
hook_Add( "CanPlayerSuicide", "FMainMenu_CanPlayerSuicide", function(ply)
	if ply:GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end )

--Prevent player from picking up weapons if in menu
hook_Add( "PlayerCanPickupWeapon", "FMainMenu_CPW", function( ply, wep )
	if ply:GetNWBool("FMainMenu_InMenu",false) && FayLib.IGC.GetKey(addonName, "AdvancedSpawn") then
		return false
	end
end )

--Prevent players from hearing others while in menu ; also uses a custom voice system to make hearing voices independent from gamemode
local playerTalkCheck = {}

hook_Add("PlayerCanHearPlayersVoice", "FMainMenu_PCHPV", function(listener, talker)
	if talker:GetNWBool("FMainMenu_InMenu",false) || listener:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "HearOtherPlayers") then
		return false
	end
	if listener:GetNWBool("FMainMenu_InMenu",false) && FayLib.IGC.GetKey(addonName, "HearOtherPlayers") then
		if playerTalkCheck[talker:UserID()] == nil then
			return false
		else
			return playerTalkCheck[talker:UserID()]
		end
	end
end)

local function checkMute(ply)
	if FAdmin && ply:FAdmin_GetGlobal("FAdmin_voicemuted") then
		return true
	end

	if ULib && ply:SetNWBool("ulx_gagged", false) then
		return true
	end

	return false
end

timer_Create("FMainMenu_PVoiceCheck", 0.2, 0, function()
	for _,talker in ipairs(player_GetHumans()) do
		-- TTT Traitor Detection
		if (ROLE_TRAITOR != nil && ROLE_DETECTIVE != nil && TEAM_TERROR != nil && talker.traitor_gvoice != nil) && (talker:IsActiveTraitor() && talker.traitor_gvoice == false) then
			playerTalkCheck[talker:UserID()] = false
		end

		if FayLib.IGC.GetKey(addonName, "PlayerVoiceDistance") <= 0 && !checkMute(talker) then
			playerTalkCheck[talker:UserID()] = true
		elseif FayLib.IGC.GetKey(addonName, "PlayerVoiceDistance") > 0 then
			local cameraPos = ""

			if FayLib.IGC.GetKey(addonName, "CameraPosition")[game_GetMap()] then
				cameraPos = FayLib.IGC.GetKey(addonName, "CameraPosition")[game_GetMap()] + Vector(0,0,64)
			else
				cameraPos = Vector(-1286.149658, 1187.535156, -11371.772461)
			end

			if (cameraPos:DistToSqr( talker:GetPos() ) <= FayLib.IGC.GetKey(addonName, "PlayerVoiceDistance")) && !checkMute(talker) then
				playerTalkCheck[talker:UserID()] = true
			elseif (cameraPos:DistToSqr( talker:GetPos() ) > FayLib.IGC.GetKey(addonName, "PlayerVoiceDistance")) then
				playerTalkCheck[talker:UserID()] = false
			end
		end
	end
end)

--Prevent players from moving while in menu
hook_Add( "SetupMove", "FMainMenu_SM", function( ply, mv, cmd )
	if ply:GetNWBool("FMainMenu_InMenu",false) then
		cmd:ClearButtons()
		cmd:ClearMovement()
		mv:SetMaxClientSpeed( 0 )
		mv:SetMaxSpeed( 0 )
		mv:SetMoveAngles( Angle(0,0,0) )
		mv:SetVelocity( Vector(0,0,0) )
		mv:SetForwardSpeed( 0 )
		mv:SetSideSpeed( 0 )
		mv:SetUpSpeed( 0 )
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( 0 )
		cmd:SetUpMove( 0 )
		if mv:KeyDown(IN_JUMP) then
			local newbuttons = bit_band(mv:GetButtons(), bit_bnot(IN_JUMP))
			mv:SetButtons(newbuttons)
		end
	end
end )

-- Sandbox Hooks
hook_Add( "PlayerSpawnEffect", "FMainMenu_PlayerSpawnEffect", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "PlayerSpawnEffect") then
		return false
	end
end )

hook_Add( "PlayerSpawnNPC", "FMainMenu_PlayerSpawnNPC", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "PlayerSpawnNPC") then
		return false
	end
end )

hook_Add( "PlayerSpawnProp", "FMainMenu_PlayerSpawnProp", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "PlayerSpawnProp") then
		return false
	end
end )

hook_Add( "PlayerSpawnRagdoll", "FMainMenu_PlayerSpawnRagdoll", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "PlayerSpawnRagdoll") then
		return false
	end
end )

hook_Add( "PlayerSpawnSENT", "FMainMenu_PlayerSpawnSENT", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "PlayerSpawnSENT") then
		return false
	end
end )

hook_Add( "PlayerSpawnSWEP", "FMainMenu_PlayerSpawnSWEP", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "PlayerSpawnSWEP") then
		return false
	end
end )

hook_Add( "PlayerSpawnVehicle", "FMainMenu_PlayerSpawnVehicle", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "PlayerSpawnVehicle") then
		return false
	end
end )

hook_Add( "PlayerGiveSWEP", "FMainMenu_PlayerGiveSWEP", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "PlayerGiveSWEP") then
		return false
	end
end )

-- DarkRP Hooks
hook_Add( "canSleep", "FMainMenu_CanSleep", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end )

hook_Add( "canArrest", "FMainMenu_CanArrest", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) then
		return false
	end
end )

hook_Add( "canBuyAmmo", "FMainMenu_CanBuyAmmo", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanBuy") then
		return false
	end
end )

hook_Add( "canBuyCustomEntity", "FMainMenu_canBuyCustomEntity", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanBuy") then
		return false
	end
end )

hook_Add( "canBuyPistol", "FMainMenu_canBuyPistol", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanBuy") then
		return false
	end
end )

hook_Add( "canBuyShipment", "FMainMenu_canBuyShipment", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanBuy") then
		return false
	end
end )

hook_Add( "canBuyVehicle", "FMainMenu_canBuyVehicle", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanBuy") then
		return false
	end
end )

hook_Add( "canChatSound", "FMainMenu_canChatSound", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanChatSound") then
		return false
	end
end )

hook_Add( "canDarkRPUse", "FMainMenu_canDarkRPUse", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanUse") then
		return false
	end
end )

hook_Add( "canDropPocketItem", "FMainMenu_canDropPocketItem", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanUsePocket") then
		return false
	end
end )

hook_Add( "canPocket", "FMainMenu_canPocket", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanUsePocket") then
		return false
	end
end )

hook_Add( "canDropWeapon", "FMainMenu_canDropWeapon", function( ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanDropWeapon") then
		return false
	end
end )

hook_Add( "canRequestHit", "FMainMenu_canRequestHit", function( hitman, ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanReqHits") then
		return false
	end
end )

hook_Add( "canRequestWarrant", "FMainMenu_canRequestWarrant", function( target, ply )
	if ply:GetNWBool("FMainMenu_InMenu",false) && !FayLib.IGC.GetKey(addonName, "DarkRPCanReqWarrants") then
		return false
	end
end )

-- TTT Hooks
hook_Add( "TTTBeginRound", "FMainMenu_TTTBeginRound", function( )
	for _,ply in ipairs(player_GetHumans()) do
		if ply:GetNWBool("FMainMenu_InMenu",false) then
			net_Start("FMainMenu_CanEditMenu")
				net_WriteString( FMainMenu.GetPhrase("TTTRoundStarted") )
			net_Send(ply)
		end
	end
end )

--[[
	WORKAROUNDS
]]--

hook_Add( "loadCustomDarkRPItems", "FMainMenu_LCDRPI", function( ) --DarkRP Workarounds, but wait until GAMEMODE settings are all loaded
	if GAMEMODE.Config.babygod then -- Babygod Workaround
		GAMEMODE.Config.babygod = false -- disable default DarkRP implementation, so we can do our own
	end
end )

--[[
	CONFIGURATION
]]--
local playerTempConfigs = {}
local playerTempCams = {}

-- Will move temporary camera to new live preview location before moving players view to it
local function camUpdate(ply)
	if playerTempCams[ply:UserID()] != nil && playerTempCams[ply:UserID()]:IsValid() then
		playerTempCams[ply:UserID()]:Remove()
	end
	playerTempCams[ply:UserID()] = ents_Create("prop_dynamic")

	local innerCam = playerTempCams[ply:UserID()]
	innerCam:SetModel("models/brokenglass_piece.mdl")
	innerCam:SetRenderMode(RENDERMODE_TRANSCOLOR)
	innerCam:SetColor(camColor)
	innerCam:DrawShadow( false )

	local cameraPos = ""
	if playerTempConfigs[ply:UserID()]["_CameraPosition"][game_GetMap()] then
		cameraPos = playerTempConfigs[ply:UserID()]["_CameraPosition"][game_GetMap()] + Vector(0,0,64)
	else
		cameraPos = Vector(-1286.149658, 1187.535156, -11371.772461)
	end

	innerCam:SetPos( cameraPos )

	local cameraAng = ""

	if playerTempConfigs[ply:UserID()]["_CameraAngle"][game_GetMap()] then
		cameraAng = playerTempConfigs[ply:UserID()]["_CameraAngle"][game_GetMap()]
	else
		cameraAng = Angle(42.586422, -40.820980, 0.000000)
	end

	innerCam:SetAngles( cameraAng )
	innerCam:Spawn()
	innerCam:Activate()
	innerCam:SetMoveType(MOVETYPE_NONE)
	innerCam:SetSolid(SOLID_NONE)

	ply:SetViewEntity(innerCam)
end

-- can take colors that lost their userdata status during net message transmission and turn them back in a given table
local function fixTableColors(varTable)
	local keyList = table_GetKeys(varTable)
	for i = 1, #keyList do
		if type(varTable[keyList[i]]) == "table" then
			local innerTable = varTable[keyList[i]]
			local innerKeyList = table_GetKeys(innerTable)
			if #innerKeyList == 4 && innerTable.a != nil && innerTable.r != nil && innerTable.g != nil && innerTable.b != nil then
				varTable[keyList[i]] = Color(innerTable.r, innerTable.g, innerTable.b, innerTable.a)
			end
		end
	end
end

-- used to handle updates to menu camera position and angle for the live preview
local tVarUpdateHandler = {
	["CameraPosition"] = function(ply)
		camUpdate(ply)
	end,
	["CameraAngle"] = function(ply)
		camUpdate(ply)
	end,
}

-- If player has access to config, then instruct client editor to open
net_Receive( "FMainMenu_Config_OpenMenu", function( len, ply )
	CAMI.PlayerHasAccess(ply, "FMainMenu_CanEditMenu", function(hasPriv, reason)
		if hasPriv then
			playerTempConfigs[ply:UserID()] = table_Copy(FayLib["IGC"]["Config"]["Server"][addonName])

			-- don't allow to open if currently in main menu
			net_Start("FMainMenu_Config_OpenMenu")
				if ply:GetNWBool("FMainMenu_InMenu",false) then
					net_WriteBool(true)
				end
			net_Send(ply)

			-- change player camera to what main menu has set
			for _,updFunc in pairs(tVarUpdateHandler) do
				updFunc(ply)
			end

			-- Fix for HudPaint not getting called when camera is out
			if ply:GetActiveWeapon():GetClass() == "gmod_camera" then
				ply:StripWeapon( "gmod_camera" )
				ply.CamStripped = true
			end
		end
	end)
end)

-- If player has access to config, then send server-side variables they request
net_Receive( "FMainMenu_Config_ReqVar", function( len, ply )
	local variableNames = net_ReadTable()
	CAMI.PlayerHasAccess(ply, "FMainMenu_CanEditMenu", function(hasPriv, reason)
		if hasPriv then
			-- get all requested variables into a single table
			local sendTable = {}
			local counter = 1
			for _,varName in ipairs(variableNames) do
				if FayLib.IGC.GetKey(addonName, varName) == nil then return end
				sendTable[counter] = FayLib.IGC.GetKey(addonName, varName)
				counter = counter + 1
			end

			-- send var to player
			net_Start("FMainMenu_Config_ReqVar")
				net_WriteString(util_TableToJSON(sendTable))
			net_Send(ply)
		end
	end)
end)

net_Receive( "FMainMenu_Config_UpdateVar", function( len, ply )
	local variableNames = net_ReadTable()
	local receivedStr = net_ReadString()
	local varTable = util_JSONToTable( receivedStr )

	-- fix for "Colors will not have the color metatable" bug
	fixTableColors(varTable)

	-- If player has access to config, then save changes to config
	CAMI.PlayerHasAccess(ply, "FMainMenu_CanEditMenu", function(hasPriv, reason)
		if hasPriv then
			local counter = 1
			for _,varName in ipairs(variableNames) do
				if FayLib.IGC.GetKey(addonName, varName) == nil then return end
				FayLib.IGC.SetKey(addonName, varName, varTable[counter])
				counter = counter + 1
			end

			FayLib.IGC.SaveConfig(addonName, "config", "fmainmenu")
			FayLib.IGC.SyncShared(addonName)
		end
	end)
end)

-- If player has access to config, then adjust relative live-preview settings
net_Receive( "FMainMenu_Config_UpdateTempVariable", function(len, ply)
	CAMI.PlayerHasAccess(ply, "FMainMenu_CanEditMenu", function(hasPriv, reason)
		if hasPriv then
			local varNames = net_ReadTable()
			local varTable = util_JSONToTable(net_ReadString())

			-- fix for "Colors will not have the color metatable" bug
			fixTableColors(varTable)

			-- update temp variables as needed for player
			local counter = 1
			for _,varName in ipairs(varNames) do
				if playerTempConfigs[ply:UserID()]["_" .. varName] then
					playerTempConfigs[ply:UserID()]["_" .. varName] = varTable[counter]
					tVarUpdateHandler[varName](ply)
				end

				counter = counter + 1
			end
		end
	end)
end)

-- Remove player from live-preview when closing config editor
net_Receive( "FMainMenu_Config_CloseMenu", function( len, ply )
	playerTempConfigs[ply:UserID()] = nil
	ply:SetViewEntity(ply)

	-- If camera had to be stripped earlier, give it back
	if ply.CamStripped then
		ply:Give( "gmod_camera" )
	end
end)