local TAG = "FloatingModel"
local OSCILLATION_SPEED = 0.5

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local TimeLib = require(ReplicatedStorage.TLib.TimeLib)

local modelOrigins = {} :: {[Model] : CFrame}

local function centerPivot(model : Model)
    local bboxCFrame : CFrame = model:GetBoundingBox()
    
    local primaryPart : Part = Instance.new("Part")
    primaryPart.Transparency = 1
    primaryPart.CanCollide = false
    primaryPart.Anchored = true
    primaryPart.Parent = model
    primaryPart.CFrame = bboxCFrame
    model.PrimaryPart = primaryPart

    return model
end

local function onAdded(model : Model)
    modelOrigins[model] = model:GetPivot()
end

local function onHeartbeat(dt : number)
    for model : Model, origin : CFrame in modelOrigins do
        local yOffset = 
            math.sin((math.pi/2 * TimeLib.getTime() + origin.X+origin.Z) * OSCILLATION_SPEED)

        local rotation = origin.X + origin.Z + math.pi * 2 * ((TimeLib.getTime() % 6)/6)
        local yOffsetNormalized = math.abs((yOffset + 1)/2) * 4

        if model:GetAttribute("IgnoreRotation") == true then
            model:PivotTo(origin + (Vector3.yAxis * yOffsetNormalized))
        else
            model:PivotTo(origin * CFrame.Angles(0,rotation,0) + (Vector3.yAxis * yOffsetNormalized))
        end
    end
end

for _, model : Model in CollectionService:GetTagged(TAG) do
    onAdded(model)
end
CollectionService:GetInstanceAddedSignal(TAG):Connect(onAdded)
RunService.Heartbeat:Connect(onHeartbeat)

return nil
