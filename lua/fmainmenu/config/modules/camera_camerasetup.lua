--[[

	CAMERA SETUP IGC MODULE

]]--

local FMainMenu = FMainMenu
local LocalPlayer = LocalPlayer
local math_Round = math.Round
local game_GetMap = game.GetMap
local table_Copy = table.Copy
local tonumber = tonumber
local Vector = Vector
local Angle = Angle
local net_Start = net.Start
local net_WriteTable = net.WriteTable
local net_WriteString = net.WriteString
local util_TableToJSON = util.TableToJSON
local net_SendToServer = CLIENT and net.SendToServer

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 11
local configPropList = {"CameraPosition","CameraAngle"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 1
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPropName"), FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPropDesc"))

	-- Position
	FMainMenu.ConfigModulePanels.createLabel(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPosLabel"))
	mainPropPanel.cameraPositionPosBoxX = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueX"), false)
	mainPropPanel.cameraPositionPosBoxY = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueY"), false)
	mainPropPanel.cameraPositionPosBoxZ = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueZ"), false)

	-- Orientation
	FMainMenu.ConfigModulePanels.createLabel(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesCameraSetupAngLabel"))
	mainPropPanel.cameraPositionRotBoxX = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueX"), false)
	mainPropPanel.cameraPositionRotBoxY = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueY"), false)
	mainPropPanel.cameraPositionRotBoxZ = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueZ"), false)

	-- Helpful button to substitute current player coordinates

	local cameraPositionChooseButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesCameraSetupCaptureLabel"))
	cameraPositionChooseButton.DoClick = function(button)
		local ply = LocalPlayer()
		local plyPOS = ply:GetPos()
		local plyANG = ply:EyeAngles()

		mainPropPanel.cameraPositionPosBoxX:SetText(math_Round( plyPOS.x, 3))
		mainPropPanel.cameraPositionPosBoxY:SetText(math_Round( plyPOS.y, 3))
		mainPropPanel.cameraPositionPosBoxZ:SetText(math_Round( plyPOS.z, 3))

		mainPropPanel.cameraPositionRotBoxX:SetText(math_Round( plyANG.x, 3))
		mainPropPanel.cameraPositionRotBoxY:SetText(math_Round( plyANG.y, 3))
		mainPropPanel.cameraPositionRotBoxZ:SetText(math_Round( plyANG.z, 3))

		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
		FMainMenu.ConfigModules[propertyCode].updatePreview()

		LocalPlayer():SetNoDraw( true )
	end

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local mapName = game_GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	LocalPlayer():SetNoDraw( false )

	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionPosBoxX:GetText(), parentPanel.lastRecVariable[1][mapName].x, 3) then
		return true
	end

	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionPosBoxY:GetText(), parentPanel.lastRecVariable[1][mapName].y, 3) then
		return true
	end

	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionPosBoxZ:GetText(), parentPanel.lastRecVariable[1][mapName].z, 3) then
		return true
	end

	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionRotBoxX:GetText(), parentPanel.lastRecVariable[2][mapName].x, 3) then
		return true
	end

	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionRotBoxY:GetText(), parentPanel.lastRecVariable[2][mapName].y, 3) then
		return true
	end

	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionRotBoxZ:GetText(), parentPanel.lastRecVariable[2][mapName].z, 3) then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local mapName = game_GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local varUpdate = table_Copy(parentPanel.lastRecVariable)

	if tonumber(parentPanel.cameraPositionPosBoxX:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionPosBoxY:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionPosBoxZ:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionRotBoxX:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionRotBoxY:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionRotBoxZ:GetText()) == nil then return end

	varUpdate[1][mapName] = Vector(tonumber(parentPanel.cameraPositionPosBoxX:GetText()), tonumber(parentPanel.cameraPositionPosBoxY:GetText()), tonumber(parentPanel.cameraPositionPosBoxZ:GetText()))
	varUpdate[2][mapName] = Angle(tonumber(parentPanel.cameraPositionRotBoxX:GetText()), tonumber(parentPanel.cameraPositionRotBoxY:GetText()), tonumber(parentPanel.cameraPositionRotBoxZ:GetText()))

	net_Start("FMainMenu_Config_UpdateTempVariable")
		net_WriteTable(configPropList)
		net_WriteString(util_TableToJSON(varUpdate))
	net_SendToServer()
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local mapName = game_GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if tonumber(parentPanel.cameraPositionPosBoxX:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionPosBoxY:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionPosBoxZ:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionRotBoxX:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionRotBoxY:GetText()) == nil then return end
	if tonumber(parentPanel.cameraPositionRotBoxZ:GetText()) == nil then return end

	parentPanel.lastRecVariable[1][mapName] = Vector(tonumber(parentPanel.cameraPositionPosBoxX:GetText()), tonumber(parentPanel.cameraPositionPosBoxY:GetText()), tonumber(parentPanel.cameraPositionPosBoxZ:GetText()))
	parentPanel.lastRecVariable[2][mapName] = Angle(tonumber(parentPanel.cameraPositionRotBoxX:GetText()), tonumber(parentPanel.cameraPositionRotBoxY:GetText()), tonumber(parentPanel.cameraPositionRotBoxZ:GetText()))

	LocalPlayer():SetNoDraw( false )

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local mapName = game_GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	FMainMenu.ConfigPreview.previewCopy["_CameraPosition"] = receivedVarTable[1]
	FMainMenu.ConfigPreview.previewCopy["_CameraAngle"] = receivedVarTable[2]

	parentPanel.cameraPositionPosBoxX:SetText(math_Round( receivedVarTable[1][mapName].x, 3))
	parentPanel.cameraPositionPosBoxY:SetText(math_Round( receivedVarTable[1][mapName].y, 3))
	parentPanel.cameraPositionPosBoxZ:SetText(math_Round( receivedVarTable[1][mapName].z, 3))
	parentPanel.cameraPositionRotBoxX:SetText(math_Round( receivedVarTable[2][mapName].x, 3))
	parentPanel.cameraPositionRotBoxY:SetText(math_Round( receivedVarTable[2][mapName].y, 3))
	parentPanel.cameraPositionRotBoxZ:SetText(math_Round( receivedVarTable[2][mapName].z, 3))
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	LocalPlayer():SetNoDraw( false )

	return configPropList
end