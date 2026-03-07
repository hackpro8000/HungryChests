local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local DailyRewardState = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardState)
local DailyRewardGeneral = require(ReplicatedStorage.GameDefinitions.DailyRewardSystem.DailyRewardGeneral)
local DefaultDailyRewardMap = require(ReplicatedStorage.GameDefinitions.DailyRewardSystem.DailyRewardMaps.DefaultDailyRewardMap)

local function checkDailyTracker(dailyTrackerID : string)
    local dailyTracker = DailyRewardState.Data.DailyTrackers[dailyTrackerID]
    
    if not dailyTracker then
        return
    end
    
    local currentTime = os.time()
    local timeSinceLastLogin = currentTime - dailyTracker.LastLoginDate
    local dailyPeriodSeconds = DailyRewardGeneral.DAILY_PERIOD_SECONDS
    
    -- Check if enough time has passed for next daily reward
    if timeSinceLastLogin < dailyPeriodSeconds then
        return
    end
    
    -- Check if grace period has expired (missed too many days)
    local gracePeriodSeconds = DailyRewardGeneral.GRACE_PERIOD_HOURS * 3600
    if timeSinceLastLogin > dailyPeriodSeconds + gracePeriodSeconds then
        -- Reset streak and reward index
        DailyRewardState:GetServer().resetDailyTracker(dailyTrackerID, table.clone(DefaultDailyRewardMap))
    else
        -- Player logged in within grace period, increment streak
        DailyRewardState:GetServer().incrementStreak(dailyTrackerID)
        
        -- Add next reward to claimable array
        if dailyTracker then
            local nextRewardIndex = dailyTracker.CurrentStreak
            if nextRewardIndex <= #dailyTracker.DailyRewardMap and not table.find(dailyTracker.ClaimableRewards, nextRewardIndex) then
                DailyRewardState:GetServer().addClaimableReward(dailyTrackerID, nextRewardIndex)
            end
        end
    end
    
    -- Update last login date
    DailyRewardState:GetServer().setLastLoginDate(dailyTrackerID, currentTime)
    
    -- Check if completed 7-day cycle (all rewards claimed)
    local totalRewards = #dailyTracker.DailyRewardMap
    
    if #dailyTracker.ClaimedRewards >= totalRewards then
        DailyRewardState:GetServer().resetDailyTracker(dailyTrackerID, table.clone(DefaultDailyRewardMap))
    end
end

BootEvents.NetworkStarted:Connect(function()
    -- Check trackers live
    task.spawn(function()
        while true do
            for dailyTrackerID, dailyTracker in DailyRewardState.Data.DailyTrackers do
                checkDailyTracker(dailyTrackerID)
            end
            task.wait(1) -- Check every second
        end
    end)

    -- Check existing daily trackers
    for dailyTrackerID, dailyTracker in DailyRewardState.Data.DailyTrackers do
        checkDailyTracker(dailyTrackerID)
    end

    -- Listen for new daily trackers being added
    DailyRewardState.addDailyTracker.listen(function(dailyTrackerID : string, dailyTracker)
        checkDailyTracker(dailyTrackerID)
        print(dailyTrackerID)
    end)
end)

return nil
