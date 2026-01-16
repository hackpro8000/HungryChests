local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleArithmetic = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleArithmetic)

local maxTorque = 1000
local peakRPM = 4500
local redline = 5000
local dropoffSharpness = 1
local dropoffDelay = -0.5

for i = 1, 5000, 100 do
    local torqueCoeff = VehicleArithmetic.getTorqueCoefficient(i, peakRPM, redline, dropoffSharpness, dropoffDelay) * maxTorque

    local part = Instance.new("Part")
    part.Anchored = true
    part.Size = Vector3.one
    part.CFrame = CFrame.new(0,torqueCoeff/100 * 10,i/100 * 10)
    part.Material = Enum.Material.Neon
    part.Color = Color3.new(1,0,0)
    part.Parent = workspace
end
