local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    GroupRewardGiven = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(player : Player) -> ()>
}
