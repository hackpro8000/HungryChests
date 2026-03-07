local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local DailyRewardsViewer = UILib.Viewer()
DailyRewardsViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.DailyRewards:Clone())
DailyRewardsViewer:AutoParent()
DailyRewardsViewer:SetVisible(false)

return DailyRewardsViewer
