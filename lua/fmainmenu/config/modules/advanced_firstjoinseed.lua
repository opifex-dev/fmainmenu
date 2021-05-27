--[[

	FIRST JOIN SEED BUTTON IGC MODULE

]]--

local FMainMenu = FMainMenu

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 62
local configPropList = {"firstJoinSeed"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 6
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesConfigFirstJoinSeedPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesConfigFirstJoinSeedPropName"), FMainMenu.GetPhrase("ConfigPropertiesConfigFirstJoinSeedPropDesc"))

	-- First Join Seed
	mainPropPanel.joinSeedBox = FMainMenu.ConfigModulePanels.createLabelBoxComboLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigFirstJoinSeedBoxLabel"))

	-- Provides ability for player to get detailed info on the first join seed
	FMainMenu.ConfigModulePanels.createLabelLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesFirstJoinSeedInfoLabel"))
	local informationButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesAdvancedGeneralInfoButtonLabel"))
	informationButton.DoClick = function(button)
		FMainMenu.ConfigModulesHelper.doInformationalWindow(FMainMenu.GetPhrase("ConfigPropertiesFirstJoinSeedInfoWindowTitle"), FMainMenu.GetPhrase("ConfigPropertiesFirstJoinSeedInfo"))
	end

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if parentPanel.joinSeedBox:GetText() != parentPanel.lastRecVariable[1] then
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

	parentPanel.lastRecVariable[1] = parentPanel.joinSeedBox:GetText()

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	parentPanel.joinSeedBox:SetText(receivedVarTable[1])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end