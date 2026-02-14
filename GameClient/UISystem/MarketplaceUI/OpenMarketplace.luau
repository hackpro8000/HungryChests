local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MarketplaceViewer = require(ReplicatedStorage.GameClient.UISystem.MarketplaceUI.MarketplaceViewer)
local PlayerStatsViewer = require(ReplicatedStorage.GameClient.UISystem.PlayerStatsUI.PlayerStatsViewer)

PlayerStatsViewer.InteractionContext:GetButton("OpenMarketplace"):ListenLMB(function(isDown : boolean)
    if isDown then
        return
    end

    MarketplaceViewer:SetVisible(true)
end)

return nil
