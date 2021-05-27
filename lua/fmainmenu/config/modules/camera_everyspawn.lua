--[[

	EVERY SPAWN IGC MODULE

]]--

local FMainMenu = FMainMenu

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 12
local configPropList = {"EverySpawn"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 1
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropName"), FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropDesc"))

	-- Every Spawn
	mainPropPanel.cameraEverySpawnOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesEverySpawnLabel"), FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne"))
	mainPropPanel.cameraEverySpawnOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo") )

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
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

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function() end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
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
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if receivedVarTable[1] then
		parentPanel.cameraEverySpawnOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne"))
	else
		parentPanel.cameraEverySpawnOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo"))
	end
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end