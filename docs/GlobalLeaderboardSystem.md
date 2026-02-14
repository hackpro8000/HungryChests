# Global Leaderboard System

## Overview

The Global Leaderboard System is a comprehensive server-client synchronized leaderboard framework built on TLib's DataLib architecture. It provides real-time leaderboard updates, automatic data persistence through Roblox DataStore, and seamless UI integration with surface-based leaderboard displays.

### Key Features

- **Real-time Synchronization**: Server-client state synchronization using DataLib
- **Automatic Data Persistence**: Built-in Roblox OrderedDataStore integration
- **Multiple Leaderboard Types**: Support for various ranking metrics (wins, trophies, coins, win streaks)
- **Surface-based UI**: Automatic leaderboard display on tagged surface instances
- **Event-driven Architecture**: OrderedSignal-based event system for predictable execution
- **Type Safety**: Full Luau type annotations throughout
- **Memory Management**: Automatic cleanup and resource management

## System Architecture

### Core Components

#### 1. GlobalLeaderboardState (`GameCommons/GlobalLeaderboardSystem/GlobalLeaderboardState.luau`)
Central state management using DataLib StateContainer pattern with automatic networking.

**Data Structure:**
```lua
type Leaderboard = {
    Title: string,
    Entries: {LeaderboardEntry}
}

type LeaderboardEntry = {
    UserIDString: string,
    Value: any
}
```

**Available Actions:**
- `registerLeaderboard(leaderboardID: string, title: string)`
- `clearEntries(leaderboardID: string)`
- `addEntry(leaderboardID: string, userIDString: string, value: any)`

#### 2. GlobalLeaderboardEvents (`GameCommons/GlobalLeaderboardSystem/GlobalLeaderboardEvents.luau`)
Event coordination using OrderedSignal for predictable execution order.

**Available Events:**
- `PreBoot`: Fired before leaderboard initialization
- `OnDownload`: Triggers data download from DataStore
- `OnUpload`: Triggers data upload to DataStore

#### 3. GlobalLeaderboardTypes (`GameCommons/GlobalLeaderboardSystem/GlobalLeaderboardTypes.luau`)
Type definitions for the leaderboard system.

#### 4. GlobalLeaderboardUpdateCycle (`GameServer/GlobalLeaderboardSystem/GlobalLeaderboardUpdateCycle.luau`)
Manages automatic data synchronization cycles (70-second intervals).

### Server-side Leaderboard Modules

Each leaderboard type follows the same pattern:

- **MostWinsLeaderboard**: Tracks player win counts
- **MostTrophiesLeaderboard**: Tracks player trophy counts  
- **MostCoinsLeaderboard**: Tracks player coin amounts
- **HighestWinStreakLeaderboard**: Tracks player highest win streaks

### Client-side UI System

#### GlobalLeaderboardRenderer (`GameClient/UISystem/GlobalLeaderboardUI/GlobalLeaderboardRenderer.luau`)
Manages leaderboard UI instances and updates them based on state changes.

#### GlobalLeaderboardSurfaceUI (`GameClient/UISystem/GlobalLeaderboardUI/GlobalLeaderboardSurfaceUI.luau`)
Individual leaderboard surface component with automatic rendering.

## API Reference

### GlobalLeaderboardState

#### Server Actions

```lua
-- Register a new leaderboard
GlobalLeaderboardState:GetServer().registerLeaderboard(leaderboardID: string, title: string)

-- Clear all entries from a leaderboard
GlobalLeaderboardState:GetServer().clearEntries(leaderboardID: string)

-- Add an entry to a leaderboard
GlobalLeaderboardState:GetServer().addEntry(leaderboardID: string, userIDString: string, value: any)
```

#### Client Listeners

```lua
-- Listen for leaderboard registration
GlobalLeaderboardState.registerLeaderboard.listen(function(leaderboardID: string)
    -- Handle registration
end)

-- Listen for entry clearing
GlobalLeaderboardState.clearEntries.listen(function(leaderboardID: string)
    -- Handle clearing
end)

-- Listen for new entries
GlobalLeaderboardState.addEntry.listen(function(leaderboardID: string, userIDString: string, value: any)
    -- Handle new entry
end)
```

#### Data Access

```lua
-- Access leaderboard data
local leaderboard = GlobalLeaderboardState.Data.Leaderboards[leaderboardID]
local title = leaderboard.Title
local entries = leaderboard.Entries
```

### GlobalLeaderboardEvents

```lua
-- Connect to system events
GlobalLeaderboardEvents.PreBoot:Connect(function()
    -- Initialize leaderboard
end)

GlobalLeaderboardEvents.OnDownload:Connect(function()
    -- Download data from DataStore
end)

GlobalLeaderboardEvents.OnUpload:Connect(function()
    -- Upload data to DataStore
end)
```

### GlobalLeaderboardSurfaceUI

```lua
-- Create new leaderboard surface UI
local surfaceUI = GlobalLeaderboardSurfaceUI.new(leaderboardID: string, globalLeaderboardInstance: Instance)

-- Set the adornee (surface to display on)
surfaceUI:SetAdornee(surfacePart: BasePart)

-- Set leaderboard title
surfaceUI:SetTitle(title: string)

-- Add an entry
surfaceUI:AddEntry(userIDString: string, value: any)

-- Clear all entries
surfaceUI:ClearEntries()

-- Clean up
surfaceUI:Destroy()
```

## Implementation Patterns

### Creating a New Leaderboard

Follow this pattern for new leaderboard types:

