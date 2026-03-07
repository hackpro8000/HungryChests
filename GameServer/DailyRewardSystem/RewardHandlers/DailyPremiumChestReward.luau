local REWARD_ID = "PremiumChest"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local LuckyDrawRequest = require(ServerScriptService.GameServer.LuckyDrawSystem.LuckyDrawRequest)
local DailyRewardEvents = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardEvents)
local DailyRewardTypes = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardTypes)
local LuckyDrawEvents = require(ReplicatedStorage.GameCommons.LuckyDrawSystem.LuckyDrawEvents)
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

    -- Trigger premium chest draw and mark as IAP
    local player = Players:GetPlayerByUserId(tonumber(userIDString))
    local luckyDrawRequest = LuckyDrawRequest.new(player, "LuckyChestDraw", quantityNum)
    luckyDrawRequest:DeclareIAP()

    LuckyDrawEvents.LuckyDrawRequested:Fire(luckyDrawRequest)
    
    rewardProcessRequest:Confirm()
end)

return nil
