local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local FriendRewardEvents = require(ReplicatedStorage.GameCommon.FriendRewardSystem.FriendRewardEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)
local CleanerLib = require(ReplicatedStorage.TLib.CleanerLib)

local ProfileLinkedCleaners = {} :: {[string] : typeof(CleanerLib.Cleaner())}

local function createCleaner(profileID : string) : typeof(CleanerLib.Cleaner())
    local cleaner = CleanerLib.Cleaner()
    
    ProfileLinkedCleaners[profileID] = cleaner

    return cleaner
end

local function onProfileAdded(friendProfileID : string, profile : ProfileSystemTypes.Profile)
    local _cleaner = createCleaner(friendProfileID) -- Future self—do we still need this?

    for profileID : string, profile1 : ProfileSystemTypes.Profile in ProfileState.Data.Profiles do
        local player1 : Player? = Players:GetPlayerByUserId(tonumber(profileID))

        if player1 == nil then
            continue
        end

        if player1:IsFriendsWithAsync(tonumber(friendProfileID)) then
            local friendJoinDate = profile1.FriendJoinDates[friendProfileID] or 0

            if os.time() < friendJoinDate + 86400 then
                continue
            end

            FriendRewardEvents.OnFriendRewardTriggered:Fire(profileID, friendProfileID)
        end
    end
end

local function onProfileRemoved(profileID : string)
    local cleaner = ProfileLinkedCleaners[profileID]

    cleaner:Clean()
    cleaner:Destroy()

    ProfileLinkedCleaners[profileID] = cleaner
end

BootEvents.NetworkStarted:Connect(function()
    ProfileState.addProfile.listen(onProfileAdded)
    ProfileState.removeProfile.listen(onProfileRemoved)
end)

return nil
