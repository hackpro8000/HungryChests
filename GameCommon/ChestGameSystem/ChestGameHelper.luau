local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StreamingLib = require(ReplicatedStorage.TLib.StreamingLib)
local ChestGameDataTypes = require(script.Parent.ChestGameDataTypes)
local ChestGameState = require(script.Parent.ChestGameState)

local Helper = {}

function Helper.getPlayerChestGame(player : Player) : (string, ChestGameDataTypes.ChestGame, string)
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

function Helper.requireChestGame(chestGameID : string)
    assert(chestGameID, "Chest game ID was not provided!")

    return assert(
        ChestGameState.Data.ChestGameCollection[chestGameID], 
        `Couldn't find chest game {chestGameID}`
    )
end

function Helper.requireParticipant(chestGameID : string, participantID : string) : ChestGameDataTypes.ChestGameParticipant
    assert(participantID, `Participant ID was not provided!`)
    
    return assert(
        Helper.requireChestGame(chestGameID).Participants[participantID], 
        `Couldn't find participant {participantID} in chest game {chestGameID}`
    )
end

function Helper.participantHasEffect(chestGameID : string, participantID : string, effectID : string) : boolean
    local participant : ChestGameDataTypes.ChestGameParticipant? = Helper.requireParticipant(chestGameID, participantID)

    return participant.Effects[effectID] == true
end

function Helper.countParticipants(chestGame: ChestGameDataTypes.ChestGame): number
    assert(chestGame, "Chest game was not provided!")
    assert(chestGame.Participants, "Chest game participants table was not provided!")
    
    local count = 0
    for _ in chestGame.Participants do
        count += 1
    end
    return count
end

function Helper.countParticipantsByID(chestGameID: string): number
    assert(chestGameID, "Chest game ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    return Helper.countParticipants(chestGame)
end

function Helper.getParticipantByIndex(chestGameID: string, index: number): (string?, ChestGameDataTypes.ChestGameParticipant?)
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

function Helper.getSeatPositionPartFromParticipant(chestGameID : string, participantID : string) : Part?
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(ChestGameState.Data.ChestGameCollection[chestGameID], `Chest Game (ID: {chestGameID}) not found`)
    local participant : ChestGameDataTypes.ChestGameParticipant = assert(chestGame.Participants[participantID], `Participant (ID : {participantID}) not found in Chest Game (ID : {chestGameID})`)

    local chestGameInstance = StreamingLib.getInstance(chestGame.InstanceStreamableID)

    local seatPositionsFolder : Folder = chestGameInstance.SeatPositions
    local seatPosition : Part? = nil

    for _, seatPosition1 : Part in seatPositionsFolder:GetChildren() do
        if seatPosition1:GetAttribute("ParticipantIndex") == participant.Index then
            seatPosition = seatPosition1
        end
    end

    return seatPosition
end

function Helper.getAvailableChests(chestGameID: string): {number}
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

function Helper.isChestOpened(chestGameID: string, chestNum: number): boolean
    assert(chestGameID, "Chest game ID was not provided!")
    assert(chestNum, "Chest number was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    return table.find(chestGame.OpenedChests or {}, chestNum) ~= nil
end

function Helper.getParticipantIDs(chestGameID : string) : {string}
    assert(chestGameID, "Chest game ID was not provided!")
    
    local participantIDs = {} :: {string}
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    for participantID : string in chestGame.Participants do
        table.insert(participantIDs, participantID)
    end

    return participantIDs
end

function Helper.getIndexSortedParticipantIDs(chestGameID : string)
    assert(chestGameID, "Chest game ID was not provided!")

    return Helper.sortParticipantIDsByIndex(
        chestGameID,
        Helper.getParticipantIDs(chestGameID)
    )
end

function Helper.sortParticipantIDsByIndex(chestGameID : string, participantIDsToSort : {string}) : {string}
    local participantIDs = {} :: {string}
    local participantIDsByIndex = {} :: {[number] : string}

    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    --[[
        This loop sorts the participant IDs by index
    ]]
    for _, participantID in participantIDsToSort do
        local participant: ChestGameDataTypes.ChestGameParticipant = chestGame.Participants[participantID]

        participantIDsByIndex[participant.Index] = participantID
    end

    --[[
        This loop eliminates gaps
    ]]
    for i, participantID in participantIDsByIndex do
        table.insert(participantIDs, participantID)
    end

    return participantIDs
end

function Helper.getLivingParticipants(chestGameID: string): {[string]: ChestGameDataTypes.ChestGameParticipant}
    assert(chestGameID, "Chest game ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    local aliveParticipants: {string} = {}
    
    for participantID: string, participant: ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if participant.HealthPoints > 0 then
            aliveParticipants[participantID] = participant
        end
    end

    return aliveParticipants
end

function Helper.getLivingParticipantIDs(chestGameID: string): {string}
    assert(chestGameID, "Chest game ID was not provided!")
    
    local chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    local aliveParticipantIDs: {string} = {}
    
    for participantID: string, participant: ChestGameDataTypes.ChestGameParticipant in chestGame.Participants do
        if participant.HealthPoints > 0 then
            table.insert(aliveParticipantIDs, participantID)
        end
    end

    return aliveParticipantIDs
end

function Helper.isChestOwnedByParticipant(chestGameID : string, chestNum : number, participantID : string) : boolean
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

function Helper.isBadChest(chestGameID: string, chestNum: number, excludeParticipantID: string?): boolean
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

function Helper.getTotalChests(chestGame: ChestGameDataTypes.ChestGame): number
    assert(chestGame, "Chest game was not provided!")
    return chestGame.GridSizeX * chestGame.GridSizeY
end

function Helper.getChestGridXY(chestGame: ChestGameDataTypes.ChestGame, chestNum: number): (number, number)
    assert(chestGame, "Chest game was not provided!")
    assert(chestNum, "Chest number was not provided!")
    assert(typeof(chestNum) == "number", "Chest number must be a number!")
    
    local gridX = ((chestNum-1) % chestGame.GridSizeX) * 4 - (chestGame.GridSizeX-1) * 2
    local gridY = math.floor((chestNum-1) / chestGame.GridSizeX) * 4 - (chestGame.GridSizeY-1) * 2
    return gridX, gridY
end

function Helper.getChestGridPosition(chestGame : ChestGameDataTypes.ChestGame, chestNum : number): Vector3
    local x, y = Helper.getChestGridXY(chestGame, chestNum)

    return Vector3.new(x,0,y)
end

function Helper.isValidchestNum(chestGame: ChestGameDataTypes.ChestGame, chestNum: number): boolean
    assert(chestGame, "Chest game was not provided!")
    assert(chestNum, "Chest number was not provided!")
    assert(typeof(chestNum) == "number", "Chest number must be a number!")
    
    return chestNum >= 1 and chestNum <= Helper.getTotalChests(chestGame)
end

function Helper.getUnopenedChests(chestGameID: string): {number}
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

function Helper.getRandomUnopenedChest(chestGameID: string, excludeParticipantID: string?): number?
    assert(chestGameID, "Chest game ID was not provided!")
    
    local _chestGame: ChestGameDataTypes.ChestGame = assert(
        ChestGameState.Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    local unopenedChests = Helper.getUnopenedChests(chestGameID)
    local validChests: {number} = {}
    
    for _, chestNum in unopenedChests do
        if excludeParticipantID and Helper.isChestOwnedByParticipant(chestGameID, chestNum, excludeParticipantID) then
            continue
        end

        table.insert(validChests, chestNum)
    end
    
    if #validChests == 0 then
        return nil
    end
    
    return validChests[math.random(#validChests)]
end

function Helper.isAnimationActive(chestGame: ChestGameDataTypes.ChestGame, currentTime: number): boolean
    assert(chestGame, "Chest game was not provided!")
    assert(currentTime, "Current time was not provided!")
    assert(typeof(currentTime) == "number", "Current time must be a number!")
    
    return chestGame.AnimationEnds ~= nil and currentTime < chestGame.AnimationEnds
end

return Helper