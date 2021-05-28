--[[

	TEXT BUTTON STYLE IGC MODULE

]]--

local FMainMenu = FMainMenu

-- localized global calls
local ipairs = ipairs
local string_find = string.find
local string_Replace = string.Replace
local tonumber = tonumber
local surface_PlaySound = surface_PlaySound

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 42
local configPropList = {"textButtonColor","textButtonOutlineColor","textButtonOutlineThickness","textButtonShadow","textButtonFont","textButtonFontSize","textButtonHoverColor","textButtonHoverSound","textButtonClickSound"}

-- fix for sound/ needing to be removed for surface.PlaySound
local function soundFix(curSound, contentBox)
	local listOfSlashes = {"sound/", "sound\\", "sound\\\\"}
	for _,slashPossible in ipairs(listOfSlashes) do
		if string_find(curSound, slashPossible) != nil then
			contentBox:SetText(string_Replace(curSound, slashPossible, ""))
		end
	end
end

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 1
FMainMenu.ConfigModules[propertyCode].category = 4
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesTextButtonDermaPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesTextButtonDermaPropName"), FMainMenu.GetPhrase("ConfigPropertiesTextButtonDermaPropDesc"))

	--text button font
	mainPropPanel.textFontOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaFont"), "DermaLarge")
	for _,font in ipairs(FMainMenu.ConfigModulesHelper.getAvailableFonts()) do
		if font != "DermaLarge" then
			mainPropPanel.textFontOption:AddChoice(font)
		end
	end

	--text button font size
	mainPropPanel.textFontSize = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaFontSize"), true)

	--text button outline thickness
	mainPropPanel.textOutlineThickness = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaOutlineThickness"), true)

	--text button shadow
	mainPropPanel.textShadowOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaFontShadow"), FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	mainPropPanel.textShadowOption:AddChoice(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))

	--text button hover sound
	mainPropPanel.textHoverSound, mainPropPanel.contentLabel = FMainMenu.ConfigModulePanels.createLabelBoxComboLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesTextButtonDermaHoverSound"))

	--sound selection button
	local hoverSoundChooseButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMusicButtonLabel"))
	hoverSoundChooseButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		FMainMenu.ConfigModulesHelper.doSoundSelection(mainPropPanel.textHoverSound, nil)
	end

	--text button click sound
	mainPropPanel.textClickSound, mainPropPanel.contentLabel = FMainMenu.ConfigModulePanels.createLabelBoxComboLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesTextButtonDermaClickSound"))

	--sound selection button
	local clickSoundChooseButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMusicButtonLabel"))
	clickSoundChooseButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		FMainMenu.ConfigModulesHelper.doSoundSelection(mainPropPanel.textClickSound, nil)
	end

	--text button color
	mainPropPanel.textColor = FMainMenu.ConfigModulePanels.createColorPicker(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaTextColor"))

	--text button color when hovered
	mainPropPanel.textHoverColor = FMainMenu.ConfigModulePanels.createColorPicker(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesTextButtonDermaHoverColor"))

	--text button outline color
	mainPropPanel.textOutlineColor = FMainMenu.ConfigModulePanels.createColorPicker(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDermaOutlineColor"))

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if !FMainMenu.ConfigModulesHelper.areColorsEqual(parentPanel.lastRecVariable[1], parentPanel.textColor:GetColor()) then
		return true
	end

	if !FMainMenu.ConfigModulesHelper.areColorsEqual(parentPanel.lastRecVariable[2], parentPanel.textOutlineColor:GetColor()) then
		return true
	end

	if parentPanel.lastRecVariable[3] != tonumber(parentPanel.textOutlineThickness:GetText()) then
		return true
	end

	local serverVar = ""
	if parentPanel.lastRecVariable[4] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	end

	if parentPanel.textShadowOption:GetText() != serverVar then
		return true
	end

	if parentPanel.lastRecVariable[5] != parentPanel.textFontOption:GetText() then
		return true
	end

	if parentPanel.lastRecVariable[6] != tonumber(parentPanel.textFontSize:GetText()) then
		return true
	end

	if !FMainMenu.ConfigModulesHelper.areColorsEqual(parentPanel.lastRecVariable[7], parentPanel.textHoverColor:GetColor()) then
		return true
	end

	soundFix(parentPanel.textHoverSound:GetText(), parentPanel.textHoverSound)

	if parentPanel.lastRecVariable[8] != parentPanel.textHoverSound:GetText() then
		return true
	end

	soundFix(parentPanel.textClickSound:GetText(), parentPanel.textClickSound)

	if parentPanel.lastRecVariable[9] != parentPanel.textClickSound:GetText() then
		return true
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if tonumber(parentPanel.textOutlineThickness:GetText()) == nil then return end
	if tonumber(parentPanel.textFontSize:GetText()) == nil then return end

	previewCopy["_" .. configPropList[1]] = parentPanel.textColor:GetColor()
	previewCopy["_" .. configPropList[2]] = parentPanel.textOutlineColor:GetColor()
	previewCopy["_" .. configPropList[3]] = tonumber(parentPanel.textOutlineThickness:GetText())

	if parentPanel.textShadowOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		previewCopy["_" .. configPropList[4]] = false
	else
		previewCopy["_" .. configPropList[4]] = true
	end

	previewCopy["_" .. configPropList[5]] = parentPanel.textFontOption:GetText()
	previewCopy["_" .. configPropList[6]] = tonumber(parentPanel.textFontSize:GetText())
	previewCopy["_" .. configPropList[7]] = parentPanel.textHoverColor:GetColor()
	previewCopy["_" .. configPropList[8]] = parentPanel.textHoverSound:GetText()
	previewCopy["_" .. configPropList[9]] = parentPanel.textClickSound:GetText()
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if tonumber(parentPanel.textOutlineThickness:GetText()) == nil then return end
	if tonumber(parentPanel.textFontSize:GetText()) == nil then return end

	if parentPanel.textShadowOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[4] = false
	elseif parentPanel.textShadowOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[4] = true
	else
		return
	end

	parentPanel.lastRecVariable[1] = parentPanel.textColor:GetColor()
	parentPanel.lastRecVariable[2] = parentPanel.textOutlineColor:GetColor()
	parentPanel.lastRecVariable[3] = tonumber(parentPanel.textOutlineThickness:GetText())
	parentPanel.lastRecVariable[5] = parentPanel.textFontOption:GetText()
	parentPanel.lastRecVariable[6] = tonumber(parentPanel.textFontSize:GetText())
	parentPanel.lastRecVariable[7] = parentPanel.textHoverColor:GetColor()
	parentPanel.lastRecVariable[8] = parentPanel.textHoverSound:GetText()
	parentPanel.lastRecVariable[9] = parentPanel.textClickSound:GetText()

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	parentPanel.textColor:SetColor(receivedVarTable[1])
	parentPanel.textOutlineColor:SetColor(receivedVarTable[2])
	parentPanel.textOutlineThickness:SetText(receivedVarTable[3])

	if receivedVarTable[4] == true then
		parentPanel.textShadowOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	else
		parentPanel.textShadowOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end

	parentPanel.textFontOption:SetValue(receivedVarTable[5])
	parentPanel.textFontSize:SetText(receivedVarTable[6])
	parentPanel.textHoverColor:SetColor(receivedVarTable[7])
	parentPanel.textHoverSound:SetText(receivedVarTable[8])
	parentPanel.textClickSound:SetText(receivedVarTable[9])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end