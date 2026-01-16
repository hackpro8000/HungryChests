local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleAssemblyLine = require(script.Parent.VehicleAssemblyLine)
local VehicleEvents = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleEvents)
local StreamingLib = require(ReplicatedStorage.TLib.StreamingLib)

local ClutchModules = ReplicatedStorage.GameDefinitions.VehicleDefinitions.Clutches
local EngineModules = ReplicatedStorage.GameDefinitions.VehicleDefinitions.Engines
local TransmissionModules = ReplicatedStorage.GameDefinitions.VehicleDefinitions.Transmissions

local function blindRequire(moduleInstance : ModuleScript?)
    return moduleInstance and require(moduleInstance) or {}
end

VehicleEvents.OnAssemble:Connect(function(vehicleInstance: Instance, vehicleAssembly)
    local vehicleRoot : BasePart = vehicleInstance.Root

    vehicleAssembly.InstanceStreamableID = StreamingLib.getID(vehicleInstance)
    vehicleAssembly.VehicleWeightKG = vehicleAssembly.VehicleWeightKG or 1000
    vehicleAssembly.Engine = VehicleAssemblyLine.createEngine(blindRequire(EngineModules:FindFirstChild(vehicleAssembly.Engine)))
    vehicleAssembly.Clutch = VehicleAssemblyLine.createClutch(blindRequire(ClutchModules:FindFirstChild(vehicleAssembly.Clutch)))
    vehicleAssembly.Transmission = VehicleAssemblyLine.createTransmission(blindRequire(TransmissionModules:FindFirstChild(vehicleAssembly.Transmission)))
    vehicleAssembly.Wheels = VehicleAssemblyLine.createWheels(vehicleInstance:FindFirstChild("Wheels"), vehicleRoot.CFrame)
end, 2)

return nil