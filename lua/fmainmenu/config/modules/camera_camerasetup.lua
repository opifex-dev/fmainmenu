--[[

	CAMERA SETUP IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 11
local configPropList = {"CameraPosition","CameraAngle"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 1
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

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
		
		mainPropPanel.cameraPositionPosBoxX:SetText(math.Round( plyPOS.x, 3))
		mainPropPanel.cameraPositionPosBoxY:SetText(math.Round( plyPOS.y, 3))
		mainPropPanel.cameraPositionPosBoxZ:SetText(math.Round( plyPOS.z, 3))
		
		mainPropPanel.cameraPositionRotBoxX:SetText(math.Round( plyANG.x, 3))
		mainPropPanel.cameraPositionRotBoxY:SetText(math.Round( plyANG.y, 3))
		mainPropPanel.cameraPositionRotBoxZ:SetText(math.Round( plyANG.z, 3))
		
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
		FMainMenu.ConfigModules[propertyCode].updatePreview()
		
		LocalPlayer():SetNoDraw( true )
	end
	
	return {configPropList, mainPropPanel}
end

FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local mapName = game.GetMap()
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

FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local mapName = game.GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local varUpdate = table.Copy(parentPanel.lastRecVariable)
	
	if(tonumber(parentPanel.cameraPositionPosBoxX:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionPosBoxY:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionPosBoxZ:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionRotBoxX:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionRotBoxY:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionRotBoxZ:GetText()) == nil) then return end

	varUpdate[1][mapName] = Vector(tonumber(parentPanel.cameraPositionPosBoxX:GetText()), tonumber(parentPanel.cameraPositionPosBoxY:GetText()), tonumber(parentPanel.cameraPositionPosBoxZ:GetText()))
	varUpdate[2][mapName] = Angle(tonumber(parentPanel.cameraPositionRotBoxX:GetText()), tonumber(parentPanel.cameraPositionRotBoxY:GetText()), tonumber(parentPanel.cameraPositionRotBoxZ:GetText()))
	
	net.Start("FMainMenu_Config_UpdateTempVariable")
		net.WriteTable(configPropList)
		net.WriteString(util.TableToJSON(varUpdate))
	net.SendToServer()
end

FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local mapName = game.GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
		
	if(tonumber(parentPanel.cameraPositionPosBoxX:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionPosBoxY:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionPosBoxZ:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionRotBoxX:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionRotBoxY:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionRotBoxZ:GetText()) == nil) then return end

	parentPanel.lastRecVariable[1][mapName] = Vector(tonumber(parentPanel.cameraPositionPosBoxX:GetText()), tonumber(parentPanel.cameraPositionPosBoxY:GetText()), tonumber(parentPanel.cameraPositionPosBoxZ:GetText()))
	parentPanel.lastRecVariable[2][mapName] = Angle(tonumber(parentPanel.cameraPositionRotBoxX:GetText()), tonumber(parentPanel.cameraPositionRotBoxY:GetText()), tonumber(parentPanel.cameraPositionRotBoxZ:GetText()))
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
	FMainMenu.ConfigModulesHelper.setUnsaved(false)
	LocalPlayer():SetNoDraw( false )
end

FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local mapName = game.GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	parentPanel.lastRecVariable = table.Copy(receivedVarTable)
	
	parentPanel.cameraPositionPosBoxX:SetText(math.Round( receivedVarTable[1][mapName].x, 3))
	parentPanel.cameraPositionPosBoxY:SetText(math.Round( receivedVarTable[1][mapName].y, 3))
	parentPanel.cameraPositionPosBoxZ:SetText(math.Round( receivedVarTable[1][mapName].z, 3))
	parentPanel.cameraPositionRotBoxX:SetText(math.Round( receivedVarTable[2][mapName].x, 3))
	parentPanel.cameraPositionRotBoxY:SetText(math.Round( receivedVarTable[2][mapName].y, 3))
	parentPanel.cameraPositionRotBoxZ:SetText(math.Round( receivedVarTable[2][mapName].z, 3))
	
	FMainMenu.ConfigModulesHelper.setUnsaved(false)
	FMainMenu.ConfigModules[propertyCode].updatePreview()
end

FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	FMainMenu.ConfigModulesHelper.requestVariables(configPropList)
	LocalPlayer():SetNoDraw( false )
end