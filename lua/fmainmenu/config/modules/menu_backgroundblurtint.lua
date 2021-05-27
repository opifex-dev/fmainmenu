--[[

	BACKGROUND EFFECTS IGC MODULE

]]--

local FMainMenu = FMainMenu
local tonumber = tonumber
local Color = Color

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 24
local configPropList = {"BackgroundBlurAmount","BackgroundColorTint"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 1
FMainMenu.ConfigModules[propertyCode].category = 2
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesBackgroundPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesBackgroundPropName"), FMainMenu.GetPhrase("ConfigPropertiesBackgroundPropDesc"))

	-- blur amount
	mainPropPanel.blurBox = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesBackgroundBlurLabel"), true)

	-- tint color
	mainPropPanel.tintBox = FMainMenu.ConfigModulePanels.createColorPicker(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesBackgroundTintLabel"))

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if parentPanel.lastRecVariable[1] != tonumber(parentPanel.blurBox:GetText()) then
		return true
	end

	if !FMainMenu.ConfigModulesHelper.areColorsEqual(parentPanel.lastRecVariable[2], parentPanel.tintBox:GetColor()) then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if tonumber(parentPanel.blurBox:GetText()) == nil then return end

	previewCopy["_" .. configPropList[1]] = tonumber(parentPanel.blurBox:GetText())
	previewCopy["_" .. configPropList[2]] = parentPanel.tintBox:GetColor()
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if tonumber(parentPanel.blurBox:GetText()) == nil then return end

	parentPanel.lastRecVariable[1] = tonumber(parentPanel.blurBox:GetText())
	parentPanel.lastRecVariable[2] = parentPanel.tintBox:GetColor()

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	parentPanel.blurBox:SetText(receivedVarTable[1])
	parentPanel.tintBox:SetColor(Color(receivedVarTable[2].r, receivedVarTable[2].g, receivedVarTable[2].b, receivedVarTable[2].a))
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end