-- localized global calls
local Color = Color
local draw_RoundedBox = draw.RoundedBox
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local vgui_Create = vgui.Create
local surface_SetTextColor = surface.SetTextColor
local surface_SetTextPos = surface.SetTextPos
local surface_DrawText = surface.DrawText
local derma_DefineControl = derma.DefineControl
local ipairs = ipairs
local surface_PlaySound = surface.PlaySound

-- custom frame with close button
local PANEL = {}
function PANEL:Init()
	local pan = self
	self:SetDraggable( true )
	self:SetSizable( false )
	self:MoveToFront()
	self:SetDeleteOnClose( true )
	self:SetScreenLock( true )
	self.panelColor = Color(75, 75, 75)
	self.innerPanelColor = Color(55, 55, 55)
	self.Paint = function(s, width, height)
		draw_RoundedBox( 5, 0, 0, width, height, self.panelColor )
		surface_SetDrawColor( self.innerPanelColor )
		surface_DrawRect( 5, 25, width-10, height-30 )
	end

	self.btnMaxim:Remove()
	self.btnMinim:Remove()
	self.btnClose:Remove()

	self.lblTitle:SetTextColor(Color(255,255,255))

	self.closeButton = vgui_Create("DButton", self)
	self.closeButton:SetText("")
	self.closeButton:SetSize(23,16)
	self.closeButton:AlignRight(5)
	self.closeButton:AlignTop(5)
	self.closeButton:SetTextColor(Color(255,255,255))
	self.closeButton:SetPaintBackgroundEnabled( false )
	self.buttonColor = Color(125, 125, 125)
	self.buttonTextColor = Color(255,255,255)
	self.closeButton.Paint = function(button, width, height)
		draw_RoundedBox( 3, 0, 0, width, height, self.buttonColor )
		surface_SetTextColor( self.buttonTextColor )
		surface_SetTextPos( 9.5, 1 )
		surface_DrawText( "X" )
	end
	self.closeButton.DoClick = function(button)
		surface_PlaySound("garrysmod/ui_click.wav")
		pan:Close()
	end
end

function PANEL:PerformLayout()
	if self.closeButton then
		self.closeButton:AlignRight(5)
		self.closeButton:AlignTop(5)
	end

	self.lblTitle:SetPos( 8, 2 )
	self.lblTitle:SetSize( self:GetWide() - 25, 20 )
end

function PANEL:SetBGColor(newCol)
	self.panelColor = newCol
	self.innerPanelColor = Color(newCol.r + 20, newCol.g + 20, newCol.b + 20, newCol.a)
end

function PANEL:SetCloseBGColor(newCol)
	self.buttonColor = newCol
end

function PANEL:SetCloseTextColor(newCol)
	self.buttonTextColor = newCol
end

derma_DefineControl("fmainmenu_config_editor", nil, PANEL, "DFrame")

-- custom frame without close button
local PANEL = {}
function PANEL:Init()
	self:ShowCloseButton( false )
	self.closeButton:Remove()
end

function PANEL:PerformLayout()
	self.lblTitle:SetPos( 8, 2 )
	self.lblTitle:SetSize( self:GetWide() - 25, 20 )
end

derma_DefineControl("fmainmenu_config_editornoclose", nil, PANEL, "fmainmenu_config_editor")

-- custom property sheet
local PANEL = {}
function PANEL:Init()
	self.panelColor = Color(55, 55, 55)
	self.Paint = function(s, width, height)
		draw_RoundedBox( 0, 0, 0, width, height, self.panelColor )
	end
end

function PANEL:PerformLayout()
	local currentTab = self:GetActiveTab()
	for _,sheet in ipairs(self.Items) do
		function sheet.Tab:Paint(w,h)
			if currentTab == sheet.Tab then
				surface_SetDrawColor(Color(75,75,75))
			else
				surface_SetDrawColor(Color(65,65,65))
			end
			surface_DrawRect(0,0,w,h)
		end

		function sheet.Tab:Think()
			sheet.Tab:SetSize(1, 1)
			sheet.Tab:SetZPos( 0 )
		end
	end
end

function PANEL:SetBGColor(newCol)
	self.panelColor = newCol
end

derma_DefineControl("fmainmenu_config_editor_sheet", nil, PANEL, "DPropertySheet")

-- custom panel
local PANEL = {}
function PANEL:Init()
	self.panelColor = Color(55, 55, 55)
	self.Paint = function(s, width, height)
		surface_SetDrawColor( self.panelColor )
		surface_DrawRect( 0, 0, width, height )
	end
end

function PANEL:SetBGColor(newCol)
	self.panelColor = newCol
end

derma_DefineControl("fmainmenu_config_editor_panel", nil, PANEL, "DPanel")

-- custom scroll panel
local PANEL = {}
function PANEL:Init()
	self.panelColor = Color(55, 55, 55)
	self.Paint = function(s, width, height)
		surface_SetDrawColor( self.panelColor )
		surface_DrawRect( 0, 0, width, height )
	end
end

function PANEL:SetBGColor(newCol)
	self.panelColor = newCol
end

derma_DefineControl("fmainmenu_config_editor_scrollpanel", nil, PANEL, "DScrollPanel")

-- custom text label
local PANEL = {}
function PANEL:Init()
	self:SetFont("Trebuchet18")
	self:SetSize( 180, 18 )
	self:SetTextColor(Color(225,225,225))
end

derma_DefineControl("fmainmenu_config_editor_label", nil, PANEL, "DLabel")

-- custom text button
local PANEL = {}
function PANEL:Init()
	self:SetText("")
	self:SetSize(52.5,25)
	self:SetTextColor(Color(225,225,225))
	self:SetFont("HudHintTextLarge")
	self:SetPaintBackgroundEnabled( false )
	self.buttonColor = Color(85, 85, 85)
	self.buttonTextColor = Color(225,225,225)
	self.Paint = function(button, width, height)
		draw_RoundedBox( 3, 0, 0, width, height, self.buttonColor )
	end
end

function PANEL:SetBGColor(newCol)
	self.buttonColor = newCol
end

derma_DefineControl("fmainmenu_config_editor_button", nil, PANEL, "DButton")

-- custom image button
local PANEL = {}
function PANEL:Init()
	self:SetSize(52.5,25)
	self:SetPaintBackgroundEnabled( false )
end

derma_DefineControl("fmainmenu_config_editor_image_button", nil, PANEL, "DImageButton")

-- custom text box
local PANEL = {}
function PANEL:Init()
	self:SetText("")
	self:SetTextColor( Color(0,0,0) )
	self:SetTextColor(Color(0,0,0))
	self:SetFont("Trebuchet18")
	self:SetCursorColor(Color(0,0,0))
end

derma_DefineControl("fmainmenu_config_editor_textentry", nil, PANEL, "DTextEntry")

-- custom combo box
local PANEL = {}
function PANEL:Init()
	self:SetSortItems( false )
end

derma_DefineControl("fmainmenu_config_editor_combobox", nil, PANEL, "DComboBox")