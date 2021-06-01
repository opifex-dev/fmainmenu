--[[

	CONFIG BASE ACCESS GROUP IGC MODULE

]]--

local FMainMenu = FMainMenu

-- localized global calls
surface_PlaySound = surface.PlaySound

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 51
local configPropList = {"configCanEdit","adminModPref"}
local allAM = {}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 5
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesConfigAccessPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesConfigAccessPropName"), FMainMenu.GetPhrase("ConfigPropertiesConfigAccessPropDesc"))

	-- config access preferred admin mod toggle
	mainPropPanel.AMToggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessAMToggleLabel"), "gmod")
	allAM = FayLib.Perms.getAvailableAdminMods()
	for _,adminMod in ipairs(allAM) do
		if adminMod != "gmod" then
			mainPropPanel.AMToggleOption:AddChoice( adminMod )
		end
	end

	-- Config Access Group Toggle, applicable only if using gmod built-in admin system
	mainPropPanel.toggleOption, mainPropPanel.toggleLabel = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessToggleLabel"), "superadmin")
	mainPropPanel.toggleOption:AddChoice( "admin" )
	mainPropPanel.toggleOption:AddChoice( "user" )
	mainPropPanel.tempYPos = mainPropPanel.tempYPos - 18

	mainPropPanel.ULXControlLabel = FMainMenu.ConfigModulePanels.createLabelLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessNoteControlULX"))
	mainPropPanel.ULXControlLabel:SetVisible(false)
	mainPropPanel.tempYPos = mainPropPanel.tempYPos - 33

	mainPropPanel.FAdminControlLabel = FMainMenu.ConfigModulePanels.createLabelLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesConfigAccessNoteControlFAdmin"))
	mainPropPanel.FAdminControlLabel:SetVisible(false)

	FMainMenu.ConfigModulePanels.createLabel(mainPropPanel, "")

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

	if parentPanel.toggleOption:GetText() != parentPanel.lastRecVariable[1] then
		return true
	end

	if parentPanel.AMToggleOption:GetText() != parentPanel.lastRecVariable[2] then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if parentPanel.AMToggleOption:GetText() == "gmod" then
		parentPanel.toggleOption:SetVisible(true)
		parentPanel.toggleLabel:SetVisible(true)
		parentPanel.ULXControlLabel:SetVisible(false)
		parentPanel.FAdminControlLabel:SetVisible(false)
	elseif parentPanel.AMToggleOption:GetText() == "ulx" then
		parentPanel.toggleOption:SetVisible(false)
		parentPanel.toggleLabel:SetVisible(false)
		parentPanel.ULXControlLabel:SetVisible(true)
		parentPanel.FAdminControlLabel:SetVisible(false)
	elseif parentPanel.AMToggleOption:GetText() == "fadmin" then
		parentPanel.toggleOption:SetVisible(false)
		parentPanel.toggleLabel:SetVisible(false)
		parentPanel.ULXControlLabel:SetVisible(false)
		parentPanel.FAdminControlLabel:SetVisible(true)
	end
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function()
	FMainMenu.ConfigModulesHelper.closeOpenExtraWindows()
end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if parentPanel.AMToggleOption:GetValue() != "gmod" then
		parentPanel.toggleOption:SetValue("superadmin")
	end

	parentPanel.lastRecVariable[1] = parentPanel.toggleOption:GetValue()
	parentPanel.lastRecVariable[2] = parentPanel.AMToggleOption:GetValue()

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	parentPanel.toggleOption:SetValue(receivedVarTable[1])
	parentPanel.AMToggleOption:SetValue(receivedVarTable[2])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end