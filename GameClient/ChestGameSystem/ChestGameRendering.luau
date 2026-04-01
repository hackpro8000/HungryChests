local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CharacterDoubles = require(ReplicatedStorage.GameClient.CinematicSystem.CharacterDoubles)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ChestGameDataTypes = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameDataTypes)
local ChestGameHelper = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameHelper)
local AnimatedChest = require(script.Parent.AnimatedChest)
local IChestGameRenderer = require(script.Parent.IChestGameRenderer)
local ChestGameState = require(ReplicatedStorage.GameCommon.ChestGameSystem.ChestGameState)
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)

local AnimatedChests = {}

local function loadChestAnimations(animatedChest : AnimatedChest.AnimatedChest)
    local animationsFolder = ReplicatedStorage.Resources.Animations.Chests:FindFirstChild(animatedChest.ChestType)

    if animationsFolder == nil then
        return
    end

    ContentProvider:PreloadAsync(animationsFolder:GetChildren())
    
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
        local gridX : number, gridY : number = ChestGameHelper.getChestGridXY(chestGame, chestNum)
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

--[[
    DUDE REFACTOR THIS!!!!!
]]
ChestGameState.openChest.listen(function(chestGameID: string, participantID: string, chestNum: number)
    if AnimatedChests[chestGameID] == nil then
        return
    end

    local chestGame : ChestGameDataTypes.ChestGame = assert(ChestGameState.Data.ChestGameCollection[chestGameID], `Chest game {chestGameID} not found!`)
    local chestGameInstance : Model? = StreamingLibClient.getInstance(chestGame.InstanceStreamableID)

    if chestGameInstance == nil then
        return
    end
    
    local participant : ChestGameDataTypes.ChestGameParticipant = chestGame.Participants[participantID]
    local seatPositionsFolder : Folder = chestGameInstance.SeatPositions
    local seatPositionPart : Part? = nil

    for _, seatPosition1 : Part in seatPositionsFolder:GetChildren() do
        if seatPosition1:GetAttribute("ParticipantIndex") == participant.Index then
            seatPositionPart = seatPosition1
        end
    end

    local characterDoubleUserID = participant.UserIDString ~= "0" and tonumber(participant.UserIDString) or Players:GetUserIdFromNameAsync("TheCelvestian")

    if CharacterDoubles.isDoubleReady() ~= true then
        CharacterDoubles.preloadForUserID(characterDoubleUserID)
    end

    local characterDouble = CharacterDoubles.createDouble(characterDoubleUserID)
    characterDouble.PrimaryPart.Anchored = false
    characterDouble.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    characterDouble.PrimaryPart.Anchored = true
    characterDouble.Parent = workspace
    local characterDoubleSize = characterDouble:GetExtentsSize()
    
    local animatedChest : AnimatedChest.AnimatedChest? = AnimatedChests[chestGameID][chestNum]
    
    local r15EatenTrack : AnimationTrack = characterDouble.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Resources.Animations.R15.PlayerEatenByChest)
    r15EatenTrack.Looped = false
    local r15ChompTrack : AnimationTrack = characterDouble.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Resources.Animations.R15.PlayerChompedByChest)
    r15ChompTrack.Looped = false
    local r15OpenTrack : AnimationTrack = characterDouble.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Resources.Animations.R15.PlayerOpeningChest)
    r15OpenTrack.Looped = false
    local r15RunTrack : AnimationTrack = characterDouble.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Resources.Animations.R15.RunAnimation)
    r15OpenTrack.Looped = true
    
    local chestOpeningCFrame : CFrame = animatedChest.CurrentRig:GetPivot():ToWorldSpace(CFrame.new(0,characterDoubleSize.Y/2,-3.38))

    if animatedChest then
        local direction = (seatPositionPart.Position - chestOpeningCFrame.Position)
        local distance = (seatPositionPart.Position - chestOpeningCFrame.Position).Magnitude
        local walkTime = distance / 16
        local rotation = CFrame.Angles(0, math.atan2(direction.X, direction.Z), 0)

        characterDouble:PivotTo(
            CFrame.new(
                seatPositionPart.Position * 
                Vector3.new(1,0,1) + 
                Vector3.yAxis * 
                chestOpeningCFrame.Y
            ) * 
            rotation
        )

        local characterTravelTween = TweenService:Create(characterDouble.PrimaryPart, 
            TweenInfo.new(walkTime, Enum.EasingStyle.Linear), 

            {
                CFrame = CFrame.new(
                    chestOpeningCFrame.Position * Vector3.new(1,0,1) + 
                    Vector3.yAxis * chestOpeningCFrame.Y
                ) * rotation
            }
        )

        characterTravelTween:Play()
        r15RunTrack:Play()
        
        task.spawn(function()
            task.wait(walkTime)

            local characterFaceChestTween = TweenService:Create(characterDouble.PrimaryPart, 
                TweenInfo.new(0.5, Enum.EasingStyle.Exponential), 
                {
                    CFrame = chestOpeningCFrame * CFrame.Angles(0, math.pi, 0)
                }
            )
            r15RunTrack:Stop(0)
            characterFaceChestTween:Play()

            if ChestGameHelper.isBadChest(chestGameID, chestNum) then
                animatedChest:DeclareBadChest()
                animatedChest:Render()
                loadChestAnimations(animatedChest)
                
                if participant.HealthPoints <= 0 then
                    animatedChest:GetAnimationTrack("PlayerEaten"):Play(0, 2, 1)
                    task.delay(animatedChest:GetAnimationTrack("PlayerEaten").Length, function()
                        characterDouble:Destroy()
                        animatedChest:SinkIntoFloor()
                    end)
                    r15EatenTrack:Play(0, 2, 1)
                else
                    animatedChest:GetAnimationTrack("PlayerChomp"):Play(0, 2, 1)
                    task.delay(animatedChest:GetAnimationTrack("PlayerChomp").Length, function()
                        characterDouble:Destroy()
                        animatedChest:SinkIntoFloor()
                    end)
                    r15ChompTrack:Play(0, 2, 1)
                end
            else
                animatedChest:DeclareGoodChest()
                animatedChest:Render()
                loadChestAnimations(animatedChest)
                animatedChest:GetAnimationTrack("ChestOpen"):Play(0, 2, 1)
                task.delay(animatedChest:GetAnimationTrack("ChestOpen").Length, function()
                    animatedChest:SinkIntoFloor()
                    characterDouble:Destroy()
                end)
                r15OpenTrack:Play(0, 2, 1)
            end
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
