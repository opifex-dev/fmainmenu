--[[

	Helper Functions For IGC Modules

]]--

local tonumber = tonumber
local math_Round = math.Round
local vgui_Create = vgui.Create
local FMainMenu = FMainMenu
local Color = Color
local net_Start = net.Start
local net_WriteTable = net.WriteTable
local net_SendToServer = net.SendToServer
local net_Receive = net.Receive
local net_ReadString = net.ReadString
local util_JSONToTable = util.JSONToTable
local type = type
local table_GetKeys = table.GetKeys
local game_GetMap = game.GetMap
local table_Copy = table.Copy
local net_WriteString = net.WriteString
local util_TableToJSON = util.TableToJSON
local ipairs = ipairs
local ScrW = ScrW
local ScrH = ScrH
local sound_PlayFile = sound.PlayFile
local IsValid = IsValid
local string_reverse = string.reverse
local string_find = string.find
local string_sub = string.sub
local string_len = string.len
local surface_PlaySound = surface.PlaySound

FMainMenu.ConfigModulesHelper = FMainMenu.ConfigModulesHelper || {}
local soundSelection = nil
local infoPopup = nil
local fontList = {
	"akbar",
	"coolvetica",
	"Roboto",
	"Marlett",
	"DermaLarge",
}

-- Used to detect changes in the on-screen form from the server-side variable
FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges = function(boxText, serverSide, precision)
	return tonumber(boxText) == nil || math_Round(tonumber(boxText), precision) != math_Round(serverSide, precision)
end

-- Function that helps to easily create the bottom buttons of the property editor
FMainMenu.ConfigModulesHelper.setupGeneralPropPanels = function()
	local propertyGeneralPanel = vgui_Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
	propertyGeneralPanel:SetSize( 240, 65 )
	propertyGeneralPanel:SetPos(5,290)

	local propPanelSaveButton = vgui_Create("fmainmenu_config_editor_button", propertyGeneralPanel)
	propPanelSaveButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesSavePropButton"))
	propPanelSaveButton:SetSize(200,25)
	propPanelSaveButton:AlignLeft(20)
	propPanelSaveButton:AlignTop(5)
	propPanelSaveButton.DoClick = function(button)
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].saveFunc()
		surface_PlaySound("friends/friend_join.wav")
		FMainMenu.ConfigModulesHelper.setUnsaved(false)
	end
	FMainMenu.Derma.SetPanelHover(propPanelSaveButton, 1)

	local propPanelRevertButton = vgui_Create("fmainmenu_config_editor_button", propertyGeneralPanel)
	propPanelRevertButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesRevertPropButton"))
	propPanelRevertButton:SetSize(200,25)
	propPanelRevertButton:AlignLeft(20)
	propPanelRevertButton:AlignTop(35)
	propPanelRevertButton.DoClick = function(button)
		local varsToRevert = FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].revertFunc()
		surface_PlaySound("garrysmod/ui_return.wav")
		FMainMenu.ConfigModulesHelper.requestVariables(varsToRevert)
	end
	FMainMenu.Derma.SetPanelHover(propPanelRevertButton, 1)
end

-- Update active property in editor
FMainMenu.ConfigModulesHelper.setPropPanel = function(newPanel)
	-- Run related closing functions for previous panel
	if FMainMenu.configPropertyWindow.onCloseProp != nil then
		FMainMenu.configPropertyWindow.onCloseProp()
		FMainMenu.configPropertyWindow.onCloseProp = nil
	end

	-- Remove old panel
	if (FMainMenu.configPropertyWindow.currentProp != nil) then
		FMainMenu.configPropertyWindow.currentProp:Remove()
	end

	-- Set new panel as current property
	FMainMenu.configPropertyWindow.currentProp = newPanel

	-- Assign new closing function, if provided
	if FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].onClosePropFunc != nil then
		FMainMenu.configPropertyWindow.onCloseProp = FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].onClosePropFunc
	end

	FMainMenu.configPropertyWindow.configBlockerPanel = vgui_Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
	FMainMenu.configPropertyWindow.configBlockerPanel:SetBGColor(Color(0, 0, 0, 155))
	FMainMenu.configPropertyWindow.configBlockerPanel:SetSize( 240, 330 )
	FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(false)
	FMainMenu.configPropertyWindow.configBlockerPanel:SetZPos(100)
	FMainMenu.configPropertyWindow.configBlockerPanel:AlignLeft(5)
	FMainMenu.configPropertyWindow.configBlockerPanel:AlignTop(25)

	FMainMenu.configPropertyWindow:MakePopup()
end

-- Checks to see if colors are equal
FMainMenu.ConfigModulesHelper.areColorsEqual = function(colorOne, colorTwo)
	if colorOne.r != colorTwo.r then
		return false
	end

	if colorOne.g != colorTwo.g then
		return false
	end

	if colorOne.b != colorTwo.b then
		return false
	end

	if colorOne.a != colorTwo.a then
		return false
	end

	return true
end

-- Basic Property Header
FMainMenu.ConfigModulesHelper.generatePropertyHeader = function(propName, propDesc)
	local propHeader = vgui_Create("fmainmenu_config_editor_scrollpanel", FMainMenu.configPropertyWindow)
	propHeader:SetSize( 240, 265 )
	propHeader:SetPos(5,25)
	propHeader.tempYPos = 0
	local propHeaderLabel = vgui_Create("fmainmenu_config_editor_label", propHeader)
	propHeaderLabel:SetText(propName)
	propHeaderLabel:SetFont("HudHintTextLarge")
	propHeaderLabel:SetPos(2,0)
	local propHeaderDescLabel = vgui_Create("fmainmenu_config_editor_label", propHeader)
	propHeaderDescLabel:SetText(propDesc)
	propHeaderDescLabel:SetPos(3, 24)
	propHeaderDescLabel:SetSize(225, 36)

	return propHeader
end

-- Request server-side variable(s) for editing
FMainMenu.ConfigModulesHelper.requestVariables = function(varNames)
	net_Start("FMainMenu_Config_ReqVar")
		net_WriteTable(varNames)
	net_SendToServer()
end

-- Request server-side variable(s) for editing
FMainMenu.ConfigModulesHelper.requestVariablesCustom = function(varNames, responseFunc)
	FMainMenu.configPropertyWindow.customFunc = responseFunc

	FMainMenu.ConfigModulesHelper.requestVariables(varNames)
end

-- Handle received server-side variable(s)
net_Receive( "FMainMenu_Config_ReqVar", function( len )
	local receivedStr = net_ReadString()
	local receivedVarTable = util_JSONToTable( receivedStr )

	-- add fix for "Colors will not have the color metatable" bug
	for i = 1, #receivedVarTable do
		if type(receivedVarTable[i]) == "table" then
			local innerTable = receivedVarTable[i]
			local innerKeyList = table_GetKeys(innerTable)
			if #innerKeyList == 4 && innerTable.a != nil && innerTable.r != nil && innerTable.g != nil && innerTable.b != nil then
				receivedVarTable[i] = Color(innerTable.r, innerTable.g, innerTable.b, innerTable.a)
			end
		end
	end

	-- fix for any map-based variables not existing
	local mapName = game_GetMap()
	for i = 1, #receivedVarTable do
		if type(receivedVarTable[i]) == "table" && receivedVarTable[i][mapName] == nil && receivedVarTable[i]["gm_flatgrass"] != nil then
			receivedVarTable[i][mapName] = receivedVarTable[i]["gm_flatgrass"]
		end
	end

	FMainMenu.configPropertyWindow.currentProp.lastRecVariable = table_Copy(receivedVarTable)

	if FMainMenu.configPropertyWindow.customFunc != nil then
		FMainMenu.configPropertyWindow.customFunc(receivedVarTable)
		FMainMenu.configPropertyWindow.customFunc = nil
	else
		FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].varFetch(receivedVarTable)
	end

	FMainMenu.ConfigModulesHelper.setUnsaved(false)
	FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].updatePreview()
end)

-- Send the request to commit config changes
FMainMenu.ConfigModulesHelper.updateVariables = function(varTable, varList)
	net_Start("FMainMenu_Config_UpdateVar")
		net_WriteTable(varList)
		net_WriteString(util_TableToJSON(varTable))
	net_SendToServer()
end

-- Sets unsaved status, used for 
FMainMenu.ConfigModulesHelper.setUnsaved = function(state)
	FMainMenu.CurConfigMenu.unsavedVar = state
	FMainMenu.CurConfigMenu.configUnsavedBlocker:SetVisible(state)
end

FMainMenu.ConfigModulesHelper.setExternalBlock = function(state)
	FMainMenu.CurConfigMenu.configExternalWindowBlocker:SetVisible(state)
end

--[[
ADJUSTMENT TYPES
1 - none
2 - shift to left X pixels
3 - shift to left X/2 pixels (keep centered)
4 - decrease size X pixels
]]--

local panelScrollAjustments = {
	[1] = function(panel) end,
	[2] = function(panel)
		panel:AlignLeft(panel:GetX() - 15)
	end,
	[3] = function(panel)
		panel:AlignLeft(panel:GetX() - 7.5)
	end,
	[4] = function(panel)
		local oldX, oldY = panel:GetSize()
		panel:SetSize(oldX-15, oldY)
	end,
}

-- Positioning/Sizing Adjustments for property panels when a scroll bar is needed
FMainMenu.ConfigModulesHelper.scrollBarAdjustments = function()
	local mainPanel = FMainMenu.configPropertyWindow.currentProp
	local widetsPanel = mainPanel:GetChildren()[1]

	if mainPanel.tempYPos > 198 then
		for _,widget in ipairs(widetsPanel:GetChildren()) do
			if widget.scrollAdjustmentType != nil then
				panelScrollAjustments[widget.scrollAdjustmentType](widget)
			end
		end
	end
end

-- Closes any open extra windows (sound selector, info popup, etc.)
FMainMenu.ConfigModulesHelper.closeOpenExtraWindows = function()
	if soundSelection != nil then
		soundSelection:Close()
	end

	if infoPopup != nil then
		infoPopup:Close()
	end
end

-- Whether the user has the sound editor open
FMainMenu.ConfigModulesHelper.isSelectingSound = function()
	if soundSelection != nil then
		return true
	end

	return false
end

