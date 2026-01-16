local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleDataTypes = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleDataTypes)

local ClutchModules = ReplicatedStorage.GameDefinitions.VehicleDefinitions.Clutches
local EngineModules = ReplicatedStorage.GameDefinitions.VehicleDefinitions.Engines
local TransmissionModules = ReplicatedStorage.GameDefinitions.VehicleDefinitions.Transmissions
local WheelModules = ReplicatedStorage.GameDefinitions.VehicleDefinitions.Wheels

local VehicleAssemblyLine = {}

function VehicleAssemblyLine.createWheels(wheelsFolder : Folder, origin : CFrame) : {[string] : VehicleDataTypes.Wheel}
    local wheels = {}

    for _, wheelPart in wheelsFolder:GetChildren() do
        local wheelType = wheelPart:GetAttribute("Wheel")
        local wheelDef = wheelType and require(WheelModules:FindFirstChild(wheelType))

        if not wheelPart:IsA("BasePart") then
            continue
        end

        if wheelType == nil then
            continue
        end

        if wheelDef == nil then
            wheelDef = wheelPart:GetAttributes()
        end

        local wheel = table.clone(wheelDef)
        
        wheel.RPM = 0
        wheel.SpringLength = 0
        
        wheel.Radius = wheel.Radius or 1.25
        wheel.LocationOnVehicle = wheelPart.CFrame * origin:Inverse()
        wheel.LateralGripCoeff = wheel.LateralGripCoeff or 1
        wheel.LateralGripLimitKG = wheel.LateralGripLimitKG or 100
        wheel.ForwardGripCoeff = wheel.ForwardGripCoeff or 1
        wheel.ForwardGripLimitKG = wheel.ForwardGripLimitKG or 100
        wheel.SteerAngleInner = wheel.SteerAngleInner or 0
        wheel.SteerAngleOuter = wheel.SteerAngleOuter or 0
        wheel.SpringMaxLength = wheel.SpringMaxLength or 2
        wheel.SpringRestLength = wheel.SpringRestLength or 2
        wheel.SpringStiffnessCoeff = wheel.SpringStiffnessCoeff or 2
        wheel.SpringStiffnessLimitKG = wheel.SpringStiffnessLimitKG or 25

        wheels[wheelPart.Name] = wheel
    end

    return wheels
end

function VehicleAssemblyLine.createEngine(engine : VehicleDataTypes.Engine) : VehicleDataTypes.Engine
    engine = engine or {}
    engine.RPM = 0
    engine.IdleRPM = engine.IdleRPM or 300
    engine.Redline = engine.Redline or 8000
    engine.PeakRPM = engine.PeakRPM or 7000
    engine.MaxTorqueNm = engine.MaxTorqueNm or 50
    engine.TorqueDropoffSharpness = engine.TorqueDropoffSharpness or 1
    engine.TorqueDropoffDelay = engine.TorqueDropoffDelay or -0.5
    engine.FlywheelWeightKG = engine.FlywheelWeightKG or 5

    return engine
end

function VehicleAssemblyLine.createTransmission(transmission : VehicleDataTypes.Transmission) : VehicleDataTypes.Transmission
    transmission = transmission or {}

    transmission.CurrentGear = 1
    transmission.FinalDrive = 1
    transmission.GearRatios = {
        7000/-50,
        0,
        7000/50,
        7000/100,
        7000/150,
        7000/200,
        7000/250
    }

    return transmission
end

function VehicleAssemblyLine.createClutch(clutch : VehicleDataTypes.Clutch) : VehicleDataTypes.Clutch
    clutch = {}

    clutch.Engagement = 0
    clutch.MaxTorqueTransferFromEngineNm = 30
    clutch.MaxTorqueTransferToEngineNm = 30
    clutch.TorqueTransferFromEngineCoeff = 1
    clutch.TorqueTransferToEngineCoeff = 1

    return clutch
end

return VehicleAssemblyLine
