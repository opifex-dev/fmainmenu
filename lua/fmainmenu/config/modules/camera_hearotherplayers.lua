--[[

	HEAR OTHER PLAYERS IGC MODULE

]]--

local ents_CreateClientProp = CLIENT and ents.CreateClientProp
local Color = Color
local FMainMenu = FMainMenu
local Angle = Angle
local tonumber = tonumber
local math_sqrt = math.sqrt
local game_GetMap = game.GetMap
local Vector = Vector

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 14
local configPropList = {"HearOtherPlayers","PlayerVoiceDistance", "CameraPosition"}
local topHalfSphere = nil
local bottomHalfSphere = nil

-- Live Preview Sphere
local function createSphereHalf()
	local sphereHalf = ents_CreateClientProp("models/props_phx/construct/wood/wood_dome360.mdl")
	sphereHalf:SetMaterial("models/debug/debugwhite")
	sphereHalf:SetColor(Color(0, 255, 0, 155))
	sphereHalf:GetPhysicsObject():EnableMotion( false )
	sphereHalf:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	sphereHalf:DrawShadow( false )
	sphereHalf:SetRenderMode( RENDERMODE_TRANSCOLOR )
	sphereHalf:DestroyShadow()

	return sphereHalf
end

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 1
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersPropName"), FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersPropDesc"))

	-- Hear Other Players Toggle
	mainPropPanel.toggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersLabel"), FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	mainPropPanel.toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )

	-- Maximum Voice Distance
	mainPropPanel.distanceBox = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersDistanceLabel"), true)

	-- Sphere setup
	topHalfSphere = createSphereHalf()
	topHalfSphere:SetAngles( Angle(0, 0, 180) )
	bottomHalfSphere = createSphereHalf()

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	local serverVar = ""
	if parentPanel.lastRecVariable[1] then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	end

	if parentPanel.toggleOption:GetText() != serverVar then
		return true
	end

	if tonumber(parentPanel.distanceBox:GetText()) == nil || tonumber(parentPanel.distanceBox:GetText()) != math_sqrt(parentPanel.lastRecVariable[2]) then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if tonumber(parentPanel.distanceBox:GetText()) == nil then return end

	if parentPanel.toggleOption:GetText() != FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		topHalfSphere:SetModelScale( 0 )
		bottomHalfSphere:SetModelScale( 0 )
		return
	end
	local boxText = parentPanel.distanceBox:GetText()

	topHalfSphere:SetModelScale( boxText / 96 )
	bottomHalfSphere:SetModelScale( boxText / 96 )
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function()
	topHalfSphere:Remove()
	bottomHalfSphere:Remove()
end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if tonumber(parentPanel.distanceBox:GetText()) == nil then return end

	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[1] = true
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[1] = false
	else
		return
	end

	local newPHDist = tonumber(parentPanel.distanceBox:GetText())
	parentPanel.lastRecVariable[2] = newPHDist * newPHDist

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, {"HearOtherPlayers","PlayerVoiceDistance"})
	parentPanel.lastRecVariable[2] = newPHDist
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local mapName = game_GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if receivedVarTable[1] then
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	else
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end
	parentPanel.distanceBox:SetText(math_sqrt(receivedVarTable[2]))
	topHalfSphere:SetPos(receivedVarTable[3][mapName] + Vector(0,0,64.5))
	bottomHalfSphere:SetPos(receivedVarTable[3][mapName] + Vector(0,0,63.5))
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end