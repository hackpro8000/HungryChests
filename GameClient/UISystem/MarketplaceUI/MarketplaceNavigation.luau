local MarketplaceNavigator = require(script.Parent.MarketplaceNavigator)
local MarketplaceViewer = require(script.Parent.MarketplaceViewer)

for _, tabName : string in {"Coins", "Trophies", "Passes"} do
    MarketplaceViewer.InteractionContext:GetButton(`TabSelector/{tabName}`):ListenLMB(function(isDown : boolean)
        if isDown == true then
            return
        end

        MarketplaceNavigator.toTab(tabName)
    end)
end

return nil
