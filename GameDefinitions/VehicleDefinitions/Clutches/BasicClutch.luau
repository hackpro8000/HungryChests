local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleDataTypes = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleDataTypes)

return {
    MaxTorqueTransferFromEngineNm   = 200,
    MaxTorqueTransferToEngineNm     = 200,
    TorqueTransferFromEngineCoeff   = 1,
    TorqueTransferToEngineCoeff     = 1,
} :: VehicleDataTypes.Clutch
