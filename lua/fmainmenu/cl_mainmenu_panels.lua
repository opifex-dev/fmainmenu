local Color = Color
local surface_CreateFont = surface.CreateFont
local hook_Add = hook.Add
local FMainMenu = FMainMenu
local FayLib = FayLib
local tostring = tostring
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local vgui_Create = vgui.Create
local surface_PlaySound = surface.PlaySound
local gui_OpenURL = gui.OpenURL
local ScrH = ScrH
local ScrW = ScrW
local file_Write = file.Write
local RunConsoleCommand = RunConsoleCommand
local draw_SimpleTextOutlined = draw.SimpleTextOutlined
local string_JavascriptSafe = string.JavascriptSafe

FMainMenu.Panels = FMainMenu.Panels || {}
FMainMenu.Lang = FMainMenu.Lang || {}

local m_border = nil
local blockerColor = Color(0,0,0,0)
local addonName = "fmainmenu"

FMainMenu.CurrentLogoFont = FMainMenu.CurrentLogoFont || "FMM_LogoFont"
FMainMenu.CurrentTextButtonFont = FMainMenu.CurrentTextButtonFont || "FMM_ButtonFont"
FMainMenu.FontCounter = FMainMenu.FontCounter || 0

--Create fonts that will be used in the menu
function FMainMenu.Panels.createNewFont(fontName, fontBase, fontSize, fontShadow)
	surface_CreateFont( fontName, {
		font = fontBase,
		extended = false,
		size = fontSize,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = fontShadow,
		additive = false,
		outline = false,
	})
end

-- Create initial fonts when config first synced from server
hook_Add("IGCSharedConfigReady", "FMainMenu_Panels_SharedReady", function()
	FMainMenu.Panels.createNewFont("FMM_LogoFont",
		FayLib.IGC.GetSharedKey(addonName, "logoFont"),
		FayLib.IGC.GetSharedKey(addonName, "logoFontSize"),
		FayLib.IGC.GetSharedKey(addonName, "logoShadow"))

	FMainMenu.Panels.createNewFont("FMM_ButtonFont",
		FayLib.IGC.GetSharedKey(addonName, "textButtonFont"),
		FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"),
		FayLib.IGC.GetSharedKey(addonName, "textButtonShadow"))
end)

-- Update fonts when needed
hook_Add("IGCSharedConfigUpdate", "FMainMenu_Panels_SharedConfigUpdate", function(addonConfigName)
	if addonConfigName == addonName then
		FMainMenu.FontCounter = FMainMenu.FontCounter + 1

		FMainMenu.Panels.createNewFont("FMM_LogoFont" .. tostring(FMainMenu.FontCounter),
			FayLib.IGC.GetSharedKey(addonName, "logoFont"),
			FayLib.IGC.GetSharedKey(addonName, "logoFontSize"),
			FayLib.IGC.GetSharedKey(addonName, "logoShadow"))

		FMainMenu.Panels.createNewFont("FMM_ButtonFont" .. tostring(FMainMenu.FontCounter),
			FayLib.IGC.GetSharedKey(addonName, "textButtonFont"),
			FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"),
			FayLib.IGC.GetSharedKey(addonName, "textButtonShadow"))

		FMainMenu.CurrentLogoFont = "FMM_LogoFont" .. tostring(FMainMenu.FontCounter)
		FMainMenu.CurrentTextButtonFont = "FMM_ButtonFont" .. tostring(FMainMenu.FontCounter)
	end
end)

