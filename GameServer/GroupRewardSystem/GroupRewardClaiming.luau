local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GroupRewardEvents = require(ReplicatedStorage.GameCommon.GroupRewardSystem.GroupRewardEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)

local RE_ClaimGroupRewards = NetLibServer.RemoteEvent("GroupRewardSystem/ClaimGroupRewards")

local function isPlayerMember(player : Player) : boolean
    for _, groupInfo in GroupService:GetGroupsAsync(player.UserId) do
        if groupInfo.Id ~= game.CreatorId then
            continue
        end

        return true
    end

    return false
end

RE_ClaimGroupRewards.OnServerEvent:Connect(function(player : Player)
    if isPlayerMember(player) then
        print(`{player.Name} claimed group rewards!`)

        local profile : ProfileSystemTypes.Profile? = ProfileState.Data.Profiles[`{player.UserId}`]

        if profile == nil then
            return
        end

        if os.time() < profile.GroupRewardClaimedOn + 86400 then
            print("Already claimed group rewards today!")

            return
        end

        GroupRewardEvents.GroupRewardGiven:Fire(player)
    end
end)

return nil
