local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)

return {
    LoadingStarted = OrderedSignal.new();
    LoadingFinished = OrderedSignal.new();
}
