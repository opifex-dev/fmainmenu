FMainMenu.CurConfigMenu = FMainMenu.CurConfigMenu || nil
FMainMenu.configPropertyWindow = FMainMenu.configPropertyWindow || nil

-- Function that helps to easily create the bottom buttons of the property editor
local function setupGeneralPropPanels(configPropertyWindow, saveFunc, revertFunc)
	-- General Panel
	local separatePanel = vgui.Create("fmainmenu_config_editor_panel", configPropertyWindow)
	separatePanel:SetSize( 240, 10 )
	separatePanel:SetPos(5,280)
	separatePanel:SetBGColor(Color(105,105,105))
	
	local propertyGeneralPanel = vgui.Create("fmainmenu_config_editor_panel", configPropertyWindow)
	propertyGeneralPanel:SetSize( 240, 65 )
	propertyGeneralPanel:SetPos(5,290)
	
	local propPanelSaveButton = vgui.Create("fmainmenu_config_editor_button", propertyGeneralPanel)
	propPanelSaveButton:SetText(FMainMenu.Lang.ConfigPropertiesSavePropButton)
	propPanelSaveButton:SetSize(200,25)
	propPanelSaveButton:AlignLeft(20)
	propPanelSaveButton:AlignTop(5)
	propPanelSaveButton.DoClick = function(button)
		saveFunc()
	end
	
	local propPanelRevertButton = vgui.Create("fmainmenu_config_editor_button", propertyGeneralPanel)
	propPanelRevertButton:SetText(FMainMenu.Lang.ConfigPropertiesRevertPropButton)
	propPanelRevertButton:SetSize(200,25)
	propPanelRevertButton:AlignLeft(20)
	propPanelRevertButton:AlignTop(35)
	propPanelRevertButton.DoClick = function(button)
		revertFunc()
	end
end

-- Send the request to commit config changes
local function updateVariables(varTable, varList)
	net.Start("FMainMenu_Config_UpdateVar")
		net.WriteTable(varList)
		net.WriteString(util.TableToJSON(varTable))
	net.SendToServer()
end

-- Update active property in editor
local function setPropPanel(newPanel, onClosePropFunc)
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
	if onClosePropFunc != nil then
		FMainMenu.configPropertyWindow.onCloseProp = onClosePropFunc
	end
	
	FMainMenu.configPropertyWindow:MakePopup()
end

-- Request server-side variable(s) for editing
local function requestVariables(varRecCallback, varNames)
	FMainMenu.configPropertyWindow.onVarRecFunc = varRecCallback

	net.Start("FMainMenu_Config_ReqVar")
		net.WriteTable(varNames)
	net.SendToServer()
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
				receivedVarTable[keyList[i]] = Color(innerTable.r, innerTable.g, innerTable.b, innerTable.a)
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
	
	FMainMenu.configPropertyWindow.onVarRecFunc(receivedVarTable)
end)

