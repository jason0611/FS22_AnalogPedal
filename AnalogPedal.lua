--
-- AnalogPedal for LS 19
--
-- Martin Eller

-- Version 0.0.1.0
-- 
--

source(g_currentModDirectory.."tools/gmsDebug.lua")
GMSDebug:init(g_currentModName, true)
GMSDebug:enableConsoleCommands("apdDebug")


AnalogPedal = {}
AnalogPedal.MOD_NAME = g_currentModName

AnalogPedal.isDedi = g_dedicatedServerInfo ~= nil

AnalogPedal.incRate = 0.05
AnalogPedal.decRate = 0.025

AnalogPedal.guiIcon = createImageOverlay(g_currentModDirectory.."throttle.dds")

-- Console

addConsoleCommand("apdInc", "Set increasement rate: apdInc #", "setInc", AnalogPedal)
function AnalogPedal:setInc(apdRate)
	local vehicle = g_currentMission.controlledVehicle
	
	if apdRate == nil then
		return "Set increasement rate: apdInc #"
	end
	
	local spec = vehicle.spec_AnalogPedal
	if spec == nil then	
		return "No APD installed"
	end
	
	local rate = tonumber(apdRate)
	if rate ~= nil then 
		AnalogPedal.incRate = rate
		return "Increasement rate set to "..tostring(spec.incRate)
	end
end

addConsoleCommand("apdDec", "Set decreasement rate: apdDec #", "setDec", AnalogPedal)
function AnalogPedal:setDec(apdRate)
	local vehicle = g_currentMission.controlledVehicle
	
	if apdRate == nil then
		return "Set decreasement rate: apdDec #"
	end
	
	local spec = vehicle.spec_AnalogPedal
	if spec == nil then	
		return "No APD installed"
	end
	
	local rate = tonumber(apdRate)
	if rate ~= nil then 
		AnalogPedal.decRate = rate
		return "Decreasement rate set to "..tostring(spec.decRate)
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
--	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", AnalogPedal)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", AnalogPedal)
-- 	SpecializationUtil.registerEventListener(vehicleType, "onReadStream", AnalogPedal)
--	SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", AnalogPedal)
--	SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", AnalogPedal)
--	SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", AnalogPedal)
end

function AnalogPedal:onLoad(savegame)
	local spec = self.spec_AnalogPedal
	
	-- spec.dirtyFlag = self:getNextDirtyFlag()
	
	spec.pedalRate = 0
	spec.isActive = true
end

function AnalogPedal:onPostLoad(savegame)
	local spec = self.spec_AnalogPedal
	if spec == nil then return end	
	Drivable.actionEventAccelerate = Utils.overwrittenFunction(Drivable.actionEventAccelerate, AnalogPedal.actionEventAccelerate)
	Drivable.actionEventBrake = Utils.overwrittenFunction(Drivable.actionEventBrake, AnalogPedal.actionEventBrake)
end

--[[
function AnalogPedal:saveToXMLFile(xmlFile, key)
	local spec = self.spec_AnalogPedal
	setXMLBool(xmlFile, key.."#beep", spec.Beep)
	setXMLFloat(xmlFile, key.."#turnSpeed", spec.TurnSpeed)
	setXMLBool(xmlFile, key.."#isActive", spec.IsActive)
	setXMLBool(xmlFile, key.."#useSpeedControl", spec.UseSpeedControl)
	setXMLBool(xmlFile, key.."#useModSpeedControl", spec.UseModSpeedControl)
	setXMLBool(xmlFile, key.."#useRaiseImplement", spec.UseRaiseImplement)
	setXMLBool(xmlFile, key.."#useStopPTO", spec.UseStopPTO)
	setXMLBool(xmlFile, key.."#turnPlow", spec.UseTurnPlow)
	setXMLBool(xmlFile, key.."#centerPlow", spec.UseCenterPlow)
	setXMLBool(xmlFile, key.."#switchRidge", spec.UseRidgeMarker)
	setXMLBool(xmlFile, key.."#useGPS", spec.UseGPS)
	setXMLBool(xmlFile, key.."#useGuidanceSteering", spec.UseGuidanceSteering)
	setXMLBool(xmlFile, key.."#useVCA", spec.UseVCA)
	setXMLBool(xmlFile, key.."#useDiffLock", spec.UseDiffLock)
end

function AnalogPedal:onReadStream(streamId, connection)
	local spec = self.spec_AnalogPedal
	spec.Beep = streamReadBool(streamId)
	spec.TurnSpeed = streamReadFloat32(streamId)
	spec.IsActive = streamReadBool(streamId)
	spec.UseSpeedControl = streamReadBool(streamId)
	spec.UseModSpeedControl = streamReadBool(streamId)
	spec.UseRaiseImplement = streamReadBool(streamId)
	spec.UseStopPTO = streamReadBool(streamId)
	spec.UseTurnPlow = streamReadBool(streamId)
	spec.UseCenterPlow = streamReadBool(streamId)
  	spec.UseRidgeMarker = streamReadBool(streamId)
  	spec.UseGPS = streamReadBool(streamId)
  	spec.UseGuidanceSteering = streamReadBool(streamId)
  	spec.UseVCA = streamReadBool(streamId)
  	spec.UseDiffLock = streamReadBool(streamId)
end

function AnalogPedal:onWriteStream(streamId, connection)
	local spec = self.spec_AnalogPedal
	streamWriteBool(streamId, spec.Beep)
	streamWriteFloat32(streamId, spec.TurnSpeed)
	streamWriteBool(streamId, spec.IsActive)
	streamWriteBool(streamId, spec.UseSpeedControl)
	streamWriteBool(streamId, spec.UseModSpeedControl)
	streamWriteBool(streamId, spec.UseRaiseImplement)
	streamWriteBool(streamId, spec.UseStopPTO)
	streamWriteBool(streamId, spec.UseTurnPlow)
	streamWriteBool(streamId, spec.UseCenterPlow)
  	streamWriteBool(streamId, spec.UseRidgeMarker)
  	streamWriteBool(streamId, spec.UseGPS)
  	streamWriteBool(streamId, spec.UseGuidanceSteering)
  	streamWriteBool(streamId, spec.UseVCA)
  	streamWriteBool(streamId, spec.UseDiffLock)
end
	
function AnalogPedal:onReadUpdateStream(streamId, timestamp, connection)
	if not connection:getIsServer() then
		local spec = self.spec_AnalogPedal
		if streamReadBool(streamId) then
			spec.Beep = streamReadBool(streamId)
			spec.TurnSpeed = streamReadFloat32(streamId)
			spec.IsActive = streamReadBool(streamId)
			spec.UseSpeedControl = streamReadBool(streamId)
			spec.UseModSpeedControl = streamReadBool(streamId)
			spec.UseRaiseImplement = streamReadBool(streamId)
			spec.UseStopPTO = streamReadBool(streamId)
			spec.UseTurnPlow = streamReadBool(streamId)
			spec.UseCenterPlow = streamReadBool(streamId)
			spec.UseRidgeMarker = streamReadBool(streamId)
			spec.UseGPS = streamReadBool(streamId)
			spec.UseGuidanceSteering = streamReadBool(streamId)
			spec.UseVCA = streamReadBool(streamId)
			spec.UseDiffLock = streamReadBool(streamId)
		end;
	end
end

function AnalogPedal:onWriteUpdateStream(streamId, connection, dirtyMask)
	if connection:getIsServer() then
		local spec = self.spec_AnalogPedal
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dirtyFlag) ~= 0) then
			streamWriteBool(streamId, spec.Beep)
			streamWriteFloat32(streamId, spec.TurnSpeed)
			streamWriteBool(streamId, spec.IsActive)
			streamWriteBool(streamId, spec.UseSpeedControl)
			streamWriteBool(streamId, spec.UseModSpeedControl)
			streamWriteBool(streamId, spec.UseRaiseImplement)
			streamWriteBool(streamId, spec.UseStopPTO)
			streamWriteBool(streamId, spec.UseTurnPlow)
			streamWriteBool(streamId, spec.UseCenterPlow)
			streamWriteBool(streamId, spec.UseRidgeMarker)
			streamWriteBool(streamId, spec.UseGPS)
			streamWriteBool(streamId, spec.UseGuidanceSteering)
			streamWriteBool(streamId, spec.UseVCA)
			streamWriteBool(streamId, spec.UseDiffLock)
		end
	end
end
]]

-- inputBindings / inputActions
	
function AnalogPedal:onRegisterActionEvents(isActiveForInput)
	AnalogPedal.actionEvents = {} 
	if self.isClient then
		headlandManagement.actionEvents = {} 
		if self:getIsActiveForInput(true) then 
			local actionEventId;
			_, actionEventId = self:addActionEvent(AnalogPedal.actionEvents, 'APD_TOGGLESTATE', self, AnalogPedal.TOGGLESTATE, false, true, false, true, nil)
		end		
	end
end

function AnalogPedal:TOGGLESTATE(actionName, keyStatus, arg3, arg4, arg5)
	local spec = self.spec_AnalogPedal
	spec.isActive = not spec.isActive
	--self:raiseDirtyFlags(spec.dirtyFlag)
end

-- Main part

function AnalogPedal:onDraw(dt)
	local spec = self.spec_AnalogPedal
	if spec.isActive then
		g_currentMission:addExtraPrintText("Throttle: "..string.format("%.00f",tostring(spec.pedalRate * 100)).."%")
		
		local scale = g_gameSettings.uiScale
		local x = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - g_currentMission.inGameMenu.hud.speedMeter.fuelGaugeRadiusX * 0.70
		local y = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
		local w = 0.015 * scale
		local h = 0.015 * scale * g_screenAspectRatio * spec.pedalRate
		renderOverlay(AnalogPedal.guiIcon, x, y, w, h)
	else
		g_currentMission:addExtraPrintText("Throttle: off")
	end
end

function AnalogPedal:onUpdate(dt)
	local spec = self.spec_AnalogPedal
	spec.pedalRate = spec.pedalRate - AnalogPedal.decRate
	if spec.pedalRate < 0 then spec.pedalRate = 0; end
	if spec.pedalRate > 0 and spec.isActive then Drivable.actionEventAccelerate(self, "AXIS_ACCELERATE_VEHICLE", spec.pedalRate, nil, true); end
end

function AnalogPedal:actionEventAccelerate(superfunc, actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_AnalogPedal
	if spec.isActive then
		if inputValue == 1 then
			spec.pedalRate = spec.pedalRate + AnalogPedal.incRate
			if spec.pedalRate > 1 then spec.pedalRate = 1; end
		end
		return superfunc(self, actionName, spec.pedalRate, callbackState, true)
	else
		return superfunc(self, actionName, inputValue, callbackState, isAnalog)
	end
end

function AnalogPedal:actionEventBrake(superfunc, actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_AnalogPedal
	if inputValue == 1 then 
		spec.pedalRate = 0
	end
	return superfunc(self, actionName, inputValue, callbackState, isAnalog)
end
