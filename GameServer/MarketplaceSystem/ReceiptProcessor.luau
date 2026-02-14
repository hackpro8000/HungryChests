local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceTypes = require(ReplicatedStorage.GameCommons.MarketplaceSystem.MarketplaceTypes)
local ReceiptProcessor = {}
ReceiptProcessor.__index = ReceiptProcessor

function ReceiptProcessor.new(receiptInfo : MarketplaceTypes.ReceiptInfo)
    local self = setmetatable({}, ReceiptProcessor)

    self.__receiptInfo = receiptInfo
    self.__confirmed = false

    return self
end

function ReceiptProcessor.GetInfo(self)
    return self.__receiptInfo
end

function ReceiptProcessor.IsConfirmed(self)
    return self.__confirmed
end

function ReceiptProcessor.Confirm(self)
    self.__confirmed = true
end

return ReceiptProcessor
