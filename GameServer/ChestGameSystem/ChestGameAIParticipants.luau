local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameServer = require(script.Parent.ChestGameServer)
local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)
local ChestGameGeneral = require(ReplicatedStorage.GameDefinitions.ChestGameSystem.ChestGameGeneral)

-- Helper function to check if animation period is active
local function isAnimationActive(chestGame: ChestGameDataTypes.ChestGame, currentTime: number): boolean
    return chestGame.AnimationEnds ~= nil and currentTime < chestGame.AnimationEnds
end

local function makeAIParticipantsChooseChests()
    for chestGameID, chestGame in ChestGameState.Data.ChestGameCollection do
        if chestGame.State ~= "ChoosingChests" then continue end
        
        -- Collect all already chosen chests
        local chosenChests = {}
        for _, participant in chestGame.Participants do
            for _, chestNum in participant.ChosenChests do
                chosenChests[chestNum] = true
            end
        end
        
        -- Find available chests
        local availableChests = {}
        local totalChests = ChestGameHelper.getTotalChests(chestGame)
        for chestNum = 1, totalChests do
            if not chosenChests[chestNum] then
                table.insert(availableChests, chestNum)
            end
        end
        
        -- Assign random chests to AI participants (UserID "0") who need them
        for participantID, participant in chestGame.Participants do
            if participant.UserIDString ~= "0" then continue end
            if #participant.ChosenChests >= chestGame.MaxChestChoice then continue end
            if #availableChests == 0 then break end
            
            local randomIndex = math.random(#availableChests)
            local randomChest = table.remove(availableChests, randomIndex)
            -- ChestGameState:GetServer().chooseChest(chestGameID, participantID, randomChest)
            ChestGameServer.chooseChestRegulated(chestGameID, participantID, randomChest)
            print(`Chose chest {randomChest} for AI participant {participantID}`)
        end
    end
end

local function makeAIParticipantsOpenChests()
    for chestGameID, chestGame in ChestGameState.Data.ChestGameCollection do
        if chestGame.State ~= "InAction" then continue end
        
        -- Check if animation period is active
        if isAnimationActive(chestGame, TimeLib.getTime()) then
            continue
        end
        
        -- Assign random chests to AI participants (UserID "0") who need them
        for participantID, participant in chestGame.Participants do
            if participant.UserIDString ~= "0" then continue end
            local chestNum : number? = ChestGameHelper.getRandomUnopenedChest(chestGameID, participantID)
            
            if chestNum ~= nil and chestGame.CurrentTurnParticipantID == participantID then
                -- Cancel current timer and set animation period (same as player action)
                ChestGameState:GetServer().cancelTimer(chestGameID)
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
                
                -- Call appropriate encapsulator action
                if isBad then
                    ChestGameState:GetServer().openBadChest(chestGameID, participantID, chestNum)
                    ChestGameState:GetServer().reduceHealthPoints(chestGameID, participantID, 1)
                    print(`AI Participant {participantID} opened bad chest {chestNum} and lost 1 HP`)
                    
                    if participant.HealthPoints <= 1 then -- Check before damage since we haven't applied it yet
                        print(`AI Participant {participantID} eliminated!`)
                        ChestGameState:GetServer().eliminateParticipant(chestGameID, participantID)
                    end
                else
                    ChestGameState:GetServer().openSafeChest(chestGameID, participantID, chestNum)
                    print(`AI Participant {participantID} opened safe chest {chestNum}`)
                end
                
                -- Schedule turn progression after animation period
                task.delay(ChestGameGeneral.TURN_ANIMATION_DURATION, function()
                    -- Use the same turn progression logic as server
                    local chestGameForTurn = ChestGameState.Data.ChestGameCollection[chestGameID]
                    if not chestGameForTurn or chestGameForTurn.State ~= "InAction" then
                        return
                    end
                    
                    -- Clear animation period
                    ChestGameState:GetServer().clearAnimationPeriod(chestGameID)
                    
                    -- Check win conditions and transition to Conclusion if needed
                    local aliveParticipants = {}
                    for participantID, participant1 in chestGameForTurn.Participants do
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
                            ChestGameState:GetServer().startTimer(chestGameID, TimeLib.getTime(), chestGameForTurn.TurnTimer)
                        end
                    end
                end)
            end
        end
    end
end

local function exhaust()
    task.wait(0.5)
end

local function handleAI()
    while true do
        makeAIParticipantsChooseChests()
        makeAIParticipantsOpenChests()
        exhaust()
    end
end

BootEvents.NetworkStarted:Connect(function()
    task.spawn(handleAI)
end)

return nil
