local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileSystemTypes)
local GamepassIDMap = require(ReplicatedStorage.GameDefinitions.MarketplaceSystem.GamepassIDMap)

local function profileAdded(profileID : string, profile : ProfileSystemTypes.Profile)
    local userID = tonumber(profileID)

    if MarketplaceService:UserOwnsGamePassAsync(userID, GamepassIDMap.VIPBundle) then
        if not profile.ChestInventory.RoyalChest then
            ProfileState:GetServer().ownChest(profileID, "RoyalChest")
        end

        if not profile.ChairInventory.RoyalChair then
            ProfileState:GetServer().ownChair(profileID, "RoyalChair")
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