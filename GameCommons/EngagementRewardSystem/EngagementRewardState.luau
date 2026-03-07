local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataLib = require(ReplicatedStorage.TLib.DataLib)
local EngagementRewardTypes = require(script.Parent.EngagementRewardTypes)

local Actions, Data = {}, {
    EngagementTrackers = {} :: {[string] : EngagementRewardTypes.EngagementTracker},
}

Actions.addEngagementTracker = DataLib.Action(function(engagementTrackerID : string, engagementTracker : EngagementRewardTypes.EngagementTracker)
    assert(engagementTrackerID, `Engagement Tracker ID was not provided!`)
    assert(engagementTracker, `Engagement Tracker data was not provided!`)
    assert(engagementTracker.CreationDate, `Engagement Tracker ${engagementTrackerID}, Creation Date was not provided!`)
    assert(engagementTracker.EngagementRewardIndex, `Engagement Tracker ${engagementTrackerID}, Engagement Reward Index was not provided!`)
    assert(engagementTracker.EngagementRewardMap, `Engagement Tracker ${engagementTrackerID}, Engagement Reward Map was not provided!`)
    assert(engagementTracker.TimeSpent, `Engagement Tracker ${engagementTrackerID}, Time Spent was not provided!`)
    
    Data.EngagementTrackers[engagementTrackerID] = engagementTracker
end)

Actions.removeEngagementTracker = DataLib.Action(function(engagementTrackerID : string)
    assert(engagementTrackerID ~= nil, `EngagementTracker ID was not provided!`)

    Data.EngagementTrackers[engagementTrackerID] = nil
end)

Actions.resetEngagementTracker = DataLib.Action(function(engagementTrackerID : string)
    local tracker = assert(Data.EngagementTrackers[engagementTrackerID], `EngagementTracker {engagementTrackerID} was not found!`)

    if tracker then
        tracker.EngagementRewardIndex = 1
        tracker.TimeSpent = 0
    end
end)

Actions.setCreationDate = DataLib.Action(function(engagementTrackerID : string, creationDate : number)
    local tracker = assert(Data.EngagementTrackers[engagementTrackerID], `EngagementTracker {engagementTrackerID} was not found!`)

    if tracker then
        tracker.CreationDate = creationDate
    end
end)

Actions.nextIndex = DataLib.Action(function(engagementTrackerID : string)
    local tracker = assert(Data.EngagementTrackers[engagementTrackerID], `EngagementTracker {engagementTrackerID} was not found!`)

    if tracker then
        tracker.EngagementRewardIndex += 1
    end
end)

Actions.claimReward = DataLib.Action(function(engagementTrackerID : string)
    local tracker = assert(Data.EngagementTrackers[engagementTrackerID], `EngagementTracker {engagementTrackerID} was not found!`)

    if tracker then
        Actions.nextIndex(engagementTrackerID)
        Actions.setTimeSpent(engagementTrackerID, 0)
    end
end)

Actions.setTimeSpent = DataLib.Action(function(engagementTrackerID : string, elapsedTime : number)
    local tracker = assert(Data.EngagementTrackers[engagementTrackerID], `EngagementTracker {engagementTrackerID} was not found!`)

    if tracker then
        tracker.TimeSpent = elapsedTime
    end
end)

Actions.addTimeSpent = DataLib.Action(function(engagementTrackerID : string, elapsedTime : number)
    local tracker = assert(Data.EngagementTrackers[engagementTrackerID], `EngagementTracker {engagementTrackerID} was not found!`)

    if tracker then
        tracker.TimeSpent += elapsedTime
    end
end)

return DataLib.StateContainer(Actions, Data)
:SetTag("NetworkDiscriminator", "EngagementRewardState")
:AddToNetwork()
