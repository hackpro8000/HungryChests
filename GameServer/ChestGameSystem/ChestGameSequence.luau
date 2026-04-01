local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)

ChestGameState.addParticipant.listen(function(chestGameID: string, participantID: string, participant)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    if ChestGameHelper.countParticipants(chestGame) >= chestGame.MaxPlayers and chestGame.State == "Dormant" then
        ChestGameState:GetServer().changeState(chestGameID, "ChoosingChests")
    end
end)

ChestGameState.removeParticipant.listen(function(chestGameID: string, participantID: string)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    if chestGame.State ~= "Dormant" and ChestGameHelper.countParticipants(chestGame) < 2 then
        ChestGameState:GetServer().resetGame(chestGameID)
        ChestGameState:GetServer().changeState(chestGameID, "Dormant")
    end
end)

return nil
