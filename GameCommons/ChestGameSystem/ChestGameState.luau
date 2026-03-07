local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(script.Parent.ChestGameDataTypes)
local DataLib = require(ReplicatedStorage.TLib.DataLib)

local Actions, Data = {}, {
    ChestGameCollection = {} :: {ChestGameDataTypes.ChestGame}
}

Actions.setAnimationPeriod = DataLib.Action(function(chestGameID : string, currentTime : number, animationPeriod : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(currentTime, "Current time was not provided!")
    assert(animationPeriod, "Animation period was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    chestGame.AnimationEnds = currentTime + animationPeriod
end)

Actions.clearAnimationPeriod = DataLib.Action(function(chestGameID : string)
    assert(chestGameID, "Chest game ID was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    chestGame.AnimationEnds = nil
end)

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

Actions.chooseChest = DataLib.Action(function(chestGameID : string, participantID : string, chestNum : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(chestNum, "Chest number was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )

    assert(table.find(participant.ChosenChests, chestNum) == nil, `Participant {participantID} already chose chest in chest game {chestGameID}`)

    table.insert(participant.ChosenChests, chestNum)
end)

Actions.unchooseChest = DataLib.Action(function(chestGameID : string, participantID : string, chestNum : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(chestNum, "Chest number was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )

    table.remove(participant.ChosenChests, table.find(participant.ChosenChests, chestNum))
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

Actions.setParticipantMaxBadChests = DataLib.Action(function(chestGameID : string, participantID : string, maxBadChests : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(maxBadChests, "Max bad chests was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )
    
    participant.MaxBadChests = maxBadChests
end)

Actions.openChest = DataLib.Action(function(chestGameID : string, participantID : string, chestNum : number)
    assert(chestGameID, "Chest game ID was not provided!")
    assert(participantID, "Participant ID was not provided!")
    assert(chestNum, "Chest number was not provided!")

    local chestGame : ChestGameDataTypes.ChestGame = assert(
        Data.ChestGameCollection[chestGameID],
        `Chest game {chestGameID} not found!`
    )

    local _participant : ChestGameDataTypes.ChestGameParticipant = assert(
        chestGame.Participants[participantID], 
        `Participant {participantID} not found in chest game {chestGameID}!`
    )

    assert(table.find(chestGame.OpenedChests, chestNum) == nil, `Chest {chestNum} already opened in chest game {chestGameID}`)

    table.insert(chestGame.OpenedChests, chestNum)
end)

Actions.openBadChest = DataLib.Action(function(chestGameID : string, participantID : string, chestNum : number)
    -- Encapsulator action that calls openChest for bad chest context
    Actions.openChest(chestGameID, participantID, chestNum)
end)

Actions.openSafeChest = DataLib.Action(function(chestGameID : string, participantID : string, chestNum : number)
    -- Encapsulator action that calls openChest for safe chest context
    Actions.openChest(chestGameID, participantID, chestNum)
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
    
    -- Reset animation period
    chestGame.AnimationEnds = nil
end)

return DataLib.StateContainer(Actions, Data)
:SetTag("NetworkDiscriminator", "ChestGameState")
:AddToNetwork()
