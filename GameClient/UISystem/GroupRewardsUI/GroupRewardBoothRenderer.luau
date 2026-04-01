local CollectionService = game:GetService("CollectionService")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToastNotificationEvents = require(ReplicatedStorage.GameClient.ToastNotificationSystem.ToastNotificationEvents)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local ProfileSystemTypes = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileSystemTypes)
local NetLibClient = require(ReplicatedStorage.TLib.NetLib.NetLibClient)
local UILib = require(ReplicatedStorage.TLib.UILib)

local RE_ClaimGroupRewards = NetLibClient.RemoteEvent("GroupRewardSystem/ClaimGroupRewards")

local BoothViewers = {} :: {[Model] : typeof(UILib.Viewer())}

local function promptJoinGroup() : Enum.GroupMembershipStatus
    local successful : boolean, result : string | Enum.GroupMembershipStatus = pcall(function(...)
        return GroupService:PromptJoinAsync(game.CreatorId)
    end)

    if successful then
        return result
    end

    return Enum.GroupMembershipStatus.None
end

local function claimReward()
    if Players.LocalPlayer:IsInGroupAsync(game.CreatorId) ~= true then
        ToastNotificationEvents.NotificationReceived:Fire("Join the group for more rewards!", 5)

        local membershipStatus = promptJoinGroup()

        if membershipStatus ~= Enum.GroupMembershipStatus.AlreadyMember then
            ToastNotificationEvents.NotificationReceived:Fire("Couldn't join group, please try again!", 5)
        end
    end

    RE_ClaimGroupRewards:FireServer()
end

local function createBoothViewer(boothInstance : Model) : typeof(UILib.Viewer())
    local boothViewer = UILib.Viewer()
    boothViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Billboards.GroupRewardBooth:Clone())
    boothViewer:SetVisible(false)
    boothViewer:AutoParent()
    boothViewer.Tree.Adornee = boothInstance.PromptAdornee

    BoothViewers[boothInstance] = boothViewer
    return boothViewer
end

local function waitForBooth(boothInstance : Model)
    assert(boothInstance:WaitForChild("PromptAdornee", 30), `Group reward booth instance has no prompt adornee!`)
    assert(boothInstance.PromptAdornee:WaitForChild("ProximityPrompt", 30), `Group reward booth instance has no proximity prompt!`)
end

local function onBoothInstanceAdded(boothInstance : Model)
    waitForBooth(boothInstance)

    local boothViewer = createBoothViewer(boothInstance)
    local proximityPrompt : ProximityPrompt = boothInstance.PromptAdornee.ProximityPrompt
    
    local function update()
        local profile : ProfileSystemTypes.Profile? = ProfileState.Data.Profiles[`{Players.LocalPlayer.UserId}`]
        
        if profile == nil then
            return
        end

        if os.time() < profile.GroupRewardClaimedOn + 86400 then
            boothViewer:FromRef("Claim").Visible = false
            boothViewer:FromRef("AlreadyClaimed").Visible = true
            boothViewer:SetLabelVisible("ComebackTomorrow", true)
        else
            boothViewer:FromRef("Claim").Visible = true
            boothViewer:FromRef("AlreadyClaimed").Visible = false
            boothViewer:SetLabelVisible("ComebackTomorrow", false)
        end
    end

    boothViewer.InteractionContext:GetButton("Claim"):ListenLMB(function(isDown : boolean)
        if isDown == true then
            return
        end
        
        claimReward()
    end)

    proximityPrompt.PromptShown:Connect(function()
        boothViewer:SetVisible(true)
    end)

    proximityPrompt.PromptHidden:Connect(function()
        boothViewer:SetVisible(false)
    end)

    proximityPrompt.Triggered:Connect(claimReward)

    boothViewer:AddToCleanup(ProfileState.claimGroupReward.listen(update))

    update()
end

local function onBoothInstanceRemoved(boothInstance : Model)
    local boothViewer = BoothViewers[boothInstance]

    if boothViewer then
        boothViewer:Destroy()

        BoothViewers[boothInstance] = nil
    end
end

BootEvents.NetworkStarted:Connect(function()
    local boothCollectionTag = "GroupRewardBooth"

    for _, boothInstance : Model in CollectionService:GetTagged(boothCollectionTag) do
        onBoothInstanceAdded(boothInstance)
    end

    CollectionService:GetInstanceAddedSignal(boothCollectionTag):Connect(onBoothInstanceAdded)
    CollectionService:GetInstanceRemovedSignal(boothCollectionTag):Connect(onBoothInstanceRemoved)
end)

return nil
