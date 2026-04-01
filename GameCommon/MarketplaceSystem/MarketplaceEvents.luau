local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceTypes = require(script.Parent.MarketplaceTypes)
local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    OnProcessReceipt = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(receiptProcessor : MarketplaceTypes.ReceiptProcessor) -> ()>
}