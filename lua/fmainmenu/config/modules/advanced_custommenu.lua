--[[

	CUSTOM MENU LAYOUT IGC MODULE

]]--

local FMainMenu = FMainMenu

-- localized global calls
local vgui_Create = CLIENT and vgui.Create
local table_insert = table.insert
local ScrW = ScrW
local ScrH = ScrH
local Color = Color
local ipairs = ipairs
local table_remove = table.remove
local table_Copy = table.Copy
local table_GetKeys = table.GetKeys
local surface_PlaySound = surface.PlaySound

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 63
local configPropList = {"MenuOverride","MenuSetup"}
local MenuSetupEditor = nil

local buttonSetups = {
	["Play"] = function(buttonPanel, button, mainPropPanel)
		-- button text
		local buttonText = vgui_Create("fmainmenu_config_editor_label", buttonPanel)
		buttonText:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorWindowButtonLabel"))
		buttonText:SetPos(5, 25)
		local buttonTextBox = vgui_Create("fmainmenu_config_editor_textentry", buttonPanel)
		buttonTextBox:SetSize( 196, 18 )
		buttonTextBox:SetPos( 50, 25 )
		buttonTextBox:AlignRight(5)
		buttonTextBox:SetText(button.Content.Text)
		function buttonTextBox:OnChange()
			mainPropPanel.internalMenuSetup[buttonPanel.bIndex].Content.Text = buttonTextBox:GetText()
			FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
			FMainMenu.ConfigModules[propertyCode].updatePreview()
		end

		return 80
	end,
	["Spacer"] = function(buttonPanel, button, mainPropPanel)
		return 60
	end,
	["URL"] = function(buttonPanel, button, mainPropPanel)
		-- button text
		local buttonText = vgui_Create("fmainmenu_config_editor_label", buttonPanel)
		buttonText:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorWindowButtonLabel"))
		buttonText:SetPos(5, 25)
		local buttonTextBox = vgui_Create("fmainmenu_config_editor_textentry", buttonPanel)
		buttonTextBox:SetSize( 196, 18 )
		buttonTextBox:SetPos( 50, 25 )
		buttonTextBox:AlignRight(5)
		buttonTextBox:SetText(button.Content.Text)
		function buttonTextBox:OnChange()
			mainPropPanel.internalMenuSetup[buttonPanel.bIndex].Content.Text = buttonTextBox:GetText()
			FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
			FMainMenu.ConfigModules[propertyCode].updatePreview()
		end

		-- button link
		local buttonLinkLabel = vgui_Create("fmainmenu_config_editor_label", buttonPanel)
		buttonLinkLabel:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorWindowLinkLabel"))
		buttonLinkLabel:SetPos(5, 48)
		local buttonLinkBox = vgui_Create("fmainmenu_config_editor_textentry", buttonPanel)
		buttonLinkBox:SetSize( 196, 18 )
		buttonLinkBox:SetPos( 50, 48 )
		buttonLinkBox:AlignRight(5)
		buttonLinkBox:SetText(button.Content.URL)
		function buttonLinkBox:OnChange()
			mainPropPanel.internalMenuSetup[buttonPanel.bIndex].Content.URL = buttonLinkBox:GetText()
			FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
			FMainMenu.ConfigModules[propertyCode].updatePreview()
		end

		return 100
	end,
	["Disconnect"] = function(buttonPanel, button, mainPropPanel)
		-- button text
		local buttonText = vgui_Create("fmainmenu_config_editor_label", buttonPanel)
		buttonText:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorWindowButtonLabel"))
		buttonText:SetPos(5, 25)
		local buttonTextBox = vgui_Create("fmainmenu_config_editor_textentry", buttonPanel)
		buttonTextBox:SetSize( 196, 18 )
		buttonTextBox:SetPos( 50, 25 )
		buttonTextBox:AlignRight(5)
		buttonTextBox:SetText(button.Content.Text)
		function buttonTextBox:OnChange()
			mainPropPanel.internalMenuSetup[buttonPanel.bIndex].Content.Text = buttonTextBox:GetText()
			FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
			FMainMenu.ConfigModules[propertyCode].updatePreview()
		end

		return 80
	end,
}

local buttonAddFunc = {
	["Play"] = function(menuTable)
		table_insert( menuTable, {
			Type = "Play",
			Content = {
				Text = "New Play Button",
			}
		})
	end,
	["Spacer"] = function(menuTable)
		table_insert( menuTable, {
			Type = "Spacer",
			Content = {
			}
		})
	end,
	["URL"] = function(menuTable)
		table_insert( menuTable, {
			Type = "URL",
			Content = {
				Text = "New URL Button",
				URL = "Link Here",
			}
		})
	end,
	["Disconnect"] = function(menuTable)
		table_insert( menuTable, {
			Type = "Disconnect",
			Content = {
				Text = "New Disconnect Button",
			}
		})
	end,
}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 1
FMainMenu.ConfigModules[propertyCode].category = 6
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesMenuOverridePropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesMenuOverridePropName"), FMainMenu.GetPhrase("ConfigPropertiesMenuOverridePropDesc"))

	-- Menu Override Toggle
	mainPropPanel.menuSetupOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMenuOverrideOptLabel"), FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	mainPropPanel.menuSetupOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )

	-- Custom Menu Setup
	mainPropPanel.internalMenuSetup = {}
	mainPropPanel.menuSetupEditorButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMenuSetupEditorButtonLabel"))
	mainPropPanel.menuSetupEditorButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		FMainMenu.ConfigModulesHelper.setExternalBlock(true)
		FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(true)

		local screenWidth = ScrW()
		local screenHeight = ScrH()

		-- frame setup
		MenuSetupEditor = vgui_Create( "fmainmenu_config_editor" )
		MenuSetupEditor:SetSize( 370, 580 )
		MenuSetupEditor:SetPos(screenWidth / 2 - 185, screenHeight / 2 - 290)
		MenuSetupEditor:SetTitle(FMainMenu.GetPhrase("ConfigMenuSetupEditorWindowTitle"))
		MenuSetupEditor:SetZPos(10)
		function MenuSetupEditor:OnClose()
			FMainMenu.ConfigModulesHelper.setExternalBlock(false)
			FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(false)

			MenuSetupEditor = nil
		end

		local mainBPanel = nil
		local panelBlocker = nil

		local function updateCacheVisuals()
			if mainBPanel != nil then
				mainBPanel:Remove()
			end

			mainBPanel = vgui_Create("fmainmenu_config_editor_scrollpanel", MenuSetupEditor)
			mainBPanel:SetBGColor(Color(55,55,55))
			mainBPanel:SetSize( 360, 520 )
			mainBPanel:AlignLeft(5)
			mainBPanel:AlignTop(25)

			local heightOff = 10
			for i, button in ipairs(mainPropPanel.internalMenuSetup) do
				local buttonPanel = vgui_Create("fmainmenu_config_editor_panel", mainBPanel)
				buttonPanel.bIndex = i
				buttonPanel:SetBGColor(Color(75,75,75))
				buttonPanel:SetSize( 320, 100 )
				buttonPanel:AlignLeft(15)
				buttonPanel:AlignTop(heightOff)

				-- button type
				local buttonTypeLabel = vgui_Create("fmainmenu_config_editor_label", buttonPanel)
				buttonTypeLabel:SetText(FMainMenu.GetPhrase("ConfigMenuSetupEditorType" .. button.Type))
				buttonTypeLabel:SetFont("HudHintTextLarge")
				buttonTypeLabel:SetPos(5, 2)

				local addHeight = buttonSetups[button.Type](buttonPanel, button, mainPropPanel)
				buttonPanel:SetSize(320, addHeight)
				heightOff = heightOff + addHeight + 10

				-- remove button
				local buttonRemove = vgui_Create("fmainmenu_config_editor_image_button", buttonPanel)
				buttonRemove:SetImage("icon16/cancel.png")
				buttonRemove:SetSize(20,20)
				buttonRemove:AlignRight(5)
				buttonRemove:AlignBottom(5)
				buttonRemove.DoClick = function(button)
					surface_PlaySound("common/warning.wav")
					FMainMenu.ConfigModulesHelper.doAdvancedConfirmationDialog(panelBlocker, function()
						-- Remove the button
						table_remove( mainPropPanel.internalMenuSetup, buttonPanel.bIndex )
						updateCacheVisuals()

						FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
						FMainMenu.ConfigModules[propertyCode].updatePreview()
					end, FMainMenu.GetPhrase("ConfigURLButtonEditorWindowDeleteConfirm"))
				end

				-- move order up button
				local buttonOrderUp = vgui_Create("fmainmenu_config_editor_image_button", buttonPanel)
				buttonOrderUp:SetSize(28,28)
				buttonOrderUp:AlignLeft(0)
				buttonOrderUp:AlignBottom(3)
				buttonOrderUp:SetKeepAspect( true )
				buttonOrderUp:SetImage("icon16/arrow_up.png")
				buttonOrderUp.DoClick = function(button)
					if buttonPanel.bIndex > 1 then
						surface_PlaySound("garrysmod/ui_click.wav")
						local temp = table_Copy(mainPropPanel.internalMenuSetup[buttonPanel.bIndex])
						mainPropPanel.internalMenuSetup[buttonPanel.bIndex] = mainPropPanel.internalMenuSetup[buttonPanel.bIndex-1]
						mainPropPanel.internalMenuSetup[buttonPanel.bIndex-1] = temp
						updateCacheVisuals()

						FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
						FMainMenu.ConfigModules[propertyCode].updatePreview()
					else
						surface_PlaySound("common/wpn_denyselect.wav")
					end
				end

				-- move order down button
				local buttonOrderDown = vgui_Create("fmainmenu_config_editor_image_button", buttonPanel)
				buttonOrderDown:SetImage("icon16/arrow_down.png")
				buttonOrderDown:SetSize(28,28)
				buttonOrderDown:AlignLeft(28)
				buttonOrderDown:AlignBottom(3)
				buttonOrderDown:SetKeepAspect( true )
				buttonOrderDown.DoClick = function(button)
					if buttonPanel.bIndex < #mainPropPanel.internalMenuSetup then
						surface_PlaySound("garrysmod/ui_click.wav")
						local temp = table_Copy(mainPropPanel.internalMenuSetup[buttonPanel.bIndex])
						mainPropPanel.internalMenuSetup[buttonPanel.bIndex] = mainPropPanel.internalMenuSetup[buttonPanel.bIndex + 1]
						mainPropPanel.internalMenuSetup[buttonPanel.bIndex + 1] = temp
						updateCacheVisuals()

						FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
						FMainMenu.ConfigModules[propertyCode].updatePreview()
					else
						surface_PlaySound("common/wpn_denyselect.wav")
					end
				end
			end
		end

		local function updateCachedTable(varTable)
			mainPropPanel.internalMenuSetup = table_Copy(varTable[2])
			updateCacheVisuals()

			FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
			FMainMenu.ConfigModules[propertyCode].updatePreview()
		end

		-- bottom toolbar
		local bottomPanel = vgui_Create("fmainmenu_config_editor_panel", MenuSetupEditor)
		bottomPanel:SetSize( 360, 30 )
		bottomPanel:AlignLeft(5)
		bottomPanel:AlignTop(545)

		-- save button
		local bottomPanelSaveButton = vgui_Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelSaveButton:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorCloseButtonText"))
		bottomPanelSaveButton:SetSize(100,24)
		bottomPanelSaveButton:AlignRight(5)
		bottomPanelSaveButton:AlignTop(3)
		bottomPanelSaveButton.DoClick = function(button)
			surface_PlaySound("garrysmod/ui_click.wav")
			MenuSetupEditor:Close()
		end
		FMainMenu.Derma.SetPanelHover(bottomPanelSaveButton, 1)

		-- revert button
		local bottomPanelRevertButton = vgui_Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelRevertButton:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorRevertButtonText"))
		bottomPanelRevertButton:SetSize(100,24)
		bottomPanelRevertButton:AlignRight(110)
		bottomPanelRevertButton:AlignTop(3)
		bottomPanelRevertButton.DoClick = function(button)
			surface_PlaySound("common/warning.wav")
			FMainMenu.ConfigModulesHelper.doAdvancedConfirmationDialog(panelBlocker, function()
				surface_PlaySound("buttons/combine_button7.wav")
				FMainMenu.ConfigModulesHelper.requestVariablesCustom(configPropList, updateCachedTable)
			end, FMainMenu.GetPhrase("ConfigURLButtonEditorWindowRevertConfirm"))
		end
		FMainMenu.Derma.SetPanelHover(bottomPanelRevertButton, 1)

		-- add button
		local bottomPanelAddButton = vgui_Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelAddButton:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorAddButtonText"))
		bottomPanelAddButton:SetSize(100,24)
		bottomPanelAddButton:AlignLeft(5)
		bottomPanelAddButton:AlignTop(3)
		bottomPanelAddButton.DoClick = function(button)
			surface_PlaySound("garrysmod/ui_click.wav")

			--Confirmation dialogue
			panelBlocker:SetVisible(true)
			local removeConfirm =  vgui_Create("fmainmenu_config_editor_panel", panelBlocker)
			removeConfirm:SetBGColor(Color(55, 55, 55, 255))
			removeConfirm:SetSize( 246, 250 )
			removeConfirm:Center()

			local leftText = FMainMenu.Derma.CreateDLabel(removeConfirm, 246, 30, false, FMainMenu.GetPhrase("ConfigMenuSetupEditorWindowChooseTypeLabel"))
			leftText:SetPos(0, 5)
			leftText:SetWrap(false)

			local tempY = 0
			for _,bType in ipairs(table_GetKeys(buttonSetups)) do
				local button = FMainMenu.Derma.CreateDButton(removeConfirm, 200, 32, FMainMenu.GetPhrase("ConfigMenuSetupEditorType" .. bType), "")
				button:SetPos(23, 32 + tempY)
				button.Type = bType
				FMainMenu.Derma:SetFrameSettings(button, Color(75,75,75, 255), 0)
				button.DoClick = function(self)
					surface_PlaySound("garrysmod/ui_click.wav")
					removeConfirm:Remove()
					panelBlocker:SetVisible(false)

					buttonAddFunc[self.Type](mainPropPanel.internalMenuSetup)

					updateCacheVisuals()

					FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
					FMainMenu.ConfigModules[propertyCode].updatePreview()
				end

				tempY = tempY + 42
			end

			local cancelButton = FMainMenu.Derma.CreateDButton(removeConfirm, 200, 32, FMainMenu.GetPhrase("ConfigCommonValueCancel"), "")
			cancelButton:SetPos(23, 208)
			FMainMenu.Derma:SetFrameSettings(cancelButton, Color(75,75,75, 255), 0)
			cancelButton.DoClick = function()
				surface_PlaySound("garrysmod/ui_click.wav")
				removeConfirm:Remove()
				panelBlocker:SetVisible(false)
			end
		end
		FMainMenu.Derma.SetPanelHover(bottomPanelAddButton, 1)

		panelBlocker =  vgui_Create("fmainmenu_config_editor_panel", MenuSetupEditor)
		panelBlocker:SetBGColor(Color(0, 0, 0, 155))
		panelBlocker:SetSize( 360, 550 )
		panelBlocker:AlignLeft(5)
		panelBlocker:SetZPos(999)
		panelBlocker:AlignTop(25)
		panelBlocker:SetVisible(false)

		updateCachedTable({nil,mainPropPanel.internalMenuSetup})

		MenuSetupEditor:MakePopup()
	end

	-- Provides ability for player to get detailed info on the Advanced Spawn system if needed
	FMainMenu.ConfigModulePanels.createLabelLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMenuOverrideInfoLabel"))
	local informationButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesAdvancedGeneralInfoButtonLabel"))
	informationButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		FMainMenu.ConfigModulesHelper.doInformationalWindow(FMainMenu.GetPhrase("ConfigPropertiesMenuOverrideInfoWindowTitle"), FMainMenu.GetPhrase("ConfigPropertiesMenuOverrideInfo"))
	end

	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	local serverVar = ""
	if parentPanel.lastRecVariable[1] then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	end

	if parentPanel.menuSetupOption:GetValue() != serverVar then
		return true
	end

	--Checks for differences between tables
	if #parentPanel.lastRecVariable[2] != #parentPanel.internalMenuSetup then
		return true
	end

	for i,button in ipairs(parentPanel.lastRecVariable[2]) do
		if button.Type != parentPanel.internalMenuSetup[i].Type then
			return true
		end

		if button.Content.Text != parentPanel.internalMenuSetup[i].Content.Text then
			return true
		end

		if button.Content.URL != parentPanel.internalMenuSetup[i].Content.URL then
			return true
		end
	end

	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if parentPanel.menuSetupOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		previewCopy["_" .. configPropList[1]] = true
	elseif parentPanel.menuSetupOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		previewCopy["_" .. configPropList[1]] = false
	else
		return
	end

	previewCopy["_" .. configPropList[2]] = parentPanel.internalMenuSetup
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function()
	FMainMenu.ConfigModulesHelper.closeOpenExtraWindows()

	if MenuSetupEditor != nil then
		MenuSetupEditor:Close()
	end
end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if parentPanel.menuSetupOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[1] = true
	elseif parentPanel.menuSetupOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[1] = false
	else
		return true
	end

	parentPanel.lastRecVariable[2] = table_Copy(parentPanel.internalMenuSetup)

	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp

	if receivedVarTable[1] then
		parentPanel.menuSetupOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	else
		parentPanel.menuSetupOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end

	parentPanel.internalMenuSetup = table_Copy( receivedVarTable[2] )
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end