# Profile System Documentation

## Overview

The Profile System is a comprehensive player data management framework that handles persistent storage, currency management, and player statistics. It provides a robust foundation for tracking player progress, rewards, and in-game economy with automatic data reconciliation and network synchronization.

## Quick Start

### 1. Profile Structure
```lua
-- Default profile structure automatically created for new players
local profile = {
    Wins = 0,           -- Total number of wins
    WinStreak = 0,      -- Current win streak
    Trophies = 0,       -- Trophy count
    Currencies = {
        Primary = 0,    -- Primary currency amount
        -- Additional currencies can be added dynamically
    }
}
```

### 2. Profile Lifecycle
- **Player Joins**: Profile loaded from DataStore with reconciliation
- **In-Game**: Real-time state synchronization via ProfileState
- **Player Leaves**: Profile automatically saved to DataStore
- **Game Shutdown**: All profiles saved before server close

### 3. Currency Management
```lua
-- Add currency to player
ProfileState.Actions.giveCurrency(playerId, "Primary", 100)

-- Take currency from player
ProfileState.Actions.takeCurrency(playerId, "Primary", 50)

-- Increment by any amount (positive or negative)
ProfileState.Actions.incrementCurrency(playerId, "Primary", 25)
```

## Architecture

### File Structure
```
GameCommons/ProfileSystem/
├── ProfileSystemTypes.luau    # Type definitions and exports
├── ProfileStruct.luau         # Default profile data structure
└── ProfileState.luau          # State container with actions

GameServer/ProfileSystem/
├── DataLoading.luau           # Server-side profile loading and reconciliation
└── DataSaving.luau            # Server-side profile saving with retry logic

GameClient/ProfileSystem/
└── DataLoading.luau           # Client-side placeholder for future UI integration
```

### State Management
The system uses the framework's **State Container Pattern** with DataLib:

```lua
-- Network-synchronized state container
return DataLib.StateContainer(Actions, Data)
    :SetTag("NetworkDiscriminator", "ProfileState")
    :AddToNetwork()
```

### Data Flow Architecture
1. **Player Join** → DataLoading retrieves/creates profile
2. **Reconciliation** → Missing fields added from ProfileStruct
3. **State Sync** → Profile added to ProfileState, syncs to clients
4. **Gameplay** → Real-time updates via ProfileState actions
5. **Player Leave** → DataSaving saves profile with retry logic

## Data Structures

### Profile Type
```lua
export type Profile = {
    Wins: number,                    -- Total wins accumulated
    WinStreak: number,               -- Current consecutive win streak
    Trophies: number,               -- Trophy count
    Currencies: {[string]: number}, -- Dynamic currency storage
}
```

### ProfileStruct (Default Template)
```lua
local ProfileStruct = {
    Wins = 0 :: number,
    WinStreak = 0 :: number,
    Trophies = 0 :: number,
    Currencies = {
        Primary = 0,               -- Default primary currency
    } :: {[string] : number},
}
```

### Player Key Format
```lua
-- DataStore key format: "{UserId}"
local playerKey = `{player.UserId}`  -- Example: "123456789"
```

## API Reference

### Profile Management Actions

#### addProfile
```lua
ProfileState.Actions.addProfile(profileID: string, profile: ProfileSystemTypes.Profile)
```
Adds a profile to the state container. Used internally by DataLoading after successful profile load.

**Parameters:**
- `profileID`: Unique player identifier (UserId as string)
- `profile`: Complete profile data structure

#### removeProfile
```lua
ProfileState.Actions.removeProfile(profileID: string)
```
Removes a profile from the state container. Used internally during cleanup.

### Currency Management Actions

#### incrementCurrency
```lua
ProfileState.Actions.incrementCurrency(profileID: string, currencyName: string, amount: number)
```
Increments a currency by any amount (positive or negative).

**Parameters:**
- `profileID`: Player identifier
- `currencyName`: Name of the currency (e.g., "Primary")
- `amount`: Amount to increment (can be negative)

**Example:**
```lua
-- Add 100 primary currency
ProfileState.Actions.incrementCurrency(playerId, "Primary", 100)

-- Remove 50 primary currency
ProfileState.Actions.incrementCurrency(playerId, "Primary", -50)
```

#### giveCurrency
```lua
ProfileState.Actions.giveCurrency(profileID: string, currencyName: string, amount: number)
```
Gives positive amount of currency to player.

**Parameters:**
- `profileID`: Player identifier
- `currencyName`: Name of the currency
- `amount`: Positive amount to give

**Validation:** Amount must be > 0

#### takeCurrency
```lua
ProfileState.Actions.takeCurrency(profileID: string, currencyName: string, amount: number)
```
Takes positive amount of currency from player.

**Parameters:**
- `profileID`: Player identifier
- `currencyName`: Name of the currency
- `amount`: Positive amount to take

**Validation:** Amount must be > 0

### General Value Management Actions

#### setShallowValue
```lua
ProfileState.Actions.setShallowValue(profileID: string, key: string, value: any)
```
Sets a shallow profile value (top-level properties only).

**Parameters:**
- `profileID`: Player identifier
- `key`: Property name (e.g., "Wins", "WinStreak", "Trophies")
- `value`: New value to set

**Example:**
```lua
-- Reset win streak
ProfileState.Actions.setShallowValue(playerId, "WinStreak", 0)

-- Set trophies directly
ProfileState.Actions.setShallowValue(playerId, "Trophies", 500)
```

#### incrementShallowValue
```lua
ProfileState.Actions.incrementShallowValue(profileID: string, key: string, amount: number)
```
Increments a numeric shallow value.

**Parameters:**
- `profileID`: Player identifier
- `key`: Property name (must be numeric)
- `amount`: Amount to increment

**Validation:** Current value must be number

### Game Reward Actions

#### giveChestGameReward
```lua
ProfileState.Actions.giveChestGameReward(
    profileID: string, 
    primaryCurrencyReward: number, 
    trophyReward: number, 
    winAmount: number?, 
    winStreakAmount: number?
)
```
Rewards player with currency, trophies, and optional win statistics.

**Parameters:**
- `profileID`: Player identifier
- `primaryCurrencyReward`: Amount of primary currency to give
- `trophyReward`: Number of trophies to award
- `winAmount`: (Optional) Amount to increment Wins
- `winStreakAmount`: (Optional) Amount to increment WinStreak

#### winChestGame
```lua
ProfileState.Actions.winChestGame(
    profileID: string, 
    primaryCurrencyReward: number, 
    trophyReward: number, 
    winAmount: number?, 
    winStreakAmount: number?
)
```
Handles win rewards with all optional parameters typically used.

#### loseChestGame
```lua
ProfileState.Actions.loseChestGame(
    profileID: string, 
    primaryCurrencyReward: number, 
    trophyReward: number
)
```
Handles loss rewards (consolation rewards) and resets win streak to 0.

## Configuration

### DataStore Configuration
```lua
-- Main data store name (configured in DataLoading/DataSaving)
local MainDataStore = DataStoreService:GetDataStore("MainDataStore")

-- Retry attempts for data operations
local MAX_ATTEMPTS = 3

-- Save timeout duration (seconds)
local SAVE_TIMEOUT = 60
```

### Budget Management
The system automatically checks DataStore request budgets:
- **Load Operations**: Requires >= 1 GetAsync budget
- **Save Operations**: Requires > 0 UpdateAsync budget
- **Automatic Waiting**: Waits for budget replenishment if needed

### Error Handling Configuration
```lua
-- Player kick message on load failure
local LOAD_FAILURE_MESSAGE = "Please rejoin!"

-- Maximum concurrent save operations
-- (Handled automatically by Promise timeouts)
```

## Data Loading (Server-Side)

### Profile Loading Process
1. **Player Added**: Trigger on Players.PlayerAdded
2. **Data Retrieval**: GetAsync from DataStore with retry logic
3. **Reconciliation**: Merge missing fields from ProfileStruct
4. **State Addition**: Add reconciled profile to ProfileState
5. **Network Sync**: Profile automatically syncs to all clients

### Reconciliation Algorithm
```lua
local function reconcile(tbl : {}, src : {})
    for i, v in src do
        local shouldRecurse = false

        if tbl[i] == nil and typeof(v) ~= "table" then
            tbl[i] = v
        elseif tbl[i] == nil and typeof(v) == "table" then
            tbl[i] = table.clone(v)
            shouldRecurse = false
        end

        if typeof(v) == "table" and tbl[i] ~= nil and shouldRecurse == true then
            reconcile(tbl[i], v)
        end
    end
end
```

### Loading Error Handling
- **Retry Logic**: Up to 3 attempts with budget checking
- **Failure Recovery**: Player kick with rejoin message
- **Warning System**: Comprehensive logging for debugging

## Data Saving (Server-Side)

### Save Triggers
1. **Player Removing**: Automatic save on player disconnect
2. **Game Shutdown**: Save all profiles on server close
3. **Manual Save**: Available through setSave function

### Save Process with Retry Logic
```lua
local function setSave(key : string, profile : ProfileSystemTypes.Profile, maxAttempts : number?) : PromiseLibTypes.Promise<() -> ()>
    return PromiseLib.new(function(resolve, reject, onCancel, onCleanup)
        local currentAttempts = 0
        local latestErr : string? = nil

        while currentAttempts < maxAttempts do
            if DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync) > 0 then
                local success, err = pcall(function()
                    MainDataStore:SetAsync(key, profile)
                end)

                if success then
                    resolve()
                    return
                else
                    warn(err)
                    latestErr = err
                end

                currentAttempts += 1
            end; task.wait()
        end

        reject(latestErr, currentAttempts)
    end)
end
```

### Cleanup Operations
- **Profile Removal**: Automatic removal from ProfileState after save
- **Promise Timeout**: 60-second timeout prevents hanging
- **Final Status**: Complete logging of save operations

## Client-Side Integration

### Current State
The client-side DataLoading module is currently a placeholder for future UI integration:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)

return nil
```

### Future Integration Points
- **UI Updates**: Respond to ProfileState action events
- **Real-time Display**: Show currency and stats updates via action monitoring
- **Notifications**: Display reward notifications on action completion
- **Profile Display**: Player profile viewing interface

### Recommended Client Implementation
```lua
-- Example client-side integration (not implemented)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)

-- Listen for profile updates
ProfileState.OnActionDone:Connect(function(actionName, ...)
    -- Access current state data
    local currentData = ProfileState.Data
    
    -- React to specific profile changes
    if actionName == "addProfile" then
        local profileID = ...
        if profileID == game.Players.LocalPlayer.UserId then
            updatePlayerUI(currentData.Profiles[profileID])
        end
    elseif actionName == "incrementCurrency" or actionName == "setShallowValue" then
        local profileID = ...
        if profileID == game.Players.LocalPlayer.UserId then
            updatePlayerUI(currentData.Profiles[profileID])
        end
    end
end)

-- Alternative: Listen to specific actions
ProfileState.incrementCurrency.listen(function(profileID, currencyName, amount)
    if profileID == game.Players.LocalPlayer.UserId then
        local profile = ProfileState.Data.Profiles[profileID]
        updatePlayerUI(profile)
    end
end)

local function updatePlayerUI(profile: ProfileSystemTypes.Profile)
    -- Update currency displays
    -- Update win counters
    -- Update trophy display
end
```

## Network Communication

### State Synchronization
- **Network Discriminator**: "ProfileState"
- **Automatic Sync**: All profile changes sync to clients
- **Real-time Updates**: Currency and stat changes propagate instantly
- **Event-Driven**: Clients can respond to action events

### Data Privacy
- **Selective Access**: Players only see their own profile data
- **Server Authority**: All modifications happen server-side
- **Validation**: Server validates all profile modifications

### Network Flow
1. **Server Load**: Profile loaded and added to ProfileState
2. **Sync**: Profile data automatically syncs to owning client
3. **Client Display**: UI updates based on synced data and action events
4. **Game Actions**: Server modifies profile via actions
5. **Real-time Sync**: Changes instantly propagate to client via action events

## Integration with Framework

### TLib Dependencies
- **DataLib**: State container pattern and network synchronization
- **PromiseLib**: Asynchronous data operations with error handling
- **BootSystem**: Startup event coordination for profile systems

### Framework Patterns
- **State Container Pattern**: Centralized profile state management
- **Promise-Based Operations**: Robust async error handling
- **Type Safety**: Strict Luau typing throughout
- **Event-Driven Architecture**: Reactive profile updates

### Boot System Integration
```lua
-- Automatic initialization via BootEvents.NetworkStarted
BootEvents.NetworkStarted:Connect(function()
    -- Initialize DataLoading for new players
    Players.PlayerAdded:Connect(onPlayerAdded)
    
    -- Initialize DataSaving for leaving players
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    -- Handle graceful shutdown
    game:BindToClose(onGameClose)
end)
```

## Usage Examples

### Basic Currency Management
```lua
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)

-- Give player reward for completing quest
local function rewardPlayer(playerId, currencyAmount, trophyAmount)
    ProfileState.Actions.giveCurrency(playerId, "Primary", currencyAmount)
    ProfileState.Actions.incrementShallowValue(playerId, "Trophies", trophyAmount)
end

-- Purchase item cost check and deduction
local function purchaseItem(playerId, cost)
    local profile = ProfileState.Data.Profiles[playerId]
    if profile and profile.Currencies.Primary >= cost then
        ProfileState.Actions.takeCurrency(playerId, "Primary", cost)
        return true
    end
    return false
end
```

### Chest Game Integration
```lua
-- Handle game win
local function onPlayerWin(playerId, baseReward)
    ProfileState.Actions.winChestGame(
        playerId,
        baseReward.primaryCurrency,
        baseReward.trophies,
        1,      -- Win increment
        1       -- Win streak increment
    )
end

-- Handle game loss
local function onPlayerLoss(playerId, consolationReward)
    ProfileState.Actions.loseChestGame(
        playerId,
        consolationReward.primaryCurrency,
        consolationReward.trophies
    )
end
```

### Custom Currency Addition
```lua
-- Add new currency type to existing profile
local function addPremiumCurrency(playerId, amount)
    -- Premium currency will be created if it doesn't exist
    ProfileState.Actions.giveCurrency(playerId, "Premium", amount)
end

-- Check currency balance
local function getCurrencyBalance(playerId, currencyName)
    local profile = ProfileState.Data.Profiles[playerId]
    if profile and profile.Currencies[currencyName] then
        return profile.Currencies[currencyName]
    end
    return 0
end
```

### Advanced Profile Management
```lua
-- Reset player statistics (admin function)
local function resetPlayerStats(playerId)
    ProfileState.Actions.setShallowValue(playerId, "Wins", 0)
    ProfileState.Actions.setShallowValue(playerId, "WinStreak", 0)
    ProfileState.Actions.setShallowValue(playerId, "Trophies", 0)
    
    -- Optionally reset currency
    local profile = ProfileState.Data.Profiles[playerId]
    if profile then
        for currencyName in pairs(profile.Currencies) do
            ProfileState.Actions.setShallowValue(playerId, currencyName, 0)
        end
    end
end

-- Grant achievement rewards
local function grantAchievementReward(playerId, rewards)
    if rewards.currency then
        for currencyName, amount in pairs(rewards.currency) do
            ProfileState.Actions.giveCurrency(playerId, currencyName, amount)
        end
    end
    
    if rewards.trophies then
        ProfileState.Actions.incrementShallowValue(playerId, "Trophies", rewards.trophies)
    end
end
```

## Troubleshooting

### Common Issues

#### Profile Not Loading
- **Check**: DataLoading module is loaded via BootEvents.NetworkStarted
- **Check**: Player has proper network connectivity
- **Check**: DataStore service is available
- **Check**: DataStore request budget is not exhausted

#### Currency Updates Not Syncing
- **Check**: ProfileState network discriminator is properly set
- **Check**: Client has network connection to server
- **Check**: Profile exists in ProfileState.Data.Profiles
- **Check**: Action parameters are valid (non-nil, correct types)

#### Save Failures
- **Check**: DataSaving module is initialized
- **Check**: PlayerRemoving event is connected
- **Check**: DataStore request budget for UpdateAsync
- **Check**: Profile data is not corrupted (invalid types)

#### Reconciliation Issues
- **Check**: ProfileStruct matches expected schema
- **Check**: Loaded data structure is not severely corrupted
- **Check**: New fields are properly added to ProfileStruct

#### Performance Issues
- **Check**: Excessive ProfileState actions in short time
- **Check**: DataStore request budget depletion
- **Check**: Large profile data sizes
- **Check**: Concurrent save operations

### Debug Tools
```lua
-- Inspect all loaded profiles
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)
for playerId, profile in pairs(ProfileState.Data.Profiles) do
    print("Player:", playerId)
    print("  Wins:", profile.Wins)
    print("  WinStreak:", profile.WinStreak)
    print("  Trophies:", profile.Trophies)
    print("  Currencies:", profile.Currencies)
end

-- Monitor ProfileState changes
ProfileState.OnActionDone:Connect(function(actionName, ...)
    print(`ProfileState action: ${actionName}`, ...)
    -- Access current state
    print("Current state:", ProfileState.Data)
end)

-- Check currency balance
local function debugCurrency(playerId, currencyName)
    local profile = ProfileState.Data.Profiles[playerId]
    if profile then
        print(`{currencyName} balance:`, profile.Currencies[currencyName] or 0)
    else
        print("Profile not found for player:", playerId)
    end
end
```

### DataStore Issues
```lua
-- Check DataStore availability
local DataStoreService = game:GetService("DataStoreService")
local success, result = pcall(function()
    return DataStoreService:GetDataStore("MainDataStore")
end)

if success then
    print("DataStore accessible:", result)
else
    print("DataStore error:", result)
end

-- Monitor request budgets
local function checkBudgets()
    local getBudget = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)
    local updateBudget = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)
    
    print("GetAsync budget:", getBudget)
    print("UpdateAsync budget:", updateBudget)
end
```

## Performance Considerations

### Optimization Tips
- **Batch Operations**: Group multiple ProfileState actions when possible
- **Currency Consolidation**: Use fewer currency types for better performance
- **Save Frequency**: Rely on automatic saves; avoid manual saves
- **Data Size**: Keep profile data minimal for faster saves/loads

### Memory Management
- **Profile Cleanup**: Automatic removal on player disconnect
- **State Size**: Monitor ProfileState size with many concurrent players
- **Promise Cleanup**: Automatic cleanup with 60-second timeouts
- **Event Connections**: Proper event management in BootSystem

### Network Optimization
- **Delta Sync**: Only changed data propagates to clients
- **Compression**: ProfileState handles efficient data transfer
- **Bandwidth**: Minimize unnecessary profile modifications
- **Client Filtering**: Players only receive their own profile data

## Future Enhancements

### Potential Features
- **Profile Versioning**: Support for profile schema migrations
- **Profile History**: Track player progress over time
- **Leaderboards**: Global ranking system based on profiles
- **Profile Backup**: Multiple backup locations for redundancy
- **Offline Processing**: Handle rewards for offline players
- **Profile Analytics**: Detailed player behavior tracking

### Extensibility Points
- **Custom Currencies**: Dynamic currency system with properties
- **Achievement System**: Integration with achievement tracking
- **Seasonal Data**: Time-based profile resets and rewards
- **Profile Templates**: Starting profiles for different player types
- **DataStore Sharding**: Multiple DataStores for scalability
- **Profile Validation**: Custom validation rules for profile data

### Integration Opportunities
- **Economy System**: Advanced market and trading features
- **Social System**: Friends lists and profile sharing
- **Progression System**: Level and experience integration
- **Inventory System**: Item management with profile storage
- **Analytics Dashboard**: Real-time player data visualization

## Security Considerations

### Data Integrity
- **Server Authority**: All profile modifications server-side
- **Input Validation**: Comprehensive parameter validation in actions
- **Type Checking**: Strict type enforcement prevents corruption
- **Reconciliation**: Automatic repair of corrupted profile data

### Anti-Exploit Measures
- **Validation**: All currency modifications validated
- **Rate Limiting**: Consider rate limiting for profile actions
- **Audit Trail**: Profile changes could be logged for analysis
- **Bounds Checking**: Prevent negative currencies and invalid stats

### Data Protection
- **Privacy**: Players only access their own profile data
- **Encryption**: DataStore provides encryption at rest
- **Access Control**: No direct DataStore access from clients
- **Backup Strategy**: Consider regular DataStore backups

(End of file - total 678 lines)