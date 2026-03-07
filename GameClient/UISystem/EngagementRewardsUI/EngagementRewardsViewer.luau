local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local EngagementRewardsViewer = UILib.Viewer()
EngagementRewardsViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.EngagementRewards:Clone())
EngagementRewardsViewer:AutoParent()
EngagementRewardsViewer:SetVisible(false)

return EngagementRewardsViewer
