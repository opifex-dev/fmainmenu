--[[

	CONFIG BASE ACCESS GROUP IGC MODULE

]]--

local FMainMenu = FMainMenu

-- localized global calls
surface_PlaySound = surface.PlaySound

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 51
local configPropList = {"configCanEdit"}

local function isUsingCustomAdminSystem()
	return ulx || FAdmin
end

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 5
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesConfigAccessPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesConfigAccessPropName"), FMainMenu.GetPhrase("ConfigPropertiesConfigAccessPropDesc"))

	-- Config Access Group Toggle, applicable only if using gmod built-in admin system
	if !isUsingCustomAdminSystem() then
		mainPropPanel.toggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessToggleLabel"), "superadmin")
		mainPropPanel.toggleOption:AddChoice( "admin" )
		mainPropPanel.toggleOption:AddChoice( "user" )
	elseif ulx != nil then
		FMainMenu.ConfigModulePanels.createLabelLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessNoteControlULX"))
		FMainMenu.ConfigModulePanels.createLabel(mainPropPanel, "")
	elseif FAdmin != nil then
		FMainMenu.ConfigModulePanels.createLabelLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessNoteControlFAdmin"))
		FMainMenu.ConfigModulePanels.createLabel(mainPropPanel, "")
	end

	-- Note about Admin System functionality
	FMainMenu.ConfigModulePanels.createLabelLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessNoteLabel"))
	local informationButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessNoteButtonLabel"))
	informationButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		FMainMenu.ConfigModulesHelper.doInformationalWindow(FMainMenu.GetPhrase("ConfigPropertiesConfigAccessNoteWindowText"), FMainMenu.GetPhrase("ConfigPropertiesConfigAccessNoteText"))
	end

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if !isUsingCustomAdminSystem() && parentPanel.toggleOption:GetText() != parentPanel.lastRecVariable[1] then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function() end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function()
	FMainMenu.ConfigModulesHelper.closeOpenExtraWindows()
end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if !isUsingCustomAdminSystem() then
		parentPanel.lastRecVariable[1] = parentPanel.toggleOption:GetValue()
	end

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if !isUsingCustomAdminSystem() then
		parentPanel.toggleOption:SetValue(receivedVarTable[1])
	end
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end