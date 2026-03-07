local REWARD_ID = "ExtraMimics"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardEvents = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardEvents)
local EngagementRewardTypes = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardTypes)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)

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
    
    ProfileState:GetServer().givePowerUp(userIDString, "ExtraMimics", quantity)
    
    rewardProcessRequest:Confirm()
end)

return nil
