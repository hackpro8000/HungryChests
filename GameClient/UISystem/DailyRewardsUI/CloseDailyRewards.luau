local DailyRewardsViewer = require(script.Parent.DailyRewardsViewer)

DailyRewardsViewer.InteractionContext:GetButton("Close"):ListenLMB(function(isDown : boolean)
    if isDown == true then
        return
    end

    DailyRewardsViewer:SetVisible(false)
end)

return nil
