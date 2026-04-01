local GetFromProbabilityMap = require(script.Parent.GetFromProbabilityMap)
local LuckyDrawState = require(script.Parent.LuckyDrawState)
local LuckyDrawTypes = require(script.Parent.LuckyDrawTypes)

local LuckyDrawHelper = {}

function LuckyDrawHelper.getProbabilityMap(luckyDrawID : LuckyDrawTypes.LuckyDraw, tierID : string) : {[string] : number}
    local luckyDraw : LuckyDrawTypes.LuckyDraw = LuckyDrawState.Data.LuckyDraws[luckyDrawID]
    local tier : LuckyDrawTypes.LuckyDrawTier = luckyDraw.Tiers[tierID]
    local pool : LuckyDrawTypes.LuckyDrawPool = luckyDraw.Pools[tier.PoolID]

    local probabilityMap = {}

    for prizeID : string, rarityID : string in pool do
        probabilityMap[prizeID] = tier.RarityMap[rarityID]
    end

    return probabilityMap
end

function LuckyDrawHelper.evaluateLuckyDrawRequest(luckyDrawRequest : LuckyDrawTypes.LuckyDrawRequest) : {string}
    local results = {}

    local luckyDrawID = luckyDrawRequest:GetLuckyDrawID()
    local tierID = luckyDrawRequest:GetTierID()
    local probabilityMap = LuckyDrawHelper.getProbabilityMap(luckyDrawID, tierID)

    for i = 1, luckyDrawRequest:GetQuantity() do
        table.insert(results, GetFromProbabilityMap(probabilityMap))
    end

    return results
end

return LuckyDrawHelper
