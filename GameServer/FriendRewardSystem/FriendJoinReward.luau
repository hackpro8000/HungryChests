local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ToastNotificationSender = require(ServerScriptService.GameServer.ToastNotificationSystem.ToastNotificationSender)
local FriendRewardEvents = require(ReplicatedStorage.GameCommon.FriendRewardSystem.FriendRewardEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)

FriendRewardEvents.OnFriendRewardTriggered:Connect(function(profileID: string, friendProfileID: string)
    print(profileID, "and", friendProfileID, "are now playing together")
    local player : Player = Players:GetPlayerByUserId(tonumber(profileID))
    local friend : Player = Players:GetPlayerByUserId(tonumber(friendProfileID))

    ToastNotificationSender.sendNotification(player, `You received $100 and 15 trophies for inviting {friend.DisplayName}!`, 5)
    
    ProfileState:GetServer().incrementShallowValue(profileID, "Trophies", 15)
    ProfileState:GetServer().giveCurrency(profileID, "Primary", 100)
    ProfileState:GetServer().friendJoined(profileID, friendProfileID, os.time())
end)

return nil
