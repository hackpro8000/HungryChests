local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local ChestGameViewer = UILib.Viewer()
ChestGameViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.ChestGame:Clone())
ChestGameViewer:AutoParent()

return ChestGameViewer
