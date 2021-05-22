--[[

	LOGO IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 23
local configPropList = {"logoIsText","logoContent"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 1
FMainMenu.ConfigModules[propertyCode].category = 2
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesLogoPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesLogoPropName"), FMainMenu.GetPhrase("ConfigPropertiesLogoPropDesc"))
	
	-- logo type selection
	mainPropPanel.toggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesLogoLabel"), FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne"))
	mainPropPanel.toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo") )
	
	-- logo comment box
	mainPropPanel.contentBox = FMainMenu.ConfigModulePanels.createLabelBoxComboLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesLogoContentLabel"))
	
	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	local serverVar = ""
	if parentPanel.lastRecVariable[1] then 
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne")
	else
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo")
	end
	
	if serverVar != parentPanel.toggleOption:GetText() then
		return true
	end
	
	if parentPanel.lastRecVariable[2] != parentPanel.contentBox:GetText() then
		return true
	end
	
	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne") then
		previewCopy["_"..configPropList[1]] = true
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo") then
		previewCopy["_"..configPropList[1]] = false
	else
		return
	end
	
	previewCopy["_"..configPropList[2]] = parentPanel.contentBox:GetText()
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
		
	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne") then
		parentPanel.lastRecVariable[1] = true
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo") then
		parentPanel.lastRecVariable[1] = false
	else
		return
	end
	
	parentPanel.lastRecVariable[2] = parentPanel.contentBox:GetText()
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	if receivedVarTable[1] then 
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne")) 
	else
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo"))
	end
	
	parentPanel.contentBox:SetText(receivedVarTable[2])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end