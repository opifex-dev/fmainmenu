--[[

	CHANGELOG IGC MODULE

]]--

local FMainMenu = FMainMenu

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 25
local configPropList = {"showChangeLog","changeLogMoveToBottom","changeLogText"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 1
FMainMenu.ConfigModules[propertyCode].category = 2
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesChangelogPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesChangelogPropName"), FMainMenu.GetPhrase("ConfigPropertiesChangelogPropDesc"))

	-- changelog toggle
	mainPropPanel.toggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesChangelogToggleLabel"), FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	mainPropPanel.toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )

	-- bottom margin toggle
	mainPropPanel.marginOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesChangelogMarginLabel"), FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne"))
	mainPropPanel.marginOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo") )

	-- Changelog Text
	mainPropPanel.textBox = FMainMenu.ConfigModulePanels.createLabelBoxComboMassive(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesChangelogTextLabel"))

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	local serverVar = ""
	if parentPanel.lastRecVariable[1] then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	end

	if parentPanel.toggleOption:GetText() != serverVar then
		return true
	end

	if parentPanel.lastRecVariable[2] then
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo")
	else
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne")
	end

	if parentPanel.marginOption:GetText() != serverVar then
		return true
	end

	if parentPanel.textBox:GetText() != parentPanel.lastRecVariable[3] then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		previewCopy["_" .. configPropList[1]] = true
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		previewCopy["_" .. configPropList[1]] = false
	else
		return
	end

	if parentPanel.marginOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo") then
		previewCopy["_" .. configPropList[2]] = true
	elseif parentPanel.marginOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne") then
		previewCopy["_" .. configPropList[2]] = false
	else
		return
	end

	previewCopy["_" .. configPropList[3]] = parentPanel.textBox:GetText()
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[1] = true
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[1] = false
	else
		return
	end

	if parentPanel.marginOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo") then
		parentPanel.lastRecVariable[2] = true
	elseif parentPanel.marginOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne") then
		parentPanel.lastRecVariable[2] = false
	else
		return
	end

	parentPanel.lastRecVariable[3] = parentPanel.textBox:GetText()

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if receivedVarTable[1] then
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	else
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end

	if receivedVarTable[2] then
		parentPanel.marginOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo"))
	else
		parentPanel.marginOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne"))
	end

	parentPanel.textBox:SetText(receivedVarTable[3])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end