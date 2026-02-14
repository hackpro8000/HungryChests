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

function ChestGameHelper.getParticipantByIndex(chestGameID: string, index: number): ChestGameDataTypes.ChestGameParticipant?
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
        for _, chestNumber in participant.ChosenChests do
            chosenChests[chestNumber] = true
        end
    end
    
    -- Generate available chests (1 to total chests)
    local totalChests = chestGame.GridSizeX * chestGame.GridSizeY
    for chestNumber = 1, totalChests do
        if not chosenChests[chestNumber] then
            table.insert(availableChests, chestNumber)
        end
    end
    
    return availableChests
end

function ChestGameHelper.isChestOpened(chestGameID: string, chestNumber: number): boolean
    assert(chestGameID, "Chest game ID was not provided!")
    assert(chestNumber, "Chest number was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    return table.find(chestGame.OpenedChests or {}, chestNumber) ~= nil
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

function ChestGameHelper.isBadChest(chestGameID: string, chestNumber: number, excludeParticipantID: string?): boolean
    assert(chestGameID, "Chest game ID was not provided!")
    assert(chestNumber, "Chest number was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    -- Check if any enemy participant chose this chest
    for participantID: string, participant: ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if excludeParticipantID and participantID == excludeParticipantID then
            continue
        end
        
        if table.find(participant.ChosenChests, chestNumber) then
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

function ChestGameHelper.getChestGridPosition(chestGame: ChestGameDataTypes.ChestGame, chestNumber: number): (number, number)
    assert(chestGame, "Chest game was not provided!")
    assert(chestNumber, "Chest number was not provided!")
    assert(typeof(chestNumber) == "number", "Chest number must be a number!")
    
    local gridX = ((chestNumber-1) % chestGame.GridSizeX) * 4 - (chestGame.GridSizeX-1) * 2
    local gridY = math.floor((chestNumber-1) / chestGame.GridSizeX) * 4 - (chestGame.GridSizeY-1) * 2
    return gridX, gridY
end

function ChestGameHelper.isValidChestNumber(chestGame: ChestGameDataTypes.ChestGame, chestNumber: number): boolean
    assert(chestGame, "Chest game was not provided!")
    assert(chestNumber, "Chest number was not provided!")
    assert(typeof(chestNumber) == "number", "Chest number must be a number!")
    
    return chestNumber >= 1 and chestNumber <= ChestGameHelper.getTotalChests(chestGame)
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
    for chestNumber = 1, totalChests do
        if not table.find(chestGame.OpenedChests, chestNumber) then
            table.insert(unopenedChests, chestNumber)
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
    
    for _, chestNumber in unopenedChests do
        if not ChestGameHelper.isBadChest(chestGameID, chestNumber, excludeParticipantID) then
            table.insert(validChests, chestNumber)
        end
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