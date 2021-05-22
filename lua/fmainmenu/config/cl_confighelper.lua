--[[

	Helper Functions For IGC Modules

]]--

FMainMenu.ConfigModulesHelper = FMainMenu.ConfigModulesHelper || {}

-- Used to detect changes in the on-screen form from the server-side variable
FMainMenu.ConfigModulesHelper.numericTextBoxHasChanges = function(boxText, serverSide, precision)
	return (tonumber(boxText) == nil || math.Round(tonumber(boxText), precision) != math.Round(serverSide, precision))
end

-- Function that helps to easily create the bottom buttons of the property editor
FMainMenu.ConfigModulesHelper.setupGeneralPropPanels = function()	
	local propertyGeneralPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
	propertyGeneralPanel:SetSize( 240, 65 )
	propertyGeneralPanel:SetPos(5,290)
	
	local propPanelSaveButton = vgui.Create("fmainmenu_config_editor_button", propertyGeneralPanel)
	propPanelSaveButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesSavePropButton"))
	propPanelSaveButton:SetSize(200,25)
	propPanelSaveButton:AlignLeft(20)
	propPanelSaveButton:AlignTop(5)
	propPanelSaveButton.DoClick = function(button)
		local varsToUpdate = FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].saveFunc()
		FMainMenu.ConfigModulesHelper.setUnsaved(false)
	end
	
	local propPanelRevertButton = vgui.Create("fmainmenu_config_editor_button", propertyGeneralPanel)
	propPanelRevertButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesRevertPropButton"))
	propPanelRevertButton:SetSize(200,25)
	propPanelRevertButton:AlignLeft(20)
	propPanelRevertButton:AlignTop(35)
	propPanelRevertButton.DoClick = function(button)
		local varsToRevert = FMainMenu.ConfigModules[FMainMenu.configPropertyWindow.propertyCode].revertFunc()
		FMainMenu.ConfigModulesHelper.requestVariables(varsToRevert)
	end
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
	
	FMainMenu.configPropertyWindow.configBlockerPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
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
	local propHeader = vgui.Create("fmainmenu_config_editor_scrollpanel", FMainMenu.configPropertyWindow)
	propHeader:SetSize( 240, 265 )
	propHeader:SetPos(5,25)
	propHeader.tempYPos = 0
	local propHeaderLabel = vgui.Create("fmainmenu_config_editor_label", propHeader)
	propHeaderLabel:SetText(propName)
	propHeaderLabel:SetFont("HudHintTextLarge")
	propHeaderLabel:SetPos(2,0)
	local propHeaderDescLabel = vgui.Create("fmainmenu_config_editor_label", propHeader)
	propHeaderDescLabel:SetText(propDesc)
	propHeaderDescLabel:SetPos(3, 24)
	propHeaderDescLabel:SetSize(225, 36)
	
	return propHeader
end

-- Request server-side variable(s) for editing
FMainMenu.ConfigModulesHelper.requestVariables = function(varNames)
	net.Start("FMainMenu_Config_ReqVar")
		net.WriteTable(varNames)
	net.SendToServer()
end

-- Request server-side variable(s) for editing
FMainMenu.ConfigModulesHelper.requestVariablesCustom = function(varNames, responseFunc)
	FMainMenu.configPropertyWindow.customFunc = responseFunc

	FMainMenu.ConfigModulesHelper.requestVariables(varNames)
end

-- Handle received server-side variable(s)
net.Receive( "FMainMenu_Config_ReqVar", function( len )
	local receivedStr = net.ReadString()
	local receivedVarTable = util.JSONToTable( receivedStr )
	
	-- add fix for "Colors will not have the color metatable" bug
	for i=1,#receivedVarTable do
		if type(receivedVarTable[i]) == "table" then
			local innerTable = receivedVarTable[i]
			local innerKeyList = table.GetKeys(innerTable)
			if(#innerKeyList == 4 && innerTable.a ~= nil && innerTable.r ~= nil && innerTable.g ~= nil && innerTable.b ~= nil) then
				receivedVarTable[i] = Color(innerTable.r, innerTable.g, innerTable.b, innerTable.a)
			end
		end
	end
	
	-- fix for any map-based variables not existing
	local mapName = game.GetMap()
	for i=1,#receivedVarTable do
		if type(receivedVarTable[i]) == "table" then
			if (receivedVarTable[i][mapName] == nil && receivedVarTable[i]["gm_flatgrass"] != nil) then
				receivedVarTable[i][mapName] = receivedVarTable[i]["gm_flatgrass"]
			end
		end
	end
	
	FMainMenu.configPropertyWindow.currentProp.lastRecVariable = table.Copy(receivedVarTable)
	
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
	net.Start("FMainMenu_Config_UpdateVar")
		net.WriteTable(varList)
		net.WriteString(util.TableToJSON(varTable))
	net.SendToServer()
end

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
		panel:AlignLeft(panel:GetX()-15)
	end,
	[3] = function(panel)
		panel:AlignLeft(panel:GetX()-7.5)
	end,
	[4] = function(panel)
		local oldX, oldY = panel:GetSize()
		panel:SetSize(oldX-15, oldY)
	end,
}

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