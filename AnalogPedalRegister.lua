--
-- register
--
-- Martin Eller 
-- Version 0.0.3.0
--
-- 
--

if g_specializationManager:getSpecializationByName("AnalogPedal") == nil then

  g_specializationManager:addSpecialization("AnalogPedal", "AnalogPedal", g_currentModDirectory.."AnalogPedal.lua", true, nil)

  for typeName, typeEntry in pairs(g_vehicleTypeManager:getVehicleTypes()) do
    
    if
    		SpecializationUtil.hasSpecialization(Drivable, typeEntry.specializations) 
		and	SpecializationUtil.hasSpecialization(Enterable, typeEntry.specializations)
		and	SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations)
    
    and not
    
	(
    		SpecializationUtil.hasSpecialization(Locomotive, typeEntry.specializations)
		or	SpecializationUtil.hasSpecialization(ConveyorBelt, typeEntry.specializations)
    )
    
    then
      	g_vehicleTypeManager:addSpecialization(typeName, "AnalogPedal")
		print("headlandManagement registered for "..typeName)
    end
  end
end

-- make localizations available
local i18nTable = getfenv(0).g_i18n
for l18nId,l18nText in pairs(g_i18n.texts) do
  i18nTable:setText(l18nId, l18nText)
end
