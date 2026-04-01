local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceEvents = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceEvents)
local MarketplaceHelper = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceHelper)
local MarketplaceTypes = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceTypes)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)

local COIN_QUANTITIES = {
    CoinBoost1 = 300,
    CoinBoost2 = 600,
    CoinBoost3 = 1000,
    CoinBoost4 = 2000,
    CoinBoost5 = 5000,
    CoinBoost6 = 10000
}

MarketplaceEvents.OnProcessReceipt:Connect(function(receiptProcessor: MarketplaceTypes.ReceiptProcessor)
    local productMapName = MarketplaceHelper.getProductMapNameFromID(receiptProcessor:GetInfo().ProductId)
    local coinQuantity = productMapName and COIN_QUANTITIES[productMapName] :: number?

    if coinQuantity then
        ProfileState:GetServer().incrementCurrency(`{receiptProcessor:GetInfo().PlayerId}`, "Primary", coinQuantity)
        receiptProcessor:Confirm()
    end
end)

return nil
