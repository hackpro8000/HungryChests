local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardTypes = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardTypes)
local DailyRewardTypes = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardTypes)

return {
    Wins = 0 :: number,
    WinStreak = 0 :: number,
    PreviousWinStreak = 0 :: number,
    Trophies = 0 :: number,
    Currencies = {
        Primary = 0,
    } :: {[string] : number},
    PowerUps = {} :: {[string] : number},
    ChestInventory = {} :: {[string] : boolean},
    ChestEquippedType = nil :: string?,
    ChairInventory = {} :: {[string] : boolean},
    ChairEquippedType = nil :: string?,
    EngagementTracker = nil :: EngagementRewardTypes.EngagementTracker?,
    DailyTracker = nil :: DailyRewardTypes.DailyTracker?,
}