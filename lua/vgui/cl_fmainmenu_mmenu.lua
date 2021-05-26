FMainMenu.Derma = FMainMenu.Derma || {}
FMainMenu.Config = FMainMenu.Config || {}

--[[
  _____                               _____ _    _          _____      _   _   _                 
 |  __ \                             / ____| |  (_)        / ____|    | | | | (_)                
 | |  | | ___ _ __ _ __ ___   __ _  | (___ | | ___ _ __   | (___   ___| |_| |_ _ _ __   __ _ ___ 
 | |  | |/ _ \ '__| '_ ` _ \ / _` |  \___ \| |/ / | '_ \   \___ \ / _ \ __| __| | '_ \ / _` / __|
 | |__| |  __/ |  | | | | | | (_| |  ____) |   <| | | | |  ____) |  __/ |_| |_| | | | | (_| \__ \
 |_____/ \___|_|  |_| |_| |_|\__,_| |_____/|_|\_\_|_| |_| |_____/ \___|\__|\__|_|_| |_|\__, |___/
                                                                                        __/ |    
                                                                                       |___/     
]]--

--Base Frame Color
FMainMenu.Config.DFrameBaseColor = Color(75, 75, 75)

--Base Panel Color
FMainMenu.Config.DPanelBaseColor = Color(75, 75, 75)

--Scroll Panel Bar Color
FMainMenu.Config.DScrollPanelBarColor = Color(75, 75, 75)

--Scroll Panel Grip Color
FMainMenu.Config.DScrollPanelGripColor = Color(155, 155, 155)

--Scroll Panel Button Color
FMainMenu.Config.DScrollPanelButtonColor = Color(110, 110, 110)

--Pixel Radius of DFrame Corner Bevel
FMainMenu.Config.DFrameRadius = 5

--Color of the button hover overlay
FMainMenu.Config.hoverOverlayColor = Color(0,0,0, 70)

--[[

END CONFIG (DO NOT TOUCH BELOW)

]]--

local blurMat = Material("pp/blurscreen")
local colorWhite = Color(255, 255, 255)
local addonName = "fmainmenu"

--Adds custom paint function for custom backgrounds and rounding edges
function FMainMenu.Derma:SetFrameSettings(frame, color, radius, isFrame)
	if isFrame then
		if(radius > 0) then
			function frame:Paint(width, height)
				draw.RoundedBox(radius, 0, 0, width, height, color)
				draw.SimpleText(frame.Title, "Trebuchet18", 8, 12, FayLib.IGC.GetSharedKey(addonName, "commonTextColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		else
			function frame:Paint(width, height)
				surface.SetDrawColor(color)
				surface.DrawRect(0, 0, width, height)
				draw.SimpleText(frame.Title, "Trebuchet18", 8, 12, FayLib.IGC.GetSharedKey(addonName, "commonTextColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	else
		if(radius > 0) then
			function frame:Paint(width, height)
				draw.RoundedBox(radius, 0, 0, width, height, color)
			end
		else
			function frame:Paint(width, height)
				surface.SetDrawColor(color)
				surface.DrawRect(0, 0, width, height)
			end
		end
	end
end

--Version of above designed to have both blur and tint simultaniously
function FMainMenu.Derma:SetFrameCombo(frame, color, blur)
	function frame:Paint(width, height)
		local scrW, scrH = ScrW(), ScrH()
	
		surface.SetDrawColor(colorWhite)
		surface.SetMaterial(blurMat)
		
		for i = 1, 3 do
			blurMat:SetFloat("$blur", (i / 3) * (blur or 8))
			blurMat:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(0, 0, scrW, scrH)
		end
		
		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, width, height)
	end
end

--Adds blur to a panel
function FMainMenu.Derma:SetFrameBlur(frame, amount)
	function frame:Paint(width, height)
		local x, y = 0, 0
		local scrW, scrH = ScrW(), ScrH()
	
		surface.SetDrawColor(colorWhite)
		surface.SetMaterial(blurMat)
		
		for i = 1, 3 do
			blurMat:SetFloat("$blur", (i / 3) * (amount or 8))
			blurMat:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
		end
	end
end

--Adds a hover effect to a button
function FMainMenu.Derma.SetPanelHover(frame, hoverType, arg)
	if hoverType == 1 then
		function frame:PaintOver(width, height)
			if frame:IsHovered() then
				surface.SetDrawColor(FMainMenu.Config.hoverOverlayColor)
				surface.DrawRect(0, 0, width, height)
			end
		end
	elseif hoverType == 2 then
		frame.POHover = false
		 function frame:Paint(wid, height)
			if frame:IsHovered() then
				if frame.POHover == false then
					frame.POHover = true
					surface.PlaySound(FayLib.IGC.GetSharedKey(addonName, "textButtonHoverSound"))
				end
				frame:SetTextColor(FayLib.IGC.GetSharedKey(addonName, "textButtonHoverColor"))
			else
				if frame.POHover then
					frame.POHover = false
				end
				frame:SetTextColor(FayLib.IGC.GetSharedKey(addonName, "textButtonColor"))
			end
			frame:UpdateFGColor()
			draw.SimpleTextOutlined( arg, "FMM_ButtonFont", 0, 0, FayLib.IGC.GetSharedKey(addonName, "textButtonColor"), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, FayLib.IGC.GetSharedKey(addonName, "textButtonOutlineThickness"), FayLib.IGC.GetSharedKey(addonName, "textButtonOutlineColor") )
		end
	end
end

--Creates Derma DFrame Object
function FMainMenu.Derma.CreateDFrame(name, parent, width, height)
	local frame = vgui.Create("DFrame", parent)
	FMainMenu.Derma:SetFrameSettings(frame, FMainMenu.Config.DFrameBaseColor, FMainMenu.Config.DFrameRadius, true)
	if(name ~= nil) then
		frame.Title = name
		frame:SetTitle("")
	end
	if(width ~= nil && height ~= nil) then
		frame:SetSize(width, height)
	end
	frame:Center()
	frame:MakePopup()
	return frame
end

--Creates Derma DPanel Object
function FMainMenu.Derma.CreateDPanel(parent, width, height, SToC)
	local frame = vgui.Create("DPanel", parent)
	FMainMenu.Derma:SetFrameSettings(frame, FMainMenu.Config.DPanelBaseColor, 0)
	if(SToC) then
		frame:Dock( FILL )
	end
	if(width ~= nil && height ~= nil) then
		frame:SetSize(width, height)
	end
	return frame
end

--Creates Derma DScrollPanel Object
function FMainMenu.Derma.CreateDScrollPanel(parent, width, height, SToC)
	local frame = vgui.Create("DScrollPanel", parent)
	FMainMenu.Derma:SetFrameSettings(frame, FMainMenu.Config.DPanelBaseColor, 0)
	if(SToC) then
		frame:Dock( FILL )
	end
	if(width ~= nil && height ~= nil) then
		frame:SetSize(width, height)
	end
	local sbar = frame:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, FMainMenu.Config.DScrollPanelBarColor )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, FMainMenu.Config.DScrollPanelGripColor )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, FMainMenu.Config.DScrollPanelButtonColor )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, FMainMenu.Config.DScrollPanelButtonColor )
	end
	return frame
end

--Creates Derma DLabel Object
function FMainMenu.Derma.CreateDLabel(parent, width, height, SToC, text)
	local frame = vgui.Create("DLabel", parent)
	if(text ~= nil) then
		frame:SetText(text)
	end
	if(SToC) then
		frame:Dock( FILL )
	end
	if(width ~= nil && height ~= nil) then
		frame:SetSize(width, height)
	end
	return frame
end

--Creates Derma DButton Object
function FMainMenu.Derma.CreateDButton(parent, width, height, text, ttip)
	local frame = vgui.Create("DButton", parent)
	if(width ~= nil && height ~= nil) then
		frame:SetSize(width, height)
	end
	if text ~= nil then
		frame:SetText(text)
	end
	return frame
end