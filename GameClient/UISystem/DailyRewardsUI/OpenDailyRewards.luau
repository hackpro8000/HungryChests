local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailyRewardsViewer = require(ReplicatedStorage.GameClient.UISystem.DailyRewardsUI.DailyRewardsViewer)
local PlayerStatsViewer = require(ReplicatedStorage.GameClient.UISystem.PlayerStatsUI.PlayerStatsViewer)

PlayerStatsViewer.InteractionContext:GetButton("OpenDailyRewards"):ListenLMB(function(isDown : boolean)
    if isDown then
        return
    end

    DailyRewardsViewer:SetVisible(true)
end)

return nil
