local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleDataTypes = require(script.Parent.VehicleDataTypes)
local DataLib = require(ReplicatedStorage.TLib.DataLib)

local Actions, Data = {}, {
    VehicleAssemblies = {} :: {[string] : VehicleDataTypes.VehicleAssembly}
}

Actions.patchWheel = DataLib.Action(function(vehicleAssemblyID : string, wheelID : string, patches : VehicleDataTypes.Wheel)
    assert(vehicleAssemblyID, "Must provide a vehicle assembly ID!")
    assert(wheelID, "Must provide a wheel ID!")
    assert(patches, "No patches provided!")

    local vehicleAssembly : VehicleDataTypes.VehicleAssembly = assert(Data.VehicleAssemblies[vehicleAssemblyID], `Vehicle assembly {vehicleAssemblyID} not found!`)
    local wheel : VehicleDataTypes.Wheel  = assert(vehicleAssembly.Wheels[wheelID], `Vehicle assembly {vehicleAssemblyID} does not have wheel {wheelID}!`)

    for key, value in patches do
        wheel[key] = value
    end
end)

Actions.addVehicleAssembly = DataLib.Action(function(vehicleAssemblyID : string, vehicleAssembly : VehicleDataTypes.VehicleAssembly)
    assert(vehicleAssemblyID, "Must provide a vehicle assembly ID!")
    assert(vehicleAssembly, "No vehicle assembly provided!")
    
    Data.VehicleAssemblies[vehicleAssemblyID] = vehicleAssembly
end)

Actions.removeVehicleAssembly = DataLib.Action(function(vehicleAssemblyID : string)
    assert(vehicleAssemblyID, "Must provide a vehicle assembly ID!")

    Data.VehicleAssemblies[vehicleAssemblyID] = nil
end)

return DataLib.StateContainer(Actions, Data)
:SetTag("NetworkDiscriminator", "VehicleState")
:AddToNetwork()