local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardEvents = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardEvents)
local RewardProcessRequest = require(script.Parent.RewardProcessRequest)
local EngagementRewardState = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardState)
local EngagementRewardTypes = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardTypes)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)

local RF_ClaimReward = NetLibServer.RemoteFunction("EngagementRewardSystem/ClaimReward")

RF_ClaimReward.OnServerInvoke = function(player)
    local engagementTracker = EngagementRewardState.Data.EngagementTrackers[`{player.UserId}`]

    if engagementTracker == nil then
        return false, "Engagement tracker not found!"
    end

    local rewardIndex : number = engagementTracker.EngagementRewardIndex
    local engagementReward : EngagementRewardTypes.EngagementReward = engagementTracker.EngagementRewardMap[rewardIndex]

    if engagementReward == nil then
        return false, "Reward not found!"
    end

    if engagementTracker.TimeSpent < engagementReward.Interval then
        return false, "Reward not ready!"
    end

    local rewardProcessRequest = RewardProcessRequest.new(`{player.UserId}`, engagementReward.Reward)
    EngagementRewardEvents.OnProcessReward:Fire(rewardProcessRequest)
    
    if rewardProcessRequest:IsConfirmed() then
        EngagementRewardState:GetServer().claimReward(`{player.UserId}`)
    elseif rewardProcessRequest:IsDenied() then
        return false, rewardProcessRequest:GetStatusError()
    end

    return true
end

return nil
