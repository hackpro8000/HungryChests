local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailyRewardTypes = require(script.Parent.DailyRewardTypes)
local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    OnProcessReward = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(rewardProcessRequest : DailyRewardTypes.DailyRewardProcessRequest) -> ()>
}
