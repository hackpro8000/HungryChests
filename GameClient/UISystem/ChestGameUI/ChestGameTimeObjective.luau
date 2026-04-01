local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ChestGameViewer = require(script.Parent.ChestGameViewer)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)

local LocalPlayer = Players.LocalPlayer

RunService.Heartbeat:Connect(function(a0: number)
    local activeChestGameID : string, activeChestGame : ChestGameDataTypes.ChestGame, activeParticipantID : string = ChestGameHelper.getPlayerChestGame(LocalPlayer)

    local objective : string? = nil
    local timeString : string? = nil

    if activeChestGame then
        if activeChestGame.State == "ChoosingChests" then
            objective = "CHOOSE YOUR CHESTS!"
        elseif activeChestGame.State == "InAction" then
            local turn : ChestGameDataTypes.ChestGameTurn = activeChestGame.CurrentTurn

            if turn and turn.ParticipantID then
                local currentParticipant = activeChestGame.Participants[turn.ParticipantID]
                if currentParticipant then
                    if turn.ParticipantID == activeParticipantID then
                        objective = "YOUR TURN"
                    else
                        -- Get player name from participant ID
                        local player = Players:GetPlayerByUserId(tonumber(currentParticipant.UserIDString))
                        local displayName = player and player.DisplayName or currentParticipant.UserIDString
                        objective = `{displayName}'s TURN`
                    end
                end
            end
        end

        if activeChestGame.TimerMax then
            timeString = `{(activeChestGame.TimerMax - TimeLib.getTime()) // 1}s`
        end
    end

    if objective then
        ChestGameViewer:SetLabel("Objective", objective)
        ChestGameViewer:SetLabelVisible("Objective", true)
    else
        ChestGameViewer:SetLabelVisible("Objective", false)
    end

    if timeString then
        ChestGameViewer:SetLabel("Time", timeString)
        ChestGameViewer:SetLabelVisible("Time", true)
    else
        ChestGameViewer:SetLabelVisible("Time", false)
    end
end)

return nil
