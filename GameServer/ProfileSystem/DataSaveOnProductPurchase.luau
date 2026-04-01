local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainDataStoreManager = require(script.Parent.MainDataStoreManager)
local MarketplaceEvents = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceEvents)
local MarketplaceTypes = require(ReplicatedStorage.GameCommon.MarketplaceSystem.MarketplaceTypes)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)

MarketplaceEvents.OnProcessReceipt:Connect(function(receiptProcessor)
    if receiptProcessor:IsConfirmed() then
        local receiptInfo : MarketplaceTypes.ReceiptInfo = receiptProcessor:GetInfo()
        local userIDString : string = `{receiptInfo.PlayerId}`
        local profile : ProfileSystemTypes.Profile? = ProfileState.Data.Profiles[userIDString]

        if profile == nil then
            return
        end

        MainDataStoreManager.setSave(userIDString, profile)
    end
end, math.huge)

return nil
