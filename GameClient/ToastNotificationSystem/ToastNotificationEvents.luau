local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    NotificationReceived = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal<(messageText : string, duration : number) -> ()>
}
