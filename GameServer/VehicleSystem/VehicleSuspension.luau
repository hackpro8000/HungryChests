local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local VehicleDataTypes = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleDataTypes)
local VehicleEvents = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleEvents)
local VehicleState = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleState)
local StreamingLib = require(ReplicatedStorage.TLib.StreamingLib)

local RMU = 21.952

local function updateVehicle(dt : number, vehicleID : string, vehicleAssembly : VehicleDataTypes.VehicleAssembly)
    local vehicleInstance = StreamingLib.getInstance(vehicleAssembly.InstanceStreamableID)
    local root : BasePart = vehicleInstance.Root
    local origin : CFrame = root.CFrame

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {vehicleInstance}
    
    for wheelID : string, wheel : VehicleDataTypes.Wheel in vehicleAssembly.Wheels do
        local wheelOrigin = vehicleInstance.Wheels[wheelID].CFrame
        local raycastDistance = wheel.SpringMaxLength + wheel.Radius
        local raycast = workspace:Raycast(wheelOrigin.Position, wheelOrigin.YVector * -raycastDistance, raycastParams)
        local suspensionVectorForce : VectorForce = vehicleInstance.WheelSuspensionVectorForces[wheelID]
        
        if raycast ~= nil then
            local newSpringLength = raycast.Distance - wheel.Radius
            local springCompression = (wheel.SpringMaxLength + wheel.SpringRestLength) - newSpringLength
            local springSpeed = (newSpringLength - wheel.SpringLength) / math.max(dt, 0.001)
            local springStiffnessForceKG = math.clamp(springCompression * wheel.SpringStiffnessCoeff, -wheel.SpringStiffnessLimitNm, wheel.SpringStiffnessLimitNm)
            local springDamperForceKG = math.clamp(springSpeed * wheel.SpringDampingCoeff, -wheel.SpringDampingLimitNm, wheel.SpringDampingLimitNm)

            suspensionVectorForce.Force = Vector3.yAxis * ((springStiffnessForceKG - springDamperForceKG) / RMU)

            VehicleState.patchWheel(vehicleID, wheelID, {
                SpringLength = newSpringLength,
            })
        else
            suspensionVectorForce.Force = Vector3.zero

            VehicleState.patchWheel(vehicleID, wheelID, {
                SpringLength = wheel.SpringMaxLength,
            })
        end
    end
end

local function onUpdate(dt : number)
    for vehicleID : string, vehicleAssembly : VehicleDataTypes.VehicleAssembly in VehicleState.Data.VehicleAssemblies do
        updateVehicle(dt, vehicleID, vehicleAssembly)
    end
end

BootEvents.NetworkStarted:Connect(function()
    VehicleEvents.OnUpdate:Connect(onUpdate)
end)

return nil
