--[[

	ADVANCED SPAWN IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 13
local configPropList = {"AdvancedSpawn","AdvancedSpawnPos"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 1
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnPropName"), FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnPropDesc"))
	
	-- Advanced Spawn Toggle
	mainPropPanel.advancedSpawnOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesEverySpawnLabel"), FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	mainPropPanel.advancedSpawnOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
	
	--Advanced Spawn Position
	FMainMenu.ConfigModulePanels.createLabel(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnPosLabel"))
	mainPropPanel.cameraPositionPosBoxX = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueX"), false)
	mainPropPanel.cameraPositionPosBoxY = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueY"), false)
	mainPropPanel.cameraPositionPosBoxZ = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigCommonValueZ"), false)
	
	-- Helpful function to autofill player's current position
	local cameraPositionChooseButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnCaptureLabel"))
	cameraPositionChooseButton.DoClick = function(button)
		local ply = LocalPlayer()
		local plyPOS = ply:GetPos()
		
		mainPropPanel.cameraPositionPosBoxX:SetText(math.Round( plyPOS.x, 3))
		mainPropPanel.cameraPositionPosBoxY:SetText(math.Round( plyPOS.y, 3))
		mainPropPanel.cameraPositionPosBoxZ:SetText(math.Round( plyPOS.z, 3))
		
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
		FMainMenu.ConfigModules[propertyCode].updatePreview()
	end
	
	return {configPropList, mainPropPanel}
end

FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local mapName = game.GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	local serverVar = ""
	if parentPanel.lastRecVariable[1] then 
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	end
	
	if parentPanel.advancedSpawnOption:GetValue() != serverVar then
		return true
	end
	
	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionPosBoxX:GetText(), parentPanel.lastRecVariable[2][mapName].x, 3) then
		return true
	end
	
	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionPosBoxY:GetText(), parentPanel.lastRecVariable[2][mapName].y, 3) then
		return true
	end
	
	if FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges(parentPanel.cameraPositionPosBoxZ:GetText(), parentPanel.lastRecVariable[2][mapName].z, 3) then
		return true
	end
	
	return false
end

FMainMenu.ConfigModules[propertyCode].updatePreview = function() end

FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local mapName = game.GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
		
	if(tonumber(parentPanel.cameraPositionPosBoxX:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionPosBoxY:GetText()) == nil) then return end
	if(tonumber(parentPanel.cameraPositionPosBoxZ:GetText()) == nil) then return end
	
	if parentPanel.advancedSpawnOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[1] = true
	elseif parentPanel.advancedSpawnOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[1] = false
	else
		return
	end

	parentPanel.lastRecVariable[2][mapName] = Vector(tonumber(parentPanel.cameraPositionPosBoxX:GetText()), tonumber(parentPanel.cameraPositionPosBoxY:GetText()), tonumber(parentPanel.cameraPositionPosBoxZ:GetText()))
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
	FMainMenu.ConfigModulesHelper.setUnsaved(false)
end

FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local mapName = game.GetMap()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	parentPanel.lastRecVariable = table.Copy(receivedVarTable)
	
	if receivedVarTable[1] then 
		parentPanel.advancedSpawnOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled")) 
	else
		parentPanel.advancedSpawnOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end
	parentPanel.cameraPositionPosBoxX:SetText(math.Round( receivedVarTable[2][mapName].x, 3))
	parentPanel.cameraPositionPosBoxY:SetText(math.Round( receivedVarTable[2][mapName].y, 3))
	parentPanel.cameraPositionPosBoxZ:SetText(math.Round( receivedVarTable[2][mapName].z, 3))
	
	FMainMenu.ConfigModulesHelper.setUnsaved(false)
	FMainMenu.ConfigModules[propertyCode].updatePreview()
end

FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	FMainMenu.ConfigModulesHelper.requestVariables(configPropList)
end