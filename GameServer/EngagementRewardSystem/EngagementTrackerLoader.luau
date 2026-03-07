local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local EngagementRewardState = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)
local EngagementRewardGeneral = require(ReplicatedStorage.GameDefinitions.EngagementRewardSystem.EngagementRewardGeneral)
local ExperimentalEngagementRewardMap = require(ReplicatedStorage.GameDefinitions.EngagementRewardSystem.EngagementRewardMaps.ExperimentalEngagementRewardMap)
local TestEngagementRewardMap = require(ReplicatedStorage.GameDefinitions.EngagementRewardSystem.EngagementRewardMaps.TestEngagementRewardMap)

local function createNewEngagementTracker()
    return {
        CreationDate = os.time(),
        TimeSpent = 0,
        EngagementRewardIndex = 1,
        EngagementRewardMap = table.clone(ExperimentalEngagementRewardMap),
    }
end

local function addEngagementTracker(profileID : string, profile : ProfileSystemTypes.Profile)
    local engagementTracker = profile.EngagementTracker or createNewEngagementTracker()

    if os.time() - engagementTracker.CreationDate > EngagementRewardGeneral.ENGAGEMENT_TRACKER_LIFESPAN then
        engagementTracker = createNewEngagementTracker()
    end

    EngagementRewardState:GetServer().addEngagementTracker(profileID, engagementTracker)
    ProfileState:GetServer().setEngagementTracker(profileID, engagementTracker)
end

BootEvents.NetworkStarted:Connect(function()
    for profileID, profile in ProfileState.Data.Profiles do
        addEngagementTracker(profileID, profile)
    end

    ProfileState.addProfile.listen(function(profileID : string, profile)
        addEngagementTracker(profileID, profile)
    end)

    ProfileState.removeProfile.listen(function(profileID : string)
        EngagementRewardState:GetServer().removeEngagementTracker(profileID)
    end)
end)

return nil
