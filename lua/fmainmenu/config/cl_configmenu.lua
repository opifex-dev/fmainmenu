local FMainMenu = FMainMenu

-- localized global calls
local surface_PlaySound = surface.PlaySound
local include = include
local file_Find = file.Find
local pairs = pairs
local net_Receive = net.Receive
local net_ReadBool = net.ReadBool
local ScrW = ScrW
local ScrH = ScrH
local vgui_Create = vgui.Create
local Color = Color
local ipairs = ipairs
local net_Start = net.Start
local net_SendToServer = net.SendToServer
local hook_Add = hook.Add
local concommand_Add = concommand.Add

-- variables related to below functionality
FMainMenu.CurConfigMenu = FMainMenu.CurConfigMenu || nil
FMainMenu.configPropertyWindow = FMainMenu.configPropertyWindow || nil
local addonName = "fmainmenu"

-- load helper functions
include( "fmainmenu/config/cl_confighelper.lua" )
include( "fmainmenu/config/cl_configpanels.lua" )
include( "fmainmenu/config/cl_configpreview.lua" )

-- load all property guis before we need them
local files = file_Find("fmainmenu/config/modules/*.lua", "LUA")
for _, f in pairs(files) do
	include("fmainmenu/config/modules/" .. f)
end

-- If player is allowed, open editor
net_Receive( "FMainMenu_Config_OpenMenu", function( len )
	-- Editor cannot open when the player is currently in the main menu (live preview restrictions)
	if net_ReadBool() then
		FMainMenu.Log(FMainMenu.GetPhrase("ConfigLeaveMenu"), false)
		return
	end

	-- Prevent duplicate windows
	if FMainMenu.CurConfigMenu == nil then
		local screenWidth = ScrW()
		local screenHeight = ScrH()

		local mainBlocker = vgui_Create("fmainmenu_config_editor_panel")
		mainBlocker:SetSize( screenWidth, screenHeight )
		mainBlocker.Paint = function(s, width, height) end
		mainBlocker:SetZPos(5)

		-- Code prepping for GUI previews
		FMainMenu.ConfigPreview.previewLevel = 0
		FMainMenu.ConfigPreview.previewCopy = {}
		for k,v in pairs(FayLib.IGC["Config"]["Shared"][addonName]) do -- copy shared vars
			FMainMenu.ConfigPreview.previewCopy[k] = v
		end

		--[[
			Config Properties Window
		]]--

		FMainMenu.configPropertyWindow = vgui_Create( "fmainmenu_config_editornoclose" )
		FMainMenu.configPropertyWindow:SetSize( 250, 360 )
		FMainMenu.configPropertyWindow:SetPos(screenWidth-250, screenHeight-360)
		FMainMenu.configPropertyWindow:SetTitle(FMainMenu.GetPhrase("ConfigPropertiesWindowTitle"))
		FMainMenu.configPropertyWindow.propertyCode = 0
		FMainMenu.configPropertyWindow:SetZPos(100)

		FMainMenu.configPropertyWindow.currentProp = vgui_Create("fmainmenu_config_editor_panel", FMainMenu.configPropertyWindow)
		FMainMenu.configPropertyWindow.currentProp:SetSize( 240, 330 )
		FMainMenu.configPropertyWindow.currentProp:SetPos(5,25)

		local configPropertyWindowDefLabel = vgui_Create("fmainmenu_config_editor_label", FMainMenu.configPropertyWindow.currentProp)
		configPropertyWindowDefLabel:SetText(FMainMenu.GetPhrase("ConfigPropertiesNoneSelected"))
		configPropertyWindowDefLabel:SetSize(240, 25)
		configPropertyWindowDefLabel:SetFont("HudHintTextLarge")
		configPropertyWindowDefLabel:SetContentAlignment(5)

		--[[
			Config Option Selector
		]]--

		FMainMenu.CurConfigMenu = vgui_Create( "fmainmenu_config_editornoclose" )
		FMainMenu.CurConfigMenu:SetSize( 250, 250 )
		FMainMenu.CurConfigMenu:SetPos(screenWidth-250, screenHeight-620)
		FMainMenu.CurConfigMenu:SetTitle(FMainMenu.GetPhrase("ConfigPropertiesSelectorTitle"))
		FMainMenu.CurConfigMenu.unsavedVar = false
		FMainMenu.CurConfigMenu:SetZPos(100)

		local configSheet = vgui_Create( "fmainmenu_config_editor_sheet", FMainMenu.CurConfigMenu)
		configSheet:SetSize( 240, 220 )
		configSheet:AlignRight(5)
		configSheet:AlignTop(25)

		FMainMenu.CurConfigMenu.configUnsavedBlocker = vgui_Create("fmainmenu_config_editor_panel", FMainMenu.CurConfigMenu)
		FMainMenu.CurConfigMenu.configUnsavedBlocker:SetSize( 240, 195 )
		FMainMenu.CurConfigMenu.configUnsavedBlocker:SetBGColor(Color(0,0,0,155))
		FMainMenu.CurConfigMenu.configUnsavedBlocker:AlignRight(5)
		FMainMenu.CurConfigMenu.configUnsavedBlocker:AlignTop(50)
		FMainMenu.CurConfigMenu.configUnsavedBlocker:SetVisible(false)

		FMainMenu.CurConfigMenu.configExternalWindowBlocker = vgui_Create("fmainmenu_config_editor_panel", FMainMenu.CurConfigMenu)
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:SetSize( 240, 195 )
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:SetBGColor(Color(0,0,0,0))
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:AlignRight(5)
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:AlignTop(50)
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:SetVisible(false)

		-- setup sheet categories
		local configSheets = {}
		local configSheetNames = {FMainMenu.GetPhrase("ConfigPropertiesCategoriesCamera"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesMenu"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesHooks"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesDerma"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesAccess"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesAdvanced")}
		local sheetTempHeights = {}

		for i = 1, 6 do
			configSheets[i] = vgui_Create("fmainmenu_config_editor_scrollpanel", configSheet)
			configSheets[i]:SetSize( 232, 188 )
			sheetTempHeights[i] = 0
		end

		-- Recursively generate property buttons
		for propCode,propTable in pairs(FMainMenu.ConfigModules) do
			if propTable.liveUpdate then
				local liveIndicator = vgui_Create("fmainmenu_config_editor_panel", configSheets[propTable.category])
				liveIndicator:SetSize( 15, 15 )
				liveIndicator:AlignLeft(0)
				liveIndicator:AlignTop(10 + sheetTempHeights[propTable.category])
				liveIndicator:SetBGColor(Color(0, 200, 0))
			end

			local propButton = vgui_Create("fmainmenu_config_editor_button", configSheets[propTable.category])
			propButton:SetText(propTable.propName)
			propButton:SetSize(216,25)
			propButton:AlignLeft(4)
			propButton:AlignTop(5 + sheetTempHeights[propTable.category])
			propButton.propCode = propCode
			propButton.category = propTable.category
			propButton.previewLevel = propTable.previewLevel
			propButton.DoClick = function(button)
				surface_PlaySound("garrysmod/ui_click.wav")
				if FMainMenu.configPropertyWindow.propertyCode == propButton.propCode then return end
				FMainMenu.configPropertyWindow.propertyCode = propButton.propCode
				local varsList = FMainMenu.ConfigModules[button.propCode].GeneratePanel(configSheets[propButton.category])
				FMainMenu.ConfigModulesHelper.requestVariables(varsList[1])
				FMainMenu.ConfigModulesHelper.setupGeneralPropPanels()
				FMainMenu.ConfigModulesHelper.setPropPanel(varsList[2])
				FMainMenu.ConfigPreview.previewLevel = propButton.previewLevel

				timer.Simple(0, function()
					FMainMenu.ConfigModulesHelper.scrollBarAdjustments()
				end)
			end
			FMainMenu.Derma.SetPanelHover(propButton, 1)

			sheetTempHeights[propTable.category] = sheetTempHeights[propTable.category] + 30
		end

		-- set up scroll for sheet panels when needed
		for i = 1, 6 do
			local mainPanel = configSheets[i]:GetChildren()[1]
			local totalOptions = 0
			for _,panel in ipairs(mainPanel:GetChildren()) do
				if panel:GetClassName() == "Label" then
					totalOptions = totalOptions + 1
				end
			end

			if totalOptions > 6 then
				for _,panel in ipairs(mainPanel:GetChildren()) do
					local oldX, oldY = panel:GetSize()
					panel:SetSize(200, oldY)
				end
			end

			configSheet:AddSheet( configSheetNames[i], configSheets[i], nil )
		end

		--[[
			Top-Middle Info Bar
		]]--

		local topInfoBar = vgui_Create("fmainmenu_config_editor_panel", mainBlocker)
		topInfoBar:SetSize( screenWidth / 3, 30 )
		topInfoBar:SetPos(screenWidth / 3,0)
		topInfoBar:SetZPos(10)
		--topInfoBar:SetBGColor(Color(75, 75, 75))

		local topInfoBarNameLabel = vgui_Create("fmainmenu_config_editor_label", topInfoBar)
		topInfoBarNameLabel:SetText(FMainMenu.GetPhrase("ConfigTopBarHeaderText"))
		topInfoBarNameLabel:SetFont("Trebuchet24")
		topInfoBarNameLabel:SetContentAlignment( 5 )
		topInfoBarNameLabel:SetSize(screenWidth / 3, 30)
		topInfoBarNameLabel:SetPos(0, 0)



		--[[
			Config Editor Exit Logic & Unsaved Changes Alert
		]]--

		local function closeConfig()
			net_Start("FMainMenu_Config_CloseMenu")
			net_SendToServer()
			if soundSelection != nil then
				soundSelection:Close()
			end
			if URLButtonEditor != nil then
				URLButtonEditor:Close()
			end
			mainBlocker:Remove()
			FMainMenu.configPropertyWindow.quitting = true
			if FMainMenu.configPropertyWindow.onCloseProp !=  nil then
				FMainMenu.configPropertyWindow.onCloseProp()
			end
			FMainMenu.configPropertyWindow:Remove()
			FMainMenu.configPropertyWindow = nil
			FMainMenu.CurConfigMenu:Close()
			FMainMenu.CurConfigMenu = nil
			FMainMenu.ConfigPreview.previewLevel = 0
		end

		local topInfoBarCloseButton = vgui_Create("fmainmenu_config_editor_button", topInfoBar)
		topInfoBarCloseButton:SetText(FMainMenu.GetPhrase("ConfigTopBarExitText"))
		topInfoBarCloseButton:SetSize(52.5,25)
		topInfoBarCloseButton:AlignRight(5)
		topInfoBarCloseButton:AlignTop(2.5)
		topInfoBarCloseButton.DoClick = function(button)
			if !FMainMenu.CurConfigMenu.unsavedVar then
				surface_PlaySound("garrysmod/ui_click.wav")
				closeConfig()
			else
				surface_PlaySound("common/warning.wav")
				-- If the active property has changes, confirm they want to discard
				topInfoBar:SetKeyboardInputEnabled( false )
				topInfoBar:SetMouseInputEnabled( false )
				FMainMenu.configPropertyWindow:SetKeyboardInputEnabled( false )
				FMainMenu.configPropertyWindow:SetMouseInputEnabled( false )

				local closeBlocker = vgui_Create("fmainmenu_config_editor_panel")
				closeBlocker:SetSize( screenWidth, screenHeight )
				closeBlocker:SetZPos( 100 )
				closeBlocker.Paint = function(s, width, height) end

				local closeCheck = vgui_Create( "fmainmenu_config_editornoclose" )
				closeCheck:SetSize( 300, 125 )
				closeCheck:SetZPos( 101 )
				closeCheck:Center()
				closeCheck:SetTitle(FMainMenu.GetPhrase("ConfigUnsavedChangesHeader"))

				local closeQuestionLabel = vgui_Create("fmainmenu_config_editor_label", closeCheck)
				closeQuestionLabel:SetText(FMainMenu.GetPhrase("ConfigUnsavedChanges"))
				closeQuestionLabel:SetSize(280,125)
				closeQuestionLabel:SetContentAlignment(8)
				closeQuestionLabel:SetPos(10, 25)

				local closeQuestionNo = vgui_Create("fmainmenu_config_editor_button", closeCheck)
				closeQuestionNo:SetText(FMainMenu.GetPhrase("ConfigCommonValueNo"))
				closeQuestionNo:SetSize(50,25)
				closeQuestionNo:AlignRight(50)
				closeQuestionNo:AlignTop(85)
				closeQuestionNo.DoClick = function(button)
					surface_PlaySound("garrysmod/ui_click.wav")
					closeCheck:Close()
					closeBlocker:Remove()
					topInfoBar:MakePopup()
					FMainMenu.configPropertyWindow:MakePopup()
				end

				local closeQuestionYes = vgui_Create("fmainmenu_config_editor_button", closeCheck)
				closeQuestionYes:SetText(FMainMenu.GetPhrase("ConfigCommonValueYes"))
				closeQuestionYes:SetSize(50,25)
				closeQuestionYes:AlignLeft(50)
				closeQuestionYes:AlignTop(85)
				closeQuestionYes.DoClick = function(button)
					surface_PlaySound("garrysmod/ui_click.wav")
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
hook_Add( "HUDShouldDraw", "HideHUD_FMainMenu_ConfigEditor", function( name )
	if ( hide[ name ] and FMainMenu.CurConfigMenu ) then
		return false
	end
end )

-- Concommand to request editor access
local function requestMenu( player, command, arguments )
	net_Start( "FMainMenu_Config_OpenMenu" )
	net_SendToServer()
end

concommand_Add( "fmainmenu_config", requestMenu )