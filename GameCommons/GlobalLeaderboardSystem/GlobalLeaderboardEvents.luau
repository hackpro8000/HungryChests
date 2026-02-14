local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

return {
    PreBoot = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal;
    OnDownload = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal;
    OnUpload = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal;
}
