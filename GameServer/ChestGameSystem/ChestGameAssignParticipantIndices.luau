local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)

-- ChestGameState.addParticipant.listen(function(chestGameID: string)
--     local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    
--     task.defer(function()
--         local index = 1
        
--         for participantID : string, participant : ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
--             ChestGameState.setParticipantIndex(chestGameID, participantID, index)

--             index += 1
--         end
--     end)
-- end)

return nil
