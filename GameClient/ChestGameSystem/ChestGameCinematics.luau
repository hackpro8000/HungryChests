local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainCinematicController = require(ReplicatedStorage.GameClient.CinematicSystem.MainCinematicController)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local CineLib = require(ReplicatedStorage.TLib.CineLib)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)

local LocalPlayer = Players.LocalPlayer

MainCinematicController:AddModifier("ChestGameCinematics@2", function(cameraChanges, dt: number)
    local activeChestGameID, activeChestGame, _activeParticipantID = ChestGameHelper.getPlayerChestGame(LocalPlayer)

    if activeChestGameID == nil then
        return
    end

    local activeChestGameInstance = StreamingLibClient.getInstance(activeChestGame.InstanceStreamableID)

    if activeChestGameInstance then
        local chestGameInstanceSize = activeChestGameInstance:GetExtentsSize()
        local vantageAngle = math.pi/2 * .75
        local cameraCurrentCFrame = MainCinematicController.TargetCamera.CFrame
        local origin = activeChestGameInstance.Mat.CFrame
        local originOffset = origin * CFrame.new(0,20,chestGameInstanceSize.Z/2)
        local originRotated = originOffset * CFrame.fromEulerAnglesYXZ(vantageAngle, math.pi, 0)
        local vantagePointCFrame = originRotated * CFrame.new(0, 0, -chestGameInstanceSize.Z)
        local focalPoint = origin.Position
        local goalCFrame = CFrame.lookAt(vantagePointCFrame.Position, focalPoint)

        cameraChanges.CFrame = cameraCurrentCFrame:Lerp(goalCFrame, dt * 2)
        cameraChanges.CameraType = Enum.CameraType.Scriptable
        cameraChanges.FOV = 40
    end
end)

return nil
