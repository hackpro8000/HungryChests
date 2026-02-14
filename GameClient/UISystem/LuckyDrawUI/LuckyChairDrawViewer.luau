local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local LuckyChairDrawViewer = UILib.Viewer()
LuckyChairDrawViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Billboards.LuckyChairDraw:Clone())
LuckyChairDrawViewer:AutoParent()
LuckyChairDrawViewer:SetVisible(false)

return LuckyChairDrawViewer
