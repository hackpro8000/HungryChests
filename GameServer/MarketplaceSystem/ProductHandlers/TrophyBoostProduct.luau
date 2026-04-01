local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceEvents = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceEvents)
local MarketplaceHelper = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceHelper)
local MarketplaceTypes = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceTypes)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)

local TROPHY_QUANTITIES = {
    TrophyBoost1 = 20,
    TrophyBoost2 = 40,
    TrophyBoost3 = 80,
    TrophyBoost4 = 100,
    TrophyBoost5 = 160,
    TrophyBoost6 = 180
}

MarketplaceEvents.OnProcessReceipt:Connect(function(receiptProcessor: MarketplaceTypes.ReceiptProcessor)
    local productMapName = MarketplaceHelper.getProductMapNameFromID(receiptProcessor:GetInfo().ProductId)
    local trophyQuantity = productMapName and TROPHY_QUANTITIES[productMapName] :: number?

    if trophyQuantity then
        ProfileState:GetServer().incrementShallowValue(`{receiptProcessor:GetInfo().PlayerId}`, "Trophies", trophyQuantity)
        receiptProcessor:Confirm()
    end
end)

return nil