-- Assigns buttons with the need text colors, fonts, etc.
local function buttonSetup(button, text, fontName)
	button:SetPaintBackground(false)
	button:SetText(text)
	button:SetFont(fontName)
	button:SetTextColor(FayLib.IGC.GetSharedKey(addonName, "textButtonColor"))
	surface_SetFont(fontName)

	local fontWidth = surface_GetTextSize( text )
	button:SetSize(fontWidth, FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"))
	button:SetContentAlignment(4)
	FMainMenu.Derma.SetPanelHover(button, 2, text)
end

-- Creates Menu Button (functionality set manually)
function FMainMenu.Panels.CreateButton(text)
	local TextButton = vgui_Create("DButton", m_border)
	buttonSetup(TextButton, text, FMainMenu.CurrentTextButtonFont)
	return TextButton
end

-- Creates Menu URL Button (opens URL when clicked)
function FMainMenu.Panels.CreateURLButton(text, URL)
	local URLButton = vgui_Create("DButton", m_border)
	buttonSetup(URLButton, text, FMainMenu.CurrentTextButtonFont)
	URLButton.IntURL = URL
	URLButton.DoClick = function()
		surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonClickSound"))
		gui_OpenURL( URLButton.IntURL )
	end

	return URLButton
end

-- Creates Changelog Box with specified text
function FMainMenu.Panels.CreateChangeLog(text)
	local CLPanel = FMainMenu.Derma.CreateDPanel(m_border, 256, ScrH() * (1 / 3), false )
	if FayLib.IGC.GetSharedKey(addonName, "changeLogMoveToBottom") then
		CLPanel:SetPos(ScrW() - 266, (ScrH() * (2 / 3)) - 10)
	else
		CLPanel:SetPos(ScrW() - 266, 10)
	end
	FMainMenu.Derma:SetFrameSettings(CLPanel, FayLib.IGC.GetSharedKey(addonName, "commonPanelColor"), 0)

	local CLText = FMainMenu.Derma.CreateDLabel(CLPanel, 221, (ScrH() * (1 / 3)) - 5, false, text)
	CLText:SetPos(10, 5)
	CLText:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
	CLText:SetContentAlignment( 7 )
end

-- Creates Welcomer Box with message and URL specified by the config
function FMainMenu.Panels.CreateWelcomer()
	local blocker = FMainMenu.Derma.CreateDPanel(nil, ScrW(), ScrH(), false )
	blocker:SetPaintBackground( false )
	FMainMenu.Derma:SetFrameSettings(blocker, blockerColor, 0)

	local welcomeFrame = FMainMenu.Derma.CreateDFrame(FMainMenu.GetPhrase("WelcomerFrameTitle"), nil, 380, 256)
	FMainMenu.Derma:SetFrameSettings(welcomeFrame, FayLib.IGC.GetSharedKey(addonName, "commonFrameColor"), FayLib.IGC.GetSharedKey(addonName, "commonFrameBevelRadius"), true)

	local initWelcomePanel = FMainMenu.Derma.CreateDPanel(welcomeFrame, 365, 221, false )
	initWelcomePanel:SetPos(5, 25)
	FMainMenu.Derma:SetFrameSettings(initWelcomePanel, FayLib.IGC.GetSharedKey(addonName, "commonPanelColor"), 0)

	local initWelcomeScrollPanel = FMainMenu.Derma.CreateDScrollPanel(initWelcomePanel, 365, 211 - FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"), false )
	FMainMenu.Derma:SetFrameSettings(initWelcomeScrollPanel, FayLib.IGC.GetSharedKey(addonName, "commonPanelColor"), 0)

	local leftText = FMainMenu.Derma.CreateDLabel(initWelcomeScrollPanel, 345, 216, false, FayLib.IGC.GetSharedKey(addonName, "firstJoinText"))
	leftText:SetPos(5, 5)
	leftText:SetAutoStretchVertical( true )
	leftText:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )

	local firstButton = FMainMenu.Derma.CreateDButton(initWelcomePanel, 355, FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"), FayLib.IGC.GetSharedKey(addonName, "firstJoinURLText"), "")
	firstButton:SetPos(5, 216 - FayLib.IGC.GetSharedKey(addonName, "textButtonFontSize"))
	firstButton:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
	FMainMenu.Derma.SetPanelHover(firstButton, 1)
	FMainMenu.Derma:SetFrameSettings(firstButton, FayLib.IGC.GetSharedKey(addonName, "commonButtonColor"), 0)
	firstButton.DoClick = function()
		surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonClickSound"))
		file_Write("fmainmenu/" .. FMainMenu.firstJoinSeed .. ".txt", "true")
		if FayLib.IGC.GetSharedKey(addonName, "firstJoinURLEnabled") == true then
			gui_OpenURL( FayLib.IGC.GetSharedKey(addonName, "firstJoinURL") )
		end
		welcomeFrame:Close()
		blocker:Remove()
	end
end

-- Creates Disconnect Confirmation Box
function FMainMenu.Panels.CreateConfirmDC()
	local blocker = FMainMenu.Derma.CreateDPanel(nil, ScrW(), ScrH(), false )
	blocker:SetPaintBackground( false )
	FMainMenu.Derma:SetFrameSettings(blocker, blockerColor, 0)

	local disconnectFrame = FMainMenu.Derma.CreateDFrame(FMainMenu.GetPhrase("DisconnectFrameTitle"), nil, 256, 128)
	FMainMenu.Derma:SetFrameSettings(disconnectFrame, FayLib.IGC.GetSharedKey(addonName, "commonFrameColor"), FayLib.IGC.GetSharedKey(addonName, "commonFrameBevelRadius"), true)

	local initDisconnectPanel = FMainMenu.Derma.CreateDPanel(disconnectFrame, 246, 93, false )
	initDisconnectPanel:SetPos(5, 25)
	FMainMenu.Derma:SetFrameSettings(initDisconnectPanel, FayLib.IGC.GetSharedKey(addonName, "commonPanelColor"), 0)

	local leftText = FMainMenu.Derma.CreateDLabel(initDisconnectPanel, 221, 113, false, FMainMenu.GetPhrase("DisconnectConfirmText"))
	leftText:SetPos(10, 10)
	leftText:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor"))

	local secondButton = FMainMenu.Derma.CreateDButton(initDisconnectPanel, 108, 32, FMainMenu.GetPhrase("ConfigCommonValueNo"), "")
	secondButton:SetPos(130, 56)
	secondButton:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
	FMainMenu.Derma.SetPanelHover(secondButton, 1)
	FMainMenu.Derma:SetFrameSettings(secondButton, FayLib.IGC.GetSharedKey(addonName, "commonButtonColor"), 0)
	secondButton.DoClick = function()
		surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonClickSound"))
		disconnectFrame:Close()
		blocker:Remove()
	end

	local firstButton = FMainMenu.Derma.CreateDButton(initDisconnectPanel, 108, 32, FMainMenu.GetPhrase("ConfigCommonValueYes"), "")
	firstButton:SetPos(8, 56)
	firstButton:SetTextColor( FayLib.IGC.GetSharedKey(addonName, "commonTextColor") )
	FMainMenu.Derma.SetPanelHover(firstButton, 1)
	FMainMenu.Derma:SetFrameSettings(firstButton, FayLib.IGC.GetSharedKey(addonName, "commonButtonColor"), 0)
	firstButton.DoClick = function()
		surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonClickSound"))
		RunConsoleCommand( "disconnect" )
	end
end

-- Creates Background blocker and sets up logo, blur, and tint.
function FMainMenu.Panels.SetupBasics()
	if m_border != nil then FMainMenu.Panels.Destroy() end
	m_border = FMainMenu.Derma.CreateDPanel(nil, ScrW(), ScrH(), false)
	m_border:SetPaintBackgroundEnabled(false)

	-- tint and blur
	local tintColor = FayLib.IGC.GetSharedKey(addonName, "BackgroundColorTint")
	local blurAmount = FayLib.IGC.GetSharedKey(addonName, "BackgroundBlurAmount")

	if tintColor.alpha == 0 then
		tintColor = false
	end

	if blurAmount == 0 then
		blurAmount = false
	end

	if tintColor != false && blurAmount == false then
		FMainMenu.Derma:SetFrameSettings(m_border, tintColor, 0)
	elseif tintColor == false && blurAmount != false then
		FMainMenu.Derma:SetFrameBlur(m_border, blurAmount)
	elseif tintColor != false && blurAmount != false then
		FMainMenu.Derma:SetFrameCombo(m_border, tintColor, blurAmount)
	end

	-- logo
	if FayLib.IGC.GetSharedKey(addonName, "logoIsText") then
		surface_SetFont(FMainMenu.CurrentLogoFont)
		local fontWidth = surface_GetTextSize(FayLib.IGC.GetSharedKey(addonName, "logoContent"))
		local logo = FMainMenu.Derma.CreateDLabel(m_border, fontWidth, FayLib.IGC.GetSharedKey(addonName, "logoFontSize"), false, "")
		if !FayLib.IGC.GetSharedKey(addonName, "GarrysModStyle") then
			logo:SetPos(ScrW() * 0.04, (ScrH() * 0.5) - FayLib.IGC.GetSharedKey(addonName, "logoFontSize") - 64)
		else
			logo:SetPos(ScrW() * 0.04, ScrW() * 0.04)
		end
		logo:SetFont(FMainMenu.CurrentLogoFont)
		logo:SetWrap(false)
		logo:SetTextColor(FayLib.IGC.GetSharedKey(addonName, "textLogoColor"))
		logo:SetContentAlignment( 1 )
		function logo:Paint()
			draw_SimpleTextOutlined( FayLib.IGC.GetSharedKey(addonName, "logoContent"), FMainMenu.CurrentLogoFont, 0, 0, FayLib.IGC.GetSharedKey(addonName, "textLogoColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, FayLib.IGC.GetSharedKey(addonName, "logoOutlineThickness"), FayLib.IGC.GetSharedKey(addonName, "logoOutlineColor") )
		end
	else
		local logo = vgui_Create("DHTML", m_border)
		logo:SetSize(ScrW() * 0.5, 192)
		if !FayLib.IGC.GetSharedKey(addonName, "GarrysModStyle") then
			logo:SetPos(ScrW() * 0.04, (ScrH() * 0.5) - 256)
		else
			logo:SetPos(ScrW() * 0.04, 32)
		end
		logo:SetMouseInputEnabled(false)
		function logo:ConsoleMessage(msg) end
		logo:SetHTML([[
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
					var url = "]] .. string_JavascriptSafe(FayLib.IGC.GetSharedKey(addonName, "logoContent")) .. [[";
					document.getElementById("img").src = url;
				</script>
			</body>
		</html>
		]])
	end

	return BackPanel
end

-- Destroys Menu
function FMainMenu.Panels.Destroy()
	if m_border != nil then
		local mb = m_border
		mb:Remove()
		m_border = nil
	end
end