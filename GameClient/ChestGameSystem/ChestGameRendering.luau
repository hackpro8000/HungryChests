local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)
local AnimatedChest = require(script.Parent.AnimatedChest)
local IChestGameRenderer = require(script.Parent.IChestGameRenderer)
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)

local AnimatedChests = {}

local function loadChestAnimations(animatedChest : AnimatedChest.AnimatedChest)
    local animationsFolder = ReplicatedStorage.Resources.Animations.Chests:FindFirstChild(animatedChest.ChestType)

    if animationsFolder == nil then
        return
    end
    
    animatedChest:LoadAnimation(animationsFolder:FindFirstChild("ChestOpen"), "ChestOpen").Looped = false
    animatedChest:LoadAnimation(animationsFolder:FindFirstChild("PlayerChomp"), "PlayerChomp").Looped = false
    animatedChest:LoadAnimation(animationsFolder:FindFirstChild("PlayerEaten"), "PlayerEaten").Looped = false
end

local function createAnimatedChests(chestGameID : string)
    if AnimatedChests[chestGameID] then
        return
    end
    
    AnimatedChests[chestGameID] = {}

    local chestGame : ChestGameDataTypes.ChestGame = ChestGameState.Data.ChestGameCollection[chestGameID]
    local chestGameInstance : Model? = StreamingLibClient.getInstance(chestGame.InstanceStreamableID)
    local totalChests : number = ChestGameHelper.getTotalChests(chestGame)
    local participantCount : number = ChestGameHelper.countParticipants(chestGame)

    if chestGameInstance == nil then
        return
    end

    for chestNum : number = 1, totalChests do
        local gridX : number, gridY : number = ChestGameHelper.getChestGridPosition(chestGame, chestNum)
        local vectorOffset : Vector3 = Vector3.new(gridX, 0, gridY)
        local cframe : CFrame = chestGameInstance.Mat.CFrame * CFrame.new(vectorOffset) * CFrame.Angles(0, math.pi, 0)
        local participantIndex : number = ((chestNum-1) % participantCount) + 1
        local _, participant : ChestGameDataTypes.ChestGameParticipant? = ChestGameHelper.getParticipantByIndex(chestGameID, participantIndex)
        local chestType : string = participant.ChestType

        local animatedChest : AnimatedChest.AnimatedChest = AnimatedChest.new(chestType)
        animatedChest:SetRenderCFrame(cframe)
        animatedChest:SetRenderParent(chestGameInstance)
        animatedChest:Render()
        loadChestAnimations(animatedChest)

        AnimatedChests[chestGameID][chestNum] = animatedChest
    end
end

local function clearAnimatedChests(chestGameID : string)
    if AnimatedChests[chestGameID] == nil then
        return
    end
    
    for chestNum : number, animatedChest : AnimatedChest.AnimatedChest in AnimatedChests[chestGameID] do
        animatedChest:Destroy()
    end

    AnimatedChests[chestGameID] = nil
end

local function onChestGameCreated(chestGameID : string)
    IChestGameRenderer.renderChairs(chestGameID)
end

ChestGameState.changeState.listen(function(chestGameID: string, state: "ChoosingChests" | "Conclusion" | "Dormant" | "InAction")
    if state == "ChoosingChests" or state == "InAction" then
        createAnimatedChests(chestGameID)
    else
        clearAnimatedChests(chestGameID)
    end
end)

ChestGameState.openBadChest.listen(function(chestGameID: string, participantID: string, chestNum: number)
    if AnimatedChests[chestGameID] == nil then
        return
    end

    local animatedChest : AnimatedChest.AnimatedChest? = AnimatedChests[chestGameID][chestNum]

    if animatedChest then
        animatedChest:DeclareBadChest()
        animatedChest:Render()
        loadChestAnimations(animatedChest)
        animatedChest:GetAnimationTrack("PlayerChomp"):Play(0, 2, 1)
        animatedChest:GetAnimationTrack("PlayerChomp").Ended:Once(function()
            animatedChest:SinkIntoFloor()
        end)
    end
end)

ChestGameState.openSafeChest.listen(function(chestGameID: string, participantID: string, chestNum: number)
    if AnimatedChests[chestGameID] == nil then
        return
    end

    local animatedChest : AnimatedChest.AnimatedChest? = AnimatedChests[chestGameID][chestNum]

    if animatedChest then
        animatedChest:DeclareGoodChest()
        animatedChest:Render()
        loadChestAnimations(animatedChest)
        animatedChest:GetAnimationTrack("ChestOpen"):Play(0, 2, 1)
        animatedChest:GetAnimationTrack("ChestOpen").Ended:Once(function()
            animatedChest:SinkIntoFloor()
        end)
    end
end)

ChestGameState.changeState.listenBefore(function(chestGameID: string, state: "ChoosingChests" | "Dormant" | "InAction" | "Conclusion")
    if state == "Dormant" then
        IChestGameRenderer.cleanOldChairRendering(chestGameID)
    end
end)

ChestGameState.addParticipant.listen(function(chestGameID: string, participantID: string, participant: ChestGameDataTypes.ChestGameParticipant)
    IChestGameRenderer.renderChairs(chestGameID)
end)

ChestGameState.removeParticipant.listen(function(chestGameID: string, participantID: string)
    IChestGameRenderer.renderChairs(chestGameID)
end)

BootEvents.NetworkStarted:Connect(function()
    for chestGameID: string, chestGame: ChestGameDataTypes.ChestGame in ChestGameState.Data.ChestGameCollection do
		task.spawn(onChestGameCreated, chestGameID, chestGame)
	end

	ChestGameState.createChestGame.listen(onChestGameCreated)
end)

return nil
