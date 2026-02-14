local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyDrawState = require(ReplicatedStorage.GameCommons.LuckyDrawSystem.LuckyDrawState)
local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)
local NetLibUtils = require(ReplicatedStorage.TLib.NetLib.NetLibUtils)

local RF_RequestLuckyDraw = NetLibClient.RemoteFunction("LuckyDrawSystem/RequestLuckyDraw")

local LuckyDrawNetworker = {}

function LuckyDrawNetworker.requestLuckyDraw(luckyDrawID : string, tierID : string, quantity : number)
    return NetLibUtils.Async(RF_RequestLuckyDraw, luckyDrawID, tierID, quantity)
end

return LuckyDrawNetworker
