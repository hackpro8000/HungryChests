local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local MarketplaceViewer = UILib.Viewer()
MarketplaceViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.Marketplace:Clone())
MarketplaceViewer:AutoParent()
MarketplaceViewer:SetVisible(false)

return MarketplaceViewer
