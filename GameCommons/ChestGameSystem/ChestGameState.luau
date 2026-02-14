local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(script.Parent.ChestGameDataTypes)
local DataLib = require(ReplicatedStorage.TLib.DataLib)

local Actions, Data = {}, {
    ChestGameCollection = {} :: {ChestGameDataTypes.ChestGame}
}

Actions.createChestGame = DataLib.Action(function(chestGameID : string, chestGame : ChestGameDataTypes.ChestGame)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(chestGame, "Chest game was not provided!")

    Data.ChestGameCollection[chestGameID] = chestGame
end)

Actions.changeState = DataLib.Action(function(chestGameID : string, state : "Dormant" | "ChoosingChests" | "InAction" | "Conclusion")
    assert(chestGameID, "Chest game ID was not provided!")
    assert(state, "State not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    chestGame.State = state
end)

Actions.startTimer = DataLib.Action(function(chestGameID : string, startTime : number, duration : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(startTime, "Start time was not provided!")
    assert(duration, "Duration was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    chestGame.TimerMin = startTime
    chestGame.TimerMax = startTime + duration
end)

Actions.stopTimer = DataLib.Action(function(chestGameID : string)
    assert(chestGameID, "Chest game ID was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    chestGame.TimerMin = nil
    chestGame.TimerMax = nil
end)

Actions.chooseChest = DataLib.Action(function(chestGameID : string, participantID : string, chestNumber : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(chestNumber, "Chest number was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )

    assert(table.find(participant.ChosenChests, chestNumber) == nil, `Participant {participantID} already chose chest in chest game {chestGameID}`)

    table.insert(participant.ChosenChests, chestNumber)
end)

Actions.unchooseChest = DataLib.Action(function(chestGameID : string, participantID : string, chestNumber : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(chestNumber, "Chest number was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )

    table.remove(participant.ChosenChests, table.find(participant.ChosenChests, chestNumber))
end)

Actions.addParticipant = DataLib.Action(function(chestGameID : string, participantID : string, participant : ChestGameDataTypes.ChestGameParticipant)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(participant, "Participant was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    assert(chestGame.Participants[participantID] == nil, `Participant {participantID} already exists in chest game {chestGameID}!`)

    chestGame.Participants[participantID] = participant
end)

Actions.removeParticipant = DataLib.Action(function(chestGameID : string, participantID : string)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local _participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )
    
    chestGame.Participants[participantID] = nil
end)

Actions.setParticipantIndex = DataLib.Action(function(chestGameID : string, participantID : string, index : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(index, "Index was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )
    
    participant.Index = index
end)

Actions.openChest = DataLib.Action(function(chestGameID : string, participantID : string, chestNumber : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(chestNumber, "Chest number was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local _participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )

    assert(table.find(chestGame.OpenedChests, chestNumber) == nil, `Chest {chestNumber} already opened in chest game {chestGameID}`)

    table.insert(chestGame.OpenedChests, chestNumber)
end)

Actions.setCurrentTurnParticipant = DataLib.Action(function(chestGameID : string, participantID : string?)
    assert(chestGameID, "Chest game ID was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    chestGame.CurrentTurnParticipantID = participantID
end)

Actions.reduceHealthPoints = DataLib.Action(function(chestGameID : string, participantID : string, damage : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(damage, "Damage was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )

    participant.HealthPoints = math.max(0, participant.HealthPoints - damage)
end)

Actions.eliminateParticipant = DataLib.Action(function(chestGameID : string, participantID : string)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )

    participant.HealthPoints = 0
end)

Actions.cancelTimer = DataLib.Action(function(chestGameID : string)
    assert(chestGameID, "Chest game ID was not provided!")
    
    local _chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    -- Delegate to stopTimer action
    Actions.stopTimer(chestGameID)
end)

Actions.timeoutTimer = DataLib.Action(function(chestGameID : string)
    assert(chestGameID, "Chest game ID was not provided!")
    
    local _chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )
    
    -- Delegate to stopTimer action
    Actions.stopTimer(chestGameID)
end)

Actions.resetGame = DataLib.Action(function(chestGameID : string)
    assert(chestGameID, "Chest game ID was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    -- Reset opened chests
    chestGame.OpenedChests = {}
    
    -- Reset current turn participant
    chestGame.CurrentTurnParticipantID = nil
    
    -- Reset timer
    chestGame.TimerMin = nil
    chestGame.TimerMax = nil
end)

return DataLib.StateContainer(Actions, Data)
:SetTag("NetworkDiscriminator", "ChestGameState")
:AddToNetwork()
