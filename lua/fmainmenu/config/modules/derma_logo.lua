--[[

	LOGO DERMA STYLE IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 41
local configPropList = {"textLogoColor","logoFont","logoFontSize","logoOutlineColor","logoOutlineThickness","logoShadow"}
local fontList = {
	"akbar",
	"coolvetica",
	"Roboto",
	"Marlett",
	"DermaLarge",
}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 1
FMainMenu.ConfigModules[propertyCode].category = 4
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesLogoDermaPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesLogoDermaPropName"), FMainMenu.GetPhrase("ConfigPropertiesLogoDermaPropDesc"))

	--logo text font
	mainPropPanel.logoFontOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaFont"), "Marlett")
	for _,font in ipairs(fontList) do
		if font != "Marlett" then
			mainPropPanel.logoFontOption:AddChoice(font)
		end
	end
	
	--logo text font size
	mainPropPanel.fontSize = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaFontSize"), true)
	
	--logo text font thickness
	mainPropPanel.fontThickness = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaOutlineThickness"), true)
	
	--logo text font shadow
	mainPropPanel.logoShadowOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaFontShadow"), FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	mainPropPanel.logoShadowOption:AddChoice(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	
	--logo text color
	mainPropPanel.logoColor = FMainMenu.ConfigModulePanels.createColorPicker(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaTextColor"))
	
	--logo text font outline color
	mainPropPanel.outlineColor = FMainMenu.ConfigModulePanels.createColorPicker(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaOutlineColor"))
	
	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	if !FMainMenu.ConfigModulesHelper.areColorsEqual(parentPanel.lastRecVariable[1], parentPanel.logoColor:GetColor()) then
		return true
	end
	
	if parentPanel.lastRecVariable[2] != parentPanel.logoFontOption:GetText() then 
		return true
	end
	
	if parentPanel.lastRecVariable[3] != tonumber(parentPanel.fontSize:GetText()) then 
		return true
	end
	
	if !FMainMenu.ConfigModulesHelper.areColorsEqual(parentPanel.lastRecVariable[4], parentPanel.outlineColor:GetColor()) then
		return true
	end
	
	if parentPanel.lastRecVariable[5] != tonumber(parentPanel.fontThickness:GetText()) then 
		return true
	end
	
	local serverVar = ""
	if parentPanel.lastRecVariable[6] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	end
	
	if parentPanel.logoShadowOption:GetText() != serverVar then
		return true
	end
	
	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if tonumber(parentPanel.fontSize:GetText()) == nil then return end
	if tonumber(parentPanel.fontThickness:GetText()) == nil then return end
	
	previewCopy["_"..configPropList[1]] = parentPanel.logoColor:GetColor()
	previewCopy["_"..configPropList[2]] = parentPanel.logoFontOption:GetText()
	previewCopy["_"..configPropList[3]] = tonumber(parentPanel.fontSize:GetText())
	previewCopy["_"..configPropList[4]] = parentPanel.outlineColor:GetColor()
	previewCopy["_"..configPropList[5]] = tonumber(parentPanel.fontThickness:GetText())
	
	if parentPanel.logoShadowOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		previewCopy["_"..configPropList[6]] = false
	else
		previewCopy["_"..configPropList[6]] = true
	end
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	if tonumber(parentPanel.fontSize:GetText()) == nil then return end
	if tonumber(parentPanel.fontThickness:GetText()) == nil then return end
	
	if parentPanel.logoShadowOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[6] = false
	elseif parentPanel.logoShadowOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[6] = true
	else
		return
	end
	
	parentPanel.lastRecVariable[1] = parentPanel.logoColor:GetColor()
	parentPanel.lastRecVariable[2] = parentPanel.logoFontOption:GetText()
	parentPanel.lastRecVariable[3] = tonumber(parentPanel.fontSize:GetText())
	parentPanel.lastRecVariable[4] = parentPanel.outlineColor:GetColor()
	parentPanel.lastRecVariable[5] = tonumber(parentPanel.fontThickness:GetText())
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	parentPanel.logoColor:SetColor(receivedVarTable[1])
	parentPanel.logoFontOption:SetValue(receivedVarTable[2])
	parentPanel.fontSize:SetText(receivedVarTable[3])
	parentPanel.outlineColor:SetColor(receivedVarTable[4])
	parentPanel.fontThickness:SetText(receivedVarTable[5])
	
	if receivedVarTable[6] == true then
		parentPanel.logoShadowOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	else
		parentPanel.logoShadowOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end