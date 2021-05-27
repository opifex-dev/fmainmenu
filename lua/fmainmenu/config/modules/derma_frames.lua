--[[

	FRAME DERMA STYLE IGC MODULE

]]--

local FMainMenu = FMainMenu

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 43
local configPropList = {"commonFrameColor","commonFrameBevelRadius"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 4
FMainMenu.ConfigModules[propertyCode].category = 4
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesFrameDermaPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesFrameDermaPropName"), FMainMenu.GetPhrase("ConfigPropertiesFrameDermaPropDesc"))

	--dialog frame bevel
	mainPropPanel.dermaFrameBevel = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesFrameDermaFrameBevel"), true)

	--dialog frame color
	mainPropPanel.dermaFrameColor = FMainMenu.ConfigModulePanels.createColorPicker(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesFrameDermaFrameColor"))

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if !FMainMenu.ConfigModulesHelper.areColorsEqual(parentPanel.lastRecVariable[1], parentPanel.dermaFrameColor:GetColor()) then
		return true
	end

	if parentPanel.lastRecVariable[2] != tonumber(parentPanel.dermaFrameBevel:GetText()) then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if tonumber(parentPanel.dermaFrameBevel:GetText()) == nil then return end

	previewCopy["_" .. configPropList[1]] = parentPanel.dermaFrameColor:GetColor()
	previewCopy["_" .. configPropList[2]] = tonumber(parentPanel.dermaFrameBevel:GetText())
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if tonumber(parentPanel.dermaFrameBevel:GetText()) == nil then return end

	parentPanel.lastRecVariable[1] = parentPanel.dermaFrameColor:GetColor()
	parentPanel.lastRecVariable[2] = tonumber(parentPanel.dermaFrameBevel:GetText())

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	parentPanel.dermaFrameColor:SetColor(receivedVarTable[1])
	parentPanel.dermaFrameBevel:SetText(receivedVarTable[2])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end