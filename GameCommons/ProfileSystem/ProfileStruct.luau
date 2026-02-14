return {
    Wins = 0 :: number,
    WinStreak = 0 :: number,
    Trophies = 0 :: number,
    Currencies = {
        Primary = 0,
    } :: {[string] : number},
    ChestInventory = {} :: {[string] : boolean},
    ChestEquippedType = nil :: string?,
    ChairInventory = {} :: {[string] : boolean},
    ChairEquippedType = nil :: string?,
}