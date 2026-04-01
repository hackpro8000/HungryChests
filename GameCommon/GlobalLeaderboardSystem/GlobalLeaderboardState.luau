local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataLib = require(ReplicatedStorage.TLib.DataLib)
local GlobalLeaderboardTypes = require(script.Parent.GlobalLeaderboardTypes)

local Actions, Data = {}, {
    Leaderboards = {} :: {[string] : GlobalLeaderboardTypes.Leaderboard}
}

Actions.registerLeaderboard = DataLib.Action(function(leaderboardID : string, title : string)
    assert(leaderboardID, "Leaderboard ID not provided!")
    assert(title, "Title not provided!")

    Data.Leaderboards[leaderboardID] = {
        Title = title,
        Entries = {}
    }
end)

Actions.clearEntries = DataLib.Action(function(leaderboardID : string)
    assert(leaderboardID, "Leaderboard ID not provided!")

    local leaderboard = assert(Data.Leaderboards[leaderboardID], `Leaderboard {leaderboardID} not found!`)

    table.clear(leaderboard.Entries)
end)

Actions.addEntry = DataLib.Action(function(leaderboardID : string, userIDString : string, value : any)
    assert(leaderboardID, "Leaderboard ID not provided!")
    assert(userIDString, "User ID (string) not provided!")
    assert(value, "Value not provided!")
    
    local entry : GlobalLeaderboardTypes.LeaderboardEntry = {
        UserIDString = userIDString,
        Value = value,
    }

    local leaderboard = assert(Data.Leaderboards[leaderboardID], `Leaderboard {leaderboardID} not found!`)

    table.insert(leaderboard.Entries, entry)
end)

return DataLib.StateContainer(Actions, Data)
:SetTag("NetworkDiscriminator", "GlobalLeaderboardState")
:AddToNetwork()
