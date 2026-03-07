local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EngagementRewardTypes = require(ReplicatedStorage.GameCommons.EngagementRewardSystem.EngagementRewardTypes)
local DailyRewardTypes = require(ReplicatedStorage.GameCommons.DailyRewardSystem.DailyRewardTypes)
local ProfileSystemTypes = require(script.Parent.ProfileSystemTypes)
local DataLib = require(ReplicatedStorage.TLib.DataLib)

local Actions, Data = {}, {
    Profiles = {} :: {[string] : ProfileSystemTypes.Profile}
}

Actions.addProfile = DataLib.Action(function(profileID : string, profile : ProfileSystemTypes.Profile)
    assert(profileID, "Profile ID not provided!")
    assert(profile, `Profile data not provided for profile ID : {profileID}!`)

    Data.Profiles[profileID] = profile
end)

Actions.removeProfile = DataLib.Action(function(profileID : string)
    assert(profileID, "Profile ID not provided!")
    assert(Data.Profiles[profileID], `Could not find and remove profile {profileID}!`)

    Data.Profiles[profileID] = nil
end)

Actions.incrementCurrency = DataLib.Action(function(profileID : string, currencyName : string, amount : number)
    assert(profileID, "Parameter `profileID` cannot be nil!")
    assert(currencyName, "Parameter `currencyName` cannot be nil!")
    assert(amount, "Parameter `amount` cannot be nil!")
    assert(typeof(amount) == "number", `amount must be number, got {typeof(amount)}`)

    local profile = Data.Profiles[profileID]
    
    assert(profile, `Could not find profile with ID: {profileID}`)
    assert(profile.Currencies, `Profile {profileID} has no Currencies table!`)

    local currentAmount = profile.Currencies[currencyName] or 0
    profile.Currencies[currencyName] = currentAmount + amount
end)

Actions.giveCurrency = DataLib.Action(function(profileID : string, currencyName : string, amount : number)
    assert(amount and amount > 0, "Parameter `amount` must be a positive number!")

    Actions.incrementCurrency(profileID, currencyName, amount)
end)

Actions.takeCurrency = DataLib.Action(function(profileID : string, currencyName : string, amount : number)
    assert(amount and amount > 0, "Parameter `amount` must be a positive number!")

    Actions.incrementCurrency(profileID, currencyName, -amount)
end)

Actions.setShallowValue = DataLib.Action(function(profileID : string, key : string, value : any)
    assert(profileID, "Parameter `profileID` cannot be nil!")
    assert(key, "Parameter `key` cannot be nil!")
    assert(value ~= nil, "Parameter `value` cannot be nil!")

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile[key] = value
end)

Actions.incrementShallowValue = DataLib.Action(function(profileID : string, key : string, amount : number)
    assert(profileID, "Parameter `profileID` cannot be nil!")
    assert(key, "Parameter `key` cannot be nil!")
    assert(amount, "Parameter `amount` cannot be nil!")
    assert(typeof(amount) == "number", `amount must be number, got {typeof(amount)}`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)

    local currentValue = profile[key] or 0
    assert(typeof(currentValue) == "number", `Current value for key {key} must be number, got {typeof(currentValue)}`)
    
    Actions.setShallowValue(profileID, key, currentValue + amount)
end)

Actions.givePowerUp = DataLib.Action(function(profileID : string, powerUp : string, amount : number)
    assert(profileID, "Parameter `profileID` cannot be nil!")
    assert(powerUp, "Parameter `powerUp` cannot be nil!")
    assert(amount, "Parameter `amount` cannot be nil!")
    assert(typeof(amount) == "number", `amount must be number, got {typeof(amount)}`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)

    local currentValue = profile.PowerUps[powerUp] or 0
    
    profile.PowerUps[powerUp] = currentValue + amount
end)

Actions.usePowerUp = DataLib.Action(function(profileID : string, powerUp : string, amount : number)
    assert(profileID, "Parameter `profileID` cannot be nil!")
    assert(powerUp, "Parameter `powerUp` cannot be nil!")
    assert(amount, "Parameter `amount` cannot be nil!")
    assert(typeof(amount) == "number", `amount must be number, got {typeof(amount)}`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)

    local currentValue = profile.PowerUps[powerUp] or 0
    
    profile.PowerUps[powerUp] = currentValue - amount
end)

Actions.giveChestGameReward = DataLib.Action(function(profileID : string, primaryCurrencyReward : number, trophyReward : number, winAmount : number?, winStreakAmount : number?)
    assert(profileID, `Profile ID not provided!`)
    assert(primaryCurrencyReward, `Primary currency reward not provided!`)
    assert(trophyReward, `Trophy reward not provided!`)

    Actions.incrementCurrency(profileID, "Primary", primaryCurrencyReward)
    Actions.incrementShallowValue(profileID, "Trophies", trophyReward)
    
    if winAmount then
        Actions.incrementShallowValue(profileID, "Wins", winAmount)
    end
    
    if winStreakAmount then
        Actions.incrementShallowValue(profileID, "WinStreak", winStreakAmount)
    end
end)

Actions.winChestGame = DataLib.Action(function(profileID : string, primaryCurrencyReward : number, trophyReward : number, winAmount : number?, winStreakAmount : number?)
    assert(profileID, `Profile ID not provided!`)
    
    Actions.giveChestGameReward(profileID, primaryCurrencyReward, trophyReward, winAmount, winStreakAmount)
end)

Actions.loseChestGame = DataLib.Action(function(profileID : string, primaryCurrencyReward : number, trophyReward : number)
    assert(profileID, `Profile ID not provided!`)
    
    Actions.setShallowValue(profileID, "WinStreak", 0)
    Actions.giveChestGameReward(profileID, primaryCurrencyReward, trophyReward)
end)

Actions.ownChest = DataLib.Action(function(profileID : string, chestType : string)
    assert(profileID, `Profile ID not provided!`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile.ChestInventory[chestType] = true
end)

Actions.ownChair = DataLib.Action(function(profileID : string, chairType : string)
    assert(profileID, `Profile ID not provided!`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile.ChairInventory[chairType] = true
end)

Actions.equipChest = DataLib.Action(function(profileID : string, chestType : string)
    assert(profileID, `Profile ID not provided!`)
    assert(chestType, `Chest type not provided!`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile.ChestEquippedType = chestType
end)

Actions.unequipChest = DataLib.Action(function(profileID : string)
    assert(profileID, `Profile ID not provided!`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile.ChestEquippedType = nil
end)

Actions.equipChair = DataLib.Action(function(profileID : string, chestType : string)
    assert(profileID, `Profile ID not provided!`)
    assert(chestType, `Chest type not provided!`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile.ChairEquippedType = chestType
end)

Actions.unequipChair = DataLib.Action(function(profileID : string)
    assert(profileID, `Profile ID not provided!`)

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile.ChairEquippedType = nil
end)

Actions.setEngagementTracker = DataLib.Action(function(profileID : string, engagementTracker : EngagementRewardTypes.EngagementTracker)
    assert(profileID, "Profile ID not provided!")
    assert(engagementTracker, "Engagement tracker not provided!")

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile.EngagementTracker = engagementTracker
end)

Actions.setDailyTracker = DataLib.Action(function(profileID : string, dailyTracker : DailyRewardTypes.DailyTracker)
    assert(profileID, "Profile ID not provided!")
    assert(dailyTracker, "Daily tracker not provided!")

    local profile = Data.Profiles[profileID]
    assert(profile, `Could not find profile with ID: {profileID}`)
    
    profile.DailyTracker = dailyTracker
end)

return DataLib.StateContainer(Actions, Data)
:SetTag("NetworkDiscriminator", "ProfileState")
:AddToNetwork()
