local PANEL = {}
function PANEL:Init()
	local pan = self
	self:SetDraggable( true )
	self:SetSizable( false )
	self:MoveToFront()
	self:SetDeleteOnClose( true )
	self:SetScreenLock( true )
	self.panelColor = Color(100,100,100)
	self.innerPanelColor = Color(120,120,120)
	self.Paint = function(s, width, height)
		draw.RoundedBox( 5, 0, 0, width, height, self.panelColor )
		surface.SetDrawColor( self.innerPanelColor )
		surface.DrawRect( 5, 25, width-10, height-30 )
	end
	
	self.btnMaxim:Remove()
	self.btnMinim:Remove()
	self.btnClose:Remove()
	
	self.lblTitle:SetTextColor(Color(255,255,255))
	
	self.closeButton = vgui.Create("DButton", self)
	self.closeButton:SetText("")
	self.closeButton:SetSize(23,16)
	self.closeButton:AlignRight(5)
	self.closeButton:AlignTop(5)
	self.closeButton:SetTextColor(Color(255,255,255))
	self.closeButton:SetPaintBackgroundEnabled( false )
	self.buttonColor = Color(135, 135, 135)
	self.buttonTextColor = Color(255,255,255)
	self.closeButton.Paint = function(button, width, height)
		draw.RoundedBox( 3, 0, 0, width, height, self.buttonColor )
		surface.SetTextColor( self.buttonTextColor )
		surface.SetTextPos( 9.5, 1 )
		surface.DrawText( "X" )
	end
	self.closeButton.DoClick = function(button)
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
	self.innerPanelColor = Color(newCol.r+20, newCol.g+20, newCol.b+20, newCol.a)
end

function PANEL:SetCloseBGColor(newCol)
	self.buttonColor = newCol
end

function PANEL:SetCloseTextColor(newCol)
	self.buttonTextColor = newCol
end

derma.DefineControl("fmainmenu_config_editor", nil, PANEL, "DFrame")

local PANEL = {}
function PANEL:Init()
	self:ShowCloseButton( false )
	self.closeButton:Remove()
end

function PANEL:PerformLayout()
	self.lblTitle:SetPos( 8, 2 )
	self.lblTitle:SetSize( self:GetWide() - 25, 20 )
end

derma.DefineControl("fmainmenu_config_editornoclose", nil, PANEL, "fmainmenu_config_editor")

local PANEL = {}
function PANEL:Init()
	local pan = self
	self.panelColor = Color(125,125,125)
	self.Paint = function(s, width, height)
		draw.RoundedBox( 5, 0, 0, width, height, self.panelColor )
	end
end

function PANEL:SetBGColor(newCol)
	self.panelColor = newCol
end

derma.DefineControl("fmainmenu_config_editor_sheet", nil, PANEL, "DPropertySheet")

local PANEL = {}
function PANEL:Init()
	local pan = self
	self.panelColor = Color(125,125,125)
	self.Paint = function(s, width, height)
		surface.SetDrawColor( self.panelColor )
		surface.DrawRect( 0, 0, width, height )
	end
end

function PANEL:SetBGColor(newCol)
	self.panelColor = newCol
end

derma.DefineControl("fmainmenu_config_editor_panel", nil, PANEL, "DPanel")

local PANEL = {}
function PANEL:Init()
	local pan = self
	self.panelColor = Color(125,125,125)
	self.Paint = function(s, width, height)
		surface.SetDrawColor( self.panelColor )
		surface.DrawRect( 0, 0, width, height )
	end
end

function PANEL:SetBGColor(newCol)
	self.panelColor = newCol
end

derma.DefineControl("fmainmenu_config_editor_scrollpanel", nil, PANEL, "DScrollPanel")

local PANEL = {}
function PANEL:Init()
	self:SetFont("Trebuchet18")
	self:SetSize( 180, 18 )
	self:SetTextColor(Color(255,255,255))
end

derma.DefineControl("fmainmenu_config_editor_label", nil, PANEL, "DLabel")

local PANEL = {}
function PANEL:Init()
	self:SetText("")
	self:SetSize(52.5,25)
	self:SetTextColor(Color(255,255,255))
	self:SetFont("HudHintTextLarge")
	self:SetPaintBackgroundEnabled( false )
	self.buttonColor = Color(105, 105, 105)
	self.buttonTextColor = Color(255,255,255)
	self.Paint = function(button, width, height)
		draw.RoundedBox( 3, 0, 0, width, height, self.buttonColor )
	end
end

derma.DefineControl("fmainmenu_config_editor_button", nil, PANEL, "DButton")

local PANEL = {}
function PANEL:Init()
	self:SetSize(52.5,25)
	self:SetPaintBackgroundEnabled( false )
end

derma.DefineControl("fmainmenu_config_editor_image_button", nil, PANEL, "DImageButton")

local PANEL = {}
function PANEL:Init()
	self:SetText("")
	self:SetTextColor( Color(0,0,0) )
	self:SetTextColor(Color(0,0,0))
	self:SetFont("Trebuchet18")
	self:SetCursorColor(Color(0,0,0))
end

derma.DefineControl("fmainmenu_config_editor_textentry", nil, PANEL, "DTextEntry")

local PANEL = {}
function PANEL:Init()
	self:SetSortItems( false )
end

derma.DefineControl("fmainmenu_config_editor_combobox", nil, PANEL, "DComboBox")