--[[

	DARKRP HOOKS IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 32
local configPropList = {"DarkRPCanBuy","DarkRPCanChatSound","DarkRPCanUse","DarkRPCanUsePocket","DarkRPCanDropWeapon","DarkRPCanReqHits","DarkRPCanReqWarrants"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 3
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksPropName"), FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksPropDesc"))
	
	-- DarkRPCanBuy toggle
	mainPropPanel.canBuyOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanBuy"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.canBuyOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- DarkRPCanChatSound toggle
	mainPropPanel.canChatSoundOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanChatSound"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.canChatSoundOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- DarkRPCanUse toggle
	mainPropPanel.canUseOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanUse"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.canUseOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- DarkRPCanUsePocket toggle
	mainPropPanel.canUsePocketOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanUsePocket"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.canUsePocketOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- DarkRPCanDropWeapon toggle
	mainPropPanel.canDropWeaponOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanDropWeapon"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.canDropWeaponOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- DarkRPCanReqHits toggle
	mainPropPanel.canReqHitsOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanReqHits"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.canReqHitsOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- DarkRPCanReqWarrants toggle
	mainPropPanel.canReqWarrantsOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesDarkRPHooksCanReqWarrants"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.canReqWarrantsOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	return {configPropList, mainPropPanel}
end

-- Determines whether the local property settings differ from the servers, meaning the user has changed it
FMainMenu.ConfigModules[propertyCode].isVarChanged = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	local serverVar = ""
	if parentPanel.lastRecVariable[1] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.canBuyOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[2] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.canChatSoundOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[3] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.canUseOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[4] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.canUsePocketOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[5] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.canDropWeaponOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[6] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.canReqHitsOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[7] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.canReqWarrantsOption:GetText() != serverVar then
		return true
	end
	
	return false
end

-- Updates necessary live preview options
FMainMenu.ConfigModules[propertyCode].updatePreview = function() end

-- Called when property is closed, allows for additional clean up if needed
FMainMenu.ConfigModules[propertyCode].onClosePropFunc = function() end

-- Handles saving changes to a property
FMainMenu.ConfigModules[propertyCode].saveFunc = function()
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
		
	if parentPanel.canBuyOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[1] = false
		elseif parentPanel.canBuyOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[1] = true
		else
			return
		end
		
		if parentPanel.canChatSoundOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[2] = false
		elseif parentPanel.canChatSoundOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[2] = true
		else
			return
		end
		
		if parentPanel.canUseOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[3] = false
		elseif parentPanel.canUseOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[3] = true
		else
			return
		end
		
		if parentPanel.canUsePocketOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[4] = false
		elseif parentPanel.canUsePocketOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[4] = true
		else
			return
		end
		
		if parentPanel.canDropWeaponOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[5] = false
		elseif parentPanel.canDropWeaponOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[5] = true
		else
			return
		end
		
		if parentPanel.canReqHitsOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[6] = false
		elseif parentPanel.canReqHitsOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[6] = true
		else
			return
		end
		
		if parentPanel.canReqWarrantsOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[7] = false
		elseif parentPanel.canReqWarrantsOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[7] = true
		else
			return
		end
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	if receivedVarTable[1] == true then
		parentPanel.canBuyOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.canBuyOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[2] == true then
		parentPanel.canChatSoundOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.canChatSoundOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[3] == true then
		parentPanel.canUseOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.canUseOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[4] == true then
		parentPanel.canUsePocketOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.canUsePocketOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[5] == true then
		parentPanel.canDropWeaponOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.canDropWeaponOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[6] == true then
		parentPanel.canReqHitsOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.canReqHitsOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[7] == true then
		parentPanel.canReqWarrantsOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.canReqWarrantsOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end