local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardTypes = require(script.Parent.EngagementRewardTypes)
local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    OnProcessReward = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(rewardProcessRequest : EngagementRewardTypes.RewardProcessRequest) -> ()>
}
