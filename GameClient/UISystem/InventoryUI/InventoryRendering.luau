local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryViewer = require(script.Parent.InventoryViewer)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)
local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)

local LocalPlayer = Players.LocalPlayer

local RE_EquipChest = NetLibClient.RemoteEvent("InventorySystem/EquipChest")
local RE_EquipChair = NetLibClient.RemoteEvent("InventorySystem/EquipChair")

local ChestTabRendering = {}
local ChairTabRendering = {}
local PowerUpsTabRendering = {}

local function clearRendering(rendering : {Instance})
    for _, instance : Instance in rendering do
        instance:Destroy()
    end

    table.clear(rendering)
end

local function renderPowerUpsTab(profile : ProfileSystemTypes.Profile)
    clearRendering(PowerUpsTabRendering)
    local tabInstance = InventoryViewer:FromRef("Tabs/PowerUps")
    local cellTemplate = tabInstance.CellTemplate
    
    for powerUp : string, amount : number in profile.PowerUps do
        local renderedCell = cellTemplate:Clone()
        renderedCell.Title.Text = powerUp
        renderedCell.Visible = true
        renderedCell.Icon.BackgroundColor3 = Color3.new(0,0,0)

        renderedCell.Selector.MouseButton1Up:Once(function()

        end)
        
        renderedCell.Parent = tabInstance

        table.insert(PowerUpsTabRendering, renderedCell)
    end
end

local function renderChestsTab(profile : ProfileSystemTypes.Profile)
    clearRendering(ChestTabRendering)

    local tabInstance = InventoryViewer:FromRef("Tabs/Chests")
    local cellTemplate = tabInstance.CellTemplate

    for chestType : string in profile.ChestInventory do
        local renderedCell = cellTemplate:Clone()
        renderedCell.Title.Text = chestType
        renderedCell.Visible = true

        if profile.ChestEquippedType == chestType then
            renderedCell.Icon.BackgroundColor3 = Color3.new(1,1,0)
        else
            renderedCell.Icon.BackgroundColor3 = Color3.new(0,0,0)
        end
        
        renderedCell.Selector.MouseButton1Up:Once(function()
            RE_EquipChest:FireServer(chestType)
        end)

        renderedCell.Parent = tabInstance

        table.insert(ChestTabRendering, renderedCell)
    end
end

local function renderChairsTab(profile : ProfileSystemTypes.Profile)
    clearRendering(ChairTabRendering)

    local tabInstance = InventoryViewer:FromRef("Tabs/Chairs")
    local cellTemplate = tabInstance.CellTemplate

    for chairType : string in profile.ChairInventory do
        local renderedCell = cellTemplate:Clone()
        renderedCell.Title.Text = chairType
        renderedCell.Visible = true

        if profile.ChairEquippedType == chairType then
            renderedCell.Icon.BackgroundColor3 = Color3.new(1,1,0)
        else
            renderedCell.Icon.BackgroundColor3 = Color3.new(0,0,0)
        end
        
        renderedCell.Selector.MouseButton1Up:Once(function()
            RE_EquipChair:FireServer(chairType)
        end)

        renderedCell.Parent = tabInstance

        table.insert(ChairTabRendering, renderedCell)
    end
end

local function onProfileLoaded(profile : ProfileSystemTypes.Profile)
    renderChestsTab(profile)
    renderChairsTab(profile)
    renderPowerUpsTab(profile)
end

BootEvents.NetworkStarted:Connect(function()
    local localProfileID = `{LocalPlayer.UserId}`
    local profile = ProfileState.Data.Profiles[localProfileID]
    
    if profile then
        onProfileLoaded(profile)
    end

    ProfileState.addProfile.listen(function(profileID : string, profile : ProfileSystemTypes.Profile)
        if profileID ~= localProfileID then
            return
        end

        onProfileLoaded(profile)
    end)

    ProfileState.ownChest.listen(function(profileID: string, chestType: string)
        if profileID ~= localProfileID then
            return
        end

        local profile = ProfileState.Data.Profiles[localProfileID]

        renderChestsTab(profile)
    end)

    ProfileState.equipChest.listen(function(profileID: string, chestType: string)
        if profileID ~= localProfileID then
            return
        end

        local profile = ProfileState.Data.Profiles[localProfileID]

        renderChestsTab(profile)
    end)

    ProfileState.ownChair.listen(function(profileID: string, chairType: string)
        if profileID ~= localProfileID then
            return
        end

        local profile = ProfileState.Data.Profiles[localProfileID]

        renderChairsTab(profile)
    end)

    ProfileState.equipChair.listen(function(profileID: string, chairType: string)
        if profileID ~= localProfileID then
            return
        end

        local profile = ProfileState.Data.Profiles[localProfileID]

        renderChairsTab(profile)
    end)
    
    ProfileState.givePowerUp.listen(function(profileID: string, powerUp: string, amount: number)
        if profileID ~= localProfileID then
            return
        end

        local profile = ProfileState.Data.Profiles[localProfileID]

        renderPowerUpsTab(profile)
    end)
    
    ProfileState.usePowerUp.listen(function(profileID: string, powerUp: string, amount: number)
        if profileID ~= localProfileID then
            return
        end

        local profile = ProfileState.Data.Profiles[localProfileID]

        renderPowerUpsTab(profile)
    end)
end)

return nil
