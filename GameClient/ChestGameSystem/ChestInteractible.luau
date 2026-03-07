local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CleanerLib = require(ReplicatedStorage.TLib.CleanerLib)

local ChestInteractible = {}
ChestInteractible.__index = ChestInteractible

export type ChestInteractible = typeof(ChestInteractible.new())

local function createInteractiblePart(self : ChestInteractible)
    local interactiblePart = Instance.new("Part")
    interactiblePart.Transparency = 1
    interactiblePart.CanCollide = false
    interactiblePart.Anchored = true
    interactiblePart.Size = Vector3.one * 4
    interactiblePart.CFrame = self.CFrame
    interactiblePart.Parent = workspace

    self.__cleaner:Add(interactiblePart)

    return interactiblePart
end

local function createClickDetector(self : ChestInteractible)
    local clickDetector = Instance.new("ClickDetector", self.InteractiblePart)
    clickDetector.MaxActivationDistance = 0

    return clickDetector
end

--[[
    Construct a new AnimatedChest
]]
function ChestInteractible.new(cframe : CFrame)
    local self = setmetatable({}, ChestInteractible)

    self.__cleaner = CleanerLib.Cleaner() :: typeof(CleanerLib.Cleaner())
    self.CFrame = cframe
    self.InteractiblePart = createInteractiblePart(self)
    self.ClickDetector = createClickDetector(self)

    return self
end

--[[
    Enable interaction
]]
function ChestInteractible.Enable(self : ChestInteractible)
    self.ClickDetector.MaxActivationDistance = math.huge
end

--[[
    Disable interaction
]]
function ChestInteractible.Disable(self : ChestInteractible)
    self.ClickDetector.MaxActivationDistance = 0
end

--[[
    Destroy and cleanup the chest interactible
]]
function ChestInteractible.Destroy(self : ChestInteractible)
    self.__cleaner:Clean()
    self.__cleaner:Destroy()
end

return ChestInteractible
