--[[

	FIRST JOIN WELCOMER IGC MODULE

]]--

local FMainMenu = FMainMenu

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 27
local configPropList = {"firstJoinWelcome","firstJoinText","firstJoinURLText","firstJoinURL","firstJoinURLEnabled"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 2
FMainMenu.ConfigModules[propertyCode].category = 2
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesFJWelcomerPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesFJWelcomerPropName"), FMainMenu.GetPhrase("ConfigPropertiesFJWelcomerPropDesc"))

	-- welcomer toggle
	mainPropPanel.toggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesWelcomerTypeLabel"), FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	mainPropPanel.toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )

	-- welcome text
	mainPropPanel.FJTextBox = FMainMenu.ConfigModulePanels.createLabelBoxComboLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesWelcomerTextLabel"))

	-- Button Text
	mainPropPanel.FJURLTextBox = FMainMenu.ConfigModulePanels.createLabelBoxComboLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesWelcomerURLTextLabel"))

	-- url button toggle
	mainPropPanel.urlToggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesWelcomerURLButtonToggleLabel"), FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	mainPropPanel.urlToggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )

	-- Website Link
	mainPropPanel.FJURLBox, mainPropPanel.FJURLLabel = FMainMenu.ConfigModulePanels.createLabelBoxComboLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesWelcomerURLLabel"))
	mainPropPanel.FJURLLabel:SetVisible(false)
	mainPropPanel.FJURLBox:SetVisible(false)

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if parentPanel.urlToggleOption:GetText() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.FJURLLabel:SetVisible(true)
		parentPanel.FJURLBox:SetVisible(true)
	else
		parentPanel.FJURLLabel:SetVisible(false)
		parentPanel.FJURLBox:SetVisible(false)
	end

	local serverVar = ""
	if parentPanel.lastRecVariable[1] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	end

	if parentPanel.toggleOption:GetText() != serverVar then
		return true
	end

	if parentPanel.FJTextBox:GetText() != parentPanel.lastRecVariable[2] then
		return true
	end

	if parentPanel.FJURLTextBox:GetText() != parentPanel.lastRecVariable[3] then
		return true
	end

	if parentPanel.FJURLBox:GetText() != parentPanel.lastRecVariable[4] then
		return true
	end

	if parentPanel.lastRecVariable[5] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	end

	if parentPanel.urlToggleOption:GetText() != serverVar then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		previewCopy["_" .. configPropList[1]] = false
	else
		previewCopy["_" .. configPropList[1]] = true
	end

	previewCopy["_" .. configPropList[2]] = parentPanel.FJTextBox:GetText()

	previewCopy["_" .. configPropList[3]] = parentPanel.FJURLTextBox:GetText()

	previewCopy["_" .. configPropList[4]] = parentPanel.FJURLBox:GetText()

	if parentPanel.urlToggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		previewCopy["_" .. configPropList[5]] = false
	else
		previewCopy["_" .. configPropList[5]] = true
	end
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[1] = false
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[1] = true
	else
		return
	end

	parentPanel.lastRecVariable[2] = parentPanel.FJTextBox:GetText()

	parentPanel.lastRecVariable[3] = parentPanel.FJURLTextBox:GetText()

	parentPanel.lastRecVariable[4] = parentPanel.FJURLBox:GetText()

	if parentPanel.urlToggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[5] = false
	elseif parentPanel.urlToggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[5] = true
	else
		return
	end

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if receivedVarTable[1] == true then
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	else
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end

	parentPanel.FJTextBox:SetText(receivedVarTable[2])
	parentPanel.FJURLTextBox:SetText(receivedVarTable[3])
	parentPanel.FJURLBox:SetText(receivedVarTable[4])

	if receivedVarTable[5] == true then
		parentPanel.urlToggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
		parentPanel.FJURLLabel:SetVisible(true)
		parentPanel.FJURLBox:SetVisible(true)
	else
		parentPanel.urlToggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
		parentPanel.FJURLLabel:SetVisible(false)
		parentPanel.FJURLBox:SetVisible(false)
	end
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end