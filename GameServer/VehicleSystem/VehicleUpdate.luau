local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local VehicleEvents = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleEvents)

RunService.Heartbeat:Connect(function(dt: number)
    VehicleEvents.OnUpdate:Fire(dt)
end)

return nil
