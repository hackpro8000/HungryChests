local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)



local function makeAIParticipantsChooseChests()
    for chestGameID, chestGame in ChestGameState.Data.ChestGameCollection do
        if chestGame.State ~= "ChoosingChests" then continue end
        
        -- Collect all already chosen chests
        local chosenChests = {}
        for _, participant in chestGame.Participants do
            for _, chestNumber in participant.ChosenChests do
                chosenChests[chestNumber] = true
            end
        end
        
        -- Find available chests
        local availableChests = {}
        local totalChests = ChestGameHelper.getTotalChests(chestGame)
        for chestNumber = 1, totalChests do
            if not chosenChests[chestNumber] then
                table.insert(availableChests, chestNumber)
            end
        end
        
        -- Assign random chests to AI participants (UserID "0") who need them
        for participantID, participant in chestGame.Participants do
            if participant.UserIDString ~= "0" then continue end
            if #participant.ChosenChests >= chestGame.MaxChestChoice then continue end
            if #availableChests == 0 then break end
            
            local randomIndex = math.random(#availableChests)
            local randomChest = table.remove(availableChests, randomIndex)
            ChestGameState:GetServer().chooseChest(chestGameID, participantID, randomChest)
            print(`Chose chest {randomChest} for AI participant {participantID}`)
        end
    end
end

local function makeAIParticipantsOpenChests()
    for chestGameID, chestGame in ChestGameState.Data.ChestGameCollection do
        if chestGame.State ~= "InAction" then continue end
        
        -- Assign random chests to AI participants (UserID "0") who need them
        for participantID, participant in chestGame.Participants do
            if participant.UserIDString ~= "0" then continue end
            local chestNumber : number? = ChestGameHelper.getRandomUnopenedChest(chestGameID)
            
            if chestNumber ~= nil and chestGame.CurrentTurnParticipantID == participantID then
                ChestGameState:GetServer().openChest(chestGameID, participantID, chestNumber)
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