```lua
local LEADERBOARD_ID = "YourLeaderboard"

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local GlobalLeaderboardEvents = require(ReplicatedStorage.GameCommons.GlobalLeaderboardSystem.GlobalLeaderboardEvents)
local GlobalLeaderboardState = require(ReplicatedStorage.GameCommons.GlobalLeaderboardSystem.GlobalLeaderboardState)
local ProfileState = require(ReplicatedStorage.GameCommons.ProfileSystem.ProfileState)

local OrderedDataStore = DataStoreService:GetOrderedDataStore(LEADERBOARD_ID)

-- DataStore operations
local function upload(key: string, value: any)
    OrderedDataStore:SetAsync(key, value)
end

local function download(): Pages?
    local result: Pages? = nil
    
    local function try()
        result = OrderedDataStore:GetSortedAsync(false, 50, 1)
    end
    
    for attempt = 1, 5 do
        local success, output = pcall(try)
        if success then
            break
        else
            warn(output)
        end
    end
    
    return result
end

-- Event handling
GlobalLeaderboardEvents.PreBoot:Connect(function()
    GlobalLeaderboardState:GetServer().registerLeaderboard(LEADERBOARD_ID, "YOUR TITLE")
    
    GlobalLeaderboardEvents.OnUpload:Connect(function()
        -- Upload logic: iterate through profiles and upload relevant data
        for profileID: string, profile in ProfileState.Data.Profiles do
            local successful, output = pcall(upload, profileID, profile.YourStat)
            if not successful then
                warn(output)
            end
        end
    end)
    
    GlobalLeaderboardEvents.OnDownload:Connect(function()
        local pages: Pages? = download()
        
        if pages then
            GlobalLeaderboardState:GetServer().clearEntries(LEADERBOARD_ID)
            
            for _, entry: {key: string, value: any} in pages:GetCurrentPage() do
                GlobalLeaderboardState:GetServer().addEntry(LEADERBOARD_ID, entry.key, entry.value)
            end
        end
    end)
end)
```

### Setting Up Leaderboard Surfaces

1. Create a Part or Model in your game world
2. Add a `StringValue` attribute named "LeaderboardID" with your leaderboard ID
3. Tag the instance with "GlobalLeaderboard" using CollectionService
4. Add a child Part named "Surface" for the UI to display on

Example:
```lua
-- In Roblox Studio:
-- 1. Create a Part named "LeaderboardDisplay"
-- 2. Add attribute: LeaderboardID = "MostWins"
-- 3. Add tag: GlobalLeaderboard
-- 4. Add child Part named "Surface"
```

## Configuration

### DataStore Settings

The system uses Roblox's built-in OrderedDataStore with these settings:

- **Sort Order**: Descending (highest values first)
- **Page Size**: 50 entries
- **Starting Page**: 1 (top entries)

### Update Cycle

- **Upload Interval**: 70 seconds
- **Download Interval**: 70 seconds
- **Retry Logic**: 5 attempts for DataStore operations
- **Error Handling**: Warnings logged on failures

## Integration with Framework

### TLib Dependencies

The system integrates with multiple TLib libraries:

- **DataLib**: State management and networking
- **OrderedSignal**: Event coordination
- **ProfileSystem**: Player data access for leaderboard stats

### Boot System Integration

The system initializes automatically through the Boot System:

1. `PreBoot` event registers leaderboards
2. `NetworkStarted` event begins sync cycles
3. UI components automatically connect and update

### State Container Pattern

Follows framework's State Container pattern with:
- Action-based state mutations
- Network discriminator tags
- Automatic client-server synchronization
- Type-safe data structures

## Performance Considerations

### DataStore Throttling

The system implements retry logic to handle DataStore rate limits:
- Maximum 5 retry attempts per operation
- Warning logs for failed operations
- Exponential backoff not implemented (consider for high-traffic games)

### Memory Management

- Automatic cleanup of UI connections
- Surface UI instances tracked and destroyed properly
- No memory leaks from event connections

### Network Efficiency

- Only changed leaderboard data is synced
- Batch operations for entry updates
- Efficient data structures minimize transfer size

## Troubleshooting

### Common Issues

**Leaderboard not displaying:**
- Verify the instance has the "GlobalLeaderboard" tag
- Check that "LeaderboardID" attribute matches a registered leaderboard
- Ensure there's a child Part named "Surface"

**Data not updating:**
- Check DataStore service permissions
- Verify ProfileSystem data is available
- Look for DataStore error warnings in output

**Performance issues:**
- Consider reducing leaderboard update frequency
- Implement data caching for frequently accessed leaderboards
- Monitor DataStore usage statistics

### Debugging

Enable detailed logging by modifying the retry logic:

```lua
local function try()
    result = OrderedDataStore:GetSortedAsync(false, 50, 1)
    print(`Successfully downloaded data for {LEADERBOARD_ID}`)
end

for attempt = 1, 5 do
    local success, output = pcall(try)
    if success then
        break
    else
        warn(`Attempt {attempt} failed for {LEADERBOARD_ID}: {output}`)
    end
end
```

## Future Enhancements

### Extension Points

The system is designed for easy extension:

1. **New Leaderboard Types**: Follow the existing pattern
2. **Custom UI Components**: Extend GlobalLeaderboardSurfaceUI
3. **Data Sources**: Replace DataStore with external APIs
4. **Event Listeners**: Add custom logic to state change events

## Best Practices

1. **Use meaningful leaderboard IDs** that reflect the tracked metric
2. **Implement proper error handling** for DataStore operations
3. **Consider rate limits** when designing update frequencies
4. **Test with realistic player counts** to ensure performance
5. **Monitor DataStore usage** to avoid hitting limits
6. **Use type annotations** for all new components
7. **Follow the State Container pattern** for consistency
8. **Clean up resources properly** to prevent memory leaks

The Global Leaderboard System provides a robust foundation for competitive features in your Roblox game, with automatic data persistence, real-time updates, and seamless UI integration.