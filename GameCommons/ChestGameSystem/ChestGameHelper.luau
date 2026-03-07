local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(script.Parent.ChestGameDataTypes)
local ChestGameState = require(script.Parent.ChestGameState)

local ChestGameHelper = {}

function ChestGameHelper.getPlayerChestGame(player : Player) : (string, ChestGameDataTypes.ChestGame, string)
    assert(player, "Player was not provided!")
    assert(typeof(player) == "Instance" and player:IsA("Player"), "Parameter must be a Player instance!")
    
    local playerID = tostring(player.UserId)
    
    for chestGameID, chestGame in ChestGameState.Data.ChestGameCollection do
        for participantID, participant in chestGame.Participants do
            if participant.UserIDString == playerID then
                return chestGameID, chestGame, participantID
            end
        end
    end
    
    return nil, nil, nil
end

function ChestGameHelper.countParticipants(chestGame: ChestGameDataTypes.ChestGame): number
    assert(chestGame, "Chest game was not provided!")
    assert(chestGame.Participants, "Chest game participants table was not provided!")
    
    local count = 0
    for _ in chestGame.Participants do
        count += 1
    end
    return count
end

function ChestGameHelper.countParticipantsByID(chestGameID: string): number
    assert(chestGameID, "Chest game ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    return ChestGameHelper.countParticipants(chestGame)
end

function ChestGameHelper.getParticipantByIndex(chestGameID: string, index: number): (string?, ChestGameDataTypes.ChestGameParticipant?)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(index, "Index was not provided!")
    assert(typeof(index) == "number", "Index must be a number!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    for participantID : string, participant : ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if participant.Index == index then
            return participantID, participant
        end
    end
    
    return nil
end

function ChestGameHelper.getAvailableChests(chestGameID: string): {number}
    assert(chestGameID, "Chest game ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    local chosenChests: {[number]: boolean} = {}
    local availableChests: {number} = {}
    
    -- Collect all chosen chests from all participants
    for _, participant in chestGame.Participants do
        for _, chestNum in participant.ChosenChests do
            chosenChests[chestNum] = true
        end
    end
    
    -- Generate available chests (1 to total chests)
    local totalChests = chestGame.GridSizeX * chestGame.GridSizeY
    for chestNum = 1, totalChests do
        if not chosenChests[chestNum] then
            table.insert(availableChests, chestNum)
        end
    end
    
    return availableChests
end

function ChestGameHelper.isChestOpened(chestGameID: string, chestNum: number): boolean
    assert(chestGameID, "Chest game ID was not provided!")
    assert(chestNum, "Chest number was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    return table.find(chestGame.OpenedChests or {}, chestNum) ~= nil
end

function ChestGameHelper.getActiveParticipants(chestGameID: string): {string}
    assert(chestGameID, "Chest game ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    local activeParticipants: {string} = {}
    
    for participantID: string, participant: ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if participant.HealthPoints > 0 then
            table.insert(activeParticipants, participantID)
        end
    end
    
    table.sort(activeParticipants, function(participantID0, participantID1)
        local participant0 = chestGame.Participants[participantID0]
        local participant1 = chestGame.Participants[participantID1]

        return participant0.Index < participant1.Index
    end)

    return activeParticipants
end

function ChestGameHelper.isChestOwnedByParticipant(chestGameID : string, chestNum : number, participantID : string) : boolean
    assert(chestGameID, "Chest game ID was not provided!")
    assert(chestNum, "Chest number was not provided!")
    assert(participantID, "Participant ID was not provided")

    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )  

    for participantID1: string, participant: ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if participantID1 ~= participantID then
            continue
        end
        
        if table.find(participant.ChosenChests, chestNum) then
            return true
        end
    end

    return false
end

function ChestGameHelper.isBadChest(chestGameID: string, chestNum: number, excludeParticipantID: string?): boolean
    assert(chestGameID, "Chest game ID was not provided!")
    assert(chestNum, "Chest number was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    -- Check if any enemy participant chose this chest
    for participantID: string, participant: ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if excludeParticipantID and participantID == excludeParticipantID then
            continue
        end
        
        if table.find(participant.ChosenChests, chestNum) then
            return true
        end
    end
    
    return false
end

-- Grid helper functions
function ChestGameHelper.getTotalChests(chestGame: ChestGameDataTypes.ChestGame): number
    assert(chestGame, "Chest game was not provided!")
    return chestGame.GridSizeX * chestGame.GridSizeY
end

function ChestGameHelper.getChestGridPosition(chestGame: ChestGameDataTypes.ChestGame, chestNum: number): (number, number)
    assert(chestGame, "Chest game was not provided!")
    assert(chestNum, "Chest number was not provided!")
    assert(typeof(chestNum) == "number", "Chest number must be a number!")
    
    local gridX = ((chestNum-1) % chestGame.GridSizeX) * 4 - (chestGame.GridSizeX-1) * 2
    local gridY = math.floor((chestNum-1) / chestGame.GridSizeX) * 4 - (chestGame.GridSizeY-1) * 2
    return gridX, gridY
end

function ChestGameHelper.isValidchestNum(chestGame: ChestGameDataTypes.ChestGame, chestNum: number): boolean
    assert(chestGame, "Chest game was not provided!")
    assert(chestNum, "Chest number was not provided!")
    assert(typeof(chestNum) == "number", "Chest number must be a number!")
    
    return chestNum >= 1 and chestNum <= ChestGameHelper.getTotalChests(chestGame)
end

-- Consolidated duplicate functions from other modules
function ChestGameHelper.getUnopenedChests(chestGameID: string): {number}
    assert(chestGameID, "Chest game ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    local unopenedChests: {number} = {}
    
    -- Generate all possible chests (1 to total chests)
    local totalChests = chestGame.GridSizeX * chestGame.GridSizeY
    for chestNum = 1, totalChests do
        if not table.find(chestGame.OpenedChests, chestNum) then
            table.insert(unopenedChests, chestNum)
        end
    end
    
    return unopenedChests
end

function ChestGameHelper.getRandomUnopenedChest(chestGameID: string, excludeParticipantID: string?): number?
    assert(chestGameID, "Chest game ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    local unopenedChests = ChestGameHelper.getUnopenedChests(chestGameID)
    local validChests: {number} = {}
    
    for _, chestNum in unopenedChests do
        if excludeParticipantID and ChestGameHelper.isChestOwnedByParticipant(chestGameID, chestNum, excludeParticipantID) then
            continue
        end

        table.insert(validChests, chestNum)
    end
    
    if #validChests == 0 then
        return nil
    end
    
    return validChests[math.random(#validChests)]
end

function ChestGameHelper.getNextAliveParticipant(chestGameID: string, currentParticipantID: string): string?
    assert(chestGameID, "Chest game ID was not provided!")
    assert(currentParticipantID, "Current participant ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    local currentParticipant = chestGame.Participants[currentParticipantID]
    assert(currentParticipant, `Current participant {currentParticipantID} not found in chest game {chestGameID}!`)
    
    local activeParticipants = ChestGameHelper.getActiveParticipants(chestGameID)
    if #activeParticipants <= 1 then
        return nil
    end
    
    -- Find current participant in active list
    local currentIndex = currentParticipant.Index
    
    -- Get next participant (wrap around)
    local nextIndex = (((currentIndex+1)-1) % #activeParticipants) + 1
    return activeParticipants[nextIndex] or activeParticipants[math.random(1, #activeParticipants)]
end

return ChestGameHelper