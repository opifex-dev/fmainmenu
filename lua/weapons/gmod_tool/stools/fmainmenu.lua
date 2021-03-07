TOOL.Category = "Fay's Main Menu"
TOOL.Name = "#tool.fmainmenu.name"
TOOL.Command = nil
local addonName = "fmainmenu"

if CLIENT then

	--Opens the example menu
	local menuTog = false
	
	local function toggleMenu()
		if !menuTog then
			menuTog = true
			
			FMainMenu.Panels.SetupBasics()
			
			--Positioning for menu items
			local xPos = ScrW() * 0.05
			local normalSize = 192
			if FayLib.IGC.GetSharedKey(addonName, "logoIsText") then
				normalSize = 72
			end
			
			local curYPos = (ScrH() * 0.5) - 32
			if FayLib.IGC.GetSharedKey(addonName, "GarrysModStyle") then
				local additive = 64
				if FayLib.IGC.GetSharedKey(addonName, "logoIsText") then
					additive = 104
				end
				curYPos = additive + normalSize
			end
			
			--Modules for Menu Override
			local modules = {
				["Play"] = function(Content)
					local playButton = FMainMenu.Panels.CreateButton(Content.Text)
					playButton:SetPos(xPos, curYPos)
					curYPos = curYPos + 48
				end,
				["URL"] = function(Content)
					local urlButton = FMainMenu.Panels.CreateURLButton(Content.Text, Content.URL)
					urlButton:SetPos(xPos, curYPos)
					curYPos = curYPos + 48
				end,
				["Disconnect"] = function(Content)
					local quitButton = FMainMenu.Panels.CreateButton(Content.Text)
					quitButton:SetPos(xPos, curYPos)
					curYPos = curYPos + 48
				end,
				["Spacer"] = function(Content)
					curYPos = curYPos + 24
				end,
			}
			
			--Create Menu Buttons
			if FayLib.IGC.GetSharedKey(addonName, "MenuOverride") then
				for _,entry in ipairs(FayLib.IGC.GetSharedKey(addonName, "MenuSetup")) do
					modules[entry.Type](entry.Content)
				end
			else
				local playButton = FMainMenu.Panels.CreateButton(FMainMenu.Lang.PlayButtonText)
				playButton:SetPos(xPos, curYPos)
				curYPos = curYPos + 72
				
				for _,btn in ipairs(FayLib.IGC.GetSharedKey(addonName, "URLButtons")) do
					local urlButton = FMainMenu.Panels.CreateURLButton(btn.Text, btn.URL)
					urlButton:SetPos(xPos, curYPos)
					curYPos = curYPos + 48
				end
				
				if FayLib.IGC.GetSharedKey(addonName, "URLButtons") then
					curYPos = curYPos + 24
				end
				
				if FayLib.IGC.GetSharedKey(addonName, "dcButton") then
					local quitButton = FMainMenu.Panels.CreateButton(FMainMenu.Lang.DisconnectButtonText)
					quitButton:SetPos(xPos, curYPos)
				end
			end
			
			--Changelog
			if FayLib.IGC.GetSharedKey(addonName, "showChangeLog") then
				local finalLog = ""
				local cLExplode = string.Explode("\n", FayLib.IGC.GetSharedKey(addonName, "changeLogText"))
				for _,v in ipairs(cLExplode) do
					finalLog = finalLog..v.."\n"
				end
				FMainMenu.Panels.CreateChangeLog(finalLog)
			end
		else
			FMainMenu.Panels.Destroy()
			menuTog = false
		end
	end

	local mouseDown = false

	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
	}

	language.Add("tool.fmainmenu.name", "View Helper")
	language.Add("tool.fmainmenu.desc", "Assists in creating views for Fay's Main Menu")
	language.Add( "tool.fmainmenu.left", "Print view data to console" )
	language.Add( "tool.fmainmenu.right", "Toggle drawing example menu over view" )
	
	function TOOL:LeftClick( trace )
		if !mouseDown then
			mouseDown = true
			RunConsoleCommand("fmainmenu_getpos")
			LocalPlayer():ChatPrint("View data has been printed into the console.")
		end
	end
	
	function TOOL:RightClick( trace )
		if !mouseDown then
			mouseDown = true
			toggleMenu()
		end
	end
	
	function TOOL:Holster()
		if menuTog then
			toggleMenu()
		end
	end
	
	function TOOL:Think()
		if !input.IsMouseDown( MOUSE_LEFT ) && !input.IsMouseDown( MOUSE_RIGHT ) then
			mouseDown = false
		end
	end
end