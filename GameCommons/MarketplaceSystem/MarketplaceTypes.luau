export type ReceiptProcessor = {
    IsConfirmed : (self : ReceiptProcessor) -> boolean,
    Confirm : (self : ReceiptProcessor) -> (),
    GetInfo : (self : ReceiptProcessor) -> ReceiptInfo
}

export type ReceiptInfo = {
    PurchaseId : number,
    PlayerId : number,
    ProductId : number,
    PlaceWherePurchased : number,
    CurrencySpent : number,
    CurrencyType : Enum.CurrencyType,
    ProductPurchaseChannel : Enum.ProductPurchaseChannel
}

return nil
