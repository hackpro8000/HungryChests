local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local DailyRewardState = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardState)
local DailyRewardTypes = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardTypes)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)
local DefaultDailyRewardMap = require(ReplicatedStorage.GameDefinitions.DailyRewardSystem.DailyRewardMaps.DefaultDailyRewardMap)

local function createNewDailyTracker()
    return {
        LastLoginDate = os.time(),
        CurrentStreak = 1,
        ClaimedRewards = {},
        ClaimableRewards = {1}, -- Day 1 is always claimable on start
        DailyRewardMap = table.clone(DefaultDailyRewardMap),
    }
end

local function updateClaimableRewards(dailyTracker : DailyRewardTypes.DailyTracker)
    -- Add rewards based on current streak
    for i = 1, dailyTracker.CurrentStreak, 1 do
        if i <= #dailyTracker.DailyRewardMap and not table.find(dailyTracker.ClaimableRewards, i) then
            table.insert(dailyTracker.ClaimableRewards, i)
        end
    end
end

local function addDailyTracker(profileID : string, profile : ProfileSystemTypes.Profile)
    local dailyTracker = profile.DailyTracker or createNewDailyTracker()
    dailyTracker.ClaimedRewards = dailyTracker.ClaimedRewards or {}

    -- Check if tracker is older than 2 days, reset if so
    local twoDaysInSeconds = 2 * 86400 -- 2 days = 172800 seconds
    if os.time() - dailyTracker.LastLoginDate > twoDaysInSeconds then
        dailyTracker = createNewDailyTracker()
    else
        -- Update claimable rewards based on current streak
        updateClaimableRewards(dailyTracker)
    end

    DailyRewardState:GetServer().addDailyTracker(profileID, dailyTracker)
    ProfileState:GetServer().setDailyTracker(profileID, dailyTracker)
end

BootEvents.NetworkStarted:Connect(function()
    for profileID, profile in ProfileState.Data.Profiles do
        addDailyTracker(profileID, profile)
    end

    ProfileState.addProfile.listen(function(profileID : string, profile)
        addDailyTracker(profileID, profile)
    end)

    ProfileState.removeProfile.listen(function(profileID : string)
        DailyRewardState:GetServer().removeDailyTracker(profileID)
    end)
end)

return nil