-- Opens a sound selection dialog
FMainMenu.ConfigModulesHelper.doSoundSelection = function(contentBox, volumeBox)
	FMainMenu.ConfigModulesHelper.setExternalBlock(true)
	FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(true)

	local internalStation = nil
	local currentVol = 0.5
	local currentSelection = contentBox:GetText()
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

		sound_PlayFile( path , "noblock", function( station, errCode, errStr )
			if ( IsValid( station ) ) then
				station:EnableLooping(true)
				station:SetVolume(currentVol)
				internalStation = station
			end
		end)
	end

	-- frame setup
	soundSelection = vgui_Create( "fmainmenu_config_editor" )
	soundSelection:SetSize( 720, 580 )
	soundSelection:SetPos(screenWidth / 2 - 360, screenHeight / 2 - 290)
	soundSelection:SetTitle(FMainMenu.GetPhrase("ConfigSoundSelectorWindowTitle"))
	soundSelection:SetZPos(10)
	function soundSelection:OnClose()
		stopSoundPreview()
		FMainMenu.ConfigModulesHelper.setExternalBlock(false)
		FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(false)

		soundSelection = nil
	end

	-- file tree
	local fileBrowser = vgui_Create( "DFileBrowser", soundSelection )
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
		soundSelection:SetTitle(FMainMenu.GetPhrase("ConfigSoundSelectorWindowTitle") .. " (" .. FMainMenu.GetPhrase("ConfigSoundSelectorWindowSelectionHeader") .. currentSelection .. ")")
	end

	function fileBrowser:OnDoubleClick( path, pnl )
		soundPreview(path)
	end

	-- bottom toolbar
	local bottomPanel = vgui_Create("fmainmenu_config_editor_panel", soundSelection)
	bottomPanel:SetSize( 710, 30 )
	bottomPanel:AlignLeft(5)
	bottomPanel:AlignTop(545)

	local bottomPanelSelectButton = vgui_Create("fmainmenu_config_editor_button", bottomPanel)
	bottomPanelSelectButton:SetText(FMainMenu.GetPhrase("ConfigSoundSelectorChooseButtonText"))
	bottomPanelSelectButton:SetSize(100,24)
	bottomPanelSelectButton:AlignRight(5)
	bottomPanelSelectButton:AlignTop(3)
	bottomPanelSelectButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		if currentSelection != "" then
			surface_PlaySound("garrysmod/content_downloaded.wav")
			contentBox:SetText(currentSelection)
			contentBox:OnChange()
			if volumeBox != nil then
				volumeBox:SetText(math_Round( currentVol, 2))
				volumeBox:OnChange()
			end
		end

		soundSelection:Close()
	end
	FMainMenu.Derma.SetPanelHover(bottomPanelSelectButton, 1)

	local bottomPanelPlayButton = vgui_Create("fmainmenu_config_editor_button", bottomPanel)
	bottomPanelPlayButton:SetText(FMainMenu.GetPhrase("ConfigSoundSelectorPlayButtonText"))
	bottomPanelPlayButton:SetSize(100,24)
	bottomPanelPlayButton:AlignLeft(5)
	bottomPanelPlayButton:AlignTop(3)
	bottomPanelPlayButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		if currentSelection != "" then
			soundPreview(currentSelection)
		end
	end
	FMainMenu.Derma.SetPanelHover(bottomPanelPlayButton, 1)

	local bottomPanelStopButton = vgui_Create("fmainmenu_config_editor_button", bottomPanel)
	bottomPanelStopButton:SetText(FMainMenu.GetPhrase("ConfigSoundSelectorStopButtonText"))
	bottomPanelStopButton:SetSize(100,24)
	bottomPanelStopButton:AlignLeft(110)
	bottomPanelStopButton:AlignTop(3)
	bottomPanelStopButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		stopSoundPreview()
	end
	FMainMenu.Derma.SetPanelHover(bottomPanelStopButton, 1)

	local bottomPanelVolSlider = vgui_Create("DNumSlider", bottomPanel)
	bottomPanelVolSlider:SetSize(250,24)
	bottomPanelVolSlider:AlignLeft(290)
	bottomPanelVolSlider:SetMin( 0 )
	bottomPanelVolSlider:SetMax( 1 )
	bottomPanelVolSlider:SetDecimals( 1 )
	bottomPanelVolSlider:SetText( "Volume" )
	bottomPanelVolSlider:AlignTop(3)
	bottomPanelVolSlider.OnValueChanged = function( self, value )
		currentVol = value
		if internalStation != nil then
			internalStation:SetVolume(currentVol)
		end
	end

	if currentSelection != "" then
		local reverseStr = string_reverse(currentSelection)
		local lastSlash = string_find(reverseStr, "/")
		if lastSlash != nil then
			fileBrowser:SetCurrentFolder( string_sub(currentSelection, 1, string_len(currentSelection) - lastSlash) )
		end
	else
		currentSelection = ""
	end

	if volumeBox != nil && tonumber(volumeBox:GetText()) != nil then
		currentVol = tonumber(volumeBox:GetText())
		bottomPanelVolSlider:SetValue( currentVol )
	end

	soundSelection:MakePopup()
end

-- Opens an information dialog
FMainMenu.ConfigModulesHelper.doInformationalWindow = function(windowTitle, infoText)
	FMainMenu.ConfigModulesHelper.setExternalBlock(true)
	FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(true)

	local screenWidth = ScrW()
	local screenHeight = ScrH()

	-- frame setup
	infoPopup = vgui_Create( "fmainmenu_config_editor" )
	infoPopup:SetSize( 360, 280 )
	infoPopup:SetPos(screenWidth / 2 - 180, screenHeight / 2 - 140)
	infoPopup:SetTitle(windowTitle)
	infoPopup:SetZPos(10)
	function infoPopup:OnClose()
		FMainMenu.ConfigModulesHelper.setExternalBlock(false)
		FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(false)

		infoPopup = nil
	end

	-- background panel
	local mainPanel = vgui_Create("fmainmenu_config_editor_panel", infoPopup)
	mainPanel:SetSize( 350, 250 )
	mainPanel:AlignLeft(5)
	mainPanel:AlignTop(25)

	-- information label
	local mainLabel = vgui_Create("fmainmenu_config_editor_label", mainPanel)
	mainLabel:SetText(infoText)
	mainLabel:SetSize(350,210)
	mainLabel:AlignLeft(5)
	mainLabel:AlignTop(3)
	mainLabel:SetContentAlignment(7)
	mainLabel:SetWrap( true )

	-- close button
	local closeButton = vgui_Create("fmainmenu_config_editor_button", mainPanel)
	closeButton:SetText(FMainMenu.GetPhrase("ConfigCommonValueClose"))
	closeButton:SetSize(300,25)
	closeButton:AlignRight(25)
	closeButton:AlignTop(215)
	closeButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		infoPopup:Close()
	end
	FMainMenu.Derma.SetPanelHover(closeButton, 1)

	infoPopup:MakePopup()
end

-- Reused code between buttons editors for allowing user to confirm action
FMainMenu.ConfigModulesHelper.doAdvancedConfirmationDialog = function(panelBlocker, confirmFunc, warnText)
	--Confirmation dialogue
	panelBlocker:SetVisible(true)
	local removeConfirm =  vgui_Create("fmainmenu_config_editor_panel", panelBlocker)
	removeConfirm:SetBGColor(Color(55, 55, 55, 255))
	removeConfirm:SetSize( 246, 93 )
	removeConfirm:Center()

	local leftText = FMainMenu.Derma.CreateDLabel(removeConfirm, 221, 113, false, warnText)
	leftText:SetPos(10, 5)

	local secondButton = FMainMenu.Derma.CreateDButton(removeConfirm, 108, 32, FMainMenu.GetPhrase("ConfigCommonValueNo"), "")
	secondButton:SetPos(130, 56)
	FMainMenu.Derma.SetPanelHover(secondButton, 1)
	FMainMenu.Derma:SetFrameSettings(secondButton, Color(75,75,75, 255), 0)
	secondButton.DoClick = function()
		surface_PlaySound("garrysmod/ui_click.wav")
		removeConfirm:Remove()
		panelBlocker:SetVisible(false)
	end

	local firstButton = FMainMenu.Derma.CreateDButton(removeConfirm, 108, 32, FMainMenu.GetPhrase("ConfigCommonValueYes"), "")
	firstButton:SetPos(8, 56)
	FMainMenu.Derma.SetPanelHover(firstButton, 1)
	FMainMenu.Derma:SetFrameSettings(firstButton, Color(75,75,75, 255), 0)
	firstButton.DoClick = function()
		surface_PlaySound("garrysmod/ui_click.wav")
		removeConfirm:Remove()
		panelBlocker:SetVisible(false)

		confirmFunc()
	end
end

-- Get usable font (shared table between derma modules)
FMainMenu.ConfigModulesHelper.getAvailableFonts = function()
	return fontList
end