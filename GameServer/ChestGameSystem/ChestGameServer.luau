local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local ChestGameServer = {}

function ChestGameServer.chooseChestRegulated(chestGameID : string, participantID : string, chestNum : number)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local participant = chestGame.Participants[participantID]
    local participantCount : number = ChestGameHelper.countParticipantsByID(chestGameID)
    local participantIndex : number = ((chestNum-1) % participantCount) + 1

    assert(#participant.ChosenChests < chestGame.MaxChestChoice, `Cannot choose more than {chestGame.MaxChestChoice} chests!`)

    for participantID1 : string, participant1 : ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if participantID1 == participantID then
            continue
        end

        if table.find(participant1.ChosenChests, chestNum) then
            -- Conflict detected - randomize the existing participant's choice
            local availableChests = ChestGameHelper.getAvailableChests(chestGameID)
            
            -- Remove the conflicting chest from available choices
            local conflictFreeChests = {}
            for _, chestNum in availableChests do
                if chestNum ~= chestNum then
                    table.insert(conflictFreeChests, chestNum)
                end
            end
            
            if #conflictFreeChests >= 1 then
                -- Randomize the existing participant's choice
                local newChest = conflictFreeChests[math.random(#conflictFreeChests)]
                
                -- Remove existing conflicting choice
                ChestGameState:GetServer().unchooseChest(chestGameID, participantID1, chestNum)
                
                -- Assign new random choice to existing participant
                ChestGameState:GetServer().chooseChest(chestGameID, participantID1, newChest)
                
                -- Overwrite chestNum for the current participant's choice
                table.remove(conflictFreeChests, table.find(conflictFreeChests, newChest))
                chestNum = conflictFreeChests[math.random(#conflictFreeChests)]
            end
        end
    end

    ChestGameState:GetServer().chooseChest(chestGameID, participantID, chestNum)
end

function ChestGameServer.openChestRegulated(chestGameID : string, participantID : string, chestNum : number)
    
end

return ChestGameServer
