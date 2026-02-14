local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)

-- Listen for state changes to handle Conclusion phase
ChestGameState.changeState.listenInOrder(2, function(chestGameID: string, newState: ChestGameDataTypes.ChestGameState)
    if newState ~= "Conclusion" then
        return
    end
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    -- Announce winner if there is one
    local aliveParticipants = {}
    for participantID, participant in chestGame.Participants do
        if participant.HealthPoints > 0 then
            table.insert(aliveParticipants, participantID)
        end
    end
    
    if #aliveParticipants == 1 then
        local winnerID = aliveParticipants[1]
        local winner = chestGame.Participants[winnerID]
        local winnerPlayer = Players:GetPlayerByUserId(tonumber(winner.UserIDString))
        
        if winnerPlayer then
            print(`Player {winnerPlayer.Name} won the chest game {chestGameID}!`)
            -- TODO: Add victory effects/celebration here
        end
    end
    
    -- Wait for celebration/draw message
    task.wait(3)
    
    -- Reset game state for next round
    ChestGameState:GetServer().resetGame(chestGameID)
    
    -- Transition to Dormant state for cleanup
    ChestGameState:GetServer().changeState(chestGameID, "Dormant")
end)

return nil