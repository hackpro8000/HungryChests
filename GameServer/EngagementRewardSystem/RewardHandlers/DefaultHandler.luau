local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardEvents = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardEvents)
local EngagementRewardTypes = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardTypes)

EngagementRewardEvents.OnProcessReward:Connect(function(rewardProcessRequest : EngagementRewardTypes.RewardProcessRequest)
    if rewardProcessRequest:IsPending() then
        local rewardID = rewardProcessRequest:ParseReward("string:1")
        
        rewardProcessRequest:Deny(`Reward with ID "{rewardID}" wasn't processed, did you forget to implement a reward handler?`)
    end
end, math.huge)

return nil
