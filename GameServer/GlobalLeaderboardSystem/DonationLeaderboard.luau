local LEADERBOARD_ID = "Donations"

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local GlobalLeaderboardEvents = require(ReplicatedStorage.GameCommon.GlobalLeaderboardSystem.GlobalLeaderboardEvents)
local GlobalLeaderboardState = require(ReplicatedStorage.GameCommon.GlobalLeaderboardSystem.GlobalLeaderboardState)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)

local DonationsOrderedDataStore = DataStoreService:GetOrderedDataStore(LEADERBOARD_ID)
local MainDataStore = DataStoreService:GetDataStore("MainDataStore")

local function upload(key : string, value : any)
    DonationsOrderedDataStore:SetAsync(key, value)
end

local function download() : Pages?
    local result : Pages? = nil

    local function try()
        result = DonationsOrderedDataStore:GetSortedAsync(false, 50, 1)
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
    GlobalLeaderboardState:GetServer().registerLeaderboard(LEADERBOARD_ID, "MOST DONATIONS")

    GlobalLeaderboardEvents.OnUpload:Connect(function()
        for profileID : string, profile : ProfileSystemTypes.Profile in ProfileState.Data.Profiles do
            local successful, output = pcall(upload, profileID, profile.RobuxDonated)

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
