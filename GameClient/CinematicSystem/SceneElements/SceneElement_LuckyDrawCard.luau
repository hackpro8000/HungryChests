local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CleanerLib = require(ReplicatedStorage.TLib.CleanerLib)
local UILib = require(ReplicatedStorage.TLib.UILib)

local LuckyDrawCard = {}
LuckyDrawCard.__index = LuckyDrawCard

local RarityTextFormatting = {
    ["Rare"] = [[<font color="rgb(0, 255, 106)">Rare</font>]],
    ["Legendary"] = [[<font color="rgb(255, 93, 93)">Legendary</font>]],
    ["Divine"] = [[<font color="rgb(255, 204, 0)">Divine</font>]],
}

local function centerPivot(model : Model)
    local bboxCFrame : CFrame = model:GetBoundingBox()
    
    local primaryPart : Part = Instance.new("Part")
    primaryPart.Transparency = 1
    primaryPart.Parent = model
    primaryPart.CFrame = bboxCFrame
    model.PrimaryPart = primaryPart

    return model
end

function LuckyDrawCard.new()
    local self = setmetatable({}, LuckyDrawCard)

    self.cleaner = CleanerLib.Cleaner() :: typeof(CleanerLib.Cleaner())
    self.viewer = UILib.Viewer() :: typeof(UILib.Viewer())
    self:__initElement()

    return self
end

function LuckyDrawCard.GetAdornee(self : typeof(LuckyDrawCard.new())) : Part
    return self.viewer.Tree.Adornee
end

function LuckyDrawCard.SetViewportSubject(self : typeof(LuckyDrawCard.new()), subject : Model)
    centerPivot(subject)
    subject:PivotTo(CFrame.Angles(-math.rad(14.491), -math.rad(133.085), -math.rad(14.978)))

    subject.Parent = self.viewer:FromRef("Viewport")
end

function LuckyDrawCard.SetDisplayName(self : typeof(LuckyDrawCard.new()), displayName : string)
    self.viewer:SetLabel("DisplayName", displayName)
end

function LuckyDrawCard.SetRarity(self : typeof(LuckyDrawCard.new()), rarity : string)
    self.viewer:SetLabel("Rarity", RarityTextFormatting[rarity])
end

function LuckyDrawCard.__updateElement(self : typeof(LuckyDrawCard.new()), dt : number)
end

function LuckyDrawCard.__initElement(self : typeof(LuckyDrawCard.new()))
    self.viewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Surfaces.LuckyDrawCard:Clone())
    self.viewer:AutoParent()

    self.cleaner:Add(self.viewer)
    self.cleaner:Add(RunService.RenderStepped:Connect(function(dt : number)
        self:__updateElement(dt)
    end))
end

function LuckyDrawCard.Destroy(self : typeof(LuckyDrawCard.new()))
    self.cleaner:Clean()
    self.cleaner:Destroy()
end

return LuckyDrawCard
