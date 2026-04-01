local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyDrawEvents = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawEvents)
local LuckyDrawRequest = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawRequest)
local LuckyDrawTypes = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawTypes)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)

local RF_RequestLuckyDraw = NetLibServer.RemoteFunction("LuckyDrawSystem/RequestLuckyDraw")
local RE_LuckyDrawConfirmed = NetLibServer.RemoteEvent("LuckyDrawSystem/LuckyDrawConfirmed")

function RF_RequestLuckyDraw.OnServerInvoke(player : Player, luckyDrawID : string, tierID : string, quantity : number)
    local luckyDrawRequest = LuckyDrawRequest.new(player, luckyDrawID, tierID, quantity)

    LuckyDrawEvents.LuckyDrawRequested:Fire(luckyDrawRequest)

    if luckyDrawRequest:IsConfirmed() then
        return luckyDrawRequest:GetResult()
    else
        return nil
    end
end

LuckyDrawEvents.LuckyDrawConfirmed:Connect(function(luckyDrawRequest : LuckyDrawTypes.LuckyDrawRequest)
    RE_LuckyDrawConfirmed:FireAllClients(luckyDrawRequest)
end)

return nil
