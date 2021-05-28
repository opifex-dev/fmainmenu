local FMainMenu = FMainMenu

FMainMenu.ConfigPreview = FMainMenu.ConfigPreview || {}
FMainMenu.ConfigPreview.previewLevel = FMainMenu.ConfigPreview.previewLevel || 0
FMainMenu.ConfigPreview.previewCopy = FMainMenu.ConfigPreview.previewCopy || {}

-- localized global calls
local Material = Material
local Color = Color
local draw_RoundedBox = draw.RoundedBox
local draw_SimpleText = draw.SimpleText
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local draw_SimpleTextOutlined = draw.SimpleTextOutlined
local hook_Add = hook.Add
local ScrW = ScrW
local ScrH = ScrH
local tostring = tostring
local vgui_Create = vgui.Create
local string_JavascriptSafe = string.JavascriptSafe
local ipairs = ipairs
local sound_PlayFile = sound.PlayFile
local IsValid = IsValid
local sound_PlayURL = sound.PlayURL
local surface_SetMaterial = surface.SetMaterial
local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local surface_DrawTexturedRect = surface.DrawTexturedRect

-- variables used for keeping track of various aspects of the preview and also detecting changes between variables (ie. we don't want to recreate the fonts every frame)
local blurMat = Material("pp/blurscreen")
local colorWhite = Color(255, 255, 255)
local HTMLLogo = nil
local ChangelogBox = nil
local welcomerBox = nil
local welcomerBoxLeftText = nil
local welcomerBoxButton = nil
local welcomerBoxPanel = nil
local welcomerBoxScrollPanel = nil
local wBBPanel = nil
local CLText = nil
local cachedLink = ""
local musicStation = nil
local cachedMusicContent = ""
local cachedMusicOption = nil
local cachedMusicVolume = nil
local cachedMusicLooping = nil
local cachedLogoFont = ""
local cachedLogoFontSize = -1
local cachedLogoFontShadow = -1
local previewLogoFont = nil
local previewLogoFontCounter = 1
local cachedButtonFont = ""
local cachedButtonFontSize = -1
local cachedButtonFontShadow = -1
local previewButtonFont = nil
local previewButtonFontCounter = 1

--Adds custom paint function for custom backgrounds and rounding edges
local function previewFrameSettings(frame, color, radius, isFrame, commonTextColor)
	if isFrame then
		if radius > 0 then
			function frame:Paint(width, height)
				draw_RoundedBox(radius, 0, 0, width, height, color)
				draw_SimpleText(frame.Title, "Trebuchet18", 8, 12, commonTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		else
			function frame:Paint(width, height)
				surface_SetDrawColor(color)
				surface_DrawRect(0, 0, width, height)
				draw_SimpleText(frame.Title, "Trebuchet18", 8, 12, commonTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	else
		if radius > 0 then
			function frame:Paint(width, height)
				draw_RoundedBox(radius, 0, 0, width, height, color)
			end
		else
			function frame:Paint(width, height)
				surface_SetDrawColor(color)
				surface_DrawRect(0, 0, width, height)
			end
		end
	end
end

-- common setup code between URL and File based background music previews
local function musicStationSetup(station)
	if ( IsValid( station ) ) then
		station:EnableLooping(previewCopy["_musicLooping"])
		station:SetVolume(previewCopy["_musicVolume"])
		musicStation = station
	end
end

--Handles the "custom layout" advanced option preview
local customLayoutSetup = {
	["Play"] = function(Content, xPos, curYPos, previewCopy)
		draw_SimpleTextOutlined( Content.Text, previewButtonFont, xPos, curYPos, previewCopy["_textButtonColor"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, previewCopy["_textButtonOutlineThickness"], previewCopy["_textButtonOutlineColor"] )
		return curYPos + previewCopy["_textButtonFontSize"] + 12
	end,
	["URL"] = function(Content, xPos, curYPos, previewCopy)
		draw_SimpleTextOutlined( Content.Text, previewButtonFont, xPos, curYPos, previewCopy["_textButtonColor"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, previewCopy["_textButtonOutlineThickness"], previewCopy["_textButtonOutlineColor"] )
		return curYPos + previewCopy["_textButtonFontSize"] + 12
	end,
	["Disconnect"] = function(Content, xPos, curYPos, previewCopy)
		draw_SimpleTextOutlined( Content.Text, previewButtonFont, xPos, curYPos, previewCopy["_textButtonColor"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, previewCopy["_textButtonOutlineThickness"], previewCopy["_textButtonOutlineColor"] )
		return curYPos + previewCopy["_textButtonFontSize"] + 12
	end,
	["Spacer"] = function(Content, xPos, curYPos, previewCopy)
		return curYPos + ((2 / 3) * previewCopy["_textButtonFontSize"])
	end,
}

--[[
	Preview Hooks
	
	The below HUDPaint and HUDPaintBackground hooks will be used to render a real-time preview of vgui changes the player is making in the editor.
	I will also be listing all the possible states below so I don't forget.
	
	NOTE: We can likely utilize the updatePreview function I made for the other previews by keeping a copy of all needed variables to simulate the menu,
	and using the updatePreview function to modify whatever property the user is editing
	
	previewLevel:
	0 - no GUI, background only
	1 - background + base menu only
	2 - 1 but with first time join module simulated on top
	3 - 1 but with music
	4 - 2 but always enabled
]]--

-- live preview for main menu
hook_Add( "HUDPaint", "ExampleMenu_FMainMenu_ConfigEditor", function()
	local previewLevel = FMainMenu.ConfigPreview.previewLevel || 0
	local previewCopy = FMainMenu.ConfigPreview.previewCopy || {}
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

			-- position adjustment for gmod style
			local titleH = (height * 0.5) - previewCopy["_logoFontSize"] - 64
			if previewCopy["_GarrysModStyle"] then
				titleH = width * 0.04
			end

			-- if font value changed, create new font
			if previewCopy["_logoFont"] != cachedLogoFont || previewCopy["_logoFontSize"] != cachedLogoFontSize || previewCopy["_logoShadow"] != cachedLogoFontShadow then
				previewLogoFont = "FMM_PreviewLogoFont" .. tostring(previewLogoFontCounter)
				FMainMenu.Panels.createNewFont(previewLogoFont, previewCopy["_logoFont"], previewCopy["_logoFontSize"], previewCopy["_logoShadow"])
				cachedLogoFont = previewCopy["_logoFont"]
				cachedLogoFontSize = previewCopy["_logoFontSize"]
				cachedLogoFontShadow = previewCopy["_logoShadow"]
				previewLogoFontCounter = previewLogoFontCounter + 1
			end

			-- draw the text
			draw_SimpleTextOutlined( previewCopy["_logoContent"], previewLogoFont, width * 0.04, titleH, previewCopy["_textLogoColor"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, previewCopy["_logoOutlineThickness"], previewCopy["_logoOutlineColor"] )
		else
			-- recreate HTML panel if content box changed
			if HTMLLogo == nil || cachedLink != previewCopy["_logoContent"] then
				if HTMLLogo != nil then HTMLLogo:Remove() end
				HTMLLogo = vgui_Create("DHTML")
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
							var url = "]] .. string_JavascriptSafe(previewCopy["_logoContent"]) .. [[";
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

		-- determine menu buttons start point
		local curYPos = (ScrH() * 0.5) - 32
		if previewCopy["_GarrysModStyle"] then
			local additive = 64
			if previewCopy["_logoIsText"] then
				additive = 104
			end
			curYPos = additive + normalSize
		end

		-- update menu button font if needed
		if previewCopy["_textButtonFont"] != cachedButtonFont || previewCopy["_textButtonFontSize"] != cachedButtonFontSize || previewCopy["_textButtonShadow"] != cachedButtonFontShadow then
			previewButtonFont = "FMM_PreviewButtonFont" .. tostring(previewButtonFontCounter)
			FMainMenu.Panels.createNewFont(previewButtonFont, previewCopy["_textButtonFont"], previewCopy["_textButtonFontSize"], previewCopy["_textButtonShadow"])
			cachedButtonFont = previewCopy["_textButtonFont"]
			cachedButtonFontSize = previewCopy["_textButtonFontSize"]
			cachedButtonFontShadow = previewCopy["_textButtonShadow"]
			previewButtonFontCounter = previewButtonFontCounter + 1
		end

		if previewCopy["_MenuOverride"] then -- custom layout
			for _,entry in ipairs(previewCopy["_MenuSetup"]) do
				curYPos = customLayoutSetup[entry.Type](entry.Content, xPos, curYPos, previewCopy)
			end
		else -- default layout
			-- Play Button
			draw_SimpleTextOutlined( FMainMenu.GetPhrase("PlayButtonText"), previewButtonFont, xPos, curYPos, previewCopy["_textButtonColor"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, previewCopy["_textButtonOutlineThickness"], previewCopy["_textButtonOutlineColor"] )
			curYPos = curYPos + previewCopy["_textButtonFontSize"] + 36

			-- URL Buttons
			for _,URLButton in ipairs(previewCopy["_URLButtons"]) do
				draw_SimpleTextOutlined( URLButton.Text, previewButtonFont, xPos, curYPos, previewCopy["_textButtonColor"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, previewCopy["_textButtonOutlineThickness"], previewCopy["_textButtonOutlineColor"] )
				curYPos = curYPos + previewCopy["_textButtonFontSize"] + 12
			end

			-- Disconnect Button
			if previewCopy["_dcButton"] then
				curYPos = curYPos + 24
				if #previewCopy["_URLButtons"] == 0 then
					curYPos = curYPos - 36
				end
				draw_SimpleTextOutlined( FMainMenu.GetPhrase("DisconnectButtonText"), previewButtonFont, xPos, curYPos, previewCopy["_textButtonColor"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, previewCopy["_textButtonOutlineThickness"], previewCopy["_textButtonOutlineColor"] )
			end
		end

		-- Changelog
		if previewCopy["_showChangeLog"] then
			if ChangelogBox == nil then
				ChangelogBox = FMainMenu.Derma.CreateDPanel(nil, 256, 450, false )
				previewFrameSettings(ChangelogBox, previewCopy["_commonPanelColor"], 0, false, previewCopy["_commonTextColor"])
				ChangelogBox:SetZPos(1)

				CLText = FMainMenu.Derma.CreateDLabel(ChangelogBox, 221, 440, false, text)
				CLText:SetFont("HudHintTextLarge")
				CLText:SetPos(10, 5)
				CLText:SetTextColor( previewCopy["_commonPanelColor"] )
				CLText:SetContentAlignment( 7 )
				CLText:SetWrap( true )
			end

			-- adjust position to changes in config
			if previewCopy["_changeLogMoveToBottom"] then
				ChangelogBox:SetPos(width-266, height-460)
			else
				ChangelogBox:SetPos(width-266, 10)
			end

			-- adjust other related settings to changes in config
			CLText:SetTextColor( previewCopy["_commonTextColor"] )
			CLText:SetText(previewCopy["_changeLogText"])
			previewFrameSettings(ChangelogBox, previewCopy["_commonPanelColor"], 0, false, previewCopy["_commonTextColor"])
		else
			if ChangelogBox != nil then
				CLText:Remove()
				ChangelogBox:Remove()
				ChangelogBox = nil
				CLText = nil
			end
		end

		-- First Time Welcome
		if previewLevel == 2 && previewCopy["_firstJoinWelcome"] || previewLevel == 4 then
			if welcomerBox == nil then
				-- panel setup
				welcomerBox = FMainMenu.Derma.CreateDFrame(FMainMenu.GetPhrase("WelcomerFrameTitle"), nil, 380, 256)
				previewFrameSettings(welcomerBox, previewCopy["_commonFrameColor"], previewCopy["_commonFrameBevelRadius"], true, previewCopy["_commonTextColor"])
				welcomerBox:SetZPos(-100)

				welcomerBoxPanel = FMainMenu.Derma.CreateDPanel(welcomerBox, 365, 221, false )
				welcomerBoxPanel:SetPos(5, 25)
				previewFrameSettings(welcomerBoxPanel, previewCopy["_commonPanelColor"], 0, false, previewCopy["_commonTextColor"])

				welcomerBoxScrollPanel = FMainMenu.Derma.CreateDScrollPanel(welcomerBoxPanel, 365, 175, false )
				previewFrameSettings(welcomerBoxScrollPanel, previewCopy["_commonPanelColor"], 0)

				welcomerBoxLeftText = FMainMenu.Derma.CreateDLabel(welcomerBoxScrollPanel, 345, 128, false, previewCopy["_firstJoinText"])
				welcomerBoxLeftText:SetPos(5, 5)
				welcomerBoxLeftText:SetTextColor( previewCopy["_commonTextColor"] )
				welcomerBoxLeftText:SetAutoStretchVertical( true )

				wBBPanel = FMainMenu.Derma.CreateDPanel(welcomerBoxPanel, 355, 36, false )
				wBBPanel:SetPos(5, 180)
				previewFrameSettings(wBBPanel, previewCopy["_commonButtonColor"], 0)

				welcomerBoxButton = FMainMenu.Derma.CreateDLabel(welcomerBoxPanel, 355, 36, false, previewCopy["_firstJoinURLText"])
				welcomerBoxButton:SetWrap(false)
				welcomerBoxButton:SetPos(5, 180)
				welcomerBoxButton:SetTextColor( previewCopy["_commonTextColor"] )
				welcomerBoxButton:SetContentAlignment( 5 )
			end

			-- adjust various settings to changes in config
			welcomerBoxLeftText:SetText(previewCopy["_firstJoinText"])
			welcomerBoxButton:SetText(previewCopy["_firstJoinURLText"])
			welcomerBoxLeftText:SetTextColor( previewCopy["_commonTextColor"] )
			welcomerBoxButton:SetTextColor( previewCopy["_commonTextColor"] )
			previewFrameSettings(wBBPanel, previewCopy["_commonButtonColor"], 0)
			previewFrameSettings(welcomerBoxPanel, previewCopy["_commonPanelColor"], 0, false, previewCopy["_commonTextColor"])
			previewFrameSettings(welcomerBoxScrollPanel, previewCopy["_commonPanelColor"], 0)
			welcomerBoxScrollPanel:SetBarColor(previewCopy["_commonScrollPanelBarColor"])
			welcomerBoxScrollPanel:SetGripColor(previewCopy["_commonScrollPanelGripColor"])
			welcomerBoxScrollPanel:SetButtonColor(previewCopy["_commonScrollPanelButtonColor"])
			previewFrameSettings(welcomerBox, previewCopy["_commonFrameColor"], previewCopy["_commonFrameBevelRadius"], true, previewCopy["_commonTextColor"])
		else
			if welcomerBox != nil then
				welcomerBox:Close()
				welcomerBox = nil
				welcomerBoxButton = nil
				welcomerBoxLeftText = nil
				welcomerBoxPanel = nil
				welcomerBoxScrollPanel = nil
				wBBPanel = nil
			end
		end

		-- Music Preview
		if previewLevel == 3 && FMainMenu.ConfigModulesHelper.isSelectingSound() == false then
			-- check if music must be changed
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
					sound_PlayFile( previewCopy["_musicContent"] , "noblock", function( station, errCode, errStr )
						musicStationSetup(station)
					end)
				elseif previewCopy["_musicToggle"] == 2 then
					--url
					sound_PlayURL( previewCopy["_musicContent"] , "noblock", function( station, errCode, errStr )
						musicStationSetup(station)
					end)
				end
			end
		else
			if musicStation != nil then -- music stops when no longer needed
				cachedMusicContent = ""
				cachedMusicOption = nil
				cachedMusicVolume = nil
				cachedMusicLooping = nil

				musicStation:Stop()
				musicStation = nil
			end
		end
	else
		-- cleanup when we no longer want the preview to render
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
			welcomerBoxPanel = nil
			welcomerBoxScrollPanel = nil
			wBBPanel = nil
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

-- Preview Blur and Tint
hook_Add( "HUDPaintBackground", "ExampleMenuBackground_FMainMenu_ConfigEditor", function()
	local previewLevel = FMainMenu.ConfigPreview.previewLevel || 0
	local previewCopy = FMainMenu.ConfigPreview.previewCopy || {}
	if previewLevel > 0 then -- draw menu background
		local width = ScrW()
		local height = ScrH()

		-- background tint
		surface_SetDrawColor(previewCopy["_BackgroundColorTint"])
		surface_DrawRect(0, 0, width, height)

		-- background blur
		local blurAmount = previewCopy["_BackgroundBlurAmount"]
		if blurAmount > 0 then
			surface_SetDrawColor(colorWhite)
			surface_SetMaterial(blurMat)

			for i = 1, 3 do
				blurMat:SetFloat("$blur", (i / 3) * (blurAmount || 8))
				blurMat:Recompute()

				render_UpdateScreenEffectTexture()
				surface_DrawTexturedRect(0, 0, width, height)
			end
		end
	end
end)