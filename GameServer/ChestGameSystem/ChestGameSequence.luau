local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local StreamingLib = require(ReplicatedStorage.TLib.StreamingLib)

ChestGameState.addParticipant.listen(function(chestGameID: string, participantID: string, participant)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    if ChestGameHelper.countParticipants(chestGame) >= chestGame.MaxPlayers and chestGame.State == "Dormant" then
        task.defer(function()
            ChestGameState:GetServer().changeState(chestGameID, "ChoosingChests")
        end)
        print(`Choosing chests! ({chestGame.MaxPlayers} players ready)`)
    end
end)

ChestGameState.removeParticipant.listen(function(chestGameID: string, participantID: string)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    if chestGame.State ~= "Dormant" then
        task.defer(function()
            ChestGameState:GetServer().changeState(chestGameID, "Dormant")
        end)
    end
end)

return nil
