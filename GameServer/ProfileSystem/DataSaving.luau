
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)
local PromiseLib = require(ReplicatedStorage.TLib.PromiseLib)
local PromiseLibTypes = require(ReplicatedStorage.TLib.PromiseLib.PromiseLibTypes)

local MainDataStore = DataStoreService:GetDataStore("MainDataStore")

local function getKey(player : Player) : string
    assert(player, `Player wasn't provided. Cannot return a key.`)
    
    return `{player.UserId}`
end

local function setSave(key : string, profile : ProfileSystemTypes.Profile, maxAttempts : number?) : PromiseLibTypes.Promise<() -> ()>
    maxAttempts = maxAttempts or 3

    return PromiseLib.new(function(resolve: () -> (), reject: (err : string?, attempts : number?) -> (), onCancel: (() -> ()) -> boolean, onCleanup: () -> ())
        local currentAttempts = 0
        local latestErr : string? = nil

        local function saveData()
            MainDataStore:SetAsync(key, profile)
        end

        while currentAttempts < maxAttempts do
            if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) > 0 then
                local success, err = pcall(saveData)

                if success then
                    resolve()
                    return
                else
                    warn(err)
                    latestErr = err
                end

                currentAttempts += 1
            end; task.wait()
        end

        reject(latestErr, currentAttempts)
    end)
end

local function onPlayerRemoving(player : Player)
    local key = getKey(player)
    local profile = ProfileState.Data.Profiles[key]
    
    if profile then
        setSave(key, profile, 3):Then(function()
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
        setSave(key, profile):Then(function()
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
