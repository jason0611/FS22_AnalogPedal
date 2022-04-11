--
-- register
--
-- Martin Eller 
-- Version 0.1.0.1
--
-- 
--

if g_specializationManager:getSpecializationByName("AnalogPedal") == nil then

  g_specializationManager:addSpecialization("AnalogPedal", "AnalogPedal", g_currentModDirectory.."AnalogPedal.lua", true, nil)

  for typeName, typeEntry in pairs(g_vehicleTypeManager.types) do
    
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
		print("AnalogPedal registered for "..typeName)
    end
  end
end
