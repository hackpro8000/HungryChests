local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILib = require(ReplicatedStorage.TLib.UILib)

local PlayerStatsViewer = UILib.Viewer()
PlayerStatsViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.PlayerStats:Clone())
PlayerStatsViewer:AutoParent()

return PlayerStatsViewer