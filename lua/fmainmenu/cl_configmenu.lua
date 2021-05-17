FMainMenu.CurConfigMenu = FMainMenu.CurConfigMenu || nil
FMainMenu.configPropertyWindow = FMainMenu.configPropertyWindow || nil
local previewLevel = 0
local previewCopy = {}
local addonName = "fmainmenu"

local soundSelection = nil
local URLButtonEditor = nil


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
	
	FMainMenu.configPropertyWindow.configBlockerPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
	FMainMenu.configPropertyWindow.configBlockerPanel:SetBGColor(Color(0, 0, 0, 155))
	FMainMenu.configPropertyWindow.configBlockerPanel:SetSize( 240, 330 )
	FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(false)
	FMainMenu.configPropertyWindow.configBlockerPanel:SetZPos(100)
	FMainMenu.configPropertyWindow.configBlockerPanel:AlignLeft(5)
	FMainMenu.configPropertyWindow.configBlockerPanel:AlignTop(25)
	
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
		configUnsavedBlocker:SetSize( 240, 195 )
		configUnsavedBlocker:SetBGColor(Color(0,0,0,155))
		configUnsavedBlocker:AlignRight(5)
		configUnsavedBlocker:AlignTop(50)
		configUnsavedBlocker:SetVisible(false)
		
		local configExternalWindowBlocker = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.CurConfigMenu)
		configExternalWindowBlocker:SetSize( 240, 195 )
		configExternalWindowBlocker:SetBGColor(Color(0,0,0,0))
		configExternalWindowBlocker:AlignRight(5)
		configExternalWindowBlocker:AlignTop(50)
		configExternalWindowBlocker:SetVisible(false)
		
		local function setUnsaved(state)
			FMainMenu.CurConfigMenu.unsavedVar = state
			configUnsavedBlocker:SetVisible(state)
		end
		
		local function setExternalBlock(state)
			configExternalWindowBlocker:SetVisible(state)
		end
		
		local configSheetOne = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetOne:SetSize( 240, 220 )
		
		--Camera Setup
		local cameraSetupButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetOne)
		cameraSetupButtonLiveIndicator:SetSize( 15, 15 )
		cameraSetupButtonLiveIndicator:AlignLeft(0)
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
		cameraHearOtherPlayersButtonLiveIndicator:AlignLeft(0)
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
		
		
		
		local configSheetTwo = vgui.Create("fmainmenu_config_editor_scrollpanel", configSheet)
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
		configSheetTwoGMODStyleButtonLiveIndicator:AlignLeft(0)
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
		configSheetTwoLogoButtonLiveIndicator:AlignLeft(0)
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
		configSheetTwoBackgroundButtonLiveIndicator:AlignLeft(0)
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
		local configSheetTwoChangelogButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoChangelogButtonLiveIndicator:SetSize( 15, 15 )
		configSheetTwoChangelogButtonLiveIndicator:AlignLeft(0)
		configSheetTwoChangelogButtonLiveIndicator:AlignTop(130)
		configSheetTwoChangelogButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoChangelogButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoChangelogButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesChangelogPropName"))
		configSheetTwoChangelogButton:SetSize(200,25)
		configSheetTwoChangelogButton:AlignLeft(4)
		configSheetTwoChangelogButton:AlignTop(125)
		configSheetTwoChangelogButton.DoClick = function(button)
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
		
		-- Music Properties
		local configSheetTwoMusicButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoMusicButtonLiveIndicator:SetSize( 15, 15 )
		configSheetTwoMusicButtonLiveIndicator:AlignLeft(0)
		configSheetTwoMusicButtonLiveIndicator:AlignTop(160)
		configSheetTwoMusicButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoMusicButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoMusicButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicPropName"))
		configSheetTwoMusicButton:SetSize(200,25)
		configSheetTwoMusicButton:AlignLeft(4)
		configSheetTwoMusicButton:AlignTop(155)
		configSheetTwoMusicButton.DoClick = function(button)
			local propertyCode = 26
			previewLevel = 3
			local tableKeyName = {"musicToggle","musicLooping","musicVolume","musicFade","musicContent"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- music toggle
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicTypeLabel"))
			toggleLabel:SetPos(2, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 70, 18 )
			toggleOption:SetPos( 168, 70 )
			toggleOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel") )
			
			-- loop music toggle
			local loopLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			loopLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicLoopLabel"))
			loopLabel:SetPos(2, 91)
			local loopOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			loopOption:SetSize( 70, 18 )
			loopOption:SetPos( 168, 91 )
			loopOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			loopOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			loopOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			
			-- music volume
			local textLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			textLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicVolumeLabel"))
			textLabel:SetPos(2, 112)
			local textBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			textBox:SetSize( 40, 18 )
			textBox:SetPos( 198, 112 )
			
			-- music fade
			local fadeLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			fadeLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicFadeLabel"))
			fadeLabel:SetPos(2, 133)
			local fadeBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			fadeBox:SetSize( 40, 18 )
			fadeBox:SetPos( 198, 133 )
			
			-- music content
			local contentLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			contentLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicSelectLabel"))
			contentLabel:SetPos(2, 152)
			local contentBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			contentBox:SetSize( 236, 18 )
			contentBox:SetPos( 2, 173 )
			
			-- File Selector Button, should probably be invisible when "File" is not the current option
			local audioFileChooseButton = vgui.Create("fmainmenu_config_editor_button", propertyPanel)
			audioFileChooseButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesMusicButtonLabel"))
			audioFileChooseButton:SetSize(200,25)
			audioFileChooseButton:AlignLeft(20)
			audioFileChooseButton:AlignTop(225)
			audioFileChooseButton:SetVisible(false)
			audioFileChooseButton.DoClick = function(button)
				setExternalBlock(true)
				FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(true)
				
				local internalStation = nil
				local currentVol = 0.5
				local currentSelection = contentBox:GetText()
				
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
					setExternalBlock(false)
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
						contentBox:SetText(currentSelection)
						contentBox:OnChange()
						textBox:SetText(math.Round( currentVol, 2))
						textBox:OnChange()
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
				
				if tonumber(textBox:GetText()) ~= nil then
					currentVol = tonumber(textBox:GetText())
					bottomPanelVolSlider:SetValue( currentVol )
				end
					
				soundSelection:MakePopup()
			end
			
			
			
			-- Update needed live preview stuff
			local function updatePreview()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel") then
					previewCopy["_"..tableKeyName[1]] = 1
					contentBox:SetVisible(true)
					contentLabel:SetVisible(true)
					audioFileChooseButton:SetVisible(true)
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel") then
					previewCopy["_"..tableKeyName[1]] = 2
					contentBox:SetVisible(true)
					contentLabel:SetVisible(true)
					audioFileChooseButton:SetVisible(false)
				else
					previewCopy["_"..tableKeyName[1]] = 0
					contentBox:SetVisible(false)
					contentLabel:SetVisible(false)
					audioFileChooseButton:SetVisible(false)
				end
				
				if loopOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					previewCopy["_"..tableKeyName[2]] = true
				else
					previewCopy["_"..tableKeyName[2]] = false
				end
				
				if tonumber(textBox:GetText()) != nil then
					previewCopy["_"..tableKeyName[3]] = tonumber(textBox:GetText())
				end
				
				if tonumber(fadeBox:GetText()) != nil then
					previewCopy["_"..tableKeyName[4]] = tonumber(fadeBox:GetText())
				end
				
				previewCopy["_"..tableKeyName[5]] = contentBox:GetText()
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] == 1 then 
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel")
				elseif propertyPanel.lastRecVariable[1] == 2 then
					serverVar = FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
				end
				
				if toggleOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[2] then 
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
				end
				
				if loopOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				if tonumber(textBox:GetText()) != propertyPanel.lastRecVariable[3] then
					setUnsaved(true)
					return
				end
				
				if tonumber(fadeBox:GetText()) != propertyPanel.lastRecVariable[4] then
					setUnsaved(true)
					return
				end
				
				if contentBox:GetText() != propertyPanel.lastRecVariable[5] then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function toggleOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			function loopOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			function textBox:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function fadeBox:OnChange()
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
				
				if varTable[1] == 2 then 
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel")) 
				elseif varTable[1] == 1 then
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel"))
				else
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
				end
				
				if varTable[2] then 
					loopOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled")) 
				else
					loopOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
				end
				
				textBox:SetText(varTable[3])
				fadeBox:SetText(varTable[4])
				contentBox:SetText(varTable[5])
				
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"musicToggle","musicLooping","musicVolume","musicFade","musicContent"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()				
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionOneLabel") then
					propertyPanel.lastRecVariable[1] = 1
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigPropertiesMusicTypeOptionTwoLabel") then
					propertyPanel.lastRecVariable[1] = 2
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					propertyPanel.lastRecVariable[1] = 0
				else
					return
				end
				
				if loopOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					propertyPanel.lastRecVariable[2] = true
				elseif loopOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					propertyPanel.lastRecVariable[2] = false
				else
					return
				end
				
				if tonumber(textBox:GetText()) != nil then
					propertyPanel.lastRecVariable[3] = tonumber(textBox:GetText())
				else
					return
				end
				
				if tonumber(fadeBox:GetText()) != nil then
					propertyPanel.lastRecVariable[4] = tonumber(fadeBox:GetText())
				else
					return
				end
				
				propertyPanel.lastRecVariable[5] = contentBox:GetText()
				
				updateVariables(propertyPanel.lastRecVariable, {"musicToggle","musicLooping","musicVolume","musicFade","musicContent"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"musicToggle","musicLooping","musicVolume","musicFade","musicContent"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- First Join Welcomer
		local configSheetTwoFJWeclomerButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoFJWeclomerButtonLiveIndicator:SetSize( 15, 15 )
		configSheetTwoFJWeclomerButtonLiveIndicator:AlignLeft(0)
		configSheetTwoFJWeclomerButtonLiveIndicator:AlignTop(190)
		configSheetTwoFJWeclomerButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoFJWeclomerButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoFJWeclomerButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesFJWelcomerPropName"))
		configSheetTwoFJWeclomerButton:SetSize(200,25)
		configSheetTwoFJWeclomerButton:AlignLeft(4)
		configSheetTwoFJWeclomerButton:AlignTop(185)
		configSheetTwoFJWeclomerButton.DoClick = function(button)
			local propertyCode = 27
			previewLevel = 2
			local tableKeyName = {"firstJoinWelcome","firstJoinText","firstJoinURLText","firstJoinURL","firstJoinURLEnabled"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesFJWelcomerPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesFJWelcomerPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- welcomer toggle
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesWelcomerTypeLabel"))
			toggleLabel:SetPos(2, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 70, 18 )
			toggleOption:SetPos( 168, 70 )
			toggleOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			
			-- welcome text
			local FJTextLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			FJTextLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesWelcomerTextLabel"))
			FJTextLabel:SetPos(2, 91)
			local FJTextBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			FJTextBox:SetSize( 236, 18 )
			FJTextBox:SetPos( 2, 112 )
			
			-- Button Text
			local FJURLTextLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			FJURLTextLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesWelcomerURLTextLabel"))
			FJURLTextLabel:SetPos(2, 133)
			local FJURLTextBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			FJURLTextBox:SetSize( 236, 18 )
			FJURLTextBox:SetPos( 2, 154 )
			
			-- url button toggle
			local urlToggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			urlToggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesWelcomerURLButtonToggleLabel"))
			urlToggleLabel:SetPos(2, 175)
			local urlToggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			urlToggleOption:SetSize( 70, 18 )
			urlToggleOption:SetPos( 168, 175 )
			urlToggleOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			urlToggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			urlToggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			
			-- Website Link
			local FJURLLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			FJURLLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesWelcomerURLLabel"))
			FJURLLabel:SetPos(2, 196)
			FJURLLabel:SetVisible(false)
			local FJURLBox = vgui.Create("fmainmenu_config_editor_textentry", propertyPanel)
			FJURLBox:SetSize( 236, 18 )
			FJURLBox:SetPos( 2, 217 )
			FJURLBox:SetVisible(false)
			
			
			
			-- Update needed live preview stuff
			local function updatePreview()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					previewCopy["_"..tableKeyName[1]] = false
				else
					previewCopy["_"..tableKeyName[1]] = true
				end
				
				previewCopy["_"..tableKeyName[2]] = FJTextBox:GetText()
				
				previewCopy["_"..tableKeyName[3]] = FJURLTextBox:GetText()
				
				previewCopy["_"..tableKeyName[4]] = FJURLBox:GetText()
				
				if urlToggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					previewCopy["_"..tableKeyName[5]] = false
				else
					previewCopy["_"..tableKeyName[5]] = true
				end
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()
				if urlToggleOption:GetText() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					FJURLLabel:SetVisible(true)
					FJURLBox:SetVisible(true)
				else
					FJURLLabel:SetVisible(false)
					FJURLBox:SetVisible(false)
				end
				
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
				end
				
				if toggleOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				if FJTextBox:GetText() != propertyPanel.lastRecVariable[2] then
					setUnsaved(true)
					return
				end
				
				if FJURLTextBox:GetText() != propertyPanel.lastRecVariable[3] then
					setUnsaved(true)
					return
				end
				
				if FJURLBox:GetText() != propertyPanel.lastRecVariable[4] then
					setUnsaved(true)
					return
				end
				
				if propertyPanel.lastRecVariable[5] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
				end
				
				if urlToggleOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function toggleOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			function urlToggleOption:OnSelect( index, value, data )
				isVarChanged()
				updatePreview()
			end
			
			function FJTextBox:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function FJURLTextBox:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			function FJURLBox:OnChange()
				isVarChanged()
				updatePreview()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				
				if varTable[1] == true then
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
				else
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
				end
				
				FJTextBox:SetText(varTable[2])
				FJURLTextBox:SetText(varTable[3])
				FJURLBox:SetText(varTable[4])
				
				if varTable[5] == true then
					urlToggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
					FJURLLabel:SetVisible(true)
					FJURLBox:SetVisible(true)
				else
					urlToggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
					FJURLLabel:SetVisible(false)
					FJURLBox:SetVisible(false)
				end
				
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"firstJoinWelcome","firstJoinText","firstJoinURLText","firstJoinURL","firstJoinURLEnabled"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					propertyPanel.lastRecVariable[1] = false
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					propertyPanel.lastRecVariable[1] = true
				else
					return
				end
				
				propertyPanel.lastRecVariable[2] = FJTextBox:GetText()
				
				propertyPanel.lastRecVariable[3] = FJURLTextBox:GetText()
				
				propertyPanel.lastRecVariable[4] = FJURLBox:GetText()
				
				if urlToggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					propertyPanel.lastRecVariable[5] = false
				elseif urlToggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					propertyPanel.lastRecVariable[5] = true
				else
					return
				end
				
				updateVariables(propertyPanel.lastRecVariable, {"firstJoinWelcome","firstJoinText","firstJoinURLText","firstJoinURL","firstJoinURLEnabled"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"firstJoinWelcome","firstJoinText","firstJoinURLText","firstJoinURL","firstJoinURLEnabled"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- Disconnect Button
		local configSheetTwoFJWeclomerButtonLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoFJWeclomerButtonLiveIndicator:SetSize( 15, 15 )
		configSheetTwoFJWeclomerButtonLiveIndicator:AlignLeft(0)
		configSheetTwoFJWeclomerButtonLiveIndicator:AlignTop(220)
		configSheetTwoFJWeclomerButtonLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoFJWeclomerButton = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoFJWeclomerButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesDisconnectPropName"))
		configSheetTwoFJWeclomerButton:SetSize(200,25)
		configSheetTwoFJWeclomerButton:AlignLeft(4)
		configSheetTwoFJWeclomerButton:AlignTop(215)
		configSheetTwoFJWeclomerButton.DoClick = function(button)
			local propertyCode = 28
			previewLevel = 1
			local tableKeyName = {"dcButton"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDisconnectPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDisconnectPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- diconnect button toggle
			local toggleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			toggleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDisconnectToggleLabel"))
			toggleLabel:SetPos(2, 70)
			local toggleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			toggleOption:SetSize( 70, 18 )
			toggleOption:SetPos( 168, 70 )
			toggleOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueEnabled") )
			toggleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDisabled") )
			
			
			
			-- Update needed live preview stuff
			local function updatePreview()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					previewCopy["_"..tableKeyName[1]] = false
				else
					previewCopy["_"..tableKeyName[1]] = true
				end
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()				
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDisabled")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueEnabled")
				end
				
				if toggleOption:GetText() != serverVar then
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
				
				if varTable[1] == true then
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueEnabled"))
				else
					toggleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDisabled"))
				end
				
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"dcButton"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDisabled") then
					propertyPanel.lastRecVariable[1] = false
				elseif toggleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueEnabled") then
					propertyPanel.lastRecVariable[1] = true
				else
					return
				end
				
				updateVariables(propertyPanel.lastRecVariable, {"dcButton"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"dcButton"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- URL Buttons
		local configSheetTwoURLButtonsLiveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheetTwo)
		configSheetTwoURLButtonsLiveIndicator:SetSize( 15, 15 )
		configSheetTwoURLButtonsLiveIndicator:AlignLeft(0)
		configSheetTwoURLButtonsLiveIndicator:AlignTop(250)
		configSheetTwoURLButtonsLiveIndicator:SetBGColor(Color(0, 200, 0))
		local configSheetTwoURLButtons = vgui.Create("fmainmenu_config_editor_button", configSheetTwo)
		configSheetTwoURLButtons:SetText(FMainMenu.GetPhrase("ConfigPropertiesURLButtonsPropName"))
		configSheetTwoURLButtons:SetSize(200,25)
		configSheetTwoURLButtons:AlignLeft(4)
		configSheetTwoURLButtons:AlignTop(245)
		configSheetTwoURLButtons.DoClick = function(button)
			local propertyCode = 29
			previewLevel = 1
			local tableKeyName = {"URLButtons"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesURLButtonsPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesURLButtonsPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- URL Buttons Editor
			local internalURLButtons = {}
			local URLButtonsEditorButton = vgui.Create("fmainmenu_config_editor_button", propertyPanel)
			URLButtonsEditorButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesURLButtonsEditorButtonLabel"))
			URLButtonsEditorButton:SetSize(200,25)
			URLButtonsEditorButton:AlignLeft(20)
			URLButtonsEditorButton:AlignTop(70)
			-- IMPORTANT: OnClick function move below isVarChanged so it can be triggered
			
			
			
			-- Update needed live preview stuff
			local function updatePreview()
				previewCopy["_"..tableKeyName[1]] = internalURLButtons
			end
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()
				--Checks for differences between tables
				if #propertyPanel.lastRecVariable[1] != #internalURLButtons then
					setUnsaved(true)
					return
				end
				
				for i,button in ipairs(propertyPanel.lastRecVariable[1]) do
					if button.Text != internalURLButtons[i].Text then
						setUnsaved(true)
						return
					end
					
					if button.URL != internalURLButtons[i].URL then
						setUnsaved(true)
						return
					end
				end
				
				setUnsaved(false)
			end
			
			URLButtonsEditorButton.DoClick = function(button)
				setExternalBlock(true)
				FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(true)
					
				-- frame setup
				URLButtonEditor = vgui.Create( "fmainmenu_config_editor" )
				URLButtonEditor:SetSize( 370, 580 )
				URLButtonEditor:SetPos(screenWidth/2-185, screenHeight/2-290)
				URLButtonEditor:SetTitle(FMainMenu.GetPhrase("ConfigURLButtonEditorWindowTitle"))
				URLButtonEditor:SetZPos(10)
				function URLButtonEditor:OnClose()
					setExternalBlock(false)
					FMainMenu.configPropertyWindow.configBlockerPanel:SetVisible(false)
					
					URLButtonEditor = nil
				end
				
				local mainBPanel = nil
				
				local function updateCacheVisuals()
					if mainBPanel != nil then
						mainBPanel:Remove()
					end
					
					mainBPanel = vgui.Create("fmainmenu_config_editor_scrollpanel", URLButtonEditor)
					mainBPanel:SetBGColor(Color(110,110,110))
					mainBPanel:SetSize( 360, 520 )
					mainBPanel:AlignLeft(5)
					mainBPanel:AlignTop(25)
				
					local panelBlocker = nil
					local heightOff = 10
					for i,button in ipairs(internalURLButtons) do
						local buttonPanel = vgui.Create("fmainmenu_config_editor_panel", mainBPanel)
						buttonPanel.bIndex = i
						buttonPanel:SetBGColor(Color(100,100,100))
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
							internalURLButtons[buttonPanel.bIndex].Text = buttonTextBox:GetText()
							isVarChanged()
							updatePreview()
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
							internalURLButtons[buttonPanel.bIndex].URL = buttonLinkBox:GetText()
							isVarChanged()
							updatePreview()
						end
						
						-- remove button
						local buttonRemove = vgui.Create("fmainmenu_config_editor_image_button", buttonPanel)
						buttonRemove:SetImage("icon16/cancel.png")
						buttonRemove:SetSize(20,20)
						buttonRemove:AlignRight(5)
						buttonRemove:AlignBottom(5)
						buttonRemove.DoClick = function(button)
							--Confirmation dialogue
							panelBlocker:SetVisible(true)
							local removeConfirm =  vgui.Create("fmainmenu_config_editor_panel", panelBlocker)
							removeConfirm:SetBGColor(Color(55, 55, 55, 255))
							removeConfirm:SetSize( 246, 93 )
							removeConfirm:Center()
							
							local leftText = FMainMenu.Derma.CreateDLabel(removeConfirm, 221, 113, false, FMainMenu.GetPhrase("ConfigURLButtonEditorWindowDeleteConfirm"))
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
								
								-- Remove the button
								table.remove( internalURLButtons, buttonPanel.bIndex )
								updateCacheVisuals()
								
								isVarChanged()
								updatePreview()
							end
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
								local temp = table.Copy(internalURLButtons[buttonPanel.bIndex])
								internalURLButtons[buttonPanel.bIndex] = internalURLButtons[buttonPanel.bIndex-1]
								internalURLButtons[buttonPanel.bIndex-1] = temp
								updateCacheVisuals()
								
								isVarChanged()
								updatePreview()
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
							if buttonPanel.bIndex < #internalURLButtons then
								local temp = table.Copy(internalURLButtons[buttonPanel.bIndex])
								internalURLButtons[buttonPanel.bIndex] = internalURLButtons[buttonPanel.bIndex+1]
								internalURLButtons[buttonPanel.bIndex+1] = temp
								updateCacheVisuals()
								
								isVarChanged()
								updatePreview()
							end
						end
					end
					
					panelBlocker =  vgui.Create("fmainmenu_config_editor_panel", URLButtonEditor)
					panelBlocker:SetBGColor(Color(0, 0, 0, 155))
					panelBlocker:SetSize( 360, 520 )
					panelBlocker:AlignLeft(5)
					panelBlocker:AlignTop(25)
					panelBlocker:SetVisible(false)
				end
				
				local function updateCachedTable(varTable)
					internalURLButtons = table.Copy(varTable[1])
					updateCacheVisuals()
					
					isVarChanged()
					updatePreview()
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
					requestVariables(updateCachedTable, {"URLButtons"})
				end
				
				local bottomPanelAddButton = vgui.Create("fmainmenu_config_editor_button", bottomPanel)
				bottomPanelAddButton:SetText(FMainMenu.GetPhrase("ConfigURLButtonEditorAddButtonText"))
				bottomPanelAddButton:SetSize(100,24)
				bottomPanelAddButton:AlignLeft(5)
				bottomPanelAddButton:AlignTop(3)
				bottomPanelAddButton.DoClick = function(button)
					table.insert( internalURLButtons, {
						Text = "New Button",
						URL = "Link Here",
					} )
					updateCacheVisuals()
					
					isVarChanged()
					updatePreview()
				end
				
				updateCachedTable({internalURLButtons})
					
				URLButtonEditor:MakePopup()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = table.Copy(varTable)
				
				internalURLButtons = table.Copy(varTable[1])
				
				setUnsaved(false)
				updatePreview()
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"URLButtons"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				propertyPanel.lastRecVariable[1] = table.Copy(internalURLButtons)
				
				updateVariables(propertyPanel.lastRecVariable, {"URLButtons"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"URLButtons"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		configSheet:AddSheet( FMainMenu.GetPhrase("ConfigPropertiesCategoriesMenu"), configSheetTwo, nil )
		
		
		
		local configSheetThree = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetThree:SetSize( 240, 230 )
		
		-- Sandbox Hooks
		local configSheetThreeSandboxHooksButton = vgui.Create("fmainmenu_config_editor_button", configSheetThree)
		configSheetThreeSandboxHooksButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPropName"))
		configSheetThreeSandboxHooksButton:SetSize(200,25)
		configSheetThreeSandboxHooksButton:AlignLeft(4)
		configSheetThreeSandboxHooksButton:AlignTop(5)
		configSheetThreeSandboxHooksButton.DoClick = function(button)
			local propertyCode = 31
			previewLevel = 0
			local tableKeyName = {"PlayerSpawnEffect","PlayerSpawnNPC","PlayerSpawnProp","PlayerSpawnRagdoll","PlayerSpawnSENT","PlayerSpawnSWEP","PlayerSpawnVehicle","PlayerGiveSWEP"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- PlayerSpawnEffect toggle
			local playerSpawnEffectLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			playerSpawnEffectLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnEffect"))
			playerSpawnEffectLabel:SetPos(2, 70)
			local playerSpawnEffectOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			playerSpawnEffectOption:SetSize( 70, 18 )
			playerSpawnEffectOption:SetPos( 168, 70 )
			playerSpawnEffectOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			playerSpawnEffectOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			playerSpawnEffectOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- PlayerSpawnNPC toggle
			local playerSpawnNPCLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			playerSpawnNPCLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnNPC"))
			playerSpawnNPCLabel:SetPos(2, 91)
			local playerSpawnNPCOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			playerSpawnNPCOption:SetSize( 70, 18 )
			playerSpawnNPCOption:SetPos( 168, 91 )
			playerSpawnNPCOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			playerSpawnNPCOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			playerSpawnNPCOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- PlayerSpawnProp toggle
			local playerSpawnPropLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			playerSpawnPropLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnProp"))
			playerSpawnPropLabel:SetPos(2, 112)
			local playerSpawnPropOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			playerSpawnPropOption:SetSize( 70, 18 )
			playerSpawnPropOption:SetPos( 168, 112 )
			playerSpawnPropOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			playerSpawnPropOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			playerSpawnPropOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- PlayerSpawnRagdoll toggle
			local playerSpawnRagdollLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			playerSpawnRagdollLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnRagdoll"))
			playerSpawnRagdollLabel:SetPos(2, 133)
			local playerSpawnRagdollOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			playerSpawnRagdollOption:SetSize( 70, 18 )
			playerSpawnRagdollOption:SetPos( 168, 133 )
			playerSpawnRagdollOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			playerSpawnRagdollOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			playerSpawnRagdollOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- PlayerSpawnSENT toggle
			local playerSpawnSENTLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			playerSpawnSENTLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnSENT"))
			playerSpawnSENTLabel:SetPos(2, 154)
			local playerSpawnSENTOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			playerSpawnSENTOption:SetSize( 70, 18 )
			playerSpawnSENTOption:SetPos( 168, 154 )
			playerSpawnSENTOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			playerSpawnSENTOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			playerSpawnSENTOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- PlayerSpawnSWEP toggle
			local playerSpawnSWEPLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			playerSpawnSWEPLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnSWEP"))
			playerSpawnSWEPLabel:SetPos(2, 175)
			local playerSpawnSWEPOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			playerSpawnSWEPOption:SetSize( 70, 18 )
			playerSpawnSWEPOption:SetPos( 168, 175 )
			playerSpawnSWEPOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			playerSpawnSWEPOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			playerSpawnSWEPOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- PlayerSpawnVehicle toggle
			local playerSpawnVehicleLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			playerSpawnVehicleLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnVehicle"))
			playerSpawnVehicleLabel:SetPos(2, 196)
			local playerSpawnVehicleOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			playerSpawnVehicleOption:SetSize( 70, 18 )
			playerSpawnVehicleOption:SetPos( 168, 196 )
			playerSpawnVehicleOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			playerSpawnVehicleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			playerSpawnVehicleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- PlayerGiveSWEP toggle
			local playerGiveSWEPLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			playerGiveSWEPLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerGiveSWEP"))
			playerGiveSWEPLabel:SetPos(2, 217)
			local playerGiveSWEPOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			playerGiveSWEPOption:SetSize( 70, 18 )
			playerGiveSWEPOption:SetPos( 168, 217 )
			playerGiveSWEPOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			playerGiveSWEPOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			playerGiveSWEPOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()				
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if playerSpawnEffectOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[2] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if playerSpawnNPCOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[3] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if playerSpawnPropOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[4] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if playerSpawnRagdollOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[5] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if playerSpawnSENTOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[6] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if playerSpawnSWEPOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[7] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if playerSpawnVehicleOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[8] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if playerGiveSWEPOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function playerSpawnEffectOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function playerSpawnNPCOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function playerSpawnPropOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function playerSpawnRagdollOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function playerSpawnSENTOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function playerSpawnSWEPOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function playerSpawnVehicleOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function playerGiveSWEPOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				
				if varTable[1] == true then
					playerSpawnEffectOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					playerSpawnEffectOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[2] == true then
					playerSpawnNPCOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					playerSpawnNPCOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[3] == true then
					playerSpawnPropOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					playerSpawnPropOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[4] == true then
					playerSpawnRagdollOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					playerSpawnRagdollOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[5] == true then
					playerSpawnSENTOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					playerSpawnSENTOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[6] == true then
					playerSpawnSWEPOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					playerSpawnSWEPOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[7] == true then
					playerSpawnVehicleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					playerSpawnVehicleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[8] == true then
					playerGiveSWEPOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					playerGiveSWEPOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				setUnsaved(false)
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"PlayerSpawnEffect","PlayerSpawnNPC","PlayerSpawnProp","PlayerSpawnRagdoll","PlayerSpawnSENT","PlayerSpawnSWEP","PlayerSpawnVehicle","PlayerGiveSWEP"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if playerSpawnEffectOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[1] = false
				elseif playerSpawnEffectOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[1] = true
				else
					return
				end
				
				if playerSpawnNPCOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[2] = false
				elseif playerSpawnNPCOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[2] = true
				else
					return
				end
				
				if playerSpawnPropOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[3] = false
				elseif playerSpawnPropOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[3] = true
				else
					return
				end
				
				if playerSpawnRagdollOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[4] = false
				elseif playerSpawnRagdollOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[4] = true
				else
					return
				end
				
				if playerSpawnSENTOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[5] = false
				elseif playerSpawnSENTOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[5] = true
				else
					return
				end
				
				if playerSpawnSWEPOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[6] = false
				elseif playerSpawnSWEPOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[6] = true
				else
					return
				end
				
				if playerSpawnVehicleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[7] = false
				elseif playerSpawnVehicleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[7] = true
				else
					return
				end
				
				if playerGiveSWEPOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[8] = false
				elseif playerGiveSWEPOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[8] = true
				else
					return
				end
				
				updateVariables(propertyPanel.lastRecVariable, {"PlayerSpawnEffect","PlayerSpawnNPC","PlayerSpawnProp","PlayerSpawnRagdoll","PlayerSpawnSENT","PlayerSpawnSWEP","PlayerSpawnVehicle","PlayerGiveSWEP"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"PlayerSpawnEffect","PlayerSpawnNPC","PlayerSpawnProp","PlayerSpawnRagdoll","PlayerSpawnSENT","PlayerSpawnSWEP","PlayerSpawnVehicle","PlayerGiveSWEP"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		-- DarkRP Hooks
		local configSheetThreeDarkRPHooksButton = vgui.Create("fmainmenu_config_editor_button", configSheetThree)
		configSheetThreeDarkRPHooksButton:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksPropName"))
		configSheetThreeDarkRPHooksButton:SetSize(200,25)
		configSheetThreeDarkRPHooksButton:AlignLeft(4)
		configSheetThreeDarkRPHooksButton:AlignTop(35)
		configSheetThreeDarkRPHooksButton.DoClick = function(button)
			local propertyCode = 32
			previewLevel = 0
			local tableKeyName = {"DarkRPCanBuy","DarkRPCanChatSound","DarkRPCanUse","DarkRPCanUsePocket","DarkRPCanDropWeapon","DarkRPCanReqHits","DarkRPCanReqWarrants"}
			if FMainMenu.configPropertyWindow.propertyCode == propertyCode then return end
			FMainMenu.configPropertyWindow.propertyCode = propertyCode
		
			--Property Panel Setup
			local propertyPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
			propertyPanel:SetSize( 240, 255 )
			propertyPanel:SetPos(5,25)
			local propertyPanelLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksPropName"))
			propertyPanelLabel:SetFont("HudHintTextLarge")
			propertyPanelLabel:SetPos(2,0)
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksPropDesc"))
			propertyPanelDescLabel:SetPos(3, 24)
			propertyPanelDescLabel:SetSize(225, 36)
		
			-- DarkRPCanBuy toggle
			local canBuyLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			canBuyLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanBuy"))
			canBuyLabel:SetPos(2, 70)
			local canBuyOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			canBuyOption:SetSize( 70, 18 )
			canBuyOption:SetPos( 168, 70 )
			canBuyOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			canBuyOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			canBuyOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- DarkRPCanChatSound toggle
			local canChatSoundLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			canChatSoundLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanChatSound"))
			canChatSoundLabel:SetPos(2, 91)
			local canChatSoundOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			canChatSoundOption:SetSize( 70, 18 )
			canChatSoundOption:SetPos( 168, 91 )
			canChatSoundOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			canChatSoundOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			canChatSoundOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- DarkRPCanUse toggle
			local canUseLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			canUseLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanUse"))
			canUseLabel:SetPos(2, 112)
			local canUseOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			canUseOption:SetSize( 70, 18 )
			canUseOption:SetPos( 168, 112 )
			canUseOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			canUseOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			canUseOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- DarkRPCanUsePocket toggle
			local canUsePocketLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			canUsePocketLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanUsePocket"))
			canUsePocketLabel:SetPos(2, 133)
			local canUsePocketOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			canUsePocketOption:SetSize( 70, 18 )
			canUsePocketOption:SetPos( 168, 133 )
			canUsePocketOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			canUsePocketOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			canUsePocketOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- DarkRPCanDropWeapon toggle
			local canDropWeaponLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			canDropWeaponLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanDropWeapon"))
			canDropWeaponLabel:SetPos(2, 154)
			local canDropWeaponOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			canDropWeaponOption:SetSize( 70, 18 )
			canDropWeaponOption:SetPos( 168, 154 )
			canDropWeaponOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			canDropWeaponOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			canDropWeaponOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- DarkRPCanReqHits toggle
			local canReqHitsLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			canReqHitsLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanReqHits"))
			canReqHitsLabel:SetPos(2, 175)
			local canReqHitsOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			canReqHitsOption:SetSize( 70, 18 )
			canReqHitsOption:SetPos( 168, 175 )
			canReqHitsOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			canReqHitsOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			canReqHitsOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			-- DarkRPCanReqWarrants toggle
			local canReqWarrantsLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			canReqWarrantsLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanReqWarrants"))
			canReqWarrantsLabel:SetPos(2, 196)
			local canReqWarrantsOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			canReqWarrantsOption:SetSize( 70, 18 )
			canReqWarrantsOption:SetPos( 168, 196 )
			canReqWarrantsOption:SetValue( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			canReqWarrantsOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
			canReqWarrantsOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueDenied") )
			
			
			
			-- Used to detect changes in the on-screen form from the server-side variable	
			local function isVarChanged()				
				local serverVar = ""
				if propertyPanel.lastRecVariable[1] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if canBuyOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[2] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if canChatSoundOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[3] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if canUseOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[4] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if canUsePocketOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[5] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if canDropWeaponOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[6] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if canReqHitsOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				serverVar = ""
				if propertyPanel.lastRecVariable[7] == false then
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
				else
					serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
				end
				
				if canReqWarrantsOption:GetText() != serverVar then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
			function canBuyOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function canChatSoundOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function canUseOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function canUsePocketOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function canDropWeaponOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function canReqHitsOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			function canReqWarrantsOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			-- Called when server responds with current server-side variables
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				
				if varTable[1] == true then
					canBuyOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					canBuyOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[2] == true then
					canChatSoundOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					canChatSoundOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[3] == true then
					canUseOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					canUseOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[4] == true then
					canUsePocketOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					canUsePocketOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[5] == true then
					canDropWeaponOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					canDropWeaponOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[6] == true then
					canReqHitsOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					canReqHitsOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				if varTable[7] == true then
					canReqWarrantsOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
				else
					canReqWarrantsOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
				end
				
				setUnsaved(false)
			end
			
			-- Send the request for said server-side variables
			requestVariables(onGetVar, {"DarkRPCanBuy","DarkRPCanChatSound","DarkRPCanUse","DarkRPCanUsePocket","DarkRPCanDropWeapon","DarkRPCanReqHits","DarkRPCanReqWarrants"})
			
			-- Called when someone wants to commit changes to a property
			local function saveFunc()
				if canBuyOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[1] = false
				elseif canBuyOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[1] = true
				else
					return
				end
				
				if canChatSoundOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[2] = false
				elseif canChatSoundOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[2] = true
				else
					return
				end
				
				if canUseOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[3] = false
				elseif canUseOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[3] = true
				else
					return
				end
				
				if canUsePocketOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[4] = false
				elseif canUsePocketOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[4] = true
				else
					return
				end
				
				if canDropWeaponOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[5] = false
				elseif canDropWeaponOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[5] = true
				else
					return
				end
				
				if canReqHitsOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[6] = false
				elseif canReqHitsOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[6] = true
				else
					return
				end
				
				if canReqWarrantsOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
					propertyPanel.lastRecVariable[7] = false
				elseif canReqWarrantsOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
					propertyPanel.lastRecVariable[7] = true
				else
					return
				end
				
				updateVariables(propertyPanel.lastRecVariable, {"DarkRPCanBuy","DarkRPCanChatSound","DarkRPCanUse","DarkRPCanUsePocket","DarkRPCanDropWeapon","DarkRPCanReqHits","DarkRPCanReqWarrants"})
				setUnsaved(false)
			end
			
			-- Called when someone wants to revert changes to a property
			local function revertFunc()
				requestVariables(onGetVar, {"DarkRPCanBuy","DarkRPCanChatSound","DarkRPCanUse","DarkRPCanUsePocket","DarkRPCanDropWeapon","DarkRPCanReqHits","DarkRPCanReqWarrants"})
			end
			
			-- Setup the save and revert buttons
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
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
			if soundSelection != nil then
				soundSelection:Close()
			end
			if URLButtonEditor != nil then
				URLButtonEditor:Close()
			end
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
	3 - 1 but with music
]]--
local blurMat = Material("pp/blurscreen")
local colorWhite = Color(255, 255, 255)
local HTMLLogo = nil
local ChangelogBox = nil
local welcomerBox = nil
local welcomerBoxLeftText = nil
local welcomerBoxButton = nil
local CLText = nil
local cachedLink = ""
local musicStation = nil
local cachedMusicContent = ""
local cachedMusicOption = nil
local cachedMusicVolume = nil
local cachedMusicLooping = nil

hook.Add( "HUDPaint", "ExampleMenu_FMainMenu_ConfigEditor", function()
	if previewLevel > 0 then -- draw menu
		local width = ScrW()
		local height = ScrH()
	
		-- Logo
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
		
		-- Buttons
		local xPos = width * 0.05
		local normalSize = 192
		if previewCopy["_logoIsText"] then
			normalSize = previewCopy["_logoFontSize"]
		end
		
		local curYPos = (ScrH() * 0.5) - 32
		if previewCopy["_GarrysModStyle"] then
			local additive = 64
			if previewCopy["_logoIsText"] then
				additive = 104
			end
			curYPos = additive + normalSize
		end
		
		-- Play Button
		draw.SimpleText( FMainMenu.GetPhrase("PlayButtonText"), FMainMenu.CurrentTextButtonFont, xPos, curYPos, FayLib.IGC.GetSharedKey(addonName, "textButtonColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		curYPos = curYPos + 72
		
		-- URL Buttons
		for _,URLButton in ipairs(previewCopy["_URLButtons"]) do
			draw.SimpleText( URLButton.Text, FMainMenu.CurrentTextButtonFont, xPos, curYPos, FayLib.IGC.GetSharedKey(addonName, "textButtonColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			curYPos = curYPos + 48
		end
		
		-- Disconnect Button
		if previewCopy["_dcButton"] then
			curYPos = curYPos + 24
			if #previewCopy["_URLButtons"] == 0 then
				curYPos = curYPos - 36
			end
			draw.SimpleText( FMainMenu.GetPhrase("DisconnectButtonText"), FMainMenu.CurrentTextButtonFont, xPos, curYPos, FayLib.IGC.GetSharedKey(addonName, "textButtonColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end

		-- Changelog
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
			
		-- First Time Welcome
		if previewLevel == 2 then
			if welcomerBox == nil then
				welcomerBox = FMainMenu.Derma.CreateDFrame(FMainMenu.GetPhrase("WelcomerFrameTitle"), nil, 380, 256)
				welcomerBox:SetZPos(1)
				welcomerBox:Center()
				welcomerBox:ShowCloseButton( false )
				welcomerBox:SetDraggable( false )
				
				local initTroublePanel = FMainMenu.Derma.CreateDPanel(welcomerBox, 365, 221, false )
				initTroublePanel:SetPos(5, 25)
				FMainMenu.Derma:SetFrameSettings(initTroublePanel, FayLib.IGC.GetSharedKey(addonName, "commonPanelColor"), 0)
				welcomerBoxLeftText = FMainMenu.Derma.CreateDLabel(initTroublePanel, 345, 128, false, previewCopy["_firstJoinText"])
				welcomerBoxLeftText:SetFont("HudHintTextLarge")
				welcomerBoxLeftText:SetPos(10, 10)
				welcomerBoxLeftText:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
				welcomerBoxLeftText:SetWrap( true )
				welcomerBoxLeftText:SetContentAlignment( 8 )
				
				local wBBPanel = FMainMenu.Derma.CreateDPanel(initTroublePanel, 355, FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"), false )
				wBBPanel:SetPos(5, 216-FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"))
				
				welcomerBoxButton = FMainMenu.Derma.CreateDLabel(initTroublePanel, 355, FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"), false, previewCopy["_firstJoinURLText"])
				welcomerBoxButton:SetFont("HudHintTextLarge")
				welcomerBoxButton:SetPos(5, 216-FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"))
				welcomerBoxButton:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
				welcomerBoxButton:SetContentAlignment( 5 )
			end
			
			welcomerBoxLeftText:SetText(previewCopy["_firstJoinText"])
			welcomerBoxButton:SetText(previewCopy["_firstJoinURLText"])
		else
			if welcomerBox != nil then
				welcomerBox:Close()
				welcomerBox = nil
				welcomerBoxButton = nil
				welcomerBoxLeftText = nil
			end
		end
		
		-- Music Preview
		if previewLevel == 3 && soundSelection == nil then
			if cachedMusicContent != previewCopy["_musicContent"] || cachedMusicOption != previewCopy["_musicToggle"] || cachedMusicVolume != previewCopy["_musicVolume"] || cachedMusicLooping != previewCopy["_musicLooping"] then
				cachedMusicContent = previewCopy["_musicContent"]
				cachedMusicOption = previewCopy["_musicToggle"]
				cachedMusicVolume = previewCopy["_musicVolume"]
				cachedMusicLooping = previewCopy["_musicLooping"]
				
				if musicStation != nil then
					musicStation:Stop()
					musicStation = nil
				end
				
				if previewCopy["_musicToggle"] == 1 then
					--file
					sound.PlayFile( previewCopy["_musicContent"] , "noblock", function( station, errCode, errStr )
						if ( IsValid( station ) ) then
							station:EnableLooping(previewCopy["_musicLooping"])
							station:SetVolume(previewCopy["_musicVolume"])
							musicStation = station
						end
					end)
				elseif previewCopy["_musicToggle"] == 2 then
					--url
					sound.PlayURL( previewCopy["_musicContent"] , "noblock", function( station, errCode, errStr )
						if ( IsValid( station ) ) then
							station:EnableLooping(previewCopy["_musicLooping"])
							station:SetVolume(previewCopy["_musicVolume"])
							musicStation = station
						end
					end)
				end
			end
		else
			if musicStation != nil then
				cachedMusicContent = ""
				cachedMusicOption = nil
				cachedMusicVolume = nil
				cachedMusicLooping = nil
				
				musicStation:Stop()
				musicStation = nil
			end
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
		
		if welcomerBox != nil then
			welcomerBox:Close()
			welcomerBox = nil
			welcomerBoxButton = nil
			welcomerBoxLeftText = nil
		end
		
		if musicStation != nil then
			cachedMusicContent = ""
			cachedMusicOption = nil
			cachedMusicVolume = nil
			cachedMusicLooping = nil
			
			musicStation:Stop()
			musicStation = nil
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