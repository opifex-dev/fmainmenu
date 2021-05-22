--[[

	MUSIC IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 26
local configPropList = {"musicToggle","musicLooping","musicVolume","musicFade","musicContent"}
local soundSelection = nil

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 3
FMainMenu.ConfigModules[propertyCode].category = 2
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesMusicPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = true

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesMusicPropName"), FMainMenu.GetPhrase("ConfigPropertiesMusicPropDesc"))
	
	-- music toggle
	mainPropPanel.toggleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMusicTypeLabel"), FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	mainPropPanel.toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel") )
	mainPropPanel.toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel") )
	
	-- loop music toggle
	mainPropPanel.loopOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMusicLoopLabel"), FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
	mainPropPanel.loopOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
	
	-- music volume
	mainPropPanel.textBox = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMusicVolumeLabel"), true)
	
	-- music fade
	mainPropPanel.fadeBox = FMainMenu.ConfigModulePanels.createLabelBoxComboSmall(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMusicFadeLabel"), true)
	
	-- music content
	mainPropPanel.contentBox, mainPropPanel.contentLabel = FMainMenu.ConfigModulePanels.createLabelBoxComboLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMusicSelectLabel"))
	
	-- File Selector Button
	mainPropPanel.audioFileChooseButton = FMainMenu.ConfigModulePanels.createTextButtonLarge(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesMusicButtonLabel"))
	mainPropPanel.audioFileChooseButton:SetVisible(false)
	mainPropPanel.audioFileChooseButton.DoClick = function(button)
		FMainMenu.ConfigModulesHelper.setExternalBlock(true)
		FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(true)
		
		local internalStation = nil
		local currentVol = 0.5
		local currentSelection = mainPropPanel.contentBox:GetText()
		local screenWidth = ScrW()
		local screenHeight = ScrH()
		
		-- sound preview
		local function stopSoundPreview()
			if internalStation != nil then
				internalStation:Stop()
				internalStation = nil
			end
		end
		
		local function soundPreview(path)
			stopSoundPreview()
			
			sound.PlayFile( path , "noblock", function( station, errCode, errStr )
				if ( IsValid( station ) ) then
					station:EnableLooping(true)
					station:SetVolume(currentVol)
					internalStation = station
				end
			end)
		end
		
		-- frame setup
		soundSelection = vgui.Create( "fmainmenu_config_editor" )
		soundSelection:SetSize( 720, 580 )
		soundSelection:SetPos(screenWidth/2-360, screenHeight/2-290)
		soundSelection:SetTitle(FMainMenu.GetPhrase("ConfigSoundSelectorWindowTitle"))
		soundSelection:SetZPos(10)
		function soundSelection:OnClose()
			stopSoundPreview()
			FMainMenu.ConfigModulesHelper.setExternalBlock(false)
			FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(false)
			
			soundSelection = nil
		end
		
		-- file tree
		local fileBrowser = vgui.Create( "DFileBrowser", soundSelection )
		fileBrowser:SetSize( 710, 520 )
		fileBrowser:AlignLeft(5)
		fileBrowser:AlignTop(25)
		fileBrowser:SetFileTypes("*.mp3 *.wav *.ogg")
		fileBrowser:SetName("Sound Selection")
		fileBrowser:SetBaseFolder("sound")
		fileBrowser:SetCurrentFolder( "sound" ) 
		fileBrowser:SetPath( "GAME" ) 
		fileBrowser:SetOpen(true)
		
		function fileBrowser:OnSelect( path, pnl )
			currentSelection = path
			soundSelection:SetTitle(FMainMenu.GetPhrase("ConfigSoundSelectorWindowTitle").." ("..FMainMenu.GetPhrase("ConfigSoundSelectorWindowSelectionHeader")..currentSelection..")")
		end
		
		function fileBrowser:OnDoubleClick( path, pnl )
			soundPreview(path)
		end
		
		-- bottom toolbar
		local bottomPanel = vgui.Create("fmainmenu_config_editor_panel", soundSelection)
		bottomPanel:SetSize( 710, 30 )
		bottomPanel:AlignLeft(5)
		bottomPanel:AlignTop(545)
		
		local bottomPanelSelectButton = vgui.Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelSelectButton:SetText(FMainMenu.GetPhrase("ConfigSoundSelectorChooseButtonText"))
		bottomPanelSelectButton:SetSize(100,24)
		bottomPanelSelectButton:AlignRight(5)
		bottomPanelSelectButton:AlignTop(3)
		bottomPanelSelectButton.DoClick = function(button)
			if currentSelection != "" then
				mainPropPanel.contentBox:SetText(currentSelection)
				mainPropPanel.contentBox:OnChange()
				mainPropPanel.textBox:SetText(math.Round( currentVol, 2))
				mainPropPanel.textBox:OnChange()
			end
			
			soundSelection:Close()
		end
		
		local bottomPanelPlayButton = vgui.Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelPlayButton:SetText(FMainMenu.GetPhrase("ConfigSoundSelectorPlayButtonText"))
		bottomPanelPlayButton:SetSize(100,24)
		bottomPanelPlayButton:AlignLeft(5)
		bottomPanelPlayButton:AlignTop(3)
		bottomPanelPlayButton.DoClick = function(button)
			if currentSelection != "" then
				soundPreview(currentSelection)
			end
		end
		
		local bottomPanelStopButton = vgui.Create("fmainmenu_config_editor_button", bottomPanel)
		bottomPanelStopButton:SetText(FMainMenu.GetPhrase("ConfigSoundSelectorStopButtonText"))
		bottomPanelStopButton:SetSize(100,24)
		bottomPanelStopButton:AlignLeft(110)
		bottomPanelStopButton:AlignTop(3)
		bottomPanelStopButton.DoClick = function(button)
			stopSoundPreview()
		end
		
		local bottomPanelVolSlider = vgui.Create("DNumSlider", bottomPanel)
		bottomPanelVolSlider:SetSize(250,24)
		bottomPanelVolSlider:AlignLeft(290)
		bottomPanelVolSlider:SetMin( 0 )
		bottomPanelVolSlider:SetMax( 1 )
		bottomPanelVolSlider:SetDecimals( 1 )
		bottomPanelVolSlider:SetText( "Volume" )
		bottomPanelVolSlider:AlignTop(3)
		bottomPanelVolSlider.OnValueChanged = function( self, value )
			currentVol = value
			if internalStation ~= nil then
				internalStation:SetVolume(currentVol)
			end
		end
		
		if currentSelection != "" && string.StartWith( currentSelection, "sound/" ) then
			local reverseStr = string.reverse(currentSelection)
			local lastSlash = string.find(reverseStr, "/")
			if lastSlash != nil then
				fileBrowser:SetCurrentFolder(  string.sub(currentSelection, 1, string.len(currentSelection)-lastSlash) ) 
			end
		else
			currentSelection = ""
		end
		
		if tonumber(mainPropPanel.textBox:GetText()) ~= nil then
			currentVol = tonumber(mainPropPanel.textBox:GetText())
			bottomPanelVolSlider:SetValue( currentVol )
		end
			
		soundSelection:MakePopup()
	end
	
	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	local serverVar = ""
	if parentPanel.lastRecVariable[1] == 1 then 
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel")
	elseif parentPanel.lastRecVariable[1] == 2 then
		serverVar = FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	end
	
	if parentPanel.toggleOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[2] then 
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
	end
	
	if parentPanel.loopOption:GetText() != serverVar then
		return true
	end
	
	if tonumber(parentPanel.textBox:GetText()) != parentPanel.lastRecVariable[3] then
		return true
	end
	
	if tonumber(parentPanel.fadeBox:GetText()) != parentPanel.lastRecVariable[4] then
		return true
	end
	
	if parentPanel.contentBox:GetText() != parentPanel.lastRecVariable[5] then
		return true
	end
	
	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	local previewCopy = FMainMenu.ConfigPreview.previewCopy

	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel") then
		previewCopy["_"..configPropList[1]] = 1
		parentPanel.contentBox:SetVisible(true)
		parentPanel.contentLabel:SetVisible(true)
		parentPanel.audioFileChooseButton:SetVisible(true)
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel") then
		previewCopy["_"..configPropList[1]] = 2
		parentPanel.contentBox:SetVisible(true)
		parentPanel.contentLabel:SetVisible(true)
		parentPanel.audioFileChooseButton:SetVisible(false)
	else
		previewCopy["_"..configPropList[1]] = 0
		parentPanel.contentBox:SetVisible(false)
		parentPanel.contentLabel:SetVisible(false)
		parentPanel.audioFileChooseButton:SetVisible(false)
	end
	
	if parentPanel.loopOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		previewCopy["_"..configPropList[2]] = true
	else
		previewCopy["_"..configPropList[2]] = false
	end
	
	if tonumber(parentPanel.textBox:GetText()) != nil then
		previewCopy["_"..configPropList[3]] = tonumber(parentPanel.textBox:GetText())
	end
	
	if tonumber(parentPanel.fadeBox:GetText()) != nil then
		previewCopy["_"..configPropList[4]] = tonumber(parentPanel.fadeBox:GetText())
	end
	
	previewCopy["_"..configPropList[5]] = parentPanel.contentBox:GetText()
end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function()
	if soundSelection != nil then
		soundSelection:Close()
	end
end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
		
	if parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel") then
		parentPanel.lastRecVariable[1] = 1
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel") then
		parentPanel.lastRecVariable[1] = 2
	elseif parentPanel.toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[1] = 0
	else
		return
	end
	
	if parentPanel.loopOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
		parentPanel.lastRecVariable[2] = true
	elseif parentPanel.loopOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
		parentPanel.lastRecVariable[2] = false
	else
		return
	end
	
	if tonumber(parentPanel.textBox:GetText()) != nil then
		parentPanel.lastRecVariable[3] = tonumber(parentPanel.textBox:GetText())
	else
		return
	end
	
	if tonumber(parentPanel.fadeBox:GetText()) != nil then
		parentPanel.lastRecVariable[4] = tonumber(parentPanel.fadeBox:GetText())
	else
		return
	end
	
	parentPanel.lastRecVariable[5] = parentPanel.contentBox:GetText()
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	if receivedVarTable[1] == 2 then 
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel")) 
	elseif receivedVarTable[1] == 1 then
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel"))
	else
		parentPanel.toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end
	
	if receivedVarTable[2] then 
		parentPanel.loopOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled")) 
	else
		parentPanel.loopOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
	end
	
	parentPanel.textBox:SetText(receivedVarTable[3])
	parentPanel.fadeBox:SetText(receivedVarTable[4])
	parentPanel.contentBox:SetText(receivedVarTable[5])
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end