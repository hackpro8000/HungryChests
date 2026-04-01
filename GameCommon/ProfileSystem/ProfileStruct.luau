local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardTypes = require(ReplicatedStorage.GameCommon.EngagementRewardSystem.EngagementRewardTypes)
local DailyRewardTypes = require(ReplicatedStorage.GameCommon.DailyRewardSystem.DailyRewardTypes)

return {
    Wins = 0 :: number,
    WinStreak = 0 :: number,
    PreviousWinStreak = 0 :: number,
    Trophies = 0 :: number,
    Currencies = {
        Primary = 0,
    } :: {[string] : number},
    RobuxDonated = 0 :: number,
    PowerUps = {} :: {[string] : number},
    ChestInventory = {} :: {[string] : boolean},
    ChestEquippedType = nil :: string?,
    ChairInventory = {} :: {[string] : boolean},
    ChairEquippedType = nil :: string?,
    EngagementTracker = nil :: EngagementRewardTypes.EngagementTracker?,
    FriendJoinDates = {} :: {[string] : number},
    DailyTracker = nil :: DailyRewardTypes.DailyTracker?,
    GroupRewardClaimedOn = 0 :: number,
}