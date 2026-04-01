export type ChestGame = {
    InstanceStreamableID : string,
    State : ChestGameState,
    GridSizeX : number,
    GridSizeY : number,
    MaxChestChoice : number,
    TurnTimer : number,
    MaxPlayers : number,
    TimerMin : number?,
    TimerMax : number?,
    CurrentTurnParticipantID : string?,
    CurrentTurn : ChestGameTurn,
    OpenedChests : {number},
    DefaultChairType : string,
    AnimationEnds : number?,
    Participants : {
        [string] : ChestGameParticipant
    },
    WinnerPrimaryRewardRange : NumberRange,
    LoserPrimaryRewardRange : NumberRange,
    WinnerTrophyRewardRange : NumberRange,
    LoserTrophyRewardRange : NumberRange,
}

export type TurnDecision = {
    ParticipantID : string,
    ChestNum : number,
    WasTimeoutDecision : boolean,
}

export type ChestGameTurn = {
    ParticipantID : string,
    Decision : TurnDecision?,
}

export type ChestGameParticipant = {
    UserIDString : string,
    HealthPoints : number,
    HealthPointsMax : number,
    ChosenChests : {number},
    Effects : {[string] : boolean},
    ChestType : string,
    ChairType : string,
    Index : number,
    MaxBadChests : number,
}

export type ChestGameState = "Dormant" | "ChoosingChests" | "InAction" | "Conclusion"

return nil
