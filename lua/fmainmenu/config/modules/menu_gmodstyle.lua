--[[

	GMOD STYLE POSITIONING IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 22
local configPropList = {"GarrysModStyle"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 1
FMainMenu.ConfigModules[propertyCode].category = 2
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesGMODStylePropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesGMODStylePropName"), FMainMenu.GetPhrase("ConfigPropertiesGMODStylePropDesc"))
	
	-- Hear Other Players Toggle
	mainPropPanel.toggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesGMODStyleLabel"), FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne"))
	mainPropPanel.toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo") )
	
	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	local serverVar = ""
	if parentPanel.lastRecVariable[1] then 
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne")
	else
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo")
	end
	
	if serverVar != parentPanel.toggleOption:GetText() then
		return true
	end
	
	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function() 
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne") then
		previewCopy["_"..configPropList[1]] = true
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo") then
		previewCopy["_"..configPropList[1]] = false
	end
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
		
	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne") then
		parentPanel.lastRecVariable[1] = true
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo") then
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
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne")) 
	else
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo"))
	end
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end