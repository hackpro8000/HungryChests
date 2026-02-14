local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceEvents = require(ReplicatedStorage.GameCommons.MarketplaceSystem.MarketplaceEvents)
local ReceiptProcessor = require(script.Parent.ReceiptProcessor)
local MarketplaceTypes = require(ReplicatedStorage.GameCommons.MarketplaceSystem.MarketplaceTypes)
local ModuleLib = require(ReplicatedStorage.TLib.ModuleLib)

function MarketplaceService.ProcessReceipt(receiptInfo : MarketplaceTypes.ReceiptInfo)
    local receiptProcessor : MarketplaceTypes.ReceiptProcessor = ReceiptProcessor.new(receiptInfo)

    MarketplaceEvents.OnProcessReceipt:Fire(receiptProcessor)

    if receiptProcessor:IsConfirmed() then
        return Enum.ProductPurchaseDecision.PurchaseGranted
    else
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

ModuleLib.LoadChildren(script.Parent.GamepassHandlers, "Serial")
ModuleLib.LoadChildren(script.Parent.ProductHandlers, "Serial")
return nil
