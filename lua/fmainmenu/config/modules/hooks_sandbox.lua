--[[

	EVERY SPAWN IGC MODULE

]]--

FMainMenu.ConfigModules = FMainMenu.ConfigModules || {}

local propertyCode = 31
local configPropList = {"PlayerSpawnEffect","PlayerSpawnNPC","PlayerSpawnProp","PlayerSpawnRagdoll","PlayerSpawnSENT","PlayerSpawnSWEP","PlayerSpawnVehicle","PlayerGiveSWEP"}

FMainMenu.ConfigModules[propertyCode] = {}
FMainMenu.ConfigModules[propertyCode].previewLevel = 0
FMainMenu.ConfigModules[propertyCode].category = 3
FMainMenu.ConfigModules[propertyCode].propName = FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPropName")
FMainMenu.ConfigModules[propertyCode].liveUpdate = false

-- Creates the property editing panel
FMainMenu.ConfigModules[propertyCode].GeneratePanel = function(configSheet)
	--Property Panel Setup
	local mainPropPanel = FMainMenu.ConfigModulesHelper.generatePropertyHeader(FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPropName"), FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPropDesc"))
	
	-- PlayerSpawnEffect toggle
	mainPropPanel.playerSpawnEffectOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnEffect"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.playerSpawnEffectOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- PlayerSpawnNPC toggle
	mainPropPanel.playerSpawnNPCOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnNPC"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.playerSpawnNPCOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- PlayerSpawnProp toggle
	mainPropPanel.playerSpawnPropOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnProp"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.playerSpawnPropOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- PlayerSpawnRagdoll toggle
	mainPropPanel.playerSpawnRagdollOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnRagdoll"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.playerSpawnRagdollOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- PlayerSpawnSENT toggle
	mainPropPanel.playerSpawnSENTOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnSENT"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.playerSpawnSENTOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- PlayerSpawnSWEP toggle
	mainPropPanel.playerSpawnSWEPOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnSWEP"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.playerSpawnSWEPOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- PlayerSpawnVehicle toggle
	mainPropPanel.playerSpawnVehicleOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerSpawnVehicle"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.playerSpawnVehicleOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
	-- PlayerGiveSWEP toggle
	mainPropPanel.playerGiveSWEPOption = FMainMenu.ConfigModulePanels.createComboBox(mainPropPanel, FMainMenu.GetPhrase("ConfigPropertiesSandboxHooksPlayerGiveSWEP"), FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	mainPropPanel.playerGiveSWEPOption:AddChoice( FMainMenu.GetPhrase("ConfigCommonValueAllowed") )
	
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
	
	if parentPanel.playerSpawnEffectOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[2] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.playerSpawnNPCOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[3] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.playerSpawnPropOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[4] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.playerSpawnRagdollOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[5] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.playerSpawnSENTOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[6] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.playerSpawnSWEPOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[7] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.playerSpawnVehicleOption:GetText() != serverVar then
		return true
	end
	
	serverVar = ""
	if parentPanel.lastRecVariable[8] == false then
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueDenied")
	else
		serverVar = FMainMenu.GetPhrase("ConfigCommonValueAllowed")
	end
	
	if parentPanel.playerGiveSWEPOption:GetText() != serverVar then
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
		
	if parentPanel.playerSpawnEffectOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[1] = false
		elseif parentPanel.playerSpawnEffectOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[1] = true
		else
			return
		end
		
		if parentPanel.playerSpawnNPCOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[2] = false
		elseif parentPanel.playerSpawnNPCOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[2] = true
		else
			return
		end
		
		if parentPanel.playerSpawnPropOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[3] = false
		elseif parentPanel.playerSpawnPropOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[3] = true
		else
			return
		end
		
		if parentPanel.playerSpawnRagdollOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[4] = false
		elseif parentPanel.playerSpawnRagdollOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[4] = true
		else
			return
		end
		
		if parentPanel.playerSpawnSENTOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[5] = false
		elseif parentPanel.playerSpawnSENTOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[5] = true
		else
			return
		end
		
		if parentPanel.playerSpawnSWEPOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[6] = false
		elseif parentPanel.playerSpawnSWEPOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[6] = true
		else
			return
		end
		
		if parentPanel.playerSpawnVehicleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[7] = false
		elseif parentPanel.playerSpawnVehicleOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[7] = true
		else
			return
		end
		
		if parentPanel.playerGiveSWEPOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueDenied") then
			parentPanel.lastRecVariable[8] = false
		elseif parentPanel.playerGiveSWEPOption:GetValue() == FMainMenu.GetPhrase("ConfigCommonValueAllowed") then
			parentPanel.lastRecVariable[8] = true
		else
			return
		end
	
	FMainMenu.ConfigModulesHelper.updateVariables(parentPanel.lastRecVariable, configPropList)
end

-- Called when the current values are being overwritten by the server
FMainMenu.ConfigModules[propertyCode].varFetch = function(receivedVarTable)
	local parentPanel = FMainMenu.configPropertyWindow.currentProp
	
	if receivedVarTable[1] == true then
		parentPanel.playerSpawnEffectOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.playerSpawnEffectOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[2] == true then
		parentPanel.playerSpawnNPCOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.playerSpawnNPCOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[3] == true then
		parentPanel.playerSpawnPropOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.playerSpawnPropOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[4] == true then
		parentPanel.playerSpawnRagdollOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.playerSpawnRagdollOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[5] == true then
		parentPanel.playerSpawnSENTOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.playerSpawnSENTOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[6] == true then
		parentPanel.playerSpawnSWEPOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.playerSpawnSWEPOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[7] == true then
		parentPanel.playerSpawnVehicleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.playerSpawnVehicleOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
	
	if receivedVarTable[8] == true then
		parentPanel.playerGiveSWEPOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueAllowed"))
	else
		parentPanel.playerGiveSWEPOption:SetValue(FMainMenu.GetPhrase("ConfigCommonValueDenied"))
	end
end

-- Called when the player wishes to reset the property values to those of the server
FMainMenu.ConfigModules[propertyCode].revertFunc = function()
	return configPropList
end