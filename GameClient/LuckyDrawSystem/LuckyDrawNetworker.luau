local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyDrawEvents = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawEvents)
local LuckyDrawRequest = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawRequest)
local LuckyDrawTypes = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawTypes)
local LuckyDrawState = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawState)
local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)
local NetLibUtils = require(ReplicatedStorage.TLib.NetLib.NetLibUtils)

local RF_RequestLuckyDraw = NetLibClient.RemoteFunction("LuckyDrawSystem/RequestLuckyDraw")
local RE_LuckyDrawConfirmed = NetLibClient.RemoteEvent("LuckyDrawSystem/LuckyDrawConfirmed")

local LuckyDrawNetworker = {}


function LuckyDrawNetworker.requestLuckyDraw(luckyDrawID : string, tierID : string, quantity : number)
    return NetLibUtils.Async(RF_RequestLuckyDraw, luckyDrawID, tierID, quantity)
end

RE_LuckyDrawConfirmed.OnClientEvent:Connect(function(rawLuckyDrawRequest)
    local luckyDrawRequest : LuckyDrawTypes.LuckyDrawRequest = setmetatable(rawLuckyDrawRequest, LuckyDrawRequest)

    LuckyDrawEvents.LuckyDrawConfirmed:Fire(luckyDrawRequest)
end)

return LuckyDrawNetworker
