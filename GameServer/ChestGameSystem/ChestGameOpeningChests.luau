local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)
local ChestGameGeneral = require(ReplicatedStorage.GameDefinitions.ChestGameSystem.ChestGameGeneral)

local RE_OpenChest = NetLibServer.RemoteEvent("ChestGameSystem/OpenChest")

-- Helper function to check if animation period is active
local function isAnimationActive(chestGame: ChestGameDataTypes.ChestGame, currentTime: number): boolean
    return chestGame.AnimationEnds ~= nil and currentTime < chestGame.AnimationEnds
end

-- Helper function to proceed to next turn after animation
local function proceedToNextTurn(chestGameID: string, currentParticipantID: string)
    local chestGame: ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    
    -- Check if game still exists and is in InAction state
    if not chestGame or chestGame.State ~= "InAction" then
        return
    end
    
    -- Clear animation period
    ChestGameState:GetServer().clearAnimationPeriod(chestGameID)
    
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
        local nextParticipantID = ChestGameHelper.getNextAliveParticipant(chestGameID, currentParticipantID)
        if nextParticipantID then
            ChestGameState:GetServer().setCurrentTurnParticipant(chestGameID, nextParticipantID)
            ChestGameState:GetServer().startTimer(chestGameID, TimeLib.getTime(), chestGame.TurnTimer)
        end
    end
end

-- Listen for openChest actions and handle all turn processing
ChestGameState.openChest.listen(function(chestGameID: string, participantID: string, chestNum: number)
    local chestGame: ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local participant = chestGame.Participants[participantID]
    
    print(`Processing chest {chestNum} opened by participant {participantID} in game {chestGameID}`)
    
    -- Cancel current timer as soon as chest is opened
    ChestGameState:GetServer().cancelTimer(chestGameID)
    
    -- Set animation period to prevent game progression
    ChestGameState:GetServer().setAnimationPeriod(chestGameID, TimeLib.getTime(), ChestGameGeneral.TURN_ANIMATION_DURATION)
    
    -- Check if chest is bad and deal damage
    local isBad = false
    for enemyParticipantID, enemyParticipant in chestGame.Participants do
        if enemyParticipantID ~= participantID then
            if table.find(enemyParticipant.ChosenChests, chestNum) then
                isBad = true
                break
            end
        end
    end
    
    -- Call appropriate encapsulator action based on chest type
    if isBad then
        ChestGameState:GetServer().openBadChest(chestGameID, participantID, chestNum)
        ChestGameState:GetServer().reduceHealthPoints(chestGameID, participantID, 1)
        print(`Participant {participantID} opened bad chest {chestNum} and lost 1 HP`)
        
        -- Check if participant is eliminated
        if participant.HealthPoints <= 0 then
            print(`Participant {participantID} eliminated!`)
            ChestGameState:GetServer().eliminateParticipant(chestGameID, participantID)
        end
    else
        ChestGameState:GetServer().openSafeChest(chestGameID, participantID, chestNum)
        print(`Participant {participantID} opened safe chest {chestNum}`)
    end
    
    -- Schedule turn progression after animation period
    task.delay(ChestGameGeneral.TURN_ANIMATION_DURATION, function()
        proceedToNextTurn(chestGameID, participantID)
    end)
end)

-- Listen for timer timeout (turn expired without action)
ChestGameState.timeoutTimer.listen(function(chestGameID: string)
    local chestGame: ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    
    if chestGame.State == "InAction" and chestGame.CurrentTurnParticipantID then
        print(`Turn timeout for participant {chestGame.CurrentTurnParticipantID} in game {chestGameID}`)
        
        -- Auto-select random chest
        local chestNum = ChestGameHelper.getRandomUnopenedChest(chestGameID)
        if not chestNum then
            print(`No available chests for participant {chestGame.CurrentTurnParticipantID} in game {chestGameID}`)
            return
        end
        
        print(`Auto-selected chest {chestNum} for participant {chestGame.CurrentTurnParticipantID} (timeout)`)
        
        -- Set animation period
        ChestGameState:GetServer().setAnimationPeriod(chestGameID, TimeLib.getTime(), ChestGameGeneral.TURN_ANIMATION_DURATION)
        
        -- Check if chest is bad and deal damage
        local isBad = false
        local participant = chestGame.Participants[chestGame.CurrentTurnParticipantID]
        for enemyParticipantID, enemyParticipant in chestGame.Participants do
            if enemyParticipantID ~= chestGame.CurrentTurnParticipantID then
                if table.find(enemyParticipant.ChosenChests, chestNum) then
                    isBad = true
                    break
                end
            end
        end
        
        -- Call appropriate encapsulator action based on chest type
        if isBad then
            ChestGameState:GetServer().openBadChest(chestGameID, chestGame.CurrentTurnParticipantID, chestNum)
            ChestGameState:GetServer().reduceHealthPoints(chestGameID, chestGame.CurrentTurnParticipantID, 1)
            print(`Participant {chestGame.CurrentTurnParticipantID} opened bad chest {chestNum} and lost 1 HP`)
            
            if participant.HealthPoints <= 0 then
                print(`Participant {chestGame.CurrentTurnParticipantID} eliminated!`)
                ChestGameState:GetServer().eliminateParticipant(chestGameID, chestGame.CurrentTurnParticipantID)
            end
        else
            ChestGameState:GetServer().openSafeChest(chestGameID, chestGame.CurrentTurnParticipantID, chestNum)
            print(`Participant {chestGame.CurrentTurnParticipantID} opened safe chest {chestNum}`)
        end
        
        -- Schedule turn progression after animation period
        task.delay(ChestGameGeneral.TURN_ANIMATION_DURATION, function()
            proceedToNextTurn(chestGameID, chestGame.CurrentTurnParticipantID)
        end)
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
    
    -- Check if animation period is active
    if isAnimationActive(activeChestGame, TimeLib.getTime()) then
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