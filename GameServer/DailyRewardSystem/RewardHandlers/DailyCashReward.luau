local REWARD_ID = "Cash"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailyRewardEvents = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardEvents)
local DailyRewardTypes = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardTypes)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)

DailyRewardEvents.OnProcessReward:Connect(function(rewardProcessRequest : DailyRewardTypes.DailyRewardProcessRequest)
    if not rewardProcessRequest:ContainsReward(REWARD_ID) then
        return
    end
    
    local quantity = rewardProcessRequest:GetRewardArgs(REWARD_ID)
    
    local userIDString : string = rewardProcessRequest.__dailyTrackerID
    local profile : ProfileSystemTypes.Profile? = ProfileState.Data.Profiles[userIDString]
    
    if profile == nil then
        rewardProcessRequest:Deny("NilProfile")
        return
    end
    
    local quantityNum = tonumber(quantity) or 0
    if quantityNum <= 0 then
        return
    end

    ProfileState:GetServer().giveCurrency(userIDString, "Primary", quantityNum)
    rewardProcessRequest:Confirm()
end)

return nil
