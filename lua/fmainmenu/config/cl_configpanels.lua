--[[

	Premade Panels For IGC Modules

]]--

FMainMenu.ConfigModulePanels = FMainMenu.ConfigModulePanels || {}

FMainMenu.ConfigModulePanels.createLabel = function(mainPropPanel, text)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1
	
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 18
	
	return newLabel
end

FMainMenu.ConfigModulePanels.createLabelLarge = function(mainPropPanel, text)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel:SetSize(225, 36)
	newLabel.scrollAdjustmentType = 1
	
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 33
	
	return newLabel
end

FMainMenu.ConfigModulePanels.createLabelBoxComboSmall = function(mainPropPanel, text, textOnLeft)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	if textOnLeft then
		newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
		newLabel.scrollAdjustmentType = 1
	else
		newLabel:SetPos(143, 70 + mainPropPanel.tempYPos)
		newLabel.scrollAdjustmentType = 2
	end
	
	local newTextBox = vgui.Create("fmainmenu_config_editor_textentry", mainPropPanel)
	newTextBox:SetSize( 75, 18 )
	newTextBox:SetPos( 163, 70 + mainPropPanel.tempYPos )
	newTextBox.scrollAdjustmentType = 2
	function newTextBox:OnChange()
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].isVarChanged())
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
	end
	
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 18
	
	return newTextBox, newLabel
end

FMainMenu.ConfigModulePanels.createLabelBoxComboLarge = function(mainPropPanel, text)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1
	
	local newTextBox = vgui.Create("fmainmenu_config_editor_textentry", mainPropPanel)
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

FMainMenu.ConfigModulePanels.createLabelBoxComboMassive = function(mainPropPanel, text)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1
	
	local newTextBox = vgui.Create("fmainmenu_config_editor_textentry", mainPropPanel)
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

FMainMenu.ConfigModulePanels.createComboBox = function(mainPropPanel, text, defaultValue)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1
	
	local newComboBox = vgui.Create("fmainmenu_config_editor_combobox", mainPropPanel)
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

FMainMenu.ConfigModulePanels.createTextButtonLarge = function(mainPropPanel, text)
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 9

	local newButton = vgui.Create("fmainmenu_config_editor_button", mainPropPanel)
	newButton:SetText(text)
	newButton:SetSize(200,25)
	newButton:AlignLeft(20)
	newButton:AlignTop(70 + mainPropPanel.tempYPos)
	newButton.scrollAdjustmentType = 3
	
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 28
	
	return newButton
end

FMainMenu.ConfigModulePanels.createColorPicker = function(mainPropPanel, text)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	newLabel.scrollAdjustmentType = 1
	
	local colorBox = vgui.Create("DColorMixer", mainPropPanel)
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