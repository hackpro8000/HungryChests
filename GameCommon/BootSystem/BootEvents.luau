local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)

return {
    SystemStarting = OrderedSignal.new(),
    SystemStarted = OrderedSignal.new(),
    NetworkStarting = OrderedSignal.new(),
    NetworkStarted = OrderedSignal.new(),
}