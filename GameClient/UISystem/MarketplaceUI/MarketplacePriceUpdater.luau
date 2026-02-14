local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceViewer = require(script.Parent.MarketplaceViewer)
local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local GamepassIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.GamepassIDMap)
local ProductIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.ProductIDMap)

local LocalPlayer = Players.LocalPlayer

local function onGamepassGUIAdded(gamepassGUI : GuiObject)
    local gamepassID = GamepassIDMap[gamepassGUI.Name]

    local info = MarketplaceService:GetProductInfoAsync(gamepassID, Enum.InfoType.GamePass)

    if MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, gamepassID) then
        gamepassGUI.Cost.Text = `R${info.PriceInRobux} (OWNED)`
    else
        gamepassGUI.Cost.Text = `R${info.PriceInRobux}`
        gamepassGUI.Selector.MouseButton1Up:Connect(function()
            MarketplaceService:PromptGamePassPurchase(LocalPlayer, gamepassID)
        end)
    end
end

local function onProductGUIAdded(productGUI : GuiObject)
    local productID = ProductIDMap[productGUI.Name]

    local info = MarketplaceService:GetProductInfoAsync(productID, Enum.InfoType.Product)

    productGUI.Cost.Text = `R${info.PriceInRobux}`
    productGUI.Selector.MouseButton1Up:Connect(function()
        MarketplaceService:PromptProductPurchase(LocalPlayer, productID)
    end)
end

BootEvents.NetworkStarted:Connect(function()
    for _, gamepassGUI : GuiObject in MarketplaceViewer:GetTagged("UI/Marketplace/Gamepass") do
        onGamepassGUIAdded(gamepassGUI)
    end

    for _, productGUI : GuiObject in MarketplaceViewer:GetTagged("UI/Marketplace/Product") do
        onProductGUIAdded(productGUI)
    end
end)

return nil
