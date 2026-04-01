local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyDrawTypes = require(script.Parent.LuckyDrawTypes)
local DataLib = require(ReplicatedStorage.TLib.DataLib)

local Actions, Data = {}, {
    LuckyDraws = {} :: {[string] : LuckyDrawTypes.LuckyDraw}
}

Actions.registerLuckyDraw = DataLib.Action(function(luckyDrawID : string)
    assert(luckyDrawID, "Lucky Draw ID not provided!")
    
    Data.LuckyDraws[luckyDrawID] = {
        Tiers = {};
        Pools = {};
    }
end)

Actions.setPrefabs = DataLib.Action(function(luckyDrawID : string, prefabs : {[string] : Instance})
    assert(luckyDrawID, "Lucky Draw ID not provided!")
    assert(prefabs, "Prefabs not provided!")

    local luckyDraw : LuckyDrawTypes.LuckyDraw = assert(Data.LuckyDraws[luckyDrawID], `Lucky Draw "{luckyDrawID}" isn't registered!`)

    luckyDraw.Prefabs = prefabs
end)

Actions.addTier = DataLib.Action(function(luckyDrawID : string, tierID : string, tier : LuckyDrawTypes.LuckyDrawTier)
    assert(luckyDrawID, "Lucky Draw ID not provided!")

    local luckyDraw : LuckyDrawTypes.LuckyDraw = assert(Data.LuckyDraws[luckyDrawID], `Lucky Draw "{luckyDrawID}" isn't registered!`)

    luckyDraw.Tiers[tierID] = tier
end)

Actions.addPool = DataLib.Action(function(luckyDrawID : string, poolID : string, pool : LuckyDrawTypes.LuckyDrawPool)
    assert(luckyDrawID, "Lucky Draw ID not provided!")

    local luckyDraw : LuckyDrawTypes.LuckyDraw = assert(Data.LuckyDraws[luckyDrawID], `Lucky Draw "{luckyDrawID}" isn't registered!`)

    luckyDraw.Pools[poolID] = pool
end)

Actions.unregisterLuckyDraw = DataLib.Action(function(luckyDrawID : string)
    assert(luckyDrawID, "Lucky Draw ID not provided!")

    Data.LuckyDraws[luckyDrawID] = nil
end)

return DataLib.StateContainer(Actions, Data)
:SetTag("NetworkDiscriminator", "LuckyDrawState")
:AddToNetwork()