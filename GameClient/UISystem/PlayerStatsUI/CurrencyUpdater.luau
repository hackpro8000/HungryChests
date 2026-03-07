local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
local PlayerStatsViewer = require(script.Parent.PlayerStatsViewer)

local LocalPlayer = Players.LocalPlayer

local function abbreviateNumber(number: number): string
    if number < 1000 then
        return tostring(math.floor(number))
    elseif number < 1000000 then
        return string.format("%.1fk", math.floor((number / 1000) * 10) / 10)
    elseif number < 1000000000 then
        return string.format("%.1fM", math.floor((number / 1000000) * 10) / 10)
    elseif number < 1000000000000 then
        return string.format("%.1fB", math.floor((number / 1000000000) * 10) / 10)
    else
        return string.format("%.1fT", math.floor((number / 1000000000000) * 10) / 10)
    end
end

local function update()
    local profile = ProfileState.Data.Profiles[`{LocalPlayer.UserId}`]
    if profile == nil then
        PlayerStatsViewer:SetLabel("PrimaryCurrencyAmount", `?`)
        return
    end

    PlayerStatsViewer:SetLabel("PrimaryCurrencyAmount", `{abbreviateNumber(profile.Currencies.Primary)}`)
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