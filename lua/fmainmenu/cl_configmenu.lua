FMainMenu.CurConfigMenu = FMainMenu.CurConfigMenu || nil
FMainMenu.configPropertyWindow = FMainMenu.configPropertyWindow || nil

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
	propPanelSaveButton:SetText("Save Property")
	propPanelSaveButton:SetSize(200,25)
	propPanelSaveButton:AlignLeft(20)
	propPanelSaveButton:AlignTop(5)
	propPanelSaveButton.DoClick = function(button)
		saveFunc()
	end
	
	local propPanelRevertButton = vgui.Create("fmainmenu_config_editor_button", propertyGeneralPanel)
	propPanelRevertButton:SetText("Revert Changes")
	propPanelRevertButton:SetSize(200,25)
	propPanelRevertButton:AlignLeft(20)
	propPanelRevertButton:AlignTop(35)
	propPanelRevertButton.DoClick = function(button)
		revertFunc()
	end
end

local function updateVariables(varTable, varList)
	net.Start("FMainMenu_Config_UpdateVar")
		net.WriteTable(varList)
		net.WriteString(util.TableToJSON(varTable))
	net.SendToServer()
end

net.Receive( "FMainMenu_Config_ReqVar", function( len )
	local receivedStr = net.ReadString()
	local receivedVarTable = util.JSONToTable( receivedStr )
	
	-- add fix for "Colors will not have the color metatable" bug
	local keyList = table.GetKeys(receivedVarTable)
	for i=1,#keyList do
		if type(receivedVarTable[keyList[i]]) == "table" then
			local innerTable = receivedVarTable[keyList[i]]
			local innerKeyList = table.GetKeys(innerTable)
			if(#innerKeyList == 4 && innerTable.a ~= nil && innerTable.r ~= nil && innerTable.g ~= nil && innerTable.b ~= nil) then
				receivedVarTable[keyList[i]] = Color(innerTable.r, innerTable.g, innerTable.b, innerTable.a)
			end
		end
	end
	
	FMainMenu.configPropertyWindow.onVarRecFunc(receivedVarTable)
end)

net.Receive( "FMainMenu_Config_OpenMenu", function( len )
	if net.ReadBool() then
		FMainMenu.Log(FMainMenu.Lang.ConfigLLeaveMenu, false)
		return
	end
	
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
		FMainMenu.configPropertyWindow:SetPos(screenWidth-250, screenHeight/2 + 180)
		FMainMenu.configPropertyWindow:SetTitle("FMainMenu - Config Properties")
		FMainMenu.configPropertyWindow.propertyCode = 0
		FMainMenu.configPropertyWindow:SetZPos(10)
		
		FMainMenu.configPropertyWindow.currentProp = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
		FMainMenu.configPropertyWindow.currentProp:SetSize( 240, 330 )
		FMainMenu.configPropertyWindow.currentProp:SetPos(5,25)
		
		local configPropertyWindowDefLabel = vgui.Create("fmainmenu_config_editor_label", FMainMenu.configPropertyWindow.currentProp)
		configPropertyWindowDefLabel:SetText("No Property Selected")
		configPropertyWindowDefLabel:SetSize(240, 25)
		configPropertyWindowDefLabel:SetFont("HudHintTextLarge")
		configPropertyWindowDefLabel:SetContentAlignment(5)
		
		local function setPropPanel(newPanel)
			if (FMainMenu.configPropertyWindow.currentProp != nil) then
				FMainMenu.configPropertyWindow.currentProp:Remove()
			end
			
			FMainMenu.configPropertyWindow.currentProp = newPanel
			FMainMenu.configPropertyWindow:MakePopup()
		end
		
		local function requestVariables(varRecCallback, varNames)
			FMainMenu.configPropertyWindow.onVarRecFunc = varRecCallback
		
			net.Start("FMainMenu_Config_ReqVar")
				net.WriteTable(varNames)
			net.SendToServer()
		end
		
		
	
		--[[
			Config Option Selector
		]]--
		
		FMainMenu.CurConfigMenu = vgui.Create( "fmainmenu_config_editornoclose" )
		FMainMenu.CurConfigMenu:SetSize( 250, 250 )
		FMainMenu.CurConfigMenu:SetPos(screenWidth-250, screenHeight/2-75)
		FMainMenu.CurConfigMenu:SetTitle("FMainMenu - Config Selector")
		FMainMenu.CurConfigMenu.unsavedVar = false
		FMainMenu.CurConfigMenu:SetZPos(10)
		
		local configSheet = vgui.Create( "fmainmenu_config_editor_sheet", FMainMenu.CurConfigMenu)
		configSheet:SetSize( 240, 220 )
		configSheet:AlignRight(5)
		configSheet:AlignTop(25)
		
		local configUnsavedBlocker = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.CurConfigMenu)
		configUnsavedBlocker:SetSize( 240, 190 )
		configUnsavedBlocker:SetBGColor(Color(0,0,0,175))
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
		local configSheetOneCameraSetupButton = vgui.Create("fmainmenu_config_editor_button", configSheetOne)
		configSheetOneCameraSetupButton:SetText("Camera Setup")
		configSheetOneCameraSetupButton:SetSize(200,25)
		configSheetOneCameraSetupButton:AlignLeft(11)
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
			cameraPositionLabel:SetText("Camera Setup")
			cameraPositionLabel:SetFont("HudHintTextLarge")
			local cameraPositionDescLabel = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionDescLabel:SetText("Allows you to set where the camera\nwill exist in the world")
			cameraPositionDescLabel:SetPos(1, 24)
			cameraPositionDescLabel:SetSize(225, 36)
			
			-- Position
			local cameraPositionLabel2 = vgui.Create("fmainmenu_config_editor_label", cameraPosition)
			cameraPositionLabel2:SetText("Position (Current Map): ")
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
			cameraPositionLabel3:SetText("Orientation (Current Map): ")
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
			
			local cameraPositionChooseButton = vgui.Create("fmainmenu_config_editor_button", cameraPosition)
			cameraPositionChooseButton:SetText("Capture Current Location")
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
			end
			
			local function isVarChanged()
				local mapName = game.GetMap()
				
				if tonumber(cameraPositionPosBoxX:GetText()) == nil || math.Round(tonumber(cameraPositionPosBoxX:GetText()), 3) != math.Round(cameraPosition.lastRecVariable[1][mapName].x, 3) then
					setUnsaved(true)
					return
				end
				
				if tonumber(cameraPositionPosBoxY:GetText()) == nil || math.Round(tonumber(cameraPositionPosBoxY:GetText()), 3) != math.Round(cameraPosition.lastRecVariable[1][mapName].y, 3) then
					setUnsaved(true)
					return
				end
				
				if tonumber(cameraPositionPosBoxZ:GetText()) == nil || math.Round(tonumber(cameraPositionPosBoxZ:GetText()), 3) != math.Round(cameraPosition.lastRecVariable[1][mapName].z, 3) then
					setUnsaved(true)
					return
				end
				
				if tonumber(cameraPositionRotBoxX:GetText()) == nil || math.Round(tonumber(cameraPositionRotBoxX:GetText()), 3) != math.Round(cameraPosition.lastRecVariable[2][mapName].x, 3) then
					setUnsaved(true)
					return
				end
				
				if tonumber(cameraPositionRotBoxY:GetText()) == nil || math.Round(tonumber(cameraPositionRotBoxY:GetText()), 3) != math.Round(cameraPosition.lastRecVariable[2][mapName].y, 3) then
					setUnsaved(true)
					return
				end
				
				if tonumber(cameraPositionRotBoxZ:GetText()) == nil || math.Round(tonumber(cameraPositionRotBoxZ:GetText()), 3) != math.Round(cameraPosition.lastRecVariable[2][mapName].z, 3) then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
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
			
			function cameraPositionRotBoxX:OnChange()
				isVarChanged()
			end
			
			function cameraPositionRotBoxY:OnChange()
				isVarChanged()
			end
			
			function cameraPositionRotBoxZ:OnChange()
				isVarChanged()
			end
			
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
			end
			
			requestVariables(onGetVar, {"CameraPosition","CameraAngle"})
			
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
			end
			
			local function revertFunc()
				requestVariables(onGetVar, {"CameraPosition","CameraAngle"})
			end
			
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(cameraPosition)
		end
		
		local configSheetOneCameraEverySpawnButton = vgui.Create("fmainmenu_config_editor_button", configSheetOne)
		configSheetOneCameraEverySpawnButton:SetText("Every Spawn")
		configSheetOneCameraEverySpawnButton:SetSize(200,25)
		configSheetOneCameraEverySpawnButton:AlignLeft(11)
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
			propertyPanelLabel:SetText("Every Spawn")
			propertyPanelLabel:SetFont("HudHintTextLarge")
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText("Whether the menu should appear on\nevery spawn or only once")
			propertyPanelDescLabel:SetPos(1, 24)
			propertyPanelDescLabel:SetSize(225, 36)
			
			-- Every Spawn
			local cameraEverySpawnLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraEverySpawnLabel2:SetText("Every Spawn: ")
			cameraEverySpawnLabel2:SetPos(0, 70)
			local cameraEverySpawnOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			cameraEverySpawnOption:SetSize( 50, 18 )
			cameraEverySpawnOption:SetPos( 85, 70 )
			cameraEverySpawnOption:SetValue( "True" )
			cameraEverySpawnOption:AddChoice( "True" )
			cameraEverySpawnOption:AddChoice( "False" )
			
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
			
			function cameraEverySpawnOption:OnSelect( index, value, data )
				isVarChanged()
			end
			
			local function onGetVar(varTable)
				propertyPanel.lastRecVariable = varTable
				if varTable[1] then 
					cameraEverySpawnOption:SetValue("True") 
				else
					cameraEverySpawnOption:SetValue("False")
				end
				setUnsaved(false)
			end
			
			requestVariables(onGetVar, {"EverySpawn"})
			
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
			
			local function revertFunc()
				requestVariables(onGetVar, {"EverySpawn"})
			end
			
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		local configSheetOneCameraAdvancedSpawnButton = vgui.Create("fmainmenu_config_editor_button", configSheetOne)
		configSheetOneCameraAdvancedSpawnButton:SetText("Advanced Spawn")
		configSheetOneCameraAdvancedSpawnButton:SetSize(200,25)
		configSheetOneCameraAdvancedSpawnButton:AlignLeft(11)
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
			propertyPanelLabel:SetText("Advanced Spawn")
			propertyPanelLabel:SetFont("HudHintTextLarge")
			local propertyPanelDescLabel = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			propertyPanelDescLabel:SetText("Whether the advanced spawn system\nshould be used")
			propertyPanelDescLabel:SetPos(1, 24)
			propertyPanelDescLabel:SetSize(225, 36)
			
			-- Advanced Spawn Toggle
			local cameraEverySpawnLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraEverySpawnLabel2:SetText("Advanced Spawn: ")
			cameraEverySpawnLabel2:SetPos(0, 70)
			local cameraEverySpawnOption = vgui.Create("fmainmenu_config_editor_combobox", propertyPanel)
			cameraEverySpawnOption:SetSize( 50, 18 )
			cameraEverySpawnOption:SetPos( 105, 70 )
			cameraEverySpawnOption:SetValue( "False" )
			cameraEverySpawnOption:AddChoice( "True" )
			cameraEverySpawnOption:AddChoice( "False" )	
			
			--Advanced Spawn Position
			local cameraPositionLabel2 = vgui.Create("fmainmenu_config_editor_label", propertyPanel)
			cameraPositionLabel2:SetText("Position (Current Map): ")
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
			
			local cameraPositionChooseButton = vgui.Create("fmainmenu_config_editor_button", propertyPanel)
			cameraPositionChooseButton:SetText("Capture Current Location")
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
				
				if tonumber(cameraPositionPosBoxX:GetText()) == nil || math.Round(tonumber(cameraPositionPosBoxX:GetText()), 3) != math.Round(propertyPanel.lastRecVariable[2][mapName].x, 3) then
					setUnsaved(true)
					return
				end
				
				if tonumber(cameraPositionPosBoxY:GetText()) == nil || math.Round(tonumber(cameraPositionPosBoxY:GetText()), 3) != math.Round(propertyPanel.lastRecVariable[2][mapName].y, 3) then
					setUnsaved(true)
					return
				end
				
				if tonumber(cameraPositionPosBoxZ:GetText()) == nil || math.Round(tonumber(cameraPositionPosBoxZ:GetText()), 3) != math.Round(propertyPanel.lastRecVariable[2][mapName].z, 3) then
					setUnsaved(true)
					return
				end
				
				setUnsaved(false)
			end
			
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
			
			requestVariables(onGetVar, {"AdvancedSpawn","AdvancedSpawnPos"})
			
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
			
			local function revertFunc()
				requestVariables(onGetVar, {"AdvancedSpawn","AdvancedSpawnPos"})
			end
			
			setupGeneralPropPanels(FMainMenu.configPropertyWindow, saveFunc, revertFunc)
			
			--Set completed panel as active property
			setPropPanel(propertyPanel)
		end
		
		configSheet:AddSheet( "Camera", configSheetOne, nil )
		
		local configSheetTwo = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetTwo:SetSize( 240, 230 )
		configSheet:AddSheet( "Menu", configSheetTwo, nil )
		
		local configSheetThree = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetThree:SetSize( 240, 230 )
		configSheet:AddSheet( "Hook Functionality", configSheetThree, nil )
		
		local configSheetFour = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetFour:SetSize( 240, 230 )
		configSheet:AddSheet( "Derma Style", configSheetFour, nil )
		
		local configSheetFive = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetFive:SetSize( 240, 230 )
		configSheet:AddSheet( "Config Access", configSheetFive, nil )
		
		local configSheetSix = vgui.Create("fmainmenu_config_editor_panel", configSheet)
		configSheetSix:SetSize( 240, 230 )
		configSheet:AddSheet( "Advanced", configSheetSix, nil )
		
		--[[
		local saveConfigPanel = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.CurConfigMenu)
		saveConfigPanel:SetSize( 590, 25 )
		saveConfigPanel:AlignRight(5)
		saveConfigPanel:AlignTop(450)
		saveConfigPanel:SetBGColor(Color(105,105,105))
		]]--
		--local revertButton = vgui.Create("fmainmenu_config_editor_button", saveConfigPanel)
		--local saveButton = vgui.Create("fmainmenu_config_editor_button", saveConfigPanel)
		--local previewButton = vgui.Create("fmainmenu_config_editor_button", saveConfigPanel)
		
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
		
		-- Removed for now because there is now a per-property save button, may not be needed
		--[[
		local topInfoBarSaveButton = vgui.Create("fmainmenu_config_editor_button", topInfoBar)
		topInfoBarSaveButton:SetText("Save")
		topInfoBarSaveButton:SetSize(52.5,25)
		topInfoBarSaveButton:AlignLeft(5)
		topInfoBarSaveButton:AlignTop(2.5)
		topInfoBarSaveButton.DoClick = function(button)
			print("Save!")
		end
		]]--
		
		local function closeConfig()
			mainBlocker:Remove()
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
				closeQuestionLabel:SetText("The current property is changed but unsaved,\n        would you like to discard changes?")
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

local function requestMenu( player, command, arguments )
	net.Start( "FMainMenu_Config_OpenMenu" )
	net.SendToServer()
end
 
concommand.Add( "fmainmenu_config", requestMenu )