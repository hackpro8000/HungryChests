local REWARD_ID = "PremiumThrone"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardEvents = require(ReplicatedStorage.GameCommon.EngagementRewardSystem.EngagementRewardEvents)
local EngagementRewardTypes = require(ReplicatedStorage.GameCommon.EngagementRewardSystem.EngagementRewardTypes)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)

EngagementRewardEvents.OnProcessReward:Connect(function(rewardProcessRequest : EngagementRewardTypes.RewardProcessRequest)
    local rewardID : string = rewardProcessRequest:ParseReward("string:1")
    
    if rewardID ~= REWARD_ID then
        return
    end
    
    local userIDString : string = rewardProcessRequest.__engagementTrackerID
    local profile : ProfileSystemTypes.Profile? = ProfileState.Data.Profiles[userIDString]
    
    if profile == nil then
        rewardProcessRequest:Deny("NilProfile")
        return
    end
    
    local quantity : number = rewardProcessRequest:ParseReward("number:2")
    
    -- TODO: Implement PremiumThrone reward logic
    
    rewardProcessRequest:Confirm()
end)

return nil
