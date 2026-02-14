local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LuckyDrawRequest = require(script.Parent.LuckyDrawRequest)
local LuckyDrawEvents = require(ReplicatedStorage.GameCommons.LuckyDrawSystem.LuckyDrawEvents)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)

local RF_RequestLuckyDraw = NetLibServer.RemoteFunction("LuckyDrawSystem/RequestLuckyDraw")

function RF_RequestLuckyDraw.OnServerInvoke(player : Player, luckyDrawID : string, tierID : string, quantity : number)
    local luckyDrawRequest = LuckyDrawRequest.new(player, luckyDrawID, tierID, quantity)

    LuckyDrawEvents.LuckyDrawRequested:Fire(luckyDrawRequest)

    if luckyDrawRequest:IsConfirmed() then
        return luckyDrawRequest:GetResult()
    else
        return nil
    end
end

return nil
