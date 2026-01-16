local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleDataTypes = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleDataTypes)

return {
    LateralGripCoeff = 1,
    LateralGripLimitKG = 100,
    ForwardGripCoeff = 1,
    ForwardGripLimitKG = 100,
    Radius = 1.25,
    SteerAngleInner = 60,
    SteerAngleOuter = 45,
    SpringMaxLength = 2,
    SpringRestLength = 0,
    SpringStiffnessCoeff = 45000,
    SpringStiffnessLimitKG = math.huge,
    SpringDampingCoeff = 1500,
    SpringDampingLimitKG = math.huge,
} :: VehicleDataTypes.Wheel