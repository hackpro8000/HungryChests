local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local GamepassIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.GamepassIDMap)
local UILib = require(ReplicatedStorage.TLib.UILib)

local VIPOverheadViewers = {} :: {[Player] : typeof(UILib.Viewer())}

local function createVIPOverheadViewer(player : Player)
    local viewer = UILib.Viewer()
    viewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Billboards.VIPOverhead:Clone())
    viewer:AutoParent()

    VIPOverheadViewers[player] = viewer
    
    return viewer
end

local function onPlayerAdded(player : Player)
    -- if MarketplaceService:UserOwnsGamePassAsync(player.UserId, GamepassIDMap.VIPBundle) ~= true then
    --     return
    -- end

    local viewer = createVIPOverheadViewer(player)

    local function onCharacterAdded(character : Model)
        viewer.Tree.Adornee = character:WaitForChild("HumanoidRootPart")
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function onPlayerRemoving(player : Player)
    local viewer = VIPOverheadViewers[player]

    if viewer then
        viewer:Destroy()

        VIPOverheadViewers[player] = nil
    end
end

BootEvents.NetworkStarted:Connect(function()
    for _, player : Player in Players:GetPlayers() do
        onPlayerAdded(player)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end)

return nil
