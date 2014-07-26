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
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ReArms:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

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
	
	-- Apollo.RegisterEventHandler("CombatLogDamage", "OnDamageDealt", self)
	
	Apollo.RegisterTimerHandler("ReArms_BuffTimer", "OnUpdate", self)
	Apollo.CreateTimer("ReArms_BuffTimer", 0.1, true)
	
	Print("ReArms loaded")
end


function ReArms:OnUpdate()
	local unitPlayer = GameLib.GetPlayerUnit()
	local buffs = unitPlayer:GetBuffs()
	
	for idx, buff in pairs(buffs.arHarmful) do
		Print(buff.splEffect:GetName())
	end
end


-----------------------------------------------------------------------------------------------
-- ReArms OnDocLoaded
-----------------------------------------------------------------------------------------------
function ReArms:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "ReArmsForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("ra", "OnReArmsOn", self)


		-- Do additional Addon initialization here
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


-----------------------------------------------------------------------------------------------
-- ReArmsForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function ReArms:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function ReArms:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- ReArms Instance
-----------------------------------------------------------------------------------------------
local ReArmsInst = ReArms:new()
ReArmsInst:Init()
