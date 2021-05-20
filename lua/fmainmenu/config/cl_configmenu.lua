FMainMenu.CurConfigMenu = FMainMenu.CurConfigMenu || nil
FMainMenu.configPropertyWindow = FMainMenu.configPropertyWindow || nil
local previewLevel = 0
local previewCopy = {}
local addonName = "fmainmenu"

-- load helper functions
include( "fmainmenu/config/cl_confighelper.lua" )
include( "fmainmenu/config/cl_configpanels.lua" )

-- load all property guis before we need them
local files = file.Find("fmainmenu/config/modules/*.lua", "LUA")
for _, f in pairs(files) do
	include("fmainmenu/config/modules/"..f)
end

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
		
		FMainMenu.CurConfigMenu.configUnsavedBlocker = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.CurConfigMenu)
		FMainMenu.CurConfigMenu.configUnsavedBlocker:SetSize( 240, 195 )
		FMainMenu.CurConfigMenu.configUnsavedBlocker:SetBGColor(Color(0,0,0,155))
		FMainMenu.CurConfigMenu.configUnsavedBlocker:AlignRight(5)
		FMainMenu.CurConfigMenu.configUnsavedBlocker:AlignTop(50)
		FMainMenu.CurConfigMenu.configUnsavedBlocker:SetVisible(false)
		
		FMainMenu.CurConfigMenu.configExternalWindowBlocker = vgui.Create("fmainmenu_config_editor_panel", FMainMenu.CurConfigMenu)
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:SetSize( 240, 195 )
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:SetBGColor(Color(0,0,0,0))
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:AlignRight(5)
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:AlignTop(50)
		FMainMenu.CurConfigMenu.configExternalWindowBlocker:SetVisible(false)
		
		-- setup sheet categories
		local configSheets = {}
		local configSheetNames = {FMainMenu.GetPhrase("ConfigPropertiesCategoriesCamera"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesMenu"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesHooks"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesDerma"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesAccess"), FMainMenu.GetPhrase("ConfigPropertiesCategoriesAdvanced")}
		local sheetTempHeights = {0, 0, 0, 0, 0, 0}
		
		for i=1,6 do
			configSheets[i] = vgui.Create("fmainmenu_config_editor_panel", configSheet)
			configSheets[i]:SetSize( 240, 220 )
		end
		
		-- Recursively generate property buttons
		for propCode,propTable in pairs(FMainMenu.ConfigModules) do
			if propTable.liveUpdate then
				local liveIndicator = vgui.Create("fmainmenu_config_editor_panel", configSheets[propTable.category])
				liveIndicator:SetSize( 15, 15 )
				liveIndicator:AlignLeft(0)
				liveIndicator:AlignTop(10 + sheetTempHeights[propTable.category])
				liveIndicator:SetBGColor(Color(0, 200, 0))
			end
			
			local propButton = vgui.Create("fmainmenu_config_editor_button", configSheets[propTable.category])
			propButton:SetText(propTable.propName)
			propButton:SetSize(200,25)
			propButton:AlignLeft(4)
			propButton:AlignTop(5 + sheetTempHeights[propTable.category])
			propButton.propCode = propCode
			propButton.category = propTable.category
			propButton.DoClick = function(button)
				if FMainMenu.configPropertyWindow.propertyCode == propButton.propCode then return end
				FMainMenu.configPropertyWindow.propertyCode = propButton.propCode
				local varsList = FMainMenu.ConfigModules[button.propCode].GeneratePanel(configSheets[propButton.category])
				FMainMenu.ConfigModulesHelper.requestVariables(varsList[1])
				FMainMenu.ConfigModulesHelper.setupGeneralPropPanels()
				FMainMenu.ConfigModulesHelper.setPropPanel(varsList[2])
			end
			
			sheetTempHeights[propTable.category] = sheetTempHeights[propTable.category] + 30
		end
		
		for i=1,6 do
			configSheet:AddSheet( configSheetNames[i], configSheets[i], nil )
		end
		
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