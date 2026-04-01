local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    OnFriendRewardTriggered = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(profileID : string, friendProfileID : string) -> ()>
}
