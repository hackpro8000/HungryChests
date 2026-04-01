local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)

-- Listen for state changes and reset when reverting to Dormant
ChestGameState.changeState.listen(function(chestGameID: string, newState: ChestGameDataTypes.ChestGameState)
    if newState ~= "Dormant" then
        return
    end

    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    -- Remove all participants
    local participantsToRemove = {}
    for participantID, participant in chestGame.Participants do
        table.insert(participantsToRemove, participantID)
    end
    
    for _, participantID in participantsToRemove do
        local participant = chestGame.Participants[participantID]
        if not participant then continue end
        
        -- Player participant - reload character
        if participant.UserIDString ~= "0" then
            local player = Players:GetPlayerByUserId(tonumber(participant.UserIDString))
            if player then
                player:LoadCharacterAsync()
            end
        end
        
        -- Remove participant from chest game
        ChestGameState:GetServer().removeParticipant(chestGameID, participantID)
    end
end)

return nil