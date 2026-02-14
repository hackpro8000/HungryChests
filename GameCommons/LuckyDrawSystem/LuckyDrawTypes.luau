export type RarityOld = {
    Common : number,
    Premium : number
}

export type RarityMapOld = {
    [string] : RarityOld
}

export type LuckyChestDrawRequest = {
    IsConfirmed : (self : LuckyChestDrawRequest) -> boolean,
    Confirm : (self : LuckyChestDrawRequest) -> (),
    GetPlayer : (self : LuckyChestDrawRequest) -> Player,
    GetTier : (self : LuckyChestDrawRequest) -> "CommonDraw1" | "CommonDraw5" | "PremiumDraw1" | "PremiumDraw5"
}

export type LuckyDrawRequest = {
    IsIAP           : (self : LuckyDrawRequest) -> boolean,
    IsConfirmed     : (self : LuckyDrawRequest) -> boolean,
    IsDenied        : (self : LuckyDrawRequest) -> boolean,
    Confirm         : (self : LuckyDrawRequest, result : string) -> (),
    Deny            : (self : LuckyDrawRequest, result : string) -> (),
    GetPlayer       : (self : LuckyDrawRequest) -> Player,
    GetLuckyDrawID  : (self : LuckyDrawRequest) -> Player,
    GetTierID       : (self : LuckyDrawRequest) -> string,
    GetQuantity     : (self : LuckyDrawRequest) -> number,
    GetDenialResult : (self : LuckyDrawRequest) -> string,
    GetResult       : (self : LuckyDrawRequest) -> string | {string},
}

--[[
    Prize ID mapped to a rarity ID.
]]
export type LuckyDrawPool = {
    [string] : string
}

--[[
    A map of probabilities for each rarity.
]]
export type RarityMap = {
    [string] : number,
}

--[[
    A tier determines which pool will be drawn from
    and has its own rarity map.
]]
export type LuckyDrawTier = {
    PoolID : string,
    RarityMap : RarityMap,
}

export type LuckyDraw = {
    Tiers : {[string] : LuckyDrawTier},
    Pools : {[string] : LuckyDrawPool}
}

return nil
