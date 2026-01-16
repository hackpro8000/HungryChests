local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleDataTypes = require(script.Parent.VehicleDataTypes)
local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    OnAssemble = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(vehicleInstance : Instance, vehicleAssembly : VehicleDataTypes.VehicleAssembly) -> ()>,
    OnUpdate = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(dt : number) -> ()>
}