local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CineLib = require(ReplicatedStorage.TLib.CineLib)

local MainCinematicController = CineLib.CinematicController.new(workspace.CurrentCamera)
local LocalPlayer = Players.LocalPlayer

MainCinematicController:Start({
    FOV = 70,
    CameraType = Enum.CameraType.Custom,
})

MainCinematicController:AddModifier("Default@1", function(cameraChanges, dt: number)
    cameraChanges.CameraSubject = LocalPlayer.Character and LocalPlayer.Character.Humanoid
end)

return MainCinematicController
