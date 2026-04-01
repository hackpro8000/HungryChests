local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProductIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.ProductIDMap)

local MarketplaceHelper = {}

function MarketplaceHelper.getProductMapNameFromID(productID : number) : string?
    for productMapName, productID1 in ProductIDMap do
        if productID ~= productID1 then
            continue
        end

        return productMapName
    end

    return nil
end

return MarketplaceHelper
