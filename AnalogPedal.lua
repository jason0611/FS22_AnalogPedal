--
-- AnalogPedal for LS 22
--
-- Martin Eller

-- Version 0.0.5.1
-- 
--

source(g_currentModDirectory.."tools/gmsDebug.lua")
GMSDebug:init(g_currentModName, true)
GMSDebug:enableConsoleCommands("apdDebug")


AnalogPedal = {}
AnalogPedal.MOD_NAME = g_currentModName

AnalogPedal.isDedi = g_dedicatedServerInfo ~= nil

AnalogPedal.incRate = 0.02
AnalogPedal.decRate = 0.01
AnalogPedal.minRate = 0.01

AnalogPedal.guiIcon = createImageOverlay(g_currentModDirectory.."throttle.dds")

-- Console

addConsoleCommand("apdInc", "Set increasement rate: apdInc #", "setInc", AnalogPedal)
function AnalogPedal:setInc(apdRate)
	local vehicle = g_currentMission.controlledVehicle
	
	if apdRate == nil then
		return "Set increasement rate: apdInc #"
	end

	local rate = tonumber(apdRate)
	if rate ~= nil then 
		AnalogPedal.incRate = rate
		return "Increasement rate set to "..tostring(AnalogPedal.incRate)
	end
end

addConsoleCommand("apdDec", "Set decreasement rate: apdDec #", "setDec", AnalogPedal)
function AnalogPedal:setDec(apdRate)
	local vehicle = g_currentMission.controlledVehicle
	
	if apdRate == nil then
		return "Set decreasement rate: apdDec #"
	end
	
	local rate = tonumber(apdRate)
	if rate ~= nil then 
		AnalogPedal.decRate = rate
		return "Decreasement rate set to "..tostring(AnalogPedal.decRate)
	end
end

-- Standards / Basics

function AnalogPedal.prerequisitesPresent(specializations)
  return true
end

function AnalogPedal.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", AnalogPedal)
	SpecializationUtil.registerEventListener(vehicleType, "onDraw", AnalogPedal)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", AnalogPedal)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", AnalogPedal)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", AnalogPedal)
end

function AnalogPedal:onLoad(savegame)
	local spec = self.spec_AnalogPedal
	spec.pedalRate = 0
	spec.isActive = true
	spec.analog = false
	spec.overrideAnalog = false
end

function AnalogPedal:onPostLoad(savegame)
	local spec = self.spec_AnalogPedal
	if spec == nil then return end	
	Drivable.actionEventAccelerate = Utils.overwrittenFunction(Drivable.actionEventAccelerate, AnalogPedal.actionEventAccelerate)
	Drivable.actionEventBrake = Utils.overwrittenFunction(Drivable.actionEventBrake, AnalogPedal.actionEventBrake)
	
	-- Check if Mod VCA exists
	spec.ModVCAFound = self.vcaSetState ~= nil
end


	
function AnalogPedal:onRegisterActionEvents(isActiveForInput)
	AnalogPedal.actionEvents = {} 
	if self.isClient then
		AnalogPedal.actionEvents = {} 
		if self:getIsActiveForInput(true) then 
			local actionEventId;
			_, actionEventId = self:addActionEvent(AnalogPedal.actionEvents, 'APD_TOGGLESTATE', self, AnalogPedal.TOGGLESTATE, false, true, false, true, nil)
			_, actionEventId = self:addActionEvent(AnalogPedal.actionEvents, 'APD_TOGGLEOVERRIDE', self, AnalogPedal.TOGGLEOVERRIDE, false, true, false, true, nil)
		end		
	end
end

function AnalogPedal:TOGGLESTATE(actionName, keyStatus, arg3, arg4, arg5)
	local spec = self.spec_AnalogPedal
	spec.isActive = not spec.isActive
end

function AnalogPedal:TOGGLEOVERRIDE(actionName, keyStatus, arg3, arg4, arg5)
	local spec = self.spec_AnalogPedal
	spec.overrideAnalog = not spec.overrideAnalog
end
-- Main part

function AnalogPedal:onDraw(dt)
	local spec = self.spec_AnalogPedal
	local throttle = g_i18n.modEnvironments[AnalogPedal.MOD_NAME]:getText("text_APD_throttle")
	
	if spec.isActive then
		if self.vcaGetState ~= nil and self:vcaGetState("ksToggle") then
			g_currentMission:addExtraPrintText(throttle.."VCA")
			return
		end
		if self:getCruiseControlState() == 1 then
			g_currentMission:addExtraPrintText(throttle.."SpeedControl")
			return
		end

		local analog = ""
		if spec.analog then 
			analog = " (analog)" 
		end
		local rate = string.format("%.00f",tostring(spec.pedalRate * 100)).."%"..analog
		if spec.pedalRate == AnalogPedal.minRate and not spec.analog then
			rate = g_i18n.modEnvironments[AnalogPedal.MOD_NAME]:getText("text_APD_coasting")
		end
		g_currentMission:addExtraPrintText(throttle..rate)
		local scale = g_gameSettings.uiScale
		local x = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX + g_currentMission.inGameMenu.hud.speedMeter.fuelGaugeRadiusX * 0.30
		local y = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
		local w = 0.015 * scale
		local h = 0.015 * scale * g_screenAspectRatio * spec.pedalRate
		renderOverlay(AnalogPedal.guiIcon, x, y, w, h)
	else
		g_currentMission:addExtraPrintText(throttle..g_i18n.modEnvironments[AnalogPedal.MOD_NAME]:getText("text_APD_off"))
	end
end

function AnalogPedal:onUpdate(dt)
	local spec = self.spec_AnalogPedal
	if spec.analog or spec.pedalRate == 0 or self:getCruiseControlState() == 1 then 
		return 
	end
	spec.pedalRate = spec.pedalRate - AnalogPedal.decRate
	if spec.pedalRate <= AnalogPedal.minRate then 
		spec.pedalRate = AnalogPedal.minRate
	end
	if spec.pedalRate > 0 and spec.isActive then 
		Drivable.actionEventAccelerate(self, "AXIS_ACCELERATE_VEHICLE", spec.pedalRate, nil, spec.analog)
	end
end

function AnalogPedal:actionEventAccelerate(superfunc, actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_AnalogPedal
	local returnValue = inputValue
	if spec ~= nil and spec.isActive then 
		isAnalog = isAnalog and not spec.overrideAnalog
		spec.analog = isAnalog
		if not isAnalog and (self.vcaGetState ~= nil and not self:vcaGetState("ksToggle")) and self:getCruiseControlState() ~= 1 then
			if inputValue == 1 then
				spec.pedalRate = spec.pedalRate + AnalogPedal.incRate + AnalogPedal.decRate -- compensate decreasement by onUpdate while accelerating
				if spec.pedalRate > 1 then spec.pedalRate = 1; end
			end
			--return superfunc(self, actionName, spec.pedalRate, callbackState, isAnalog)
		else
			if not isAnalog or inputValue ~= 0 then
				spec.pedalRate = inputValue
			end
		end
		returnValue = spec.pedalRate
	end
	return superfunc(self, actionName, returnValue, callbackState, isAnalog)
end

function AnalogPedal:actionEventBrake(superfunc, actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_AnalogPedal
	if spec ~= nil and inputValue >= 0.1 then 
		spec.pedalRate = 0
	end
	return superfunc(self, actionName, inputValue, callbackState, isAnalog)
end
