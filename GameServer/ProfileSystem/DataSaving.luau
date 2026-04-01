local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainDataStoreManager = require(script.Parent.MainDataStoreManager)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)

local function getKey(player : Player) : string
    assert(player, `Player wasn't provided. Cannot return a key.`)
    
    return `{player.UserId}`
end

local function onPlayerRemoving(player : Player)
    local key = getKey(player)
    local profile = ProfileState.Data.Profiles[key]
    
    if profile then
        MainDataStoreManager.setSave(key, profile, 3):Then(function()
            print(`Successfully saved data for {player.Name}`)
        end):Catch(function(err : string, attempts : number)
            warn(`Failed to profile data for {player.Name} after {attempts} attempts: {err}`)
        end):Finally(function(status: "Cancelled" | "Pending" | "Rejected" | "Resolved", ...)
            ProfileState:GetServer().removeProfile(key)
        end):Timeout(60)
    else
        warn(`No profile data found for player {player.Name}`)
    end
end

local function onGameClose()
    for key, profile in ProfileState.Data.Profiles do
        MainDataStoreManager.setSave(key, profile):Then(function()
            print(`Successfully saved data for {key}`)
        end):Finally(function(status: "Cancelled" | "Pending" | "Rejected" | "Resolved", ...)
            ProfileState:GetServer().removeProfile(key)
        end):Timeout(60)
    end

    repeat task.wait() until next(ProfileState.Data.Profiles) == nil
end

BootEvents.NetworkStarted:Connect(function()
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    game:BindToClose(onGameClose)
end)

return nil
