export type EngagementTracker = {
    CreationDate : number,
    TimeSpent : number,
    EngagementRewardIndex : number,
    EngagementRewardMap : EngagementRewardMap,
}

export type EngagementRewardMap = {
    [number] : EngagementReward,
}

export type EngagementReward = {
    Reward : string,
    Interval : number,
}

export type RewardProcessRequest = {
    new : (engagementTrackerID : string, reward : string) -> RewardProcessRequest,
    ParseReward : (self : RewardProcessRequest, parseInfo : string) -> any,
    GetStatus : (self : RewardProcessRequest) -> string,
    GetStatusError : (self : RewardProcessRequest) -> string,
    IsPending : (self : RewardProcessRequest) -> boolean,
    IsConfirmed : (self : RewardProcessRequest) -> boolean,
    IsDenied : (self : RewardProcessRequest) -> boolean,
    Confirm : (self : RewardProcessRequest) -> (),
    Deny : (self : RewardProcessRequest, reason : string) -> (),
}

return nil
