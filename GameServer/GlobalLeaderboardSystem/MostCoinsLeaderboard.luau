local LEADERBOARD_ID = "MostCoins"

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local GlobalLeaderboardEvents = require(ReplicatedStorage.GameCommons.GlobalLeaderboardSystem.GlobalLeaderboardEvents)
local GlobalLeaderboardState = require(ReplicatedStorage.GameCommons.GlobalLeaderboardSystem.GlobalLeaderboardState)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)

local MostCoinsOrderedDataStore = DataStoreService:GetOrderedDataStore(LEADERBOARD_ID)
local MainDataStore = DataStoreService:GetDataStore("MainDataStore")

local function upload(key : string, value : any)
    MostCoinsOrderedDataStore:SetAsync(key, value)
end

local function download() : Pages?
    local result : Pages? = nil

    local function try()
        result = MostCoinsOrderedDataStore:GetSortedAsync(false, 50, 1)
    end

    for attempt = 1, 5 do
        local success, output = pcall(try)

        if success then
            break
        else
            warn(output)
        end
    end

    return result
end

GlobalLeaderboardEvents.PreBoot:Connect(function()
    GlobalLeaderboardState:GetServer().registerLeaderboard(LEADERBOARD_ID, "MOST COINS")

    GlobalLeaderboardEvents.OnUpload:Connect(function()
        for profileID : string, profile : ProfileSystemTypes.Profile in ProfileState.Data.Profiles do
            local successful, output = pcall(upload, profileID, profile.Currencies.Primary)

            if not successful then
                warn(output)
            end
        end
    end)

    GlobalLeaderboardEvents.OnDownload:Connect(function()
        local pages : Pages? = download()

        if pages then
            GlobalLeaderboardState:GetServer().clearEntries(LEADERBOARD_ID)
            
            for _, entry : {key : string, value : any} in pages:GetCurrentPage() do
                local userIDString = entry.key
                local value = entry.value

                GlobalLeaderboardState:GetServer().addEntry(LEADERBOARD_ID, userIDString, value)
            end
        end
    end)
end)

return nil
