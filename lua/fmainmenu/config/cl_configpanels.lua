--[[

	Premade Panels For IGC Modules

]]--

FMainMenu.ConfigModulePanels = FMainMenu.ConfigModulePanels || {}

FMainMenu.ConfigModulePanels.createLabel = function(mainPropPanel, text)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 18
end

FMainMenu.ConfigModulePanels.createLabelBoxComboSmall = function(mainPropPanel, text, textOnLeft)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	if textOnLeft then
		newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	else
		newLabel:SetPos(143, 70 + mainPropPanel.tempYPos)
	end
	
	local newTextBox = vgui.Create("fmainmenu_config_editor_textentry", mainPropPanel)
	newTextBox:SetSize( 75, 18 )
	newTextBox:SetPos( 163, 70 + mainPropPanel.tempYPos )
	function newTextBox:OnChange()
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].isVarChanged())
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
	end
	
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 18
	
	return newTextBox
end

FMainMenu.ConfigModulePanels.createComboBox = function(mainPropPanel, text, defaultValue)
	local newLabel = vgui.Create("fmainmenu_config_editor_label", mainPropPanel)
	newLabel:SetText(text)
	newLabel:SetPos(2, 70 + mainPropPanel.tempYPos)
	
	local newComboBox = vgui.Create("fmainmenu_config_editor_combobox", mainPropPanel)
	newComboBox:SetSize( 90, 18 )
	newComboBox:SetPos( 148, 70 + mainPropPanel.tempYPos )
	newComboBox:SetValue( defaultValue )
	newComboBox:AddChoice( defaultValue )
	function newComboBox:OnSelect( index, value, data )
		FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].isVarChanged())
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
	end
	
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 18
	
	return newComboBox
end

FMainMenu.ConfigModulePanels.createTextButtonLarge = function(mainPropPanel, text)
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 9

	local newButton = vgui.Create("fmainmenu_config_editor_button", mainPropPanel)
	newButton:SetText(text)
	newButton:SetSize(200,25)
	newButton:AlignLeft(20)
	newButton:AlignTop(70 + mainPropPanel.tempYPos)
	
	mainPropPanel.tempYPos = mainPropPanel.tempYPos + 28
	
	return newButton
end