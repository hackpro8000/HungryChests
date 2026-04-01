local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainCinematicController = require(ReplicatedStorage.GameClient.CinematicSystem.MainCinematicController)
local LuckyDrawScene = require(ReplicatedStorage.GameClient.CinematicSystem.Scenes.LuckyDrawScene)
local LuckyDrawEvents = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawEvents)
local LuckyDrawTypes = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawTypes)

local sceneQueue = {} :: {LuckyDrawTypes.LuckyDrawRequest}

LuckyDrawEvents.LuckyDrawConfirmed:Connect(function(luckyDrawRequest : LuckyDrawTypes.LuckyDrawRequest)
    if luckyDrawRequest:GetPlayer() ~= Players.LocalPlayer then
        return
    end

    table.insert(sceneQueue, luckyDrawRequest)
end)

task.spawn(function()
    while true do
        local luckyDrawRequest : LuckyDrawTypes.LuckyDrawRequest? = sceneQueue[1]

        if luckyDrawRequest ~= nil then
            local luckyDrawScene = LuckyDrawScene.new(MainCinematicController, luckyDrawRequest:GetLuckyDrawID(), luckyDrawRequest:GetResult())

            luckyDrawScene.OnFinish:Wait()

            table.remove(sceneQueue, 1)
        end

        task.wait(1)
    end
end)

return nil
