local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local LuckyDrawCardUI = {}
LuckyDrawCardUI.__index = LuckyDrawCardUI

function LuckyDrawCardUI.new()
    local self = setmetatable({}, LuckyDrawCardUI)

    self.__setupViewer()

    return self
end

function LuckyDrawCardUI.__setupViewer(self : typeof(LuckyDrawCardUI.new()))
    self.Viewer = UILib.Viewer()
    self.Viewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Surfaces.LuckyDrawCard:Clone())
    self.Viewer:AutoParent()
end

function LuckyDrawCardUI.SetCFrame(self : typeof(LuckyDrawCardUI.new()), cframe : CFrame)
    self.Viewer.Tree.Adornee.CFrame = cframe
end

return LuckyDrawCardUI
