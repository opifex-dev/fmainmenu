--[[

	LANGUAGE IGC MODULE

]]--

local FMainMenu = FMainMenu

-- localized global calls
local pairs = pairs

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 21
local configPropList = {"LangSetting"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 2
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesLanguagePropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesLanguagePropName"), FMainMenu.GetPhrase("ConfigPropertiesLanguagePropDesc"))

	-- Hear Other Players Toggle
	mainPropPanel.toggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesLanguageLabel"), "English")
	for _,v in pairs(FMainMenu.languageLookup) do
		if v != "English" then
			mainPropPanel.toggleOption:AddChoice( v )
		end
	end

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	local serverVar = ""
	if FMainMenu.languageLookup[parentPanel.lastRecVariable[1]] then
		serverVar = FMainMenu.languageLookup[parentPanel.lastRecVariable[1]]
	else
		serverVar = "English"
	end

	if serverVar != parentPanel.toggleOption:GetText() then
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

	if FMainMenu.languageReverseLookup[parentPanel.toggleOption:GetText()] == nil then return true end

	parentPanel.lastRecVariable[1] = FMainMenu.languageReverseLookup[parentPanel.toggleOption:GetText()]

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	parentPanel.toggleOption:SetValue(FMainMenu.languageLookup[parentPanel.lastRecVariable[1]])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end