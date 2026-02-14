local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UILib = require(ReplicatedStorage.TLib.UILib)

local GlobalLeaderboardSurfaceUI = {}
GlobalLeaderboardSurfaceUI.__index = GlobalLeaderboardSurfaceUI

function GlobalLeaderboardSurfaceUI.new(leaderboardID : string, globalLeaderboardInstance : Instance)
    local self = setmetatable({}, GlobalLeaderboardSurfaceUI)

    self.rootViewer = UILib.Viewer()
    self.rootViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Surfaces.Leaderboard:Clone())
    self.rootViewer:AutoParent()

    self.entryViewers = {}

    return self
end

function GlobalLeaderboardSurfaceUI.SetAdornee(self, adornee : BasePart)
    self.rootViewer.Tree.Adornee = adornee
end

function GlobalLeaderboardSurfaceUI.SetTitle(self, title : string)
    self.rootViewer:SetLabel("Title", title)
end

function GlobalLeaderboardSurfaceUI.AddEntry(self, userIDString : string, value : any)
    local entryViewer = UILib.Viewer()
    entryViewer:Hydrate(self.rootViewer:FromRef("EntryTemplate"):Clone())
    entryViewer:SetParent(self.rootViewer:FromRef("ListContent"))
    entryViewer.Tree.LayoutOrder = #self.entryViewers+1
    entryViewer:SetVisible(true)
    entryViewer:SetLabel("Value", value)
    entryViewer:SetLabel("Username", `@{Players:GetNameFromUserIdAsync(tonumber(userIDString))}`)
    entryViewer:SetLabel("AvatarIcon", Players:GetUserThumbnailAsync(
        tonumber(userIDString), 
        Enum.ThumbnailType.HeadShot, 
        Enum.ThumbnailSize.Size420x420
    ))

    table.insert(self.entryViewers, entryViewer)
end

function GlobalLeaderboardSurfaceUI.ClearEntries(self)
    for _, entryViewer in self.entryViewers do
        entryViewer:Destroy()
    end

    table.clear(self.entryViewers)
end

function GlobalLeaderboardSurfaceUI.Destroy(self)
    self.rootViewer:Destroy()
end

return GlobalLeaderboardSurfaceUI
