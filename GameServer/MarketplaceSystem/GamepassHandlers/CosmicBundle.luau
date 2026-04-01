local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)
local GamepassIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.GamepassIDMap)

local function profileAdded(profileID : string, profile : ProfileSystemTypes.Profile)
    local userID = tonumber(profileID)

    if MarketplaceService:UserOwnsGamePassAsync(userID, GamepassIDMap.CosmicBundle) then
        --[[
            Cosmic Chest Reward
        ]]
        if not profile.ChestInventory.CosmicChest then
            ProfileState:GetServer().ownChest(profileID, "CosmicChest")
        end

        --[[
            Cosmic Chair Reward
        ]]
        if not profile.ChairInventory.CosmicChair then
            ProfileState:GetServer().ownChair(profileID, "CosmicChair")
        end
    end
end

BootEvents.NetworkStarted:Connect(function()
    for profileID, profile in ProfileState.Data.Profiles do
        profileAdded(profileID, profile)
    end

    ProfileState.addProfile.listen(profileAdded)
end)

return nil