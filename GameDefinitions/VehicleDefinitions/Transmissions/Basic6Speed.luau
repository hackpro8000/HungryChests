local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleDataTypes = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleDataTypes)

--[[
    RPM & Wheel RPM Ratio Triangle:

    1. Wheel RPM = Engine RPM / Gear Ratio
    2. Engine RPM = Wheel RPM * Gear Ratio
    3. Gear Ratio = Engine RPM / Wheel RPM
]]

return {
    FinalDrive = 1,
    GearRatios = {
        4000/-50,
        0,
        4000/50,
        4000/100,
        4000/150,
        4000/200,
        4000/250,
        4000/300,
    }
} :: VehicleDataTypes.Transmission