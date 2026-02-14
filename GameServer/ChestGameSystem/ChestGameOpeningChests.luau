local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)

local RE_OpenChest = NetLibServer.RemoteEvent("ChestGameSystem/OpenChest")

-- Listen for openChest actions and handle all turn processing
ChestGameState.openChest.listen(function(chestGameID: string, participantID: string, chestNumber: number)
    local chestGame: ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local participant = chestGame.Participants[participantID]
    
    print(`Processing chest {chestNumber} opened by participant {participantID} in game {chestGameID}`)
    
    -- Cancel current timer as soon as chest is opened
    ChestGameState:GetServer().cancelTimer(chestGameID)
    
    -- Check if chest is bad and deal damage
    local isBad = false
    for enemyParticipantID, enemyParticipant in chestGame.Participants do
        if enemyParticipantID ~= participantID then
            if table.find(enemyParticipant.ChosenChests, chestNumber) then
                isBad = true
                break
            end
        end
    end
    
    if isBad then
        ChestGameState:GetServer().reduceHealthPoints(chestGameID, participantID, 1)
        print(`Participant {participantID} opened bad chest {chestNumber} and lost 1 HP`)
        
        -- Check if participant is eliminated
        if participant.HealthPoints <= 0 then
            print(`Participant {participantID} eliminated!`)
            ChestGameState:GetServer().eliminateParticipant(chestGameID, participantID)
        end
    else
        print(`Participant {participantID} opened safe chest {chestNumber}`)
    end
    
    -- Check win conditions and transition to Conclusion if needed
    local aliveParticipants = {}
    for participantID, participant1 in chestGame.Participants do
        if participant1.HealthPoints > 0 then
            table.insert(aliveParticipants, participantID)
        end
    end
    
    -- If 0 or 1 participants left, transition to Conclusion
    if #aliveParticipants <= 1 then
        ChestGameState:GetServer().changeState(chestGameID, "Conclusion")
        ChestGameState:GetServer().setCurrentTurnParticipant(chestGameID, nil)
    else
        -- Get next participant
        local nextParticipantID = ChestGameHelper.getNextAliveParticipant(chestGameID, participantID)
        if nextParticipantID then
            ChestGameState:GetServer().setCurrentTurnParticipant(chestGameID, nextParticipantID)
            ChestGameState:GetServer().startTimer(chestGameID, TimeLib.getTime(), chestGame.TurnTimer)
            print(`Next turn: {nextParticipantID}`)
        end

        print(nextParticipantID)
    end
end)

-- Listen for timer timeout (turn expired without action)
ChestGameState.timeoutTimer.listen(function(chestGameID: string)
    local chestGame: ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    
    if chestGame.State == "InAction" and chestGame.CurrentTurnParticipantID then
        print(`Turn timeout for participant {chestGame.CurrentTurnParticipantID} in game {chestGameID}`)
        
        -- Auto-select random chest
        local chestNumber = ChestGameHelper.getRandomUnopenedChest(chestGameID)
        if not chestNumber then
            print(`No available chests for participant {chestGame.CurrentTurnParticipantID} in game {chestGameID}`)
            return
        end
        
        print(`Auto-selected chest {chestNumber} for participant {chestGame.CurrentTurnParticipantID} (timeout)`)
        
        -- Open the chest and let the action listener handle timer cancellation and processing
        ChestGameState:GetServer().openChest(chestGameID, chestGame.CurrentTurnParticipantID, chestNumber)
    end
end)

-- Listen for state changes to InAction
ChestGameState.changeState.listen(function(chestGameID: string, state: "ChoosingChests" | "Dormant" | "InAction")
    if state == "InAction" then
        local chestGame: ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
        
        -- Initialize opened chests if needed
        if not chestGame.OpenedChests then
            chestGame.OpenedChests = {}
        end
        
        -- Find first alive participant to start
        for participantID, participant in chestGame.Participants do
            if participant.HealthPoints > 0 then
                ChestGameState:GetServer().setCurrentTurnParticipant(chestGameID, participantID)
                ChestGameState:GetServer().startTimer(chestGameID, TimeLib.getTime(), chestGame.TurnTimer)
                print(`InAction started! First turn: {participantID}`)
                break
            end
        end
    end
end)

-- Handle player chest opening actions
RE_OpenChest.OnServerEvent:Connect(function(player: Player, chestNum: number)
    assert(chestNum, "Chest number not provided!")

    local activeChestGameID: string, activeChestGame: ChestGameDataTypes.ChestGame, activeParticipantID: string = ChestGameHelper.getPlayerChestGame(player)
    
    assert(activeChestGameID, `Couldn't find active chest game for player {player.Name}!`)
    assert(activeParticipantID, `Player {player.Name} is not actively participating in chest game {activeChestGameID}!`)
    
    local activeParticipant = activeChestGame.Participants[activeParticipantID]
    
    -- Validate it's this participant's turn and game is in InAction state
    if activeChestGame.State ~= "InAction" then
        return
    end
    
    if activeChestGame.CurrentTurnParticipantID ~= activeParticipantID then
        return
    end
    
    -- Validate chest isn't already opened
    if table.find(activeChestGame.OpenedChests or {}, chestNum) then
        return
    end
    
    -- Prevent player from opening their own dangerous chest
    if table.find(activeParticipant.ChosenChests, chestNum) then
        return
    end
    
    -- Open the chest (action listener will handle timer cancellation and processing)
    ChestGameState:GetServer().openChest(activeChestGameID, activeParticipantID, chestNum)
end)

return nil