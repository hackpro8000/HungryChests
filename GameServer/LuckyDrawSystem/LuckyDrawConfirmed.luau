local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyDrawEvents = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawEvents)
local LuckyDrawTypes = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawTypes)

LuckyDrawEvents.LuckyDrawRequested:Connect(function(luckyDrawRequest : LuckyDrawTypes.LuckyDrawRequest)
    if luckyDrawRequest:IsConfirmed() then
        LuckyDrawEvents.LuckyDrawConfirmed:Fire(luckyDrawRequest)
    end
end, math.huge)

return nil
