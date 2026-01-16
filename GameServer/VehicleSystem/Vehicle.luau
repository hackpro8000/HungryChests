local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleDataTypes = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleDataTypes)
local VehicleEvents = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleEvents)
local VehicleState = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleState)

local Vehicle = {}

function Vehicle.fromInstance(vehicleInstance : Instance) : string
    local vehicleID : string = HttpService:GenerateGUID(false)
    local vehicleAssembly : VehicleDataTypes.VehicleAssembly = vehicleInstance:GetAttributes()

    VehicleEvents.OnAssemble:Fire(vehicleInstance, vehicleAssembly)
    VehicleState:GetServer().addVehicleAssembly(vehicleID, vehicleAssembly)

    return vehicleID
end

return Vehicle
