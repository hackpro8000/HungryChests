local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local EngagementRewardState = require(ReplicatedStorage.GameCommon.EngagementRewardSystem.EngagementRewardState)

local function doTimeTracking()
    while true do
        for engagementTrackerID : string in EngagementRewardState.Data.EngagementTrackers do
            EngagementRewardState:GetServer().addTimeSpent(engagementTrackerID, 5)
        end

        task.wait(5)
    end
end

BootEvents.NetworkStarted:Connect(function()
    task.spawn(doTimeTracking)
end)

return nil
