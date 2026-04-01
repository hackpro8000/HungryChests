export type DailyTracker = {
    LastLoginDate : number,
    CurrentStreak : number,
    ClaimedRewards : {number}, -- Array of claimed reward indices
    ClaimableRewards : {number}, -- Array of claimable reward indices
    DailyRewardMap : DailyRewardMap,
}

export type DailyRewardMap = {
    [number] : DailyReward,
}

export type DailyReward = {
    Reward : string,
}

export type DailyRewardProcessRequest = {
    new : (dailyTrackerID : string, reward : string) -> DailyRewardProcessRequest,
    ParseReward : (self : DailyRewardProcessRequest, parseInfo : string) -> any,
    GetRewardArgs : (self : DailyRewardProcessRequest, rewardType : string) -> ...any,
    ContainsReward : (self : DailyRewardProcessRequest, rewardType : string) -> boolean,
    GetStatus : (self : DailyRewardProcessRequest) -> string,
    GetStatusError : (self : DailyRewardProcessRequest) -> string,
    IsPending : (self : DailyRewardProcessRequest) -> boolean,
    IsConfirmed : (self : DailyRewardProcessRequest) -> boolean,
    IsDenied : (self : DailyRewardProcessRequest) -> boolean,
    Confirm : (self : DailyRewardProcessRequest) -> (),
    Deny : (self : DailyRewardProcessRequest, reason : string) -> (),
}

return nil
