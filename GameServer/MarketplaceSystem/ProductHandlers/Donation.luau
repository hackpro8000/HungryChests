local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceEvents = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceEvents)
local MarketplaceHelper = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceHelper)
local MarketplaceTypes = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceTypes)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)

local DONATION_AMOUNTS = {
    Donate1 = 10,
    Donate2 = 25,
    Donate3 = 50,
    Donate4 = 150,
    Donate5 = 400,
    Donate6 = 800,
    Donate7 = 1250,
    Donate8 = 5000,
    Donate9 = 100000,
}

MarketplaceEvents.OnProcessReceipt:Connect(function(receiptProcessor: MarketplaceTypes.ReceiptProcessor)
    local productMapName = MarketplaceHelper.getProductMapNameFromID(receiptProcessor:GetInfo().ProductId)
    local amount = productMapName and DONATION_AMOUNTS[productMapName] :: number?

    if amount then
        ProfileState:GetServer().donateRobux(`{receiptProcessor:GetInfo().PlayerId}`, amount)
        receiptProcessor:Confirm()
    end
end)

return nil
