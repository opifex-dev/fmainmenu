FMainMenu.CurConfigMenu = FMainMenu.CurConfigMenu || nil
FMainMenu.configPropertyWindow = FMainMenu.configPropertyWindow || nil
local previewLevel = 0
local previewCopy = {}
local addonName = "fmainmenu"

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
	propPanelSaveButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesSavePropButton"))
	propPanelSaveButton:SetSize(200,25)
	propPanelSaveButton:AlignLeft(20)
	propPanelSaveButton:AlignTop(5)
	propPanelSaveButton.DoClick = function(button)
		saveFunc()
	end
	
	local propPanelRevertButton = vgui.Create("fmainmenu_config_editor_button", propertyGeneralPanel)
	propPanelRevertButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesRevertPropButton"))
	propPanelRevertButton:SetSize(200,25)
	propPanelRevertButton:AlignLeft(20)
	propPanelRevertButton:AlignTop(35)
	propPanelRevertButton.DoClick = function(button)
		revertFunc()
	end
end

-- Checks to see if colors are equal
local function isColorEqual(colorOne, colorTwo)
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
	
	FMainMenu.configPropertyWindow.onVarRecFunc(receivedVarTable)
end)

-- If player is allowed, open editor
net.Receive( "FMainMenu_Config_OpenMenu", function( len )
	-- Editor cannot open when the player is currently in the main menu (live preview restrictions)
	if net.ReadBool() then
		FMainMenu.Log(FMainMenu.GetPhrase("ConfigLeaveMenu"), false)
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
		
		-- Code prepping for GUI previews
		previewLevel = 0
		previewCopy = {}
		for k,v in pairs(FayLib.IGC["Config"]["Shared"][addonName]) do -- copy shared vars
			previewCopy[k] = v
		end
		
		
		
		--[[
			Config Properties Window
		]]--
		
		FMainMenu.configPropertyWindow = vgui.Create( "fmainmenu_config_editornoclose" )
		FMainMenu.configPropertyWindow:SetSize( 250, 360 )
		FMainMenu.configPropertyWindow:SetPos(screenWidth-250, screenHeight-360)
		FMainMenu.configPropertyWindow:SetTitle(FMainMenu.GetPhrase("ConfigPropertiesWindowTitle"))
		FMainMenu.configPropertyWindow.propertyCode = 0
		FMainMenu.configPropertyWindow:SetZPos(10)
		
		FMainMenu.configPropertyWindow.currentProp = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
		FMainMenu.configPropertyWindow.currentProp:SetSize( 240, 330 )
		FMainMenu.configPropertyWindow.currentProp:SetPos(5,25)
		
		local configPropertyWindowDefLabel = vgui.Create("fmainmenu_config_editor_label", FMainMenu.configPropertyWindow.currentProp)
		configPropertyWindowDefLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesNoneSelected"))
		configPropertyWindowDefLabel:SetSize(240, 25)
		configPropertyWindowDefLabel:SetFont("HudHintTextLarge")
		configPropertyWindowDefLabel:SetContentAlignment(5)
		
		
	
		--[[
			Config Option Selector
		]]--
		
		FMainMenu.CurConfigMenu = vgui.Create( "fmainmenu_config_editornoclose" )
		FMainMenu.CurConfigMenu:SetSize( 250, 250 )
		FMainMenu.CurConfigMenu:SetPos(screenWidth-250, screenHeight-620)
		FMainMenu.CurConfigMenu:SetTitle(FMainMenu.GetPhrase("ConfigPropertiesSelectorTitle"))
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
		configSheetOneCameraSetupButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPropName"))
		configSheetOneCameraSetupButton:SetSize(200,25)
		configSheetOneCameraSetupButton:AlignLeft(4)
		configSheetOneCameraSetupButton:AlignTop(5)
		configSheetOneCameraSetupButton.DoClick = function(button)
			local propertyCode = 11
			previewLevel = 0
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local cameraPosition = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			cameraPosition:SetSize( 240, 255 )
			cameraPosition:SetPos(5,25)
			local cameraPositionLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPropName"))
			cameraPositionLabel:SetFont("HudHintTextLarge")
			cameraPositionLabel:SetPos(2,0)
			local cameraPositionDescLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPropDesc"))
			cameraPositionDescLabel:SetPos(3, 24)
			cameraPositionDescLabel:SetSize(225, 36)
			
			-- Position
			local cameraPositionLabel2 = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionLabel2:SetText(FMainMenu.GetPhrase("ConfigPropertiesCameraSetupPosLabel"))
			cameraPositionLabel2:SetPos(2, 70)
			local cameraPositionPosBoxXLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionPosBoxXLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueX"))
			cameraPositionPosBoxXLabel:SetPos(143, 88)	
			local cameraPositionPosBoxX = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionPosBoxX:SetSize( 75, 18 )
			cameraPositionPosBoxX:SetPos( 163, 88 )
			local cameraPositionPosBoxYLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionPosBoxYLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueY"))
			cameraPositionPosBoxYLabel:SetPos(143, 104)
			local cameraPositionPosBoxY = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionPosBoxY:SetSize( 75, 18 )
			cameraPositionPosBoxY:SetPos( 163, 104 )
			local cameraPositionPosBoxZLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionPosBoxZLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueZ"))
			cameraPositionPosBoxZLabel:SetPos(143, 120)
			local cameraPositionPosBoxZ = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionPosBoxZ:SetSize( 75, 18 )
			cameraPositionPosBoxZ:SetPos( 163, 120 )
			
			-- Orientation
			local cameraPositionLabel3 = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionLabel3:SetText(FMainMenu.GetPhrase("ConfigPropertiesCameraSetupAngLabel"))
			cameraPositionLabel3:SetPos(2, 145)
			local cameraPositionRotBoxXLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionRotBoxXLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueX"))
			cameraPositionRotBoxXLabel:SetPos(143, 163)
			local cameraPositionRotBoxX = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionRotBoxX:SetSize( 75, 18 )
			cameraPositionRotBoxX:SetPos( 163, 163 )
			local cameraPositionRotBoxYLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionRotBoxYLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueY"))
			cameraPositionRotBoxYLabel:SetPos(143, 179)
			local cameraPositionRotBoxY = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionRotBoxY:SetSize( 75, 18 )
			cameraPositionRotBoxY:SetPos( 163, 179 )
			local cameraPositionRotBoxZLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionRotBoxZLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueZ"))
			cameraPositionRotBoxZLabel:SetPos(143, 195)
			local cameraPositionRotBoxZ = vgui.Create("fmainmenu_config_editor_textentry", cameraPosition)
			cameraPositionRotBoxZ:SetSize( 75, 18 )
			cameraPositionRotBoxZ:SetPos( 163, 195 )
			
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
			cameraPositionChooseButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesCameraSetupCaptureLabel"))
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
		configSheetOneCameraEverySpawnButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropName"))
		configSheetOneCameraEverySpawnButton:SetSize(200,25)
		configSheetOneCameraEverySpawnButton:AlignLeft(4)
		configSheetOneCameraEverySpawnButton:AlignTop(35)
		configSheetOneCameraEverySpawnButton.DoClick = function(button)
			local propertyCode = 12
			previewLevel = 0
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
			
			-- Every Spawn
			local cameraEverySpawnLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraEverySpawnLabel2:SetText(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnLabel"))
			cameraEverySpawnLabel2:SetPos(2, 70)
			local cameraEverySpawnOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			cameraEverySpawnOption:SetSize( 90, 18 )
			cameraEverySpawnOption:SetPos( 148, 70 )
			cameraEverySpawnOption:SetValue( FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne"))
			cameraEverySpawnOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne") )
			cameraEverySpawnOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo") )
			
			-- Used to detect changes in the on-screen form from the server-side variable
			local function isVarChanged()
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] then 
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne")
				else
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo")
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
					cameraEverySpawnOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne")) 
				else
					cameraEverySpawnOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo"))
				end
				setUnsaved(false)
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"EverySpawn"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if cameraEverySpawnOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionOne") then
					propertyPanel.lastRecVariable[1] = true
				elseif cameraEverySpawnOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesEverySpawnOptionTwo") then
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
		configSheetOneCameraAdvancedSpawnButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnPropName"))
		configSheetOneCameraAdvancedSpawnButton:SetSize(200,25)
		configSheetOneCameraAdvancedSpawnButton:AlignLeft(4)
		configSheetOneCameraAdvancedSpawnButton:AlignTop(65)
		configSheetOneCameraAdvancedSpawnButton.DoClick = function(button)
			local propertyCode = 13
			previewLevel = 0
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
			
			-- Advanced Spawn Toggle
			local cameraEverySpawnLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraEverySpawnLabel2:SetText(FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnOptLabel"))
			cameraEverySpawnLabel2:SetPos(2, 70)
			local cameraEverySpawnOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			cameraEverySpawnOption:SetSize( 70, 18 )
			cameraEverySpawnOption:SetPos( 168, 70 )
			cameraEverySpawnOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			cameraEverySpawnOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			cameraEverySpawnOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )	
			
			--Advanced Spawn Position
			local cameraPositionLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionLabel2:SetText(FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnPosLabel"))
			cameraPositionLabel2:SetPos(2, 91)
			local cameraPositionPosBoxXLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionPosBoxXLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueX"))
			cameraPositionPosBoxXLabel:SetPos(143, 109)	
			local cameraPositionPosBoxX = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			cameraPositionPosBoxX:SetSize( 75, 18 )
			cameraPositionPosBoxX:SetPos( 163, 109 )
			local cameraPositionPosBoxYLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionPosBoxYLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueY"))
			cameraPositionPosBoxYLabel:SetPos(143, 125)
			local cameraPositionPosBoxY = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			cameraPositionPosBoxY:SetSize( 75, 18 )
			cameraPositionPosBoxY:SetPos( 163, 125 )
			local cameraPositionPosBoxZLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionPosBoxZLabel:SetText(FMainMenu.GetPhrase("ConfigCommonValueZ"))
			cameraPositionPosBoxZLabel:SetPos(143, 141)
			local cameraPositionPosBoxZ = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			cameraPositionPosBoxZ:SetSize( 75, 18 )
			cameraPositionPosBoxZ:SetPos( 163, 141 )
			
			-- Helpful function to autofill player's current position
			local cameraPositionChooseButton = vgui.Create("fmainmenu_config_editor_button", propertyPanel)
			cameraPositionChooseButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesAdvancedSpawnCaptureLabel"))
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
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
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
					cameraEverySpawnOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled")) 
				else
					cameraEverySpawnOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
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
				
				if(tonumber(cameraPositionPosBoxX:GetText()) == nil) then return end
				if(tonumber(cameraPositionPosBoxY:GetText()) == nil) then return end
				if(tonumber(cameraPositionPosBoxZ:GetText()) == nil) then return end
				
				if cameraEverySpawnOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					propertyPanel.lastRecVariable[1] = true
				elseif cameraEverySpawnOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					propertyPanel.lastRecVariable[1] = false
				else
					return
				end

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
		configSheetOneCameraHearOtherPlayersButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersPropName"))
		configSheetOneCameraHearOtherPlayersButton:SetSize(200,25)
		configSheetOneCameraHearOtherPlayersButton:AlignLeft(4)
		configSheetOneCameraHearOtherPlayersButton:AlignTop(95)
		configSheetOneCameraHearOtherPlayersButton.DoClick = function(button)
			local propertyCode = 14
			previewLevel = 0
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
			
			-- Hear Other Players Toggle
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersLabel"))
			toggleLabel:SetPos(2, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 70, 18 )
			toggleOption:SetPos( 168, 70 )
			toggleOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )	
			
			-- Maximum Voice Distance
			local distanceLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			distanceLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesHearOtherPlayersDistanceLabel"))
			distanceLabel:SetPos(2, 91)
			local distanceBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			distanceBox:SetSize( 75, 18 )
			distanceBox:SetPos( 163, 91 )
			
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
				if tonumber(distanceBox:GetText()) == nil then return end
			
				if toggleOption:GetText() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					topHalfSphere:SetModelScale( 0 )
					bottomHalfSphere:SetModelScale( 0 )
					return 
				end
				local boxText = distanceBox:GetText()
				
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
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] then 
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
				end
				
				print(1)
				if toggleOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				if tonumber(distanceBox:GetText()) == nil || tonumber(distanceBox:GetText()) != math.sqrt(propertyPanel.lastRecVariable[2]) then
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
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled")) 
				else
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
				end
				distanceBox:SetText(math.sqrt(varTable[2]))
				topHalfSphere:SetPos(varTable[3][mapName] + Vector(0,0,64.5))
				bottomHalfSphere:SetPos(varTable[3][mapName] + Vector(0,0,63.5))
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"HearOtherPlayers","PlayerVoiceDistance", "CameraPosition"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if(tonumber(distanceBox:GetText()) == nil) then return end
				
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					propertyPanel.lastRecVariable[1] = true
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					propertyPanel.lastRecVariable[1] = false
				else
					return
				end

				local newPHDist = tonumber(distanceBox:GetText())
				propertyPanel.lastRecVariable[2] = newPHDist*newPHDist
				
				updateVariables(propertyPanel.lastRecVariable, {"HearOtherPlayers","PlayerVoiceDistance"})
				propertyPanel.lastRecVariable[2] = newPHDist
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
		
		configSheet:AddSheet( FMainMenu.GetPhrase("ConfigPropertiesCategoriesCamera"), configSheetOne, nil )
		
		
		
		local configSheetTwo = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetTwo:SetSize( 240, 230 )
		
		-- Language Setting
		local configSheetTwoLanguageButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoLanguageButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesLanguagePropName"))
		configSheetTwoLanguageButton:SetSize(200,25)
		configSheetTwoLanguageButton:AlignLeft(4)
		configSheetTwoLanguageButton:AlignTop(5)
		configSheetTwoLanguageButton.DoClick = function(button)
			local propertyCode = 21
			previewLevel = 0
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesLanguagePropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesLanguagePropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			--language setting dropdown
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesLanguageLabel"))
			toggleLabel:SetPos(2, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 80, 18 )
			toggleOption:SetPos( 158, 70 )
			toggleOption:SetValue( "English" )
			for _,v in pairs(FMainMenu.languageLookup) do
				toggleOption:AddChoice( v )
			end			
			
			-- Used to detect changes in the on-screen form from the server-side variable			
			local function isVarChanged()
				local serverVar = ""
				if FMainMenu.languageLookup[propertyPanel.lastRecVariable[1]] then 
					serverVar = FMainMenu.languageLookup[propertyPanel.lastRecVariable[1]]
				else
					serverVar = "English"
				end
				
				if serverVar != toggleOption:GetText() then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function toggleOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				toggleOption:SetValue(FMainMenu.languageLookup[propertyPanel.lastRecVariable[1]])
				setUnsaved(false)
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"LangSetting"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if(FMainMenu.languageReverseLookup[toggleOption:GetText()] == nil) then return end

				propertyPanel.lastRecVariable[1] = FMainMenu.languageReverseLookup[toggleOption:GetText()]
				
				updateVariables(propertyPanel.lastRecVariable, {"LangSetting"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"LangSetting"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- Garry's Mod Positioning Style
		local configSheetTwoGMODStyleButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoGMODStyleButtonLiveIndicator:SetSize( 15, 15 )
		configSheetTwoGMODStyleButtonLiveIndicator:AlignRight(12)
		configSheetTwoGMODStyleButtonLiveIndicator:AlignTop(40)
		configSheetTwoGMODStyleButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoGMODStyleButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoGMODStyleButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesGMODStylePropName"))
		configSheetTwoGMODStyleButton:SetSize(200,25)
		configSheetTwoGMODStyleButton:AlignLeft(4)
		configSheetTwoGMODStyleButton:AlignTop(35)
		configSheetTwoGMODStyleButton.DoClick = function(button)
			local propertyCode = 22
			previewLevel = 1
			local tableKeyName = "GarrysModStyle"
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesGMODStylePropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesGMODStylePropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- menu position options
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesGMODStyleLabel"))
			toggleLabel:SetPos(2, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 85, 18 )
			toggleOption:SetPos( 153, 70 )
			toggleOption:SetValue( FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo") )
			
			-- Update needed live preview stuff
			local function updatePreview()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne") then
					previewCopy["_"..tableKeyName] = true
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo") then
					previewCopy["_"..tableKeyName] = false
				end
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] then 
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne")
				else
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo")
				end
				
				if serverVar != toggleOption:GetText() then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function toggleOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				
				if varTable[1] then 
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne")) 
				else
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo"))
				end
				
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"GarrysModStyle"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectOne") then
					propertyPanel.lastRecVariable[1] = true
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesGMODStyleSelectTwo") then
					propertyPanel.lastRecVariable[1] = false
				else
					return
				end
				
				updateVariables(propertyPanel.lastRecVariable, {"GarrysModStyle"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"GarrysModStyle"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- Logo & Logo Content
		local configSheetTwoLogoButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoLogoButtonLiveIndicator:SetSize( 15, 15 )
		configSheetTwoLogoButtonLiveIndicator:AlignRight(12)
		configSheetTwoLogoButtonLiveIndicator:AlignTop(70)
		configSheetTwoLogoButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoLogoButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoLogoButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesLogoPropName"))
		configSheetTwoLogoButton:SetSize(200,25)
		configSheetTwoLogoButton:AlignLeft(4)
		configSheetTwoLogoButton:AlignTop(65)
		configSheetTwoLogoButton.DoClick = function(button)
			local propertyCode = 23
			previewLevel = 1
			local tableKeyName = {"logoIsText","logoContent"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesLogoPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesLogoPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- logo type selection
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesLogoLabel"))
			toggleLabel:SetPos(2, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 65, 18 )
			toggleOption:SetPos( 173, 70 )
			toggleOption:SetValue( FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo") )
			
			-- logo comment box
			local contentLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			contentLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesLogoContentLabel"))
			contentLabel:SetPos(2, 91)
			local contentBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			contentBox:SetSize( 236, 18 )
			contentBox:SetPos( 2, 111 )
			
			-- Update needed live preview stuff
			local function updatePreview()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne") then
					previewCopy["_"..tableKeyName[1]] = true
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo") then
					previewCopy["_"..tableKeyName[1]] = false
				end
				
				previewCopy["_"..tableKeyName[2]] = contentBox:GetText()
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] then 
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne")
				else
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo")
				end
				
				if serverVar != toggleOption:GetText() then
					setUnsaved(true)
					return
				end
				
				if propertyPanel.lastRecVariable[2] != contentBox:GetText() then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function toggleOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			function contentBox:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				
				if varTable[1] then 
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne")) 
				else
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo"))
				end
				
				contentBox:SetText(varTable[2])
				
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"logoIsText","logoContent"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesLogoSelectOne") then
					propertyPanel.lastRecVariable[1] = true
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesLogoSelectTwo") then
					propertyPanel.lastRecVariable[1] = false
				else
					return
				end
				
				propertyPanel.lastRecVariable[2] = contentBox:GetText()
				
				updateVariables(propertyPanel.lastRecVariable, {"logoIsText","logoContent"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"logoIsText","logoContent"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- Background Tint & Background Blur
		local configSheetTwoBackgroundButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoBackgroundButtonLiveIndicator:SetSize( 15, 15 )
		configSheetTwoBackgroundButtonLiveIndicator:AlignRight(12)
		configSheetTwoBackgroundButtonLiveIndicator:AlignTop(100)
		configSheetTwoBackgroundButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoBackgroundButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoBackgroundButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesBackgroundPropName"))
		configSheetTwoBackgroundButton:SetSize(200,25)
		configSheetTwoBackgroundButton:AlignLeft(4)
		configSheetTwoBackgroundButton:AlignTop(95)
		configSheetTwoBackgroundButton.DoClick = function(button)
			local propertyCode = 24
			previewLevel = 1
			local tableKeyName = {"BackgroundBlurAmount","BackgroundColorTint"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesBackgroundPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesBackgroundPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- blur amount
			local blurLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			blurLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesBackgroundBlurLabel"))
			blurLabel:SetPos(2, 70)
			local blurBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			blurBox:SetSize( 40, 18 )
			blurBox:SetPos( 198, 70 )
			
			-- tint color
			local tintLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			tintLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesBackgroundTintLabel"))
			tintLabel:SetPos(2, 91)
			local tintBox = vgui.Create("DColorMixer", propertyPanel)
			tintBox:SetSize( 236, 212 )
			tintBox:SetPos(2, 112)
			
			
			-- Update needed live preview stuff
			local function updatePreview()
				if tonumber(blurBox:GetText()) == nil then return end
				
				previewCopy["_"..tableKeyName[1]] = tonumber(blurBox:GetText())
				previewCopy["_"..tableKeyName[2]] = tintBox:GetColor()
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()
				if propertyPanel.lastRecVariable[1] != tonumber(blurBox:GetText()) then 
					setUnsaved(true)
					return
				end
				
				if !isColorEqual(propertyPanel.lastRecVariable[2], tintBox:GetColor()) then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function blurBox:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function tintBox:ValueChanged()
				isVarChanged()
				updatePreview()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				
				blurBox:SetText(varTable[1])
				
				tintBox:SetColor(Color(varTable[2].r, varTable[2].g, varTable[2].b, varTable[2].a))
				
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"BackgroundBlurAmount","BackgroundColorTint"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if tonumber(blurBox:GetText()) == nil then return end
				
				propertyPanel.lastRecVariable[1] = tonumber(blurBox:GetText())
				propertyPanel.lastRecVariable[2] = tintBox:GetColor()
				
				updateVariables(propertyPanel.lastRecVariable, {"BackgroundBlurAmount","BackgroundColorTint"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"BackgroundBlurAmount","BackgroundColorTint"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- Changelog
		local configSheetTwoBackgroundButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoBackgroundButtonLiveIndicator:SetSize( 15, 15 )
		configSheetTwoBackgroundButtonLiveIndicator:AlignRight(12)
		configSheetTwoBackgroundButtonLiveIndicator:AlignTop(130)
		configSheetTwoBackgroundButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoBackgroundButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoBackgroundButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesChangelogPropName"))
		configSheetTwoBackgroundButton:SetSize(200,25)
		configSheetTwoBackgroundButton:AlignLeft(4)
		configSheetTwoBackgroundButton:AlignTop(125)
		configSheetTwoBackgroundButton.DoClick = function(button)
			local propertyCode = 25
			previewLevel = 1
			local tableKeyName = {"showChangeLog","changeLogMoveToBottom","changeLogText"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesChangelogPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesChangelogPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- changelog toggle
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesChangelogToggleLabel"))
			toggleLabel:SetPos(2, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 70, 18 )
			toggleOption:SetPos( 168, 70 )
			toggleOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			
			-- bottom margin toggle
			local marginLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			marginLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesChangelogMarginLabel"))
			marginLabel:SetPos(2, 91)
			local marginOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			marginOption:SetSize( 95, 18 )
			marginOption:SetPos( 143, 91 )
			marginOption:SetValue( FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne") )
			marginOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne") )
			marginOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo") )
			
			-- Changelog Text
			local textLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			textLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesChangelogTextLabel"))
			textLabel:SetPos(2, 112)
			local textBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			textBox:SetSize( 236, 120 )
			textBox:SetPos( 2, 133 )
			textBox:SetEnterAllowed( true )
			textBox:SetMultiline( true )
			
			
			
			-- Update needed live preview stuff
			local function updatePreview()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					previewCopy["_"..tableKeyName[1]] = true
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					previewCopy["_"..tableKeyName[1]] = false
				end
				
				if marginOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo") then
					previewCopy["_"..tableKeyName[2]] = true
				elseif marginOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne") then
					previewCopy["_"..tableKeyName[2]] = false
				end
				
				previewCopy["_"..tableKeyName[3]] = textBox:GetText()
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] then 
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
				end
				
				if toggleOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				if propertyPanel.lastRecVariable[2] then 
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo")
				else
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne")
				end
				
				if marginOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				if textBox:GetText() != propertyPanel.lastRecVariable[3] then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function toggleOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			function marginOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			function textBox:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				
				if varTable[1] then 
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled")) 
				else
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
				end
				
				if varTable[2] then 
					marginOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo")) 
				else
					marginOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne"))
				end
				
				textBox:SetText(varTable[3])
				
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"showChangeLog","changeLogMoveToBottom","changeLogText"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					propertyPanel.lastRecVariable[1] = true
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					propertyPanel.lastRecVariable[1] = false
				else
					return
				end
				
				if marginOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMarginSelectTwo") then
					propertyPanel.lastRecVariable[2] = true
				elseif marginOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMarginSelectOne") then
					propertyPanel.lastRecVariable[2] = false
				else
					return
				end
				
				propertyPanel.lastRecVariable[3] = textBox:GetText()
				
				updateVariables(propertyPanel.lastRecVariable, {"showChangeLog","changeLogMoveToBottom","changeLogText"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"showChangeLog","changeLogMoveToBottom","changeLogText"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		configSheet:AddSheet( FMainMenu.GetPhrase("ConfigPropertiesCategoriesMenu"), configSheetTwo, nil )
		
		
		
		local configSheetThree = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetThree:SetSize( 240, 230 )
		configSheet:AddSheet( FMainMenu.GetPhrase("ConfigPropertiesCategoriesHooks"), configSheetThree, nil )
		
		
		
		local configSheetFour = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetFour:SetSize( 240, 230 )
		configSheet:AddSheet( FMainMenu.GetPhrase("ConfigPropertiesCategoriesDerma"), configSheetFour, nil )
		
		
		
		local configSheetFive = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetFive:SetSize( 240, 230 )
		configSheet:AddSheet( FMainMenu.GetPhrase("ConfigPropertiesCategoriesAccess"), configSheetFive, nil )
		
		
		
		local configSheetSix = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetSix:SetSize( 240, 230 )
		configSheet:AddSheet( FMainMenu.GetPhrase("ConfigPropertiesCategoriesCamera"), configSheetSix, nil )
		
		
		
		--[[
			Top-Middle Info Bar
		]]--
		
		local topInfoBar = vgui.Create("fmainmenu_config_editor_panel", mainBlocker)
		topInfoBar:SetSize( screenWidth/3, 30 )
		topInfoBar:SetPos(screenWidth/3,0)
		topInfoBar:SetZPos(10)
		
		local topInfoBarNameLabel = vgui.Create("fmainmenu_config_editor_label", topInfoBar)
		topInfoBarNameLabel:SetText(FMainMenu.GetPhrase("ConfigTopBarHeaderText"))
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
			previewLevel = 0
		end
		
		local topInfoBarCloseButton = vgui.Create("fmainmenu_config_editor_button", topInfoBar)
		topInfoBarCloseButton:SetText(FMainMenu.GetPhrase("ConfigTopBarExitText"))
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
				closeCheck:SetTitle(FMainMenu.GetPhrase("ConfigUnsavedChangesHeader"))
				
				local closeQuestionLabel = vgui.Create("fmainmenu_config_editor_label", closeCheck)
				closeQuestionLabel:SetText(FMainMenu.GetPhrase("ConfigUnsavedChanges"))
				closeQuestionLabel:SetSize(280,125)
				closeQuestionLabel:SetContentAlignment(8)
				closeQuestionLabel:SetPos(10, 25)
				
				local closeQuestionNo = vgui.Create("fmainmenu_config_editor_button", closeCheck)
				closeQuestionNo:SetText(FMainMenu.GetPhrase("ConfigCommonValueNo"))
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
				closeQuestionYes:SetText(FMainMenu.GetPhrase("ConfigCommonValueYes"))
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

--[[
	Preview Hooks
	
	The below HUDPaint and HUDPaintBackground hooks will be used to render a real-time preview of vgui changes the player is making in the editor.
	I will also be listing all the possible states below so I don't forget.
	
	NOTE: We can likely utilize the updatePreview function I made for the other previews by keeping a copy of all needed variables to simulate the menu,
	and using the updatePreview function to modify whatever property the user is editing
	
	previewLevel:
	0 - no GUI
	1 - background/base menu only
	2 - 1 but with first time join module simulated on top
]]--
local blurMat = Material("pp/blurscreen")
local colorWhite = Color(255, 255, 255)
local HTMLLogo = nil
local ChangelogBox = nil
local CLText = nil
local cachedLink = ""

hook.Add( "HUDPaint", "ExampleMenu_FMainMenu_ConfigEditor", function()
	if previewLevel > 0 then -- draw menu
		local width = ScrW()
		local height = ScrH()
	
		if previewCopy["_logoIsText"] then
			if HTMLLogo != nil then
				HTMLLogo:Remove()
				HTMLLogo = nil
				cachedLink = ""
			end
		
			local titleH = (height * 0.5) - previewCopy["_logoFontSize"] - 64
			if previewCopy["_GarrysModStyle"] then
				titleH = width * 0.04
			end
			draw.SimpleTextOutlined( previewCopy["_logoContent"], FMainMenu.CurrentLogoFont, width * 0.04, titleH, previewCopy["_textLogoColor"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, previewCopy["_logoOutlineThickness"], previewCopy["_logoOutlineColor"] )
		else
			if HTMLLogo == nil || cachedLink != previewCopy["_logoContent"] then
				if HTMLLogo != nil then HTMLLogo:Remove() end
				HTMLLogo = vgui.Create("DHTML")
				HTMLLogo:SetZPos(1)
				HTMLLogo:SetSize(width * 0.5, 192)
				if !previewCopy["_GarrysModStyle"] then
					HTMLLogo:SetPos(width * 0.04, (height * 0.5) - 256)
				else
					HTMLLogo:SetPos(width * 0.04, 32)
				end
				HTMLLogo:SetMouseInputEnabled(false)
				function HTMLLogo:ConsoleMessage(msg) end
				HTMLLogo:SetHTML([[
				<!DOCTYPE html>
				<html>
					<head>
						<style>
						body, html {
							padding: 0;
							margin: 0;
							height:100%;
							overflow: hidden;
							position: relative;
						}
						img {
							position: absolute;
							bottom: 0px;
							left: 0px;
							max-width: 100%;
							max-height: 100%;
							disTextButton: block;
						}
						</style>
					</head>
					<body>
						<img id="img"></img>
						<script>
							var url = "]] .. string.JavascriptSafe(previewCopy["_logoContent"]) .. [[";
							document.getElementById("img").src = url;
						</script>
					</body>
				</html>
				]])
				cachedLink = previewCopy["_logoContent"]
			else
				if !previewCopy["_GarrysModStyle"] then
					HTMLLogo:SetPos(width * 0.04, (height * 0.5) - 256)
				else
					HTMLLogo:SetPos(width * 0.04, 32)
				end
			end
		end

		if previewCopy["_showChangeLog"] then
			if ChangelogBox == nil then 
				ChangelogBox = FMainMenu.Derma.CreateDPanel(nil, 256, ScrH()*(1/3), false )
				FMainMenu.Derma:SetFrameSettings(ChangelogBox, FayLib.IGC.GetSharedKey(addonName, "commonPanelColor"), 0)
				ChangelogBox:SetZPos(1)
				
				CLText = FMainMenu.Derma.CreateDLabel(ChangelogBox, 221, (ScrH()*(1/3))-5, false, text)
				CLText:SetFont("HudHintTextLarge")
				CLText:SetPos(10, 5)
				CLText:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
				CLText:SetContentAlignment( 7 )
				CLText:SetWrap( true )
			end
			
			if previewCopy["_changeLogMoveToBottom"] then
				ChangelogBox:SetPos(width-266, (height*(2/3)))
			else
				ChangelogBox:SetPos(width-266, 10)
			end
			
			CLText:SetFont("HudHintTextLarge")
			CLText:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
			CLText:SetText(previewCopy["_changeLogText"])
			CLText:SetContentAlignment( 7 )
			CLText:SetWrap( true )
		else
			if ChangelogBox != nil then
				CLText:Remove()
				ChangelogBox:Remove()
				ChangelogBox = nil
				CLText = nil
			end
		end
			
		if previewLevel == 2 then -- draw first time join dialogue
			
		end
	else
		if HTMLLogo != nil then
			HTMLLogo:Remove()
			HTMLLogo = nil
			cachedLink = ""
		end
		
		if ChangelogBox != nil then
			CLText:Remove()
			ChangelogBox:Remove()
			ChangelogBox = nil
			CLText = nil
		end
	end
end)

hook.Add( "HUDPaintBackground", "ExampleMenuBackground_FMainMenu_ConfigEditor", function()
	if previewLevel > 0 then -- draw menu background
		local width = ScrW()
		local height = ScrH()
		
		-- background tint
		surface.SetDrawColor(previewCopy["_BackgroundColorTint"])
		surface.DrawRect(0, 0, width, height)
				
		-- background blur
		local blurAmount = previewCopy["_BackgroundBlurAmount"]
		if blurAmount > 0 then		
			surface.SetDrawColor(colorWhite)
			surface.SetMaterial(blurMat)
			
			for i = 1, 3 do
				blurMat:SetFloat("$blur", (i / 3) * (blurAmount or 8))
				blurMat:Recompute()

				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(0, 0, width, height)
			end
		end
	end
end)

-- Concommand to request editor access
local function requestMenu( player, command, arguments )
	net.Start( "FMainMenu_Config_OpenMenu" )
	net.SendToServer()
end
 
concommand.Add( "fmainmenu_config", requestMenu )