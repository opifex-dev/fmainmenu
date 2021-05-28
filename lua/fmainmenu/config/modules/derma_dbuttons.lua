--[[

	DERMA BUTTON STYLE IGC MODULE

]]--

local FMainMenu = FMainMenu

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 45
local configPropList = {"commonButtonColor"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 4
FMainMenu.ConfigModules[propertyCode].category = 4
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesButtonDermaPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesButtonDermaPropName"), FMainMenu.GetPhrase("ConfigPropertiesButtonDermaPropDesc"))

	--dialog button color
	mainPropPanel.dermaButtonColor = FMainMenu.ConfigModulePanels.createColorPicker(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesButtonDermaButtonColor"))

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if !FMainMenu.ConfigModulesHelper.areColorsEqual(parentPanel.lastRecVariable[1], parentPanel.dermaButtonColor:GetColor()) then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	previewCopy["_" .. configPropList[1]] = parentPanel.dermaButtonColor:GetColor()
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	parentPanel.lastRecVariable[1] = parentPanel.dermaButtonColor:GetColor()

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	parentPanel.dermaButtonColor:SetColor(receivedVarTable[1])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end