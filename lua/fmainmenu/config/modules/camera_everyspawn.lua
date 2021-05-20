--[[

	EVERY SPAWN IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 12
local configPropList = {"EverySpawn"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 1
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropName"), FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropDesc"))
	
	-- Every Spawn
	mainPropPanel.cameraEverySpawnOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesEverySpawnLabel"), FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne"))
	mainPropPanel.cameraEverySpawnOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo") )
	
	return {configPropList, mainPropPanel}
end

FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	local serverVar = ""
	if parentPanel.lastRecVariable[1] then 
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne")
	else
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo")
	end
	
	if parentPanel.cameraEverySpawnOption:GetValue() != serverVar then
		return true
	end
	
	return false
end

FMainMenu.ConfigModules[propertyCode].updatePreview = function() end

FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
		
	if parentPanel.cameraEverySpawnOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne") then
		parentPanel.lastRecVariable[1] = true
	elseif parentPanel.cameraEverySpawnOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo") then
		parentPanel.lastRecVariable[1] = false
	else
		return
	end
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
	FMainMenu.ConfigModulesHelper.setUnsaved(false)
end

FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	parentPanel.lastRecVariable = table.Copy(receivedVarTable)
	
	if receivedVarTable[1] then 
		parentPanel.cameraEverySpawnOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne")) 
	else
		parentPanel.cameraEverySpawnOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo"))
	end
	
	FMainMenu.ConfigModulesHelper.setUnsaved(false)
	FMainMenu.ConfigModules[propertyCode].updatePreview()
end

FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	FMainMenu.ConfigModulesHelper.requestVariables(configPropList)
end