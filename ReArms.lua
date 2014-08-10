-----------------------------------------------------------------------------------------------
-- Client Lua Script for ReArms
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- ReArms Module Definition
-----------------------------------------------------------------------------------------------
local ReArms = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local LocWpnName = {
	enUS = "(%S+)'s Weapon",
	deDE = "Waffe von (%S+)",
	frFR = "Arme de (%S+)",
}

local function GetLocaleWpnName()
	local s = Apollo.GetString(1)
	
	if s == "Annuler" then
		return LocWpnName.frFR
	elseif s == "Abbrechen" then
		return LocWpnName.deDE
	end
	return LocWpnName.enUS
end

---------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ReArms:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
	self.unitArm = nil
	
	self.WpnName = GetLocaleWpnName()
	
    return o
end



function ReArms:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ReArms OnLoad
-----------------------------------------------------------------------------------------------
function ReArms:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("ReArms.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
			
	Apollo.CreateTimer("ReArms_BuffTimer", 0.1, true)	
	
end

-----------------------------------------------------------------------------------------------
-- ReArms OnDocLoaded
-----------------------------------------------------------------------------------------------
function ReArms:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "ReArmIcon", "InWorldHudStratum", self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)
		Apollo.RegisterEventHandler("UnitEnteredCombat", "onCombatEvent", self);
			
	end
end

-----------------------------------------------------------------------------------------------
-- ReArms Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/ra"
function ReArms:OnReArmsOn()
	self.wndMain:Invoke() -- show the window
end

function ReArms:onCombatEvent(unit, fighting)
	if unit ~= GameLib:GetPlayerUnit() then return end
	if fighting then
		Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
		Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
	elseif not fighting then
		Apollo.RemoveEventHandler("UnitCreated", self)
		Apollo.RemoveEventHandler("UnitDestroyed", self)
	end
end

function ReArms:OnUnitCreated(unit)
	if unit:GetType() == "Pickup" then
		local playerName = GameLib:GetPlayerUnit():GetName();
		if string.match(unit:GetName(), self.WpnName) == playerName then
			if self.wndMain ~= nil then
				self.wndMain:Show(true, true)
				self.wndMain:SetUnit(unit)
				self.unitArm = unit
			else
				Apollo.AddAddonErrorText(self, "Problem with the window init")
			end
		end
	end
end

function  ReArms:OnUnitDestroyed(unit)
	if unit == self.unitArm then 
		self.wndMain:Show(false, true)
	end
end

-----------------------------------------------------------------------------------------------
-- ReArms Instance
-----------------------------------------------------------------------------------------------
local ReArmsInst = ReArms:new()
ReArmsInst:Init()
