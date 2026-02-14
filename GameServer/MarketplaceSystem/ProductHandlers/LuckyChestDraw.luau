local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local LuckyDrawRequest = require(ServerScriptService.GameServer.LuckyDrawSystem.LuckyDrawRequest)
local LuckyDrawEvents = require(ReplicatedStorage.GameCommons.LuckyDrawSystem.LuckyDrawEvents)
local MarketplaceEvents = require(ReplicatedStorage.GameCommons.MarketplaceSystem.MarketplaceEvents)
local MarketplaceTypes = require(ReplicatedStorage.GameCommons.MarketplaceSystem.MarketplaceTypes)
local ProductIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.ProductIDMap)

local Quantities = {
    [ProductIDMap.LuckyChestDrawPremium] = 1;
    [ProductIDMap.LuckyChestDrawPremium5] = 5;
}

MarketplaceEvents.OnProcessReceipt:Connect(function(receiptProcessor: MarketplaceTypes.ReceiptProcessor)
    local receiptInfo = receiptProcessor:GetInfo()
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    
    if player == nil then
        return
    end

    local quantity = Quantities[receiptInfo.ProductId]

    if quantity == nil then
        return
    end

    local luckyDrawRequest = LuckyDrawRequest.new(player, "LuckyChestDraw", "Premium", quantity)
    luckyDrawRequest:DeclareIAP()

    LuckyDrawEvents.LuckyDrawRequested:Fire(luckyDrawRequest)

    if luckyDrawRequest:IsConfirmed() then
        receiptProcessor:Confirm()
    end
end)

return nil
