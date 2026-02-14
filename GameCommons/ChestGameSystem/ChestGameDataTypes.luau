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
    OpenedChests : {number},
    DefaultChairType : string,
    Participants : {
        [string] : ChestGameParticipant
    },
    WinnerPrimaryRewardRange : NumberRange,
    LoserPrimaryRewardRange : NumberRange,
    WinnerTrophyRewardRange : NumberRange,
    LoserTrophyRewardRange : NumberRange,
}

export type ChestGameParticipant = {
    UserIDString : string,
    HealthPoints : number,
    HealthPointsMax : number,
    ChosenChests : {number},
    ChestType : string,
    ChairType : string,
    Index : number,
}

export type ChestGameState = "Dormant" | "ChoosingChests" | "InAction" | "Conclusion"

return nil