-- If player is allowed, open editor
net.Receive( "FMainMenu_Config_OpenMenu", function( len )
	-- Editor cannot open when the player is currently in the main menu (live preview restrictions)
	if net.ReadBool() then
		FMainMenu.Log(FMainMenu.Lang.ConfigLeaveMenu, false)
		return
	end
	
	-- Prevent duplicate windows
	if FMainMenu.CurConfigMenu == nil then
		local screenWidth = ScrW()
		local screenHeight = ScrH()
		
		local mainBlocker = vgui.Create("fmainmenu_config_editor_panel")
		mainBlocker:SetSize( screenWidth, screenHeight )
		mainBlocker.Paint = function(s, width, height) end
		mainBlocker:SetZPos(5)
		
		
		
		--[[
			Config Properties Window
		]]--
		
		FMainMenu.configPropertyWindow = vgui.Create( "fmainmenu_config_editornoclose" )
		FMainMenu.configPropertyWindow:SetSize( 250, 360 )
		FMainMenu.configPropertyWindow:SetPos(screenWidth-250, screenHeight-360)
		FMainMenu.configPropertyWindow:SetTitle(FMainMenu.Lang.ConfigPropertiesWindowTitle)
		FMainMenu.configPropertyWindow.propertyCode = 0
		FMainMenu.configPropertyWindow:SetZPos(10)
		
		FMainMenu.configPropertyWindow.currentProp = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
		FMainMenu.configPropertyWindow.currentProp:SetSize( 240, 330 )
		FMainMenu.configPropertyWindow.currentProp:SetPos(5,25)
		
		local configPropertyWindowDefLabel = vgui.Create("fmainmenu_config_editor_label", FMainMenu.configPropertyWindow.currentProp)
		configPropertyWindowDefLabel:SetText(FMainMenu.Lang.ConfigPropertiesNoneSelected)
		configPropertyWindowDefLabel:SetSize(240, 25)
		configPropertyWindowDefLabel:SetFont("HudHintTextLarge")
		configPropertyWindowDefLabel:SetContentAlignment(5)
		
		
	
		--[[
			Config Option Selector
		]]--
		
		FMainMenu.CurConfigMenu = vgui.Create( "fmainmenu_config_editornoclose" )
		FMainMenu.CurConfigMenu:SetSize( 250, 250 )
		FMainMenu.CurConfigMenu:SetPos(screenWidth-250, screenHeight-620)
		FMainMenu.CurConfigMenu:SetTitle(FMainMenu.Lang.ConfigPropertiesSelectorTitle)
		FMainMenu.CurConfigMenu.unsavedVar = false
		FMainMenu.CurConfigMenu:SetZPos(10)
		
		local configSheet = vgui.Create( "fmainmenu_config_editor_sheet", FMainMenu.CurConfigMenu)
		configSheet:SetSize( 240, 220 )
		configSheet:AlignRight(5)
		configSheet:AlignTop(25)
		
		local configUnsavedBlocker = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.CurConfigMenu)
		configUnsavedBlocker:SetSize( 240, 190 )
		configUnsavedBlocker:SetBGColor(Color(0,0,0,155))
		configUnsavedBlocker:AlignRight(5)
		configUnsavedBlocker:AlignTop(55)
		configUnsavedBlocker:SetVisible(false)
		
		local function setUnsaved(state)
			FMainMenu.CurConfigMenu.unsavedVar = state
			configUnsavedBlocker:SetVisible(state)
		end
		
		local configSheetOne = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetOne:SetSize( 240, 220 )
		
		--Camera Setup
		local cameraSetupButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetOne)
		cameraSetupButtonLiveIndicator:SetSize( 15, 15 )
		cameraSetupButtonLiveIndicator:AlignRight(12)
		cameraSetupButtonLiveIndicator:AlignTop(10)
		cameraSetupButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetOneCameraSetupButton = vgui.Create("fmainmenu_config_editor_button", configSheetOne)
		configSheetOneCameraSetupButton:SetText(FMainMenu.Lang.ConfigPropertiesCameraSetupPropName)
		configSheetOneCameraSetupButton:SetSize(200,25)
		configSheetOneCameraSetupButton:AlignLeft(4)
		configSheetOneCameraSetupButton:AlignTop(5)
		configSheetOneCameraSetupButton.DoClick = function(button)
			local propertyCode = 1
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local cameraPosition = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			cameraPosition:SetSize( 240, 255 )
			cameraPosition:SetPos(5,25)
			local cameraPositionLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionLabel:SetText(FMainMenu.Lang.ConfigPropertiesCameraSetupPropName)
			cameraPositionLabel:SetFont("HudHintTextLarge")
			local cameraPositionDescLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionDescLabel:SetText(FMainMenu.Lang.ConfigPropertiesCameraSetupPropDesc)
			cameraPositionDescLabel:SetPos(1, 24)
			cameraPositionDescLabel:SetSize(225, 36)
			
			-- Position
			local cameraPositionLabel2 = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionLabel2:SetText(FMainMenu.Lang.ConfigPropertiesCameraSetupPosLabel)
			cameraPositionLabel2:SetPos(0, 70)
			local cameraPositionPosBoxXLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionPosBoxXLabel:SetText("X: ")
			cameraPositionPosBoxXLabel:SetPos(60, 88)	
			local cameraPositionPosBoxX = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionPosBoxX:SetSize( 75, 18 )
			cameraPositionPosBoxX:SetPos( 80, 88 )
			local cameraPositionPosBoxYLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionPosBoxYLabel:SetText("Y: ")
			cameraPositionPosBoxYLabel:SetPos(60, 104)
			local cameraPositionPosBoxY = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionPosBoxY:SetSize( 75, 18 )
			cameraPositionPosBoxY:SetPos( 80, 104 )
			local cameraPositionPosBoxZLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionPosBoxZLabel:SetText("Z: ")
			cameraPositionPosBoxZLabel:SetPos(60, 120)
			local cameraPositionPosBoxZ = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionPosBoxZ:SetSize( 75, 18 )
			cameraPositionPosBoxZ:SetPos( 80, 120 )
			
			-- Orientation
			local cameraPositionLabel3 = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionLabel3:SetText(FMainMenu.Lang.ConfigPropertiesCameraSetupAngLabel)
			cameraPositionLabel3:SetPos(0, 145)
			local cameraPositionRotBoxXLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionRotBoxXLabel:SetText("X: ")
			cameraPositionRotBoxXLabel:SetPos(60, 163)
			local cameraPositionRotBoxX = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionRotBoxX:SetSize( 75, 18 )
			cameraPositionRotBoxX:SetPos( 80, 163 )
			local cameraPositionRotBoxYLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionRotBoxYLabel:SetText("Y: ")
			cameraPositionRotBoxYLabel:SetPos(60, 179)
			local cameraPositionRotBoxY = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionRotBoxY:SetSize( 75, 18 )
			cameraPositionRotBoxY:SetPos( 80, 179 )
			local cameraPositionRotBoxZLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionRotBoxZLabel:SetText("Z: ")
			cameraPositionRotBoxZLabel:SetPos(60, 195)
			local cameraPositionRotBoxZ = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionRotBoxZ:SetSize( 75, 18 )
			cameraPositionRotBoxZ:SetPos( 80, 195 )
			
			-- Used to detect changes in the on-screen form from the server-side variable
			local function checkTextBox(boxText, serverSide)
				return (tonumber(boxText) == nil || math.Round(tonumber(boxText), 3) != math.Round(serverSide, 3))
			end
			
			local function isVarChanged()
				local mapName = game.GetMap()
				
				LocalPlayer():SetNoDraw( false )
				
				if checkTextBox(cameraPositionPosBoxX:GetText(), cameraPosition.lastRecVariable[1][mapName].x) then
					setUnsaved(true)
					return
				end
				
				if checkTextBox(cameraPositionPosBoxY:GetText(), cameraPosition.lastRecVariable[1][mapName].y) then
					setUnsaved(true)
					return
				end
				
				if checkTextBox(cameraPositionPosBoxZ:GetText(), cameraPosition.lastRecVariable[1][mapName].z) then
					setUnsaved(true)
					return
				end
				
				if checkTextBox(cameraPositionRotBoxX:GetText(), cameraPosition.lastRecVariable[2][mapName].x) then
					setUnsaved(true)
					return
				end
				
				if checkTextBox(cameraPositionRotBoxY:GetText(), cameraPosition.lastRecVariable[2][mapName].y) then
					setUnsaved(true)
					return
				end
				
				if checkTextBox(cameraPositionRotBoxZ:GetText(), cameraPosition.lastRecVariable[2][mapName].z) then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			-- Used to update any live preview stuff, if applicable
			local function updatePreview()
				local mapName = game.GetMap()
				local varUpdate = table.Copy(cameraPosition.lastRecVariable)
				
				if(tonumber(cameraPositionPosBoxX:GetText()) == nil) then return end
				if(tonumber(cameraPositionPosBoxY:GetText()) == nil) then return end
				if(tonumber(cameraPositionPosBoxZ:GetText()) == nil) then return end
				if(tonumber(cameraPositionRotBoxX:GetText()) == nil) then return end
				if(tonumber(cameraPositionRotBoxY:GetText()) == nil) then return end
				if(tonumber(cameraPositionRotBoxZ:GetText()) == nil) then return end

				varUpdate[1][mapName] = Vector(tonumber(cameraPositionPosBoxX:GetText()), tonumber(cameraPositionPosBoxY:GetText()), tonumber(cameraPositionPosBoxZ:GetText()))
				varUpdate[2][mapName] = Angle(tonumber(cameraPositionRotBoxX:GetText()), tonumber(cameraPositionRotBoxY:GetText()), tonumber(cameraPositionRotBoxZ:GetText()))
				
				net.Start("FMainMenu_Config_UpdateTempVariable")
					net.WriteTable({"CameraPosition","CameraAngle"})
					net.WriteString(util.TableToJSON(varUpdate))
				net.SendToServer()
			end
			
			-- Helpful button to substitute current player coordinates
			local cameraPositionChooseButton = vgui.Create("fmainmenu_config_editor_button", cameraPosition)
			cameraPositionChooseButton:SetText(FMainMenu.Lang.ConfigPropertiesCameraSetupCaptureLabel)
			cameraPositionChooseButton:SetSize(200,25)
			cameraPositionChooseButton:AlignLeft(20)
			cameraPositionChooseButton:AlignTop(225)
			cameraPositionChooseButton.DoClick = function(button)
				local ply = LocalPlayer()
				local plyPOS = ply:GetPos()
				local plyANG = ply:EyeAngles()
				
				cameraPositionPosBoxX:SetText(math.Round( plyPOS.x, 3))
				cameraPositionPosBoxY:SetText(math.Round( plyPOS.y, 3))
				cameraPositionPosBoxZ:SetText(math.Round( plyPOS.z, 3))
				
				cameraPositionRotBoxX:SetText(math.Round( plyANG.x, 3))
				cameraPositionRotBoxY:SetText(math.Round( plyANG.y, 3))
				cameraPositionRotBoxZ:SetText(math.Round( plyANG.z, 3))
				
				isVarChanged()
				updatePreview()
				
				LocalPlayer():SetNoDraw( true )
			end
			
			-- OnChange functions for unsaved changes detection and preview updating
			function cameraPositionPosBoxX:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function cameraPositionPosBoxY:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function cameraPositionPosBoxZ:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function cameraPositionRotBoxX:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function cameraPositionRotBoxY:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function cameraPositionRotBoxZ:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				local mapName = game.GetMap()
				
				cameraPosition.lastRecVariable = varTable
				cameraPositionPosBoxX:SetText(math.Round( varTable[1][mapName].x, 3))
				cameraPositionPosBoxY:SetText(math.Round( varTable[1][mapName].y, 3))
				cameraPositionPosBoxZ:SetText(math.Round( varTable[1][mapName].z, 3))
				cameraPositionRotBoxX:SetText(math.Round( varTable[2][mapName].x, 3))
				cameraPositionRotBoxY:SetText(math.Round( varTable[2][mapName].y, 3))
				cameraPositionRotBoxZ:SetText(math.Round( varTable[2][mapName].z, 3))
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"CameraPosition","CameraAngle"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				local mapName = game.GetMap()
				
				if(tonumber(cameraPositionPosBoxX:GetText()) == nil) then return end
				if(tonumber(cameraPositionPosBoxY:GetText()) == nil) then return end
				if(tonumber(cameraPositionPosBoxZ:GetText()) == nil) then return end
				if(tonumber(cameraPositionRotBoxX:GetText()) == nil) then return end
				if(tonumber(cameraPositionRotBoxY:GetText()) == nil) then return end
				if(tonumber(cameraPositionRotBoxZ:GetText()) == nil) then return end

				cameraPosition.lastRecVariable[1][mapName] = Vector(tonumber(cameraPositionPosBoxX:GetText()), tonumber(cameraPositionPosBoxY:GetText()), tonumber(cameraPositionPosBoxZ:GetText()))
				cameraPosition.lastRecVariable[2][mapName] = Angle(tonumber(cameraPositionRotBoxX:GetText()), tonumber(cameraPositionRotBoxY:GetText()), tonumber(cameraPositionRotBoxZ:GetText()))
				
				updateVariables(cameraPosition.lastRecVariable, {"CameraPosition","CameraAngle"})
				setUnsaved(false)
				LocalPlayer():SetNoDraw( false )
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"CameraPosition","CameraAngle"})
				LocalPlayer():SetNoDraw( false )
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(cameraPosition)
		end
		
		-- Every Spawn
		local configSheetOneCameraEverySpawnButton = vgui.Create("fmainmenu_config_editor_button", configSheetOne)
		configSheetOneCameraEverySpawnButton:SetText(FMainMenu.Lang.ConfigPropertiesEverySpawnPropName)
		configSheetOneCameraEverySpawnButton:SetSize(200,25)
		configSheetOneCameraEverySpawnButton:AlignLeft(4)
		configSheetOneCameraEverySpawnButton:AlignTop(35)
		configSheetOneCameraEverySpawnButton.DoClick = function(button)
			local propertyCode = 2
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.Lang.ConfigPropertiesEverySpawnPropName)
			propertyPanelLabel:SetFont("HudHintTextLarge")
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.Lang.ConfigPropertiesEverySpawnPropDesc)
			propertyPanelDescLabel:SetPos(1, 24)
			propertyPanelDescLabel:SetSize(225, 36)
			
			-- Every Spawn
			local cameraEverySpawnLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraEverySpawnLabel2:SetText(FMainMenu.Lang.ConfigPropertiesEverySpawnLabel)
			cameraEverySpawnLabel2:SetPos(0, 70)
			local cameraEverySpawnOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			cameraEverySpawnOption:SetSize( 50, 18 )
			cameraEverySpawnOption:SetPos( 85, 70 )
			cameraEverySpawnOption:SetValue( "True" )
			cameraEverySpawnOption:AddChoice( "True" )
			cameraEverySpawnOption:AddChoice( "False" )
			
			-- Used to detect changes in the on-screen form from the server-side variable
			local function isVarChanged()
				local mapName = game.GetMap()
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] then 
					serverVar = "True"
				else
					serverVar = "False"
				end
				
				if cameraEverySpawnOption:GetValue() != serverVar then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			-- OnChange functions for unsaved changes detection and preview updating
			function cameraEverySpawnOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				if varTable[1] then 
					cameraEverySpawnOption:SetValue("True") 
				else
					cameraEverySpawnOption:SetValue("False")
				end
				setUnsaved(false)
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"EverySpawn"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if cameraEverySpawnOption:GetValue() == "True" then
					propertyPanel.lastRecVariable[1] = true
				elseif cameraEverySpawnOption:GetValue() == "False" then
					propertyPanel.lastRecVariable[1] = false
				else
					return
				end
				
				updateVariables(propertyPanel.lastRecVariable, {"EverySpawn"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"EverySpawn"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- Advanced Spawn
		local configSheetOneCameraAdvancedSpawnButton = vgui.Create("fmainmenu_config_editor_button", configSheetOne)
		configSheetOneCameraAdvancedSpawnButton:SetText(FMainMenu.Lang.ConfigPropertiesAdvancedSpawnPropName)
		configSheetOneCameraAdvancedSpawnButton:SetSize(200,25)
		configSheetOneCameraAdvancedSpawnButton:AlignLeft(4)
		configSheetOneCameraAdvancedSpawnButton:AlignTop(65)
		configSheetOneCameraAdvancedSpawnButton.DoClick = function(button)
			local propertyCode = 3
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.Lang.ConfigPropertiesAdvancedSpawnPropName)
			propertyPanelLabel:SetFont("HudHintTextLarge")
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.Lang.ConfigPropertiesAdvancedSpawnPropDesc)
			propertyPanelDescLabel:SetPos(1, 24)
			propertyPanelDescLabel:SetSize(225, 36)
			
			-- Advanced Spawn Toggle
			local cameraEverySpawnLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraEverySpawnLabel2:SetText(FMainMenu.Lang.ConfigPropertiesAdvancedSpawnOptLabel)
			cameraEverySpawnLabel2:SetPos(0, 70)
			local cameraEverySpawnOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			cameraEverySpawnOption:SetSize( 50, 18 )
			cameraEverySpawnOption:SetPos( 105, 70 )
			cameraEverySpawnOption:SetValue( "False" )
			cameraEverySpawnOption:AddChoice( "True" )
			cameraEverySpawnOption:AddChoice( "False" )	
			
			--Advanced Spawn Position
			local cameraPositionLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionLabel2:SetText(FMainMenu.Lang.ConfigPropertiesAdvancedSpawnPosLabel)
			cameraPositionLabel2:SetPos(0, 91)
			local cameraPositionPosBoxXLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionPosBoxXLabel:SetText("X: ")
			cameraPositionPosBoxXLabel:SetPos(60, 109)	
			local cameraPositionPosBoxX = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			cameraPositionPosBoxX:SetSize( 75, 18 )
			cameraPositionPosBoxX:SetPos( 80, 109 )
			local cameraPositionPosBoxYLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionPosBoxYLabel:SetText("Y: ")
			cameraPositionPosBoxYLabel:SetPos(60, 125)
			local cameraPositionPosBoxY = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			cameraPositionPosBoxY:SetSize( 75, 18 )
			cameraPositionPosBoxY:SetPos( 80, 125 )
			local cameraPositionPosBoxZLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionPosBoxZLabel:SetText("Z: ")
			cameraPositionPosBoxZLabel:SetPos(60, 141)
			local cameraPositionPosBoxZ = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			cameraPositionPosBoxZ:SetSize( 75, 18 )
			cameraPositionPosBoxZ:SetPos( 80, 141 )
			
			-- Helpful function to autofill player's current position
			local cameraPositionChooseButton = vgui.Create("fmainmenu_config_editor_button", propertyPanel)
			cameraPositionChooseButton:SetText(FMainMenu.Lang.ConfigPropertiesAdvancedSpawnCaptureLabel)
			cameraPositionChooseButton:SetSize(200,25)
			cameraPositionChooseButton:AlignLeft(20)
			cameraPositionChooseButton:AlignTop(170)
			cameraPositionChooseButton.DoClick = function(button)
				local ply = LocalPlayer()
				local plyPOS = ply:GetPos()
				
				cameraPositionPosBoxX:SetText(math.Round( plyPOS.x, 3))
				cameraPositionPosBoxY:SetText(math.Round( plyPOS.y, 3))
				cameraPositionPosBoxZ:SetText(math.Round( plyPOS.z, 3))
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable
			local function checkTextBox(boxText, serverSide)
				return (tonumber(boxText) == nil || math.Round(tonumber(boxText), 3) != math.Round(serverSide, 3))
			end
			
			local function isVarChanged()
				local mapName = game.GetMap()
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] then 
					serverVar = "True"
				else
					serverVar = "False"
				end
				
				if cameraEverySpawnOption:GetValue() != serverVar then
					setUnsaved(true)
					return
				end
				
				if checkTextBox(cameraPositionPosBoxX:GetText(), propertyPanel.lastRecVariable[2][mapName].x) then
					setUnsaved(true)
					return
				end
				
				if checkTextBox(cameraPositionPosBoxY:GetText(), propertyPanel.lastRecVariable[2][mapName].y) then
					setUnsaved(true)
					return
				end
				
				if checkTextBox(cameraPositionPosBoxZ:GetText(), propertyPanel.lastRecVariable[2][mapName].z) then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			-- OnChange functions for unsaved changes detection and preview updating
			function cameraEverySpawnOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function cameraPositionPosBoxX:OnChange()
				isVarChanged()
			end
			
			function cameraPositionPosBoxY:OnChange()
				isVarChanged()
			end
			
			function cameraPositionPosBoxZ:OnChange()
				isVarChanged()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				local mapName = game.GetMap()
				
				propertyPanel.lastRecVariable = varTable
				if varTable[1] then 
					cameraEverySpawnOption:SetValue("True") 
				else
					cameraEverySpawnOption:SetValue("False")
				end
				cameraPositionPosBoxX:SetText(math.Round( varTable[2][mapName].x, 3))
				cameraPositionPosBoxY:SetText(math.Round( varTable[2][mapName].y, 3))
				cameraPositionPosBoxZ:SetText(math.Round( varTable[2][mapName].z, 3))
				setUnsaved(false)
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"AdvancedSpawn","AdvancedSpawnPos"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				local mapName = game.GetMap()
				if cameraEverySpawnOption:GetValue() == "True" then
					propertyPanel.lastRecVariable[1] = true
				elseif cameraEverySpawnOption:GetValue() == "False" then
					propertyPanel.lastRecVariable[1] = false
				else
					return
				end
				
				if(tonumber(cameraPositionPosBoxX:GetText()) == nil) then return end
				if(tonumber(cameraPositionPosBoxY:GetText()) == nil) then return end
				if(tonumber(cameraPositionPosBoxZ:GetText()) == nil) then return end

				propertyPanel.lastRecVariable[2][mapName] = Vector(tonumber(cameraPositionPosBoxX:GetText()), tonumber(cameraPositionPosBoxY:GetText()), tonumber(cameraPositionPosBoxZ:GetText()))
				
				updateVariables(propertyPanel.lastRecVariable, {"AdvancedSpawn","AdvancedSpawnPos"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"AdvancedSpawn","AdvancedSpawnPos"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- Hear Other Players
		local cameraHearOtherPlayersButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetOne)
		cameraHearOtherPlayersButtonLiveIndicator:SetSize( 15, 15 )
		cameraHearOtherPlayersButtonLiveIndicator:AlignRight(12)
		cameraHearOtherPlayersButtonLiveIndicator:AlignTop(100)
		cameraHearOtherPlayersButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetOneCameraHearOtherPlayersButton = vgui.Create("fmainmenu_config_editor_button", configSheetOne)
		configSheetOneCameraHearOtherPlayersButton:SetText(FMainMenu.Lang.ConfigPropertiesHearOtherPlayersPropName)
		configSheetOneCameraHearOtherPlayersButton:SetSize(200,25)
		configSheetOneCameraHearOtherPlayersButton:AlignLeft(4)
		configSheetOneCameraHearOtherPlayersButton:AlignTop(95)
		configSheetOneCameraHearOtherPlayersButton.DoClick = function(button)
			local propertyCode = 4
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.Lang.ConfigPropertiesHearOtherPlayersPropName)
			propertyPanelLabel:SetFont("HudHintTextLarge")
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.Lang.ConfigPropertiesHearOtherPlayersPropDesc)
			propertyPanelDescLabel:SetPos(1, 24)
			propertyPanelDescLabel:SetSize(225, 36)
			
			-- Hear Other Players Toggle
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.Lang.ConfigPropertiesHearOtherPlayersLabel)
			toggleLabel:SetPos(0, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 50, 18 )
			toggleOption:SetPos( 118, 70 )
			toggleOption:SetValue( "False" )
			toggleOption:AddChoice( "True" )
			toggleOption:AddChoice( "False" )	
			
			-- Maximum Voice Distance
			local distanceLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			distanceLabel:SetText(FMainMenu.Lang.ConfigPropertiesHearOtherPlayersDistanceLabel)
			distanceLabel:SetPos(0, 91)
			local distanceBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			distanceBox:SetSize( 75, 18 )
			distanceBox:SetPos( 88, 91 )
			
			-- Live Preview Sphere
			local function createSphereHalf()
				local sphereHalf = ents.CreateClientProp("models/props_phx/construct/wood/wood_dome360.mdl")
				sphereHalf:SetMaterial("models/debug/debugwhite")
				sphereHalf:SetColor(Color(0, 255, 0, 155))
				sphereHalf:GetPhysicsObject():EnableMotion( false )
				sphereHalf:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
				sphereHalf:DrawShadow( false )
				sphereHalf:SetRenderMode( RENDERMODE_TRANSCOLOR )
				sphereHalf:DestroyShadow()
				
				return sphereHalf
			end
			
			local topHalfSphere = createSphereHalf()
			topHalfSphere:SetAngles( Angle(0, 0, 180) )
			local bottomHalfSphere = createSphereHalf()
			
			local function updatePreview()
				if toggleOption:GetText() == "False" then
					topHalfSphere:SetModelScale( 0 )
					bottomHalfSphere:SetModelScale( 0 )
					return 
				end
				local boxText = distanceBox:GetText()
				if tonumber(boxText) == nil then return end
				topHalfSphere:SetModelScale( boxText/96 )
				bottomHalfSphere:SetModelScale( boxText/96 )
			end
			
			-- Property panel closing code, used to clean up live preview
			local function onCloseProp()
				topHalfSphere:Remove()
				bottomHalfSphere:Remove()
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable
			local function isVarChanged()
				local mapName = game.GetMap()
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] then 
					serverVar = "True"
				else
					serverVar = "False"
				end
				
				if toggleOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				if tonumber(distanceBox:GetText()) == nil || tonumber(distanceBox:GetText()) != propertyPanel.lastRecVariable[2] then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			-- OnChange functions for unsaved changes detection and preview updating
			function toggleOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			function distanceBox:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				local mapName = game.GetMap()
				
				propertyPanel.lastRecVariable = varTable
				if varTable[1] then 
					toggleOption:SetValue("True") 
				else
					toggleOption:SetValue("False")
				end
				distanceBox:SetText(varTable[2])
				topHalfSphere:SetPos(varTable[3][mapName] + Vector(0,0,64.5))
				bottomHalfSphere:SetPos(varTable[3][mapName] + Vector(0,0,63.5))
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"HearOtherPlayers","PlayerVoiceDistance", "CameraPosition"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				local mapName = game.GetMap()
				if toggleOption:GetValue() == "True" then
					propertyPanel.lastRecVariable[1] = true
				elseif toggleOption:GetValue() == "False" then
					propertyPanel.lastRecVariable[1] = false
				else
					return
				end
				
				if(tonumber(distanceBox:GetText()) == nil) then return end

				propertyPanel.lastRecVariable[2] = tonumber(distanceBox:GetText())
				
				updateVariables(propertyPanel.lastRecVariable, {"HearOtherPlayers","PlayerVoiceDistance"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"HearOtherPlayers","PlayerVoiceDistance", "CameraPosition"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel, onCloseProp)
		end
		
		configSheet:AddSheet( FMainMenu.Lang.ConfigPropertiesCategoriesCamera, configSheetOne, nil )
		
		
		
		local configSheetTwo = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetTwo:SetSize( 240, 230 )
		
		
		
		configSheet:AddSheet( FMainMenu.Lang.ConfigPropertiesCategoriesMenu, configSheetTwo, nil )
		
		
		
		local configSheetThree = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetThree:SetSize( 240, 230 )
		configSheet:AddSheet( FMainMenu.Lang.ConfigPropertiesCategoriesHooks, configSheetThree, nil )
		
		
		
		local configSheetFour = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetFour:SetSize( 240, 230 )
		configSheet:AddSheet( FMainMenu.Lang.ConfigPropertiesCategoriesDerma, configSheetFour, nil )
		
		
		
		local configSheetFive = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetFive:SetSize( 240, 230 )
		configSheet:AddSheet( FMainMenu.Lang.ConfigPropertiesCategoriesAccess, configSheetFive, nil )
		
		
		
		local configSheetSix = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetSix:SetSize( 240, 230 )
		configSheet:AddSheet( FMainMenu.Lang.ConfigPropertiesCategoriesCamera, configSheetSix, nil )
		
		
		
		--[[
			Top-Middle Info Bar
		]]--
		
		local topInfoBar = vgui.Create("fmainmenu_config_editor_panel", mainBlocker)
		topInfoBar:SetSize( screenWidth/3, 30 )
		topInfoBar:SetPos(screenWidth/3,0)
		topInfoBar:SetZPos(10)
		
		local topInfoBarNameLabel = vgui.Create("fmainmenu_config_editor_label", topInfoBar)
		topInfoBarNameLabel:SetText("FMainMenu Config Editor")
		topInfoBarNameLabel:SetFont("Trebuchet24")
		topInfoBarNameLabel:SetContentAlignment( 5 )
		topInfoBarNameLabel:SetSize(screenWidth/3, 30)
		topInfoBarNameLabel:SetPos(0, 0)
		
		
		
		--[[
			Config Editor Exit Logic & Unsaved Changes Alert
		]]--
		
		local function closeConfig()
			net.Start("FMainMenu_Config_CloseMenu")
			net.SendToServer()
			mainBlocker:Remove()
			if FMainMenu.configPropertyWindow.onCloseProp !=  nil then
				FMainMenu.configPropertyWindow.onCloseProp()
			end
			FMainMenu.configPropertyWindow:Remove()
			FMainMenu.configPropertyWindow = nil
			FMainMenu.CurConfigMenu:Close()
			FMainMenu.CurConfigMenu = nil
		end
		
		local topInfoBarCloseButton = vgui.Create("fmainmenu_config_editor_button", topInfoBar)
		topInfoBarCloseButton:SetText("Exit")
		topInfoBarCloseButton:SetSize(52.5,25)
		topInfoBarCloseButton:AlignRight(5)
		topInfoBarCloseButton:AlignTop(2.5)
		topInfoBarCloseButton.DoClick = function(button)
			if !FMainMenu.CurConfigMenu.unsavedVar then
				closeConfig()
			else
				-- If the active property has changes, confirm they want to discard
				topInfoBar:SetKeyboardInputEnabled( false )
				topInfoBar:SetMouseInputEnabled( false )
				FMainMenu.configPropertyWindow:SetKeyboardInputEnabled( false )
				FMainMenu.configPropertyWindow:SetMouseInputEnabled( false )
			
				local closeBlocker = vgui.Create("fmainmenu_config_editor_panel")
				closeBlocker:SetSize( screenWidth, screenHeight )
				closeBlocker:SetZPos( 100 )
				closeBlocker.Paint = function(s, width, height) end
				
				local closeCheck = vgui.Create( "fmainmenu_config_editornoclose" )
				closeCheck:SetSize( 300, 125 )
				closeCheck:SetZPos( 101 )
				closeCheck:Center()
				closeCheck:SetTitle("FMainMenu - Unsaved Changes!")
				
				local closeQuestionLabel = vgui.Create("fmainmenu_config_editor_label", closeCheck)
				closeQuestionLabel:SetText(FMainMenu.Lang.ConfigUnsavedChanges)
				closeQuestionLabel:SetSize(280,125)
				closeQuestionLabel:SetContentAlignment(8)
				closeQuestionLabel:SetPos(10, 25)
				
				local closeQuestionNo = vgui.Create("fmainmenu_config_editor_button", closeCheck)
				closeQuestionNo:SetText("No")
				closeQuestionNo:SetSize(50,25)
				closeQuestionNo:AlignRight(50)
				closeQuestionNo:AlignTop(85)
				closeQuestionNo.DoClick = function(button)
					closeCheck:Close()
					closeBlocker:Remove()
					topInfoBar:MakePopup()
					FMainMenu.configPropertyWindow:MakePopup()
				end
				
				local closeQuestionYes = vgui.Create("fmainmenu_config_editor_button", closeCheck)
				closeQuestionYes:SetText("Yes")
				closeQuestionYes:SetSize(50,25)
				closeQuestionYes:AlignLeft(50)
				closeQuestionYes:AlignTop(85)
				closeQuestionYes.DoClick = function(button)
					closeCheck:Close()
					closeBlocker:Remove()
					closeConfig()
				end
				
				closeCheck:MakePopup()
			end
		end
		
		topInfoBar:MakePopup()
	end
end)

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudChat"] = true,
}

-- Hide interfering GUI elements when editor is open
hook.Add( "HUDShouldDraw", "HideHUD_FMainMenu_ConfigEditor", function( name )
	if ( hide[ name ] and FMainMenu.CurConfigMenu ) then
		return false
	end
end )

-- Concommand to request editor access
local function requestMenu( player, command, arguments )
	net.Start( "FMainMenu_Config_OpenMenu" )
	net.SendToServer()
end
 
concommand.Add( "fmainmenu_config", requestMenu )