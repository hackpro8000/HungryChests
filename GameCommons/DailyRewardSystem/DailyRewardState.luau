local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataLib = require(ReplicatedStorage.TLib.DataLib)
local DailyRewardTypes = require(script.Parent.DailyRewardTypes)

local Actions, Data = {}, {
    DailyTrackers = {} :: {[string] : DailyRewardTypes.DailyTracker},
}

Actions.addDailyTracker = DataLib.Action(function(dailyTrackerID : string, dailyTracker : DailyRewardTypes.DailyTracker)
    assert(dailyTrackerID, `Daily Tracker ID was not provided!`)
    assert(dailyTracker, `Daily Tracker data was not provided!`)
    assert(dailyTracker.LastLoginDate, `Daily Tracker ${dailyTrackerID}, Last Login Date was not provided!`)
    assert(dailyTracker.CurrentStreak, `Daily Tracker ${dailyTrackerID}, Current Streak was not provided!`)
    assert(dailyTracker.DailyRewardIndex, `Daily Tracker ${dailyTrackerID}, Daily Reward Index was not provided!`)
    assert(dailyTracker.DailyRewardMap, `Daily Tracker ${dailyTrackerID}, Daily Reward Map was not provided!`)
    
    Data.DailyTrackers[dailyTrackerID] = dailyTracker
end)

Actions.removeDailyTracker = DataLib.Action(function(dailyTrackerID : string)
    assert(dailyTrackerID ~= nil, `DailyTracker ID was not provided!`)

    Data.DailyTrackers[dailyTrackerID] = nil
end)

Actions.resetDailyTracker = DataLib.Action(function(dailyTrackerID : string, dailyRewardMap : DailyRewardTypes.DailyRewardMap)
    local tracker = assert(Data.DailyTrackers[dailyTrackerID], `DailyTracker {dailyTrackerID} was not found!`)

    if tracker then
        tracker.CurrentStreak = 1
        tracker.ClaimedRewards = {}
        tracker.ClaimableRewards = {1} -- Reset to only Day 1 claimable
        tracker.DailyRewardMap = dailyRewardMap
    end
end)

Actions.setLastLoginDate = DataLib.Action(function(dailyTrackerID : string, lastLoginDate : number)
    local tracker = assert(Data.DailyTrackers[dailyTrackerID], `DailyTracker {dailyTrackerID} was not found!`)

    if tracker then
        tracker.LastLoginDate = lastLoginDate
    end
end)

Actions.incrementStreak = DataLib.Action(function(dailyTrackerID : string)
    local tracker = assert(Data.DailyTrackers[dailyTrackerID], `DailyTracker {dailyTrackerID} was not found!`)

    if tracker then
        tracker.CurrentStreak += 1
    end
end)

Actions.claimReward = DataLib.Action(function(dailyTrackerID : string, rewardIndex : number)
    local tracker = assert(Data.DailyTrackers[dailyTrackerID], `DailyTracker {dailyTrackerID} was not found!`)

    if tracker then
        table.insert(tracker.ClaimedRewards, rewardIndex)
    end
end)

Actions.addClaimableReward = DataLib.Action(function(dailyTrackerID : string, rewardIndex : number)
    local tracker = assert(Data.DailyTrackers[dailyTrackerID], `DailyTracker {dailyTrackerID} was not found!`)

    if tracker then
        table.insert(tracker.ClaimableRewards, rewardIndex)
    end
end)

Actions.setClaimableRewards = DataLib.Action(function(dailyTrackerID : string, claimableRewards : {number})
    local tracker = assert(Data.DailyTrackers[dailyTrackerID], `DailyTracker {dailyTrackerID} was not found!`)

    if tracker then
        tracker.ClaimableRewards = claimableRewards
    end
end)

Actions.setDailyRewardMap = DataLib.Action(function(dailyTrackerID : string, dailyRewardMap : DailyRewardTypes.DailyRewardMap)
    local tracker = assert(Data.DailyTrackers[dailyTrackerID], `DailyTracker {dailyTrackerID} was not found!`)

    if tracker then
        tracker.DailyRewardMap = dailyRewardMap
    end
end)

return DataLib.StateContainer(Actions, Data)
:SetTag("NetworkDiscriminator", "DailyRewardState")
:AddToNetwork()
