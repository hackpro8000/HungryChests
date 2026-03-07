local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardsViewer = require(ReplicatedStorage.GameClient.UISystem.EngagementRewardsUI.EngagementRewardsViewer)
local PlayerStatsViewer = require(ReplicatedStorage.GameClient.UISystem.PlayerStatsUI.PlayerStatsViewer)

PlayerStatsViewer.InteractionContext:GetButton("OpenEngagementRewards"):ListenLMB(function(isDown : boolean)
    if isDown then
        return
    end

    EngagementRewardsViewer:SetVisible(true)
end)

return nil
