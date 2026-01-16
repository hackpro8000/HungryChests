local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleEvents = require(ReplicatedStorage.GameCommons.VehicleSystem.VehicleEvents)

local RMU = 21.952

local function weldAB(partA : BasePart, partB : BasePart, parent : Instance?)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = partA
    weld.Part1 = partB
    weld.Parent = parent or partA

    return weld
end

local function weldChildren(part : BasePart, instance : Instance, parent : Instance?) : {WeldConstraint}
    local weldConstraints = {}

    for _, basePart : BasePart in instance:GetChildren() do
        if not basePart:IsA("BasePart") then
            continue
        end

        table.insert(weldConstraints, weldAB(part, basePart, parent))
    end

    return weldConstraints
end

local function weldDescendants(part : BasePart, instance : Instance, parent : Instance?) : {WeldConstraint}
    local weldConstraints = {}

    for _, basePart : BasePart in instance:GetDescendants() do
        if not basePart:IsA("BasePart") then
            continue
        end

        table.insert(weldConstraints, weldAB(part, basePart, parent))
    end

    return weldConstraints
end

local function createFolder(name : string, parent : Instance?, content : {Instance}?) : Folder
    local folder : Folder = Instance.new("Folder")
    folder.Name = name

    if content ~= nil then
        for _, instance : Instance in content do
            instance.Parent = folder
        end
    end

    folder.Parent = parent

    return folder
end

VehicleEvents.OnAssemble:Connect(function(vehicleInstance: Instance, vehicleAssembly)
    local centerOfGravity : BasePart = vehicleInstance.CenterOfMass
    local vehicleRoot : BasePart = vehicleInstance.Root

    weldAB(vehicleInstance.CenterOfMass, vehicleRoot, vehicleInstance.CenterOfMass)

    local wheelSuspensionVectorForceFolder = createFolder("WheelSuspensionVectorForces", vehicleInstance)

    createFolder(
        "BodyModelWelds",

        vehicleInstance,

        weldDescendants(
            vehicleRoot,
            (assert(vehicleInstance:FindFirstChild("BodyModel"), `Vehicle Instance must have a body model!`))
        )
    )

    createFolder(
        "WheelWelds",
        
        vehicleInstance,

        weldDescendants(
            vehicleRoot,
            (assert(vehicleInstance:FindFirstChild("Wheels"), `Vehicle Instance must have wheels!`))
        )
    )

    createFolder(
        "SeatPositionWelds",
        
        vehicleInstance,

        weldDescendants(
            vehicleRoot,
            (assert(vehicleInstance:FindFirstChild("SeatPositions"), `Vehicle Instance must have seat positions!`))
        )
    )

    for _, wheelPart : BasePart in vehicleInstance.Wheels:GetChildren() do
        if wheelPart:IsA("BasePart") then
            local vectorForceAttachment = Instance.new("Attachment", wheelPart)
            local suspensionVectorForce = Instance.new("VectorForce", wheelSuspensionVectorForceFolder)
            suspensionVectorForce.Name = wheelPart.Name
            suspensionVectorForce.Force = Vector3.zero
            suspensionVectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
            suspensionVectorForce.Attachment0 = vectorForceAttachment
        end
    end

    for _, descendant : BasePart in vehicleInstance:GetDescendants() do
        if descendant:IsA("BasePart") then
            descendant.Massless = true
        end
    end

    local weightPartSize = Vector3.one * 50
    local weightPartVolume = (weightPartSize.X * weightPartSize.Y * weightPartSize.Z)
    centerOfGravity.Size = weightPartSize
    centerOfGravity.Transparency = 1
    centerOfGravity.CanCollide = false
    centerOfGravity.CanQuery = false
    centerOfGravity.CanTouch = false
    centerOfGravity.Anchored = true
    centerOfGravity.Massless = false
    centerOfGravity.CustomPhysicalProperties = PhysicalProperties.new(
        (vehicleAssembly.VehicleWeightKG/RMU)/weightPartVolume,
        0,
        0
    )

    weldAB(centerOfGravity, vehicleRoot, centerOfGravity)
end, 1)

VehicleEvents.OnAssemble:Connect(function(vehicleInstance: Instance, vehicleAssembly)
    for _, basePart : BasePart in vehicleInstance:GetDescendants() do
        if not basePart:IsA("BasePart") then
            continue
        end

        basePart.Anchored = false
    end
end, 3)

return nil
