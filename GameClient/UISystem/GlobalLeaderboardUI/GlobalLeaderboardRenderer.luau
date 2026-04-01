local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalLeaderboardSurfaceUI = require(script.Parent.GlobalLeaderboardSurfaceUI)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local GlobalLeaderboardState = require(ReplicatedStorage.GameCommon.GlobalLeaderboardSystem.GlobalLeaderboardState)
local GlobalLeaderboardTypes = require(ReplicatedStorage.GameCommon.GlobalLeaderboardSystem.GlobalLeaderboardTypes)

local LeaderboardSurfaceUIMemory = {} :: {[string] : {
    typeof(GlobalLeaderboardSurfaceUI.new())
}}

local function updateLeaderboards(leaderboardID : string)
    if LeaderboardSurfaceUIMemory[leaderboardID] == nil then
        return
    end

    if GlobalLeaderboardState.Data.Leaderboards[leaderboardID] == nil then
        return
    end

    local leaderboard : GlobalLeaderboardTypes.Leaderboard = GlobalLeaderboardState.Data.Leaderboards[leaderboardID]

    for _, leaderboardSurfaceUI in LeaderboardSurfaceUIMemory[leaderboardID] do
        leaderboardSurfaceUI:SetTitle(leaderboard.Title)
        leaderboardSurfaceUI:ClearEntries()

        for _, entry : GlobalLeaderboardTypes.LeaderboardEntry in leaderboard.Entries do
            leaderboardSurfaceUI:AddEntry(entry.UserIDString, entry.Value)
        end
    end
end

local function globalLeaderboardInstanceAdded(globalLeaderboardInstance : Instance)
    local leaderboardID = globalLeaderboardInstance:GetAttribute("LeaderboardID")

    if LeaderboardSurfaceUIMemory[leaderboardID] == nil then
        LeaderboardSurfaceUIMemory[leaderboardID] = {}
    end

    local leaderboardSurfaceUI = GlobalLeaderboardSurfaceUI.new(leaderboardID, globalLeaderboardInstance)
    leaderboardSurfaceUI:SetAdornee(globalLeaderboardInstance.Surface)

    table.insert(LeaderboardSurfaceUIMemory[leaderboardID], leaderboardSurfaceUI)
end

BootEvents.NetworkStarted:Connect(function()
    for _, globalLeaderboardInstance in CollectionService:GetTagged("GlobalLeaderboard") do
        globalLeaderboardInstanceAdded(globalLeaderboardInstance)
    end

    CollectionService:GetInstanceAddedSignal("GlobalLeaderboard"):Connect(globalLeaderboardInstanceAdded)

    for leaderboardID in GlobalLeaderboardState.Data.Leaderboards do
        for _, globalLeaderboardInstance in CollectionService:GetTagged("GlobalLeaderboardSurface") do
            globalLeaderboardInstanceAdded(globalLeaderboardInstance)
        end

        updateLeaderboards(leaderboardID)
    end

    GlobalLeaderboardState.registerLeaderboard.listen(function(leaderboardID : string)
        updateLeaderboards(leaderboardID)
    end)

    GlobalLeaderboardState.clearEntries.listen(function(leaderboardID: string)
        if LeaderboardSurfaceUIMemory[leaderboardID] == nil then
            return
        end

        if GlobalLeaderboardState.Data.Leaderboards[leaderboardID] == nil then
            return
        end

        for _, leaderboardSurfaceUI in LeaderboardSurfaceUIMemory[leaderboardID] do
            leaderboardSurfaceUI:ClearEntries()
        end
    end)

    GlobalLeaderboardState.addEntry.listen(function(leaderboardID: string, userIDString: string, value)
        if LeaderboardSurfaceUIMemory[leaderboardID] == nil then
            return
        end

        if GlobalLeaderboardState.Data.Leaderboards[leaderboardID] == nil then
            return
        end

        for _, leaderboardSurfaceUI in LeaderboardSurfaceUIMemory[leaderboardID] do
            leaderboardSurfaceUI:AddEntry(userIDString, value)
        end
    end)    
end)

return nil
