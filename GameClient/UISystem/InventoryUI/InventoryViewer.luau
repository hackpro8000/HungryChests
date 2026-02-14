local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local InventoryViewer = UILib.Viewer()
InventoryViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.Inventory:Clone())
InventoryViewer:AutoParent()
InventoryViewer:SetVisible(false)

return InventoryViewer
