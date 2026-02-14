local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local UILib = require(ReplicatedStorage.TLib.UILib)

local winStreakViewers = {}

local function winStreakUpdated(profileID : string)
    local profile = ProfileState.Data.Profiles[profileID]
    local winStreakViewer = winStreakViewers[profileID]

    winStreakViewer:SetLabel("Streak", profile.WinStreak)
    winStreakViewer.Tree.Enabled = profile.WinStreak > 0
end

local function profileAdded(profileID : string)
    local player = Players:GetPlayerByUserId(tonumber(profileID))
    local winStreakViewer = UILib.Viewer()
    winStreakViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Billboards.WinStreak:Clone())
    winStreakViewer:AutoParent()

    local function onCharacterAdded(character : Model)
        winStreakViewer.Tree.Adornee = character:WaitForChild("HumanoidRootPart")
    end

    onCharacterAdded(player.Character or player.CharacterAdded:Wait())
    player.CharacterAdded:Connect(onCharacterAdded)

    winStreakViewers[profileID] = winStreakViewer
    winStreakUpdated(profileID)
end

local function profileRemoved(profileID : string)
    local winStreakViewer = winStreakViewers[profileID]

    if winStreakViewer then
        winStreakViewer:Destroy()
        winStreakViewers[profileID] = nil
    end
end

BootEvents.NetworkStarted:Connect(function()
    for profileID : string in ProfileState.Data.Profiles do
        profileAdded(profileID)
    end

    ProfileState.addProfile.listen(profileAdded)
    ProfileState.removeProfile.listen(profileRemoved)
    ProfileState.winChestGame.listen(winStreakUpdated)
    ProfileState.loseChestGame.listen(winStreakUpdated)
end)

return nil
