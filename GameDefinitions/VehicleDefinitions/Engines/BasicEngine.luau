local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleDataTypes = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleDataTypes)

return {
    IdleRPM                 = 400,
    Redline                 = 5000,
    PeakRPM                 = 4000,
    FrictionTorqueNm        = 350,
    MaxTorqueNm             = 250,
    TorqueDropoffSharpness  = 1,
    TorqueDropoffDelay      = -0.5,
    FlywheelWeightKG        = 10,
} :: VehicleDataTypes.Engine