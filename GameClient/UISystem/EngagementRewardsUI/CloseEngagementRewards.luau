local EngagementRewardsViewer = require(script.Parent.EngagementRewardsViewer)

EngagementRewardsViewer.InteractionContext:GetButton("Close"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    EngagementRewardsViewer:SetVisible(false)
end)

return nil
