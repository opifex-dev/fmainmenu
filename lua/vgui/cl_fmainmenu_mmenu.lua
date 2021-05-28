FMainMenu.Derma = FMainMenu.Derma || {}
FMainMenu.Config = FMainMenu.Config || {}

local Color = Color
local Material = Material
local draw_RoundedBox = draw.RoundedBox
local draw_SimpleText = draw.SimpleText
local FayLib = FayLib
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local ScrW = ScrW
local ScrH = ScrH
local surface_SetMaterial = surface.SetMaterial
local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_PlaySound = surface.PlaySound
local draw_SimpleTextOutlined = draw.SimpleTextOutlined
local vgui_Create = vgui.Create
local derma_DefineControl = derma.DefineControl

local blurMat = Material("pp/blurscreen")
local colorWhite = Color(255, 255, 255)
local addonName = "fmainmenu"

--[[
	HELPER FUNCTIONS
]]--

--Adds custom paint function for custom backgrounds and rounding edges
function FMainMenu.Derma:SetFrameSettings(frame, color, radius, isFrame)
	if isFrame then
		if radius > 0 then
			function frame:Paint(width, height)
				draw_RoundedBox(radius, 0, 0, width, height, color)
				draw_SimpleText(frame.Title, "Trebuchet18", 8, 12, FayLib.IGC.GetSharedKey(addonName, "commonTextColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		else
			function frame:Paint(width, height)
				surface_SetDrawColor(color)
				surface_DrawRect(0, 0, width, height)
				draw_SimpleText(frame.Title, "Trebuchet18", 8, 12, FayLib.IGC.GetSharedKey(addonName, "commonTextColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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

--Version of above designed to have both blur and tint simultaniously
function FMainMenu.Derma:SetFrameCombo(frame, color, blur)
	function frame:Paint(width, height)
		local scrW, scrH = ScrW(), ScrH()

		surface_SetDrawColor(colorWhite)
		surface_SetMaterial(blurMat)

		for i = 1, 3 do
			blurMat:SetFloat("$blur", (i / 3) * (blur || 8))
			blurMat:Recompute()

			render_UpdateScreenEffectTexture()
			surface_DrawTexturedRect(0, 0, scrW, scrH)
		end

		surface_SetDrawColor(color)
		surface_DrawRect(0, 0, width, height)
	end
end

--Adds blur to a panel
function FMainMenu.Derma:SetFrameBlur(frame, amount)
	function frame:Paint(width, height)
		local x, y = 0, 0
		local scrW, scrH = ScrW(), ScrH()

		surface_SetDrawColor(colorWhite)
		surface_SetMaterial(blurMat)

		for i = 1, 3 do
			blurMat:SetFloat("$blur", (i / 3) * (amount || 8))
			blurMat:Recompute()

			render_UpdateScreenEffectTexture()
			surface_DrawTexturedRect(x * -1, y * -1, scrW, scrH)
		end
	end
end

--Adds a hover effect to a button
function FMainMenu.Derma.SetPanelHover(frame, hoverType, arg)
	if hoverType == 1 then
		function frame:PaintOver(width, height)
			if frame:IsHovered() then
				surface_SetDrawColor(Color(0,0,0,70))
				surface_DrawRect(0, 0, width, height)
			end
		end
	elseif hoverType == 2 then
		frame.POHover = false
		 function frame:Paint(wid, height)
			if frame:IsHovered() then
				if frame.POHover == false then
					frame.POHover = true
					surface_PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonHoverSound"))
				end
				frame:SetTextColor(FayLib.IGC.GetSharedKey(addonName, "textButtonHoverColor"))
			else
				if frame.POHover then
					frame.POHover = false
				end
				frame:SetTextColor(FayLib.IGC.GetSharedKey(addonName, "textButtonColor"))
			end
			frame:UpdateFGColor()
			draw_SimpleTextOutlined( arg, FMainMenu.CurrentTextButtonFont, 0, 0, FayLib.IGC.GetSharedKey(addonName, "textButtonColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, FayLib.IGC.GetSharedKey(addonName, "textButtonOutlineThickness"), FayLib.IGC.GetSharedKey(addonName, "textButtonOutlineColor") )
		end
	end
end

--[[
	DERMA CONTROLS
]]--

-- custom dframe
local PANEL = {}
function PANEL:Init()
	self:Center()
	self:ShowCloseButton( false )
	self:SetDraggable( false )
end

derma_DefineControl("fmainmenu_menu_dframe", nil, PANEL, "DFrame")

-- custom dlabel
local PANEL = {}
function PANEL:Init()
	self:SetContentAlignment( 8 )
	self:SetFont("HudHintTextLarge")
	self:SetWrap( true )
	self:SetTextColor( Color(255,255,255,255) )
end

derma_DefineControl("fmainmenu_menu_dlabel", nil, PANEL, "DLabel")

-- custom dbutton
local PANEL = {}
function PANEL:Init()
	self:SetContentAlignment( 5 )
	self:SetFont("HudHintTextLarge")
	self:SetTextColor( Color(255,255,255,255) )
end

derma_DefineControl("fmainmenu_menu_dbutton", nil, PANEL, "DButton")

-- custom dscrollpanel
local PANEL = {}
function PANEL:Init()
	local sbar = self:GetVBar()

	sbar.BarColor = Color(75, 75, 75)
	sbar.Paint = function( s, w, h )
		draw_RoundedBox( 0, 0, 0, w, h, s.BarColor )
	end

	sbar.btnGrip.GripColor = Color(155, 155, 155)
	sbar.btnGrip.Paint = function( s, w, h )
		draw_RoundedBox( 0, 0, 0, w, h, s.GripColor )
	end

	sbar.btnUp.ButtonColor = Color(110, 110, 110)
	sbar.btnUp.Paint = function( s, w, h )
		draw_RoundedBox( 0, 0, 0, w, h, s.ButtonColor )
	end

	sbar.btnDown.ButtonColor = Color(110, 110, 110)
	sbar.btnDown.Paint = function( s, w, h )
		draw_RoundedBox( 0, 0, 0, w, h, s.ButtonColor )
	end
end

function PANEL:SetBarColor(newColor)
	local sbar = self:GetVBar()
	sbar.BarColor = newColor
end

function PANEL:SetGripColor(newColor)
	local sbar = self:GetVBar()
	sbar.btnGrip.GripColor = newColor
end

function PANEL:SetButtonColor(newColor)
	local sbar = self:GetVBar()
	sbar.btnUp.ButtonColor = newColor
	sbar.btnDown.ButtonColor = newColor
end

derma_DefineControl("fmainmenu_menu_dscrollpanel", nil, PANEL, "DScrollPanel")

--[[
	WRAPPER FUNCTIONS
]]--

--Creates Derma DFrame Object
function FMainMenu.Derma.CreateDFrame(name, parent, width, height)
	local frame = vgui_Create("fmainmenu_menu_dframe", parent)

	if name ~= nil then
		frame.Title = name
		frame:SetTitle("")
	end

	if width ~= nil && height ~= nil then
		frame:SetSize(width, height)
	end

	frame:Center()
	frame:MakePopup()

	return frame
end

--Creates Derma DPanel Object
function FMainMenu.Derma.CreateDPanel(parent, width, height, SToC)
	local frame = vgui_Create("DPanel", parent)

	if SToC then
		frame:Dock( FILL )
	end

	if width ~= nil && height ~= nil then
		frame:SetSize(width, height)
	end

	return frame
end

--Creates Derma DScrollPanel Object
function FMainMenu.Derma.CreateDScrollPanel(parent, width, height, SToC)
	local frame = vgui_Create("fmainmenu_menu_dscrollpanel", parent)

	if SToC then
		frame:Dock( FILL )
	end

	if width ~= nil && height ~= nil then
		frame:SetSize(width, height)
	end

	frame:SetBarColor(FayLib.IGC.GetSharedKey(addonName, "commonScrollPanelBarColor"))
	frame:SetGripColor(FayLib.IGC.GetSharedKey(addonName, "commonScrollPanelGripColor"))
	frame:SetButtonColor(FayLib.IGC.GetSharedKey(addonName, "commonScrollPanelButtonColor"))

	return frame
end

--Creates Derma DLabel Object
function FMainMenu.Derma.CreateDLabel(parent, width, height, SToC, text)
	local frame = vgui_Create("fmainmenu_menu_dlabel", parent)

	if text ~= nil then
		frame:SetText(text)
	end

	if SToC then
		frame:Dock( FILL )
	end

	if width ~= nil && height ~= nil then
		frame:SetSize(width, height)
	end

	return frame
end

--Creates Derma DButton Object
function FMainMenu.Derma.CreateDButton(parent, width, height, text, ttip)
	local frame = vgui_Create("fmainmenu_menu_dbutton", parent)

	if width ~= nil && height ~= nil then
		frame:SetSize(width, height)
	end

	if text ~= nil then
		frame:SetText(text)
	end

	FMainMenu.Derma.SetPanelHover(frame, 1)

	return frame
end