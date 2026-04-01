local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SceneElement_LuckyDrawCard = require(ReplicatedStorage.GameClient.CinematicSystem.SceneElements.SceneElement_LuckyDrawCard)
local SceneElement_LuckyDrawCardCluster = require(ReplicatedStorage.GameClient.CinematicSystem.SceneElements.SceneElement_LuckyDrawCardCluster)
local LuckyDrawState = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawState)
local LuckyDrawTypes = require(ReplicatedStorage.GameCommon.LuckyDrawSystem.LuckyDrawTypes)
local CineLibTypes = require(ReplicatedStorage.TLib.CineLib.CineLibTypes)
local CleanerLib = require(ReplicatedStorage.TLib.CleanerLib)
local OrderedSignal = require(ReplicatedStorage.TLib.OrderedSignal)
local OrderedSignalTypes = require(ReplicatedStorage.TLib.OrderedSignal.OrderedSignalTypes)

local LuckyDrawScenePrefab = ReplicatedStorage.Resources.Prefabs.Scenes.LuckyDrawScene
local LuckyDrawRigs = {
    ["LuckyChairDraw"] = ReplicatedStorage.Resources.Prefabs.LuckyDrawChests.ObsidianDoubleChest,
    ["LuckyChestDraw"] = ReplicatedStorage.Resources.Prefabs.LuckyDrawChests.DiamondDoubleChest,
}

local LuckyDrawScene = {}
LuckyDrawScene.__index = LuckyDrawScene

local function loopAnimationTrackSection(animationTrack : AnimationTrack, startTime : number, endTime : number, count : number)
    for i = 1, count do
        animationTrack:Play(0, 1, 1)
        animationTrack.TimePosition = startTime
        
        repeat task.wait() until animationTrack.TimePosition >= endTime
    end
end

local function pauseAnimationTrack(animationTrack : AnimationTrack)
    animationTrack:AdjustSpeed(0)    
end

local function resumeAnimationTrack(animationTrack : AnimationTrack)
    animationTrack:AdjustSpeed(1)
end

local function pauseAnimationTrackFor(animationTrack : AnimationTrack, pauseTime : number)
    animationTrack:AdjustSpeed(0)

    task.wait(pauseTime)

    animationTrack:AdjustSpeed(1)
end

function LuckyDrawScene.new(cinematicController : CineLibTypes.CinematicController, luckyDrawID : string, luckyDrawResult : {string})
    local self = setmetatable({}, LuckyDrawScene)

    self.ID = HttpService:GenerateGUID(false)
    self.OnFinish = OrderedSignal.new() :: OrderedSignalTypes.OrderedSignal

    self.luckyDrawResult = luckyDrawResult :: {string}
    self.luckyDrawID = luckyDrawID :: string
    self.sceneSettingInstance = LuckyDrawScenePrefab:Clone() :: typeof(LuckyDrawScenePrefab)
    self.sceneRigInstance = LuckyDrawRigs[luckyDrawID]:Clone() :: typeof(LuckyDrawRigs.LuckyChestDraw)
    self.cinematicController = cinematicController :: CineLibTypes.CinematicController
    self.cleaner = CleanerLib.Cleaner() :: typeof(CleanerLib.Cleaner())
    self:__preloadAssets()
    self:__initScene()

    return self
end

function LuckyDrawScene.__perform(self : typeof(LuckyDrawScene.new()))
    local animator : Animator = self.sceneRigInstance.AnimationController.Animator
    local rigAnimationFolder : Folder = ReplicatedStorage.Resources.Animations.LuckyDraw:FindFirstChild(self.sceneRigInstance.Name)
    local mainAnimationTrack = animator:LoadAnimation(rigAnimationFolder.MainAnimationSequence)
    local luckyDrawCardCluster = SceneElement_LuckyDrawCardCluster.new(
        self.sceneRigInstance:FindFirstChild("CardStartingLocation", true),
        self.sceneRigInstance:FindFirstChild("CardFloatingLocation", true),
        self.cinematicController
    )

    self.cleaner:Add(luckyDrawCardCluster)

    local luckyDraw : LuckyDrawTypes.LuckyDraw = LuckyDrawState.Data.LuckyDraws[self.luckyDrawID]

    for i, rewardName : string in self.luckyDrawResult do
        local luckyDrawCard = SceneElement_LuckyDrawCard.new()
        luckyDrawCard:SetDisplayName(rewardName)
        luckyDrawCard:SetRarity(luckyDraw.Pools.Default[rewardName])
        luckyDrawCard:SetViewportSubject(luckyDraw.Prefabs[rewardName]:Clone())
        
        luckyDrawCardCluster:InsertLuckyDrawCard(luckyDrawCard)
    end

    mainAnimationTrack:Play(0, 2, 1)
    mainAnimationTrack.Looped = false

    repeat task.wait() until mainAnimationTrack.TimePosition >= mainAnimationTrack:GetTimeOfKeyframe("RevealCards")

    luckyDrawCardCluster:PlayAnimations()

    repeat task.wait() until mainAnimationTrack.TimePosition >= mainAnimationTrack:GetTimeOfKeyframe("ChestOpen")

    pauseAnimationTrack(mainAnimationTrack)

    task.wait(3)
    resumeAnimationTrack(mainAnimationTrack)

    repeat task.wait() until mainAnimationTrack.TimePosition >= mainAnimationTrack:GetTimeOfKeyframe("ChestSank")

    mainAnimationTrack:AdjustSpeed(0)

    self.OnFinish:Fire()
    self:Destroy()
end

function LuckyDrawScene.__preloadAssets(self : typeof(LuckyDrawScene.new()))
    local rigAnimationFolder : Folder = ReplicatedStorage.Resources.Animations.LuckyDraw:FindFirstChild(self.sceneRigInstance.Name)

    ContentProvider:PreloadAsync(rigAnimationFolder:GetDescendants())
    ContentProvider:PreloadAsync(self.sceneRigInstance:GetDescendants())
    ContentProvider:PreloadAsync(self.sceneSettingInstance:GetDescendants())
end

function LuckyDrawScene.__modify(self : typeof(LuckyDrawScene.new()), cameraChanges : CineLibTypes.CameraChanges, dt : number)
    cameraChanges.CameraType = Enum.CameraType.Scriptable
    cameraChanges.CFrame = self.sceneSettingInstance.CameraLocation.CFrame
    cameraChanges.FOV = 40
end

function LuckyDrawScene.__initScene(self : typeof(LuckyDrawScene.new()))
    self.sceneSettingInstance.Parent = workspace
    self.sceneRigInstance.Parent = workspace
    self.sceneRigInstance:PivotTo(self.sceneSettingInstance.Center.CFrame)

    self.cinematicController:AddModifier(`LuckyDrawScene-{self.ID}@3`, function(cameraChanges: CineLibTypes.CameraChanges, dt: number)
        self:__modify(cameraChanges, dt)
    end)

    self.cleaner:Add(function()
        self.cinematicController:RemoveModifier(`LuckyDrawScene-{self.ID}`)
    end)

    self.cleaner:Add(coroutine.wrap(self.__perform)(self))
    self.cleaner:Add(self.sceneSettingInstance)
    self.cleaner:Add(self.sceneRigInstance)
    self.cleaner:Add(self.OnFinish)
    self.cleaner:Add(function()
        print("Cleaning scene.")
    end)
end

function LuckyDrawScene.Destroy(self : typeof(LuckyDrawScene.new()))
    self.cleaner:Clean()
    self.cleaner:Destroy()
end

return LuckyDrawScene
