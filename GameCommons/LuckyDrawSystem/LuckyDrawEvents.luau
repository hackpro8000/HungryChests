local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyDrawTypes = require(script.Parent.LuckyDrawTypes)
local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    LuckyChestDrawRequested = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(LuckyDrawTypes.LuckyChestDrawRequest) -> ()>;
    LuckyDrawRequested = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(luckyDrawRequest : LuckyDrawTypes.LuckyDrawRequest) -> ()>
}
