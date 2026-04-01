local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SceneElement_LuckyDrawCard = require(script.Parent.SceneElement_LuckyDrawCard)
local CineLibTypes = require(ReplicatedStorage.TLib.CineLib.CineLibTypes)
local CleanerLib = require(ReplicatedStorage.TLib.CleanerLib)

local LuckyDrawCardCluster = {}
LuckyDrawCardCluster.__index = LuckyDrawCardCluster

local function springCurve(alpha : number, stiffness : number, damping : number) : number
    return math.sin((math.pi/(2*(damping/alpha))) * alpha * stiffness) * (1-alpha) + alpha
end

local function multiplyCFrameByNumber(cframe0 : CFrame, factor : number) : CFrame
    return CFrame.fromMatrix(cframe0.Position * factor, cframe0.XVector * factor, cframe0.YVector * factor)
end

local function multiplyCFrames(cframe0 : CFrame, cframe1 : CFrame) : CFrame
    return CFrame.fromMatrix(cframe0.Position * cframe1.Position, cframe0.XVector * cframe1.XVector, cframe0.YVector * cframe1.YVector)
end

local function divideCFrameByNumber(cframe : CFrame, divisor : number) : CFrame
    return CFrame.fromMatrix(cframe.Position / divisor, cframe.XVector / divisor, cframe.YVector / divisor)
end

local function getDistanceForViewportFraction(objectHeight : number, viewportFraction : number, fovRadians : number)
    return objectHeight / (2 * viewportFraction * math.tan(fovRadians / 2))
end

function LuckyDrawCardCluster.new(startingAttachment : CFrame, floatingAttachment : CFrame, cinematicController : CineLibTypes.CinematicController)
    local self = setmetatable({}, LuckyDrawCardCluster)

    self.cleaner = CleanerLib.Cleaner() :: typeof(CleanerLib.Cleaner())
    self.cinematicController = cinematicController :: CineLibTypes.CinematicController
    self.startingAttachment = startingAttachment :: Attachment
    self.floatingAttachment = floatingAttachment :: Attachment
    self.luckyDrawCards = {} :: {typeof(SceneElement_LuckyDrawCard.new())}

    return self
end

function LuckyDrawCardCluster.InsertLuckyDrawCard(self : typeof(LuckyDrawCardCluster.new()), luckyDrawCard : typeof(SceneElement_LuckyDrawCard.new()))
    table.insert(self.luckyDrawCards, luckyDrawCard)

    self.cleaner:Add(luckyDrawCard)
end

function LuckyDrawCardCluster.PlayAnimations(self : typeof(LuckyDrawCardCluster.new()))
    --[[
        Cards come flying out of the chest        
    ]]
    for i : number, luckyDrawCard : typeof(SceneElement_LuckyDrawCard.new()) in self.luckyDrawCards do
        local offsetFromCenter = #self.luckyDrawCards-1 > 0 and math.abs((#self.luckyDrawCards-1)/2 - (i-1))/(#self.luckyDrawCards-1) or 0
        local xOffset : number = (i - 1) * 1.2 - ((#self.luckyDrawCards-1) * 1.2)/2
        local onScreenCFrame : CFrame = self.cinematicController.TargetCamera.CFrame *
            CFrame.new(xOffset,0,-getDistanceForViewportFraction(1.618, 0.4, math.rad(self.cinematicController.TargetCamera.FieldOfView)))

        local finalCFrame : CFrame = CFrame.new(onScreenCFrame.Position, self.cinematicController.TargetCamera.CFrame.Position)
        local startingCFrame : CFrame = self.floatingAttachment.WorldCFrame * CFrame.Angles(0,math.pi,0)

        task.delay(offsetFromCenter * 0.5, function()
            luckyDrawCard:GetAdornee().CFrame = startingCFrame

            local maxTime : number = 0.5
            local positionStiffnessCoeff : number = 160
            local rotationStiffnessCoeff : number = 20
            local positionDampingCoeff : number = 14
            local rotationDampingCoeff : number = 7

            local timeElapsed : number = 0

            local positionVelocity : Vector3 = Vector3.zero
            local rotationVelocity : Vector3 = Vector3.zero

            local animationConnection = RunService.RenderStepped:Connect(function(dt : number)
                timeElapsed += dt
                local alpha : number = math.clamp(timeElapsed/maxTime, 0, 1)
                local yOffset : number = math.sin(math.pi*alpha) * (self.floatingAttachment.Position.Y - self.startingAttachment.Position.Y) * 0.5
                local currentPosition : Vector3 = luckyDrawCard:GetAdornee().Position
                local currentRotation : Vector3 = Vector3.new(luckyDrawCard:GetAdornee().CFrame.Rotation:ToEulerAnglesXYZ())
                local goalCFrame : CFrame = startingCFrame:Lerp(finalCFrame, math.sin(math.pi/2*alpha)) + Vector3.new(0,yOffset,0)
                local goalPosition : Vector3 = goalCFrame.Position
                local goalRotation : Vector3 = Vector3.new(finalCFrame.Rotation:toEulerAnglesXYZ())

                local positionDisplacement = goalPosition - currentPosition
                local rotationDisplacement = goalRotation - currentRotation
                local springForcePos = positionDisplacement * positionStiffnessCoeff
                local springForceRot = rotationDisplacement * rotationStiffnessCoeff
                local newPositionVelocityUndamped = (positionVelocity + springForcePos * dt)
                local newRotationVelocityUndamped = (rotationVelocity + springForceRot * dt)
                local positionVelocityDelta = (newPositionVelocityUndamped - positionVelocity) / dt
                local rotationVelocityDelta = (newRotationVelocityUndamped - rotationVelocity) / dt

                positionVelocity = (positionVelocity + springForcePos * dt) * (1 - positionDampingCoeff * dt)
                rotationVelocity = (rotationVelocity + springForceRot * dt) * (1 - rotationDampingCoeff * dt)

                local newPosition = currentPosition + positionVelocity * dt
                local newRotation = currentRotation + rotationVelocity * dt

                local newCFrame = CFrame.new(newPosition) * CFrame.fromEulerAnglesXYZ(newRotation.X, newRotation.Y, newRotation.Z)

                luckyDrawCard:GetAdornee().CFrame = newCFrame
            end)

            task.wait(maxTime + 3)
            animationConnection:Disconnect()
        end)
    end
end

function LuckyDrawCardCluster.Destroy(self : typeof(LuckyDrawCardCluster.new()))
    self.cleaner:Clean()
    self.cleaner:Destroy()
end

return LuckyDrawCardCluster
