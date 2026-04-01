local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local NetLibServer = require(ReplicatedStorage.TLib.NetLib.NetLibServer)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)
local ChestGameGeneral = require(ReplicatedStorage.GameDefinitions.ChestGameSystem.ChestGameGeneral)

local RE_OpenChest = NetLibServer.RemoteEvent("ChestGameSystem/OpenChest")

-- Listen for timer timeout (turn expired without action)
ChestGameState.timeoutTimer.listen(function(chestGameID: string)
    local chestGame: ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    
    if chestGame.State == "InAction" and chestGame.CurrentTurn then
        print(`Turn timeout for participant {chestGame.CurrentTurn.ParticipantID} in game {chestGameID}`)
        
        if chestGame.CurrentTurn.Decision ~= nil then
            return
        end

        -- Auto-select random chest
        local chestNum = ChestGameHelper.getRandomUnopenedChest(chestGameID, chestGame.CurrentTurn.ParticipantID)
        if not chestNum then
            print(`No available chests for participant {chestGame.CurrentTurn.ParticipantID} in game {chestGameID}`)
            return
        end
        
        print(`Auto-selected chest {chestNum} for participant {chestGame.CurrentTurn.ParticipantID} (timeout)`)
        
        ChestGameState:GetServer().openChest(chestGameID, chestGame.CurrentTurn.ParticipantID, chestNum)
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
    
    if activeChestGame.CurrentTurn == nil or activeChestGame.CurrentTurn.ParticipantID ~= activeParticipantID then
        return
    end

    if activeChestGame.CurrentTurn.Decision ~= nil then
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