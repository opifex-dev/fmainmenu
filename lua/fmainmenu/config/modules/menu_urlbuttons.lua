--[[

	URL BUTTONS MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 29
local configPropList = {"URLButtons"}
local URLButtonEditor = nil
local addonName = "fmainmenu"

local function doConfirmation(panelBlocker, confirmFunc, warnText)
	--Confirmation dialogue
	panelBlocker:SetVisible(true)
	local removeConfirm =  vgui.Create("fmainmenu_config_editor_panel", panelBlocker)
	removeConfirm:SetBGColor(Color(55, 55, 55, 255))
	removeConfirm:SetSize( 246, 93 )
	removeConfirm:Center()
	
	local leftText = FMainMenu.Derma.CreateDLabel(removeConfirm, 221, 113, false, warnText)
	leftText:SetFont("HudHintTextLarge")
	leftText:SetPos(10, 5)
	leftText:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor"))
	leftText:SetWrap( true )
	leftText:SetContentAlignment( 8 )
	
	local secondButton = FMainMenu.Derma.CreateDButton(removeConfirm, 108, 32, FMainMenu.GetPhrase("ConfigCommonValueNo"), "")
	secondButton:SetPos(130, 56)
	secondButton:SetFont("HudHintTextLarge")
	secondButton:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
	FMainMenu.Derma.SetPanelHover(secondButton, 1)
	secondButton:SetContentAlignment( 5 )
	FMainMenu.Derma:SetFrameSettings(secondButton, FayLib.IGC.GetSharedKey(addonName, "commonButtonColor"), 0)
	secondButton.DoClick = function()
		removeConfirm:Remove()
		panelBlocker:SetVisible(false)
	end
	
	local firstButton = FMainMenu.Derma.CreateDButton(removeConfirm, 108, 32, FMainMenu.GetPhrase("ConfigCommonValueYes"), "")
	firstButton:SetPos(8, 56)
	firstButton:SetFont("HudHintTextLarge")
	firstButton:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
	FMainMenu.Derma.SetPanelHover(firstButton, 1)
	firstButton:SetContentAlignment( 5 )
	FMainMenu.Derma:SetFrameSettings(firstButton, FayLib.IGC.GetSharedKey(addonName, "commonButtonColor"), 0)
	firstButton.DoClick = function()
		removeConfirm:Remove()
		panelBlocker:SetVisible(false)
		
		confirmFunc()
	end
end

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 1
FMainMenu.ConfigModules[propertyCode].category = 2
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesURLButtonsPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesURLButtonsPropName"), FMainMenu.GetPhrase("ConfigPropertiesURLButtonsPropDesc"))

	-- URL Buttons Editor
	mainPropPanel.internalURLButtons = {}
	mainPropPanel.URLButtonsEditorButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesURLButtonsEditorButtonLabel"))
	mainPropPanel.URLButtonsEditorButton.DoClick = function(button)
		FMainMenu.ConfigModulesHelper.setExternalBlock(true)
		FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(true)
		
		local screenWidth = ScrW()
		local screenHeight = ScrH()
		
		-- frame setup
		URLButtonEditor = vgui.Create( "fmainmenu_config_editor" )
		URLButtonEditor:SetSize( 370, 580 )
		URLButtonEditor:SetPos(screenWidth/2-185, screenHeight/2-290)
		URLButtonEditor:SetTitle(FMainMenu.GetPhrase("ConfigURLButtonEditorWindowTitle"))
		URLButtonEditor:SetZPos(10)
		function URLButtonEditor:OnClose()
			FMainMenu.ConfigModulesHelper.setExternalBlock(false)
			FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(false)
			
			URLButtonEditor = nil
		end
		
		local mainBPanel = nil
		local panelBlocker = nil
		
		local function updateCacheVisuals()
			if mainBPanel != nil then
				mainBPanel:Remove()
			end
			
			mainBPanel = vgui.Create("fmainmenu_config_editor_scrollpanel", URLButtonEditor)
			mainBPanel:SetBGColor(Color(55,55,55))
			mainBPanel:SetSize( 360, 520 )
			mainBPanel:AlignLeft(5)
			mainBPanel:AlignTop(25)
		
			local heightOff = 10
			for i,button in ipairs(mainPropPanel.internalURLButtons) do
				local buttonPanel = vgui.Create("fmainmenu_config_editor_panel", mainBPanel)
				buttonPanel.bIndex = i
				buttonPanel:SetBGColor(Color(75,75,75))
				buttonPanel:SetSize( 320, 80 )
				buttonPanel:AlignLeft(15)
				buttonPanel:AlignTop(heightOff)
				heightOff = heightOff + 90
				
				-- button text
				local buttonText = vgui.Create("fmainmenu_config_editor_label", buttonPanel)
				buttonText:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorWindowButtonLabel"))
				buttonText:SetPos(5, 5)
				local buttonTextBox = vgui.Create("fmainmenu_config_editor_textentry", buttonPanel)
				buttonTextBox:SetSize( 196, 18 )
				buttonTextBox:SetPos( 50, 5 )
				buttonTextBox:AlignRight(5)
				buttonTextBox:SetText(button.Text)
				function buttonTextBox:OnChange()
					mainPropPanel.internalURLButtons[buttonPanel.bIndex].Text = buttonTextBox:GetText()
					FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
					FMainMenu.ConfigModules[propertyCode].updatePreview()
				end
				
				-- button link
				local buttonLinkLabel = vgui.Create("fmainmenu_config_editor_label", buttonPanel)
				buttonLinkLabel:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorWindowLinkLabel"))
				buttonLinkLabel:SetPos(5, 28)
				local buttonLinkBox = vgui.Create("fmainmenu_config_editor_textentry", buttonPanel)
				buttonLinkBox:SetSize( 196, 18 )
				buttonLinkBox:SetPos( 50, 28 )
				buttonLinkBox:AlignRight(5)
				buttonLinkBox:SetText(button.URL)
				function buttonLinkBox:OnChange()
					mainPropPanel.internalURLButtons[buttonPanel.bIndex].URL = buttonLinkBox:GetText()
					FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
					FMainMenu.ConfigModules[propertyCode].updatePreview()
				end
				
				-- remove button
				local buttonRemove = vgui.Create("fmainmenu_config_editor_image_button", buttonPanel)
				buttonRemove:SetImage("icon16/cancel.png")
				buttonRemove:SetSize(20,20)
				buttonRemove:AlignRight(5)
				buttonRemove:AlignBottom(5)
				buttonRemove.DoClick = function(button)
					doConfirmation(panelBlocker, function()
						-- Remove the button
						table.remove( mainPropPanel.internalURLButtons, buttonPanel.bIndex )
						updateCacheVisuals()
						
						FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
						FMainMenu.ConfigModules[propertyCode].updatePreview()
					end, FMainMenu.GetPhrase("ConfigURLButtonEditorWindowDeleteConfirm"))
				end
				
				-- move order up button
				local buttonOrderUp = vgui.Create("fmainmenu_config_editor_image_button", buttonPanel)
				buttonOrderUp:SetSize(28,28)
				buttonOrderUp:AlignLeft(0)
				buttonOrderUp:AlignBottom(3)
				buttonOrderUp:SetKeepAspect( true )
				buttonOrderUp:SetImage("icon16/arrow_up.png")
				buttonOrderUp.DoClick = function(button)
					if buttonPanel.bIndex > 1 then
						local temp = table.Copy(mainPropPanel.internalURLButtons[buttonPanel.bIndex])
						mainPropPanel.internalURLButtons[buttonPanel.bIndex] = mainPropPanel.internalURLButtons[buttonPanel.bIndex-1]
						mainPropPanel.internalURLButtons[buttonPanel.bIndex-1] = temp
						updateCacheVisuals()
						
						FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
						FMainMenu.ConfigModules[propertyCode].updatePreview()
					end
				end
				
				-- move order down button
				local buttonOrderDown = vgui.Create("fmainmenu_config_editor_image_button", buttonPanel)
				buttonOrderDown:SetImage("icon16/arrow_down.png")
				buttonOrderDown:SetSize(28,28)
				buttonOrderDown:AlignLeft(28)
				buttonOrderDown:AlignBottom(3)
				buttonOrderDown:SetKeepAspect( true )
				buttonOrderDown.DoClick = function(button)
					if buttonPanel.bIndex < #mainPropPanel.internalURLButtons then
						local temp = table.Copy(mainPropPanel.internalURLButtons[buttonPanel.bIndex])
						mainPropPanel.internalURLButtons[buttonPanel.bIndex] = mainPropPanel.internalURLButtons[buttonPanel.bIndex+1]
						mainPropPanel.internalURLButtons[buttonPanel.bIndex+1] = temp
						updateCacheVisuals()
						
						FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
						FMainMenu.ConfigModules[propertyCode].updatePreview()
					end
				end
			end
		end
		
		local function updateCachedTable(varTable)
			mainPropPanel.internalURLButtons = table.Copy(varTable[1])
			updateCacheVisuals()
			
			FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
			FMainMenu.ConfigModules[propertyCode].updatePreview()
		end
		
		-- bottom toolbar
		local bottomPanel = vgui.Create("fmainmenu_config_editor_panel", URLButtonEditor)
		bottomPanel:SetSize( 360, 30 )
		bottomPanel:AlignLeft(5)
		bottomPanel:AlignTop(545)
		
		local bottomPanelSaveButton = vgui.Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelSaveButton:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorCloseButtonText"))
		bottomPanelSaveButton:SetSize(100,24)
		bottomPanelSaveButton:AlignRight(5)
		bottomPanelSaveButton:AlignTop(3)
		bottomPanelSaveButton.DoClick = function(button)
			URLButtonEditor:Close()
		end
		
		local bottomPanelRevertButton = vgui.Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelRevertButton:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorRevertButtonText"))
		bottomPanelRevertButton:SetSize(100,24)
		bottomPanelRevertButton:AlignRight(110)
		bottomPanelRevertButton:AlignTop(3)
		bottomPanelRevertButton.DoClick = function(button)
			doConfirmation(panelBlocker, function()
				FMainMenu.ConfigModulesHelper.requestVariablesCustom(configPropList, updateCachedTable)
			end, FMainMenu.GetPhrase("ConfigURLButtonEditorWindowRevertConfirm"))
		end
		
		local bottomPanelAddButton = vgui.Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelAddButton:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorAddButtonText"))
		bottomPanelAddButton:SetSize(100,24)
		bottomPanelAddButton:AlignLeft(5)
		bottomPanelAddButton:AlignTop(3)
		bottomPanelAddButton.DoClick = function(button)
			table.insert( mainPropPanel.internalURLButtons, {
				Text = "New Button",
				URL = "Link Here",
			} )
			updateCacheVisuals()
			
			FMainMenu.ConfigModulesHelper.setUnsaved(FMainMenu.ConfigModules[propertyCode].isVarChanged())
			FMainMenu.ConfigModules[propertyCode].updatePreview()
		end
		
		panelBlocker =  vgui.Create("fmainmenu_config_editor_panel", URLButtonEditor)
		panelBlocker:SetBGColor(Color(0, 0, 0, 155))
		panelBlocker:SetSize( 360, 550 )
		panelBlocker:AlignLeft(5)
		panelBlocker:SetZPos(999)
		panelBlocker:AlignTop(25)
		panelBlocker:SetVisible(false)
		
		updateCachedTable({mainPropPanel.internalURLButtons})
			
		URLButtonEditor:MakePopup()
	end
	
	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	--Checks for differences between tables
	if #parentPanel.lastRecVariable[1] != #parentPanel.internalURLButtons then
		return true
	end
	
	for i,button in ipairs(parentPanel.lastRecVariable[1]) do
		if button.Text != parentPanel.internalURLButtons[i].Text then
			return true
		end
		
		if button.URL != parentPanel.internalURLButtons[i].URL then
			return true
		end
	end
	
	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	previewCopy["_"..configPropList[1]] = parentPanel.internalURLButtons
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function()
	if URLButtonEditor != nil then
		URLButtonEditor:Close()
	end
end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
		
	parentPanel.lastRecVariable[1] = table.Copy(parentPanel.internalURLButtons)
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	parentPanel.internalURLButtons = table.Copy(receivedVarTable[1])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end