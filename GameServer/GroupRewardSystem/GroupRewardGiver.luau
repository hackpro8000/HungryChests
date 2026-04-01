local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GroupRewardEvents = require(ReplicatedStorage.GameCommon.GroupRewardSystem.GroupRewardEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)

GroupRewardEvents.GroupRewardGiven:Connect(function(player: Player)
    local profileID : string = `{player.UserId}`
    
    ProfileState:GetServer().giveCurrency(profileID, "Primary", 500)
    ProfileState:GetServer().incrementShallowValue(profileID, "Trophies", 80)
    ProfileState:GetServer().claimGroupReward(profileID, os.time())
end)

return nil
