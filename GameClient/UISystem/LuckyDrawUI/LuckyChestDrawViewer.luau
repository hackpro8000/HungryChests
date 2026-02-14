local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local LuckyChestDrawViewer = UILib.Viewer()
LuckyChestDrawViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Billboards.LuckyChestDraw:Clone())
LuckyChestDrawViewer:AutoParent()
LuckyChestDrawViewer:SetVisible(false)

return LuckyChestDrawViewer
