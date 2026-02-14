local MarketplaceViewer = require(script.Parent.MarketplaceViewer)

MarketplaceViewer.InteractionContext:GetButton("Close"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    MarketplaceViewer:SetVisible(false)
end)

return nil
