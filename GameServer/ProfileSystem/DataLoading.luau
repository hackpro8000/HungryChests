local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileStruct = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileStruct)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)
local PromiseLib = require(ReplicatedStorage.TLib.PromiseLib)
local PromiseLibTypes = require(ReplicatedStorage.TLib.PromiseLib.PromiseLibTypes)

local MainDataStore = DataStoreService:GetDataStore("MainDataStore")

local function getKey(player : Player) : string
    assert(player, `Player wasn't provided. Cannot return a key.`)
    
    return `{player.UserId}`
end

local function reconcile(tbl : {}, src : {})
    for i, v in src do
        local shouldRecurse = false

        if tbl[i] == nil and typeof(v) ~= "table" then
            tbl[i] = v
        elseif tbl[i] == nil and typeof(v) == "table" then
            tbl[i] = table.clone(v)
            shouldRecurse = false
        end

        if typeof(v) == "table" and tbl[i] ~= nil and shouldRecurse == true then
            reconcile(tbl[i], v)
        end
    end
end

local function getSave(key : string, maxAttempts : number?) : PromiseLibTypes.Promise<(save : ProfileSystemTypes.Profile) -> ()>
    maxAttempts = maxAttempts or 3

    return PromiseLib.new(function(resolve: (save : ProfileSystemTypes.Profile) -> (), reject: () -> (), onCancel: (() -> ()) -> boolean, onCleanup: () -> ())
        local currentAttempts = 0
        local save : ProfileSystemTypes.Profile? = nil
        local latestErr : string? = nil

        local function load()
            save = MainDataStore:GetAsync(key) or {}
        end

        while true do
            if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync) >= 1 then
                local success, err = pcall(load)

                if success == false then
                    warn(err)
                    latestErr = err
                elseif success == true and save ~= nil then
                    break
                end

                currentAttempts += 1
            end; task.wait()
        end

        if save ~= nil then
            resolve(save)
        else
            reject(latestErr, currentAttempts)
        end
    end)
end

local function onProfileSuccessfullyLoaded(player : Player, profile : ProfileSystemTypes.Profile)
    reconcile(profile, ProfileStruct)

    ProfileState:GetServer().addProfile(getKey(player), profile)
end

local function onPlayerAdded(player : Player)   
    getSave(getKey(player), 3):Then(function(profile : ProfileSystemTypes.Profile)
        onProfileSuccessfullyLoaded(player, profile)
    end):Catch(function(err : string, attempts : number)
        warn(`Gave up after attempting to load [{player.Name}/{player.UserId}]'s profile {attempts} times!`)
        
        player:Kick("Please rejoin!")
    end)
end

BootEvents.NetworkStarted:Connect(function()
    for _, player : Player in Players:GetPlayers() do
        task.spawn(onPlayerAdded, player)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
end)

return nil
