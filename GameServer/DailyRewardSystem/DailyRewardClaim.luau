local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailyRewardEvents = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardEvents)
local DailyRewardProcessRequest = require(script.Parent.DailyRewardProcessRequest)
local DailyRewardState = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardState)
local DailyRewardTypes = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardTypes)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)
local DailyRewardGeneral = require(ReplicatedStorage.GameDefinitions.DailyRewardSystem.DailyRewardGeneral)

local RF_ClaimReward = NetLibServer.RemoteFunction("DailyRewardSystem/ClaimReward")

RF_ClaimReward.OnServerInvoke = function(player, rewardIndex : number?)
    local dailyTracker = DailyRewardState.Data.DailyTrackers[`{player.UserId}`]

    if dailyTracker == nil then
        return false, "Daily tracker not found!"
    end

    -- If no reward index provided, find the next available claimable reward
    if not rewardIndex then
        for _, claimableIndex in dailyTracker.ClaimableRewards do
            if not table.find(dailyTracker.ClaimedRewards, claimableIndex) then
                rewardIndex = claimableIndex
                break
            end
        end
    end

    if not rewardIndex then
        return false, "No available rewards to claim!"
    end

    -- Check if reward is claimable
    if not table.find(dailyTracker.ClaimableRewards, rewardIndex) then
        return false, "Reward not claimable yet!"
    end

    local dailyReward : DailyRewardTypes.DailyReward = dailyTracker.DailyRewardMap[rewardIndex]

    if dailyReward == nil then
        return false, "Reward not found!"
    end

    -- Check if reward is already claimed
    if table.find(dailyTracker.ClaimedRewards, rewardIndex) then
        return false, "Reward already claimed!"
    end

    print(dailyReward.Reward)

    local rewardProcessRequest = DailyRewardProcessRequest.new(`{player.UserId}`, dailyReward.Reward)
    DailyRewardEvents.OnProcessReward:Fire(rewardProcessRequest)
    
    if rewardProcessRequest:IsConfirmed() then
        DailyRewardState:GetServer().claimReward(`{player.UserId}`, rewardIndex)
    elseif rewardProcessRequest:IsDenied() then
        return false, rewardProcessRequest:GetStatusError()
    end

    return true
end

return nil
