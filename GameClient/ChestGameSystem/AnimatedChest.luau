local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CleanerLib = require(ReplicatedStorage.TLib.CleanerLib)

local AnimatedChest = {}
AnimatedChest.__index = AnimatedChest

export type AnimatedChest = typeof(AnimatedChest.new())

local function cleanPreviousRig(self : AnimatedChest)
    if self.CurrentRig then
        self.__cleaner:Remove(self.CurrentRig)
        self.CurrentRig:Destroy()
        self.CurrentRig = nil
    end

    if self.CurrentAnimator then
        self.CurrentAnimator:Destroy()
        self.CurrentAnimator = nil
    end
end

local function setupAnimator(self : AnimatedChest)
    local animationController = self.CurrentRig:FindFirstChildOfClass("AnimationController")
    
    table.clear(self.__currentAnimationTracks)
    self.CurrentAnimator = animationController:FindFirstChildOfClass("Animator") or
        Instance.new("Animator", animationController)
end

local function setupRig(self : AnimatedChest, chestType : string, isBadChest : boolean)
    cleanPreviousRig(self)

    local regularPrefabRig = ReplicatedStorage.Resources.Prefabs.RegularChests:FindFirstChild(chestType)
    local badPrefabRig = ReplicatedStorage.Resources.Prefabs.BadChests:FindFirstChild(chestType)
    local selectedPrefabRig = isBadChest and badPrefabRig or regularPrefabRig
    
    self.CurrentRig = selectedPrefabRig:Clone()

    for _, descendant : BasePart in self.CurrentRig:GetDescendants() do
        if not descendant:IsA("BasePart") then
            continue
        end

        descendant.CanCollide = false
        descendant.CanQuery = false
        descendant.CanTouch = false
    end

    self.CurrentRig:PivotTo(self.__renderCFrame)
    self.CurrentRig.Parent = self.__renderParent

    self.__cleaner:Add(self.CurrentRig)

    setupAnimator(self)
end

--[[
    Construct a new AnimatedChest
]]
function AnimatedChest.new(chestType : string)
    assert(chestType, `Cannot construct AnimatedChest, no chest type provided!`)

    local self = setmetatable({}, AnimatedChest)

    self.__cleaner = CleanerLib.Cleaner() :: typeof(CleanerLib.Cleaner())
    self.__renderParent = nil :: Instance?
    self.__renderCFrame = CFrame.identity :: CFrame
    self.__currentAnimationTracks = {} :: {[string] : AnimationTrack}
    self.ChestType = chestType :: string
    self.IsBadChest = false :: boolean
    self.CurrentRig = nil :: Model?
    self.CurrentAnimator = nil :: Animator?

    return self
end

--[[
    Play chest sinking into floor animation
]]
function AnimatedChest.SinkIntoFloor(self : AnimatedChest)
    if self:IsRigSafe() ~= true then
        return
    end
    
    local mainBone : Bone = self.CurrentRig.RootPart.Bone

    local tween = TweenService:Create(mainBone, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = mainBone.Position - Vector3.yAxis * 6
    })

    tween:Play()
end

--[[
    Renders the chest rig
]]
function AnimatedChest.Render(self : AnimatedChest)
    setupRig(self, self.ChestType, self.IsBadChest)
end

--[[
    Checks if current rig is safe to use and isn't nil
]]
function AnimatedChest.IsRigSafe(self : AnimatedChest) : boolean
    return self.CurrentRig ~= nil and self.CurrentAnimator ~= nil
end

--[[
    Loads specified animation instance and caches it under the specified discriminator
]]
function AnimatedChest.LoadAnimation(self : AnimatedChest, animation : Animation, discriminator : string) : AnimationTrack?
    if self:IsRigSafe() ~= true then
        return
    end

    local animationTrack : AnimationTrack = self.CurrentAnimator:LoadAnimation(animation)

    self.__currentAnimationTracks[discriminator] = animationTrack
    
    return animationTrack
end

--[[
    Get an existing animation track from the discriminator
]]
function AnimatedChest.GetAnimationTrack(self : AnimatedChest, discriminator : string) : AnimationTrack?
    return self.__currentAnimationTracks[discriminator]
end

--[[
    Declare chest as a bad chest
]]
function AnimatedChest.DeclareBadChest(self : AnimatedChest)
    self.IsBadChest = true
end

--[[
    Declare chest as a good chest
]]
function AnimatedChest.DeclareGoodChest(self : AnimatedChest)
    self.IsBadChest = false
end

--[[
    Set the render parent of the chest
]]
function AnimatedChest.SetRenderParent(self : AnimatedChest, parent : Instance?)
    self.__renderParent = parent
end

--[[
    Set the render CFrame of the chest
]]
function AnimatedChest.SetRenderCFrame(self : AnimatedChest, cframe : CFrame)
    self.__renderCFrame = cframe
end

--[[
    Destroy and cleanup the chest
]]
function AnimatedChest.Destroy(self : AnimatedChest)
    self.__cleaner:Clean()
    self.__cleaner:Destroy()
end

return AnimatedChest
