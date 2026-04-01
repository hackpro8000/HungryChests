local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local ChestGameGeneral = require(ReplicatedStorage.GameDefinitions.ChestGameSystem.ChestGameGeneral)
local StreamingLibServer = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibServer)
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)

local function calculateAnimationTime(chestGameID : string) : number
    assert(chestGameID, `Chest Game ID not provided!`)
    
    local animationTime = 0

    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local chestGameInstance : Model = StreamingLibServer.getInstance(chestGame.InstanceStreamableID)
    local currentTurn : ChestGameDataTypes.ChestGameTurn? = chestGame.CurrentTurn
    local turnDecision : ChestGameDataTypes.TurnDecision? = currentTurn and currentTurn.Decision
    local participantID : string? = currentTurn and currentTurn.ParticipantID
    local participant : ChestGameDataTypes.ChestGameParticipant? = participantID and chestGame.Participants[participantID]
    local seatPositionPart : Part? = participantID and ChestGameHelper.getSeatPositionPartFromParticipant(chestGameID, participantID)
    local chestNum : number? = turnDecision and turnDecision.ChestNum
    local chestPosition : Vector3? = chestNum and ChestGameHelper.getChestGridPosition(chestGame, chestNum)

    if seatPositionPart and chestPosition then
        local isBadChest : boolean = ChestGameHelper.isBadChest(chestGameID, chestNum)
        local chestCFrame : CFrame = chestGameInstance.Mat.CFrame:ToWorldSpace(CFrame.new(chestPosition))
        local distance = (seatPositionPart.Position - chestCFrame.Position).Magnitude

        animationTime += distance / 16

        if isBadChest then
            if participant.HealthPoints > 0 then
                animationTime += 7
            else
                animationTime += 8
            end
        else
            animationTime += 3
        end
    end

    return animationTime
end

local function doFirstTurn(chestGameID : string)
    local livingParticipants : {[string] : ChestGameDataTypes.ChestGameParticipant} = ChestGameHelper.getLivingParticipants(chestGameID)

    for participantID : string, participant : ChestGameDataTypes.ChestGameParticipant in livingParticipants do
        if participant.HealthPoints <= 0 then
            continue
        end

        ChestGameState:GetServer().nextTurn(chestGameID, {
            ParticipantID = participantID,
        })

        break
    end
end

local function doNextTurn(chestGameID : string)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local previousTurn : ChestGameDataTypes.ChestGameTurn? = chestGame.CurrentTurn
    
    if previousTurn == nil then
        doFirstTurn(chestGameID)
    end

    if chestGame.State ~= "InAction" then
        return
    end

    local livingParticipantIDs = ChestGameHelper.getLivingParticipantIDs(chestGameID)
    local nextKey = (table.find(livingParticipantIDs, previousTurn.ParticipantID) or 0) + 1
    local nextKeyMod = (nextKey - 1) % #livingParticipantIDs + 1
    local nextParticipantID = livingParticipantIDs[nextKeyMod]

    if #livingParticipantIDs > 1 then
        ChestGameState:GetServer().nextTurn(chestGameID, {
            ParticipantID = nextParticipantID,
        })
    else
        ChestGameState:GetServer().changeState(chestGameID, "Conclusion")
    end
end

local function onNextTurn(chestGameID : string)
    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]

    ChestGameState:GetServer().startTimer(chestGameID, TimeLib.getTime(), chestGame.TurnTimer)
end

local function onChestOpened(chestGameID: string, participantID: string, chestNum: number)
    ChestGameState:GetServer().makeTurnDecision(chestGameID, {
        ChestNum = chestNum,
    })
end

local function onTurnDecisionMade(chestGameID : string, turnDecision : ChestGameDataTypes.TurnDecision)
    task.delay(calculateAnimationTime(chestGameID), doNextTurn, chestGameID)
    ChestGameState:GetServer().cancelTimer(chestGameID)
end

local function onStateChanged(chestGameID : string, state : ChestGameDataTypes.ChestGameState)
    if state ~= "InAction" then
        return
    end

    doFirstTurn(chestGameID)
end

BootEvents.NetworkStarted:Connect(function()
    ChestGameState.nextTurn.listen(onNextTurn)
    ChestGameState.openChest.listen(onChestOpened)
    ChestGameState.changeState.listen(onStateChanged)
    ChestGameState.makeTurnDecision.listen(onTurnDecisionMade)
end)

return nil
