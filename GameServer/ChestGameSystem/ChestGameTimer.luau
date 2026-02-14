local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)

local function stopExpiredTimers()
    local currentTime = TimeLib.getTime()
    
    for chestGameID, chestGame in ChestGameState.Data.ChestGameCollection do
        if chestGame.TimerMax and chestGame.TimerMax <= currentTime then
            ChestGameState:GetServer().timeoutTimer(chestGameID)
            print(`Stopped timer for chest game {chestGameID} - timer expired`)
        end
    end
end

BootEvents.NetworkStarted:Connect(function()
    RunService.Heartbeat:Connect(stopExpiredTimers)
end)

return nil