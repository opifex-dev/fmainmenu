--[[

	Premade Panels For IGC Modules

]]--

local FMainMenu = FMainMenu

FMainMenu.ConfigModulePanels = FMainMenu.ConfigModulePanels || {}

-- localized global calls
local vgui_Create = vgui.Create

-- create single line label
FMainMenu.ConfigModulePanels.createLabel = function(mainPropPanel, text)
	local newLabel = vgui_Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1

	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 18

	return newLabel
end

-- create double line label
FMainMenu.ConfigModulePanels.createLabelLarge = function(mainPropPanel, text)
	local newLabel = vgui_Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel:SetSize(225, 36)
	newLabel.scrollAdjustmentType = 1

	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 33

	return newLabel
end

-- combination of small label and small text box, where the label can be aligned to the left or right of the panel
FMainMenu.ConfigModulePanels.createLabelBoxComboSmall = function(mainPropPanel, text, textOnLeft)
	local newLabel = vgui_Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	if textOnLeft then
		newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
		newLabel.scrollAdjustmentType = 1
	else
		newLabel:SetPos(143, 70 + mainPropPanel.tempYPos)
		newLabel.scrollAdjustmentType = 2
	end

	local newTextBox = vgui_Create("fmainmenu_config_editor_textentry", mainPropPanel)
	newTextBox:SetSize( 75, 18 )
	newTextBox:SetPos( 163, 70 + mainPropPanel.tempYPos )
	newTextBox.scrollAdjustmentType = 2
	function newTextBox:OnChange(self)
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].isVarChanged())
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
	end

	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 18

	return newTextBox, newLabel
end

-- single line label with a panel-wide text box below it
FMainMenu.ConfigModulePanels.createLabelBoxComboLarge = function(mainPropPanel, text)
	local newLabel = vgui_Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1

	local newTextBox = vgui_Create("fmainmenu_config_editor_textentry", mainPropPanel)
	newTextBox:SetSize( 236, 18 )
	newTextBox:SetPos( 2, 88 + mainPropPanel.tempYPos )
	newTextBox.scrollAdjustmentType = 4
	function newTextBox:OnChange()
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].isVarChanged())
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
	end

	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 36

	return newTextBox, newLabel
end

-- single line label with a panel-wide multi-line text box below it
FMainMenu.ConfigModulePanels.createLabelBoxComboMassive = function(mainPropPanel, text)
	local newLabel = vgui_Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1

	local newTextBox = vgui_Create("fmainmenu_config_editor_textentry", mainPropPanel)
	newTextBox:SetSize( 236, 120 )
	newTextBox:SetPos( 2, 88 + mainPropPanel.tempYPos )
	newTextBox.scrollAdjustmentType = 4
	newTextBox:SetEnterAllowed( true )
	newTextBox:SetMultiline( true )
	function newTextBox:OnChange()
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].isVarChanged())
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
	end

	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 138

	return newTextBox, newLabel
end

-- label next to combination box with defaultValue automatically added
FMainMenu.ConfigModulePanels.createComboBox = function(mainPropPanel, text, defaultValue)
	local newLabel = vgui_Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1

	local newComboBox = vgui_Create("fmainmenu_config_editor_combobox", mainPropPanel)
	newComboBox:SetSize( 90, 18 )
	newComboBox:SetPos( 148, 70 + mainPropPanel.tempYPos )
	newComboBox:SetValue( defaultValue )
	newComboBox:AddChoice( defaultValue )
	newComboBox.scrollAdjustmentType = 2
	function newComboBox:OnSelect( index, value, data )
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].isVarChanged())
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
	end

	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 18

	return newComboBox, newLabel
end

-- centered button with text in it
FMainMenu.ConfigModulePanels.createTextButtonLarge = function(mainPropPanel, text)
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 9

	local newButton = vgui_Create("fmainmenu_config_editor_button", mainPropPanel)
	newButton:SetText(text)
	newButton:SetSize(200,25)
	newButton:AlignLeft(20)
	newButton:AlignTop(70 + mainPropPanel.tempYPos)
	newButton.scrollAdjustmentType = 3
	FMainMenu.Derma.SetPanelHover(newButton, 1)

	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 28

	return newButton
end

-- color selection panel
FMainMenu.ConfigModulePanels.createColorPicker = function(mainPropPanel, text)
	local newLabel = vgui_Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1

	local colorBox = vgui_Create("DColorMixer", mainPropPanel)
	colorBox:SetSize( 236, 216 )
	colorBox:SetPos(2, 88 + mainPropPanel.tempYPos)
	colorBox.scrollAdjustmentType = 4
	function colorBox:ValueChanged()
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].isVarChanged())
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
	end

	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 237

	return colorBox, newLabel
end