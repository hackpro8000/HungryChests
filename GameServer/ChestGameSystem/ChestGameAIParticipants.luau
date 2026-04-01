local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameServer = require(script.Parent.ChestGameServer)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)
local ChestGameGeneral = require(ReplicatedStorage.GameDefinitions.ChestGameSystem.ChestGameGeneral)

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
        if ChestGameHelper.isAnimationActive(chestGame, TimeLib.getTime()) then
            continue
        end

        if chestGame.CurrentTurn == nil then
            continue
        end
        
        -- Assign random chests to AI participants (UserID "0") who need them
        for participantID, participant in chestGame.Participants do
            if participant.UserIDString ~= "0" then continue end
            
            local chestNum : number? = ChestGameHelper.getRandomUnopenedChest(chestGameID, participantID)
            
            if chestNum == nil or chestGame.CurrentTurn.ParticipantID ~= participantID then
                continue
            end

            if chestGame.CurrentTurn.Decision then
                continue
            end

            -- Cancel current timer and set animation period (same as player action)
            ChestGameState:GetServer().cancelTimer(chestGameID)
            ChestGameState:GetServer().openChest(chestGameID, participantID, chestNum)
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
