local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local PlayerStatsViewer = require(script.Parent.PlayerStatsViewer)

local LocalPlayer = Players.LocalPlayer

local function update()
    local profile = ProfileState.Data.Profiles[`{LocalPlayer.UserId}`]
    if profile == nil then
        PlayerStatsViewer:SetLabel("PrimaryCurrencyAmount", `?`)
        return
    end

    PlayerStatsViewer:SetLabel("PrimaryCurrencyAmount", `${profile.Currencies.Primary}`)
    PlayerStatsViewer:SetLabel("TrophyAmount", `{profile.Trophies}`)
end

BootEvents.NetworkStarted:Connect(function()
    -- Initial update
    update()
    ProfileState.addProfile.listen(function(profileID: string)
        if profileID == `{LocalPlayer.UserId}` then
            update()
        end
    end)

    -- Listen for currency changes
    ProfileState.incrementCurrency.listen(function(profileID: string)
        if profileID == `{LocalPlayer.UserId}` then
            update()
        end
    end)
end)

return nil