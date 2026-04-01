# UI System Documentation

## Overview

The UI System is a comprehensive client-side framework that provides reactive, real-time user interface components integrated with TLib UILib and the framework's state container pattern. It handles player stats display, game-specific UI, and responsive data binding with automatic updates when state changes occur.

## Quick Start

### 1. Basic Viewer Component
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILib = require(ReplicatedStorage.TLib.UILib)

local MyViewer = UILib.Viewer()
MyViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.MyScreen:Clone())
MyViewer:AutoParent()
```

### 2. Reactive Data Binding
```lua
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)

ProfileState.addProfile.listen(function(profileID: string)
    updateUI() -- React to profile creation
end)

ProfileState.incrementCurrency.listen(function(profileID: string)
    updateUI() -- React to currency changes
end)
```

## Architecture

### File Structure
```
GameClient/UISystem/
├── UISystemLoader.luau                # System initialization
├── PlayerStatsUI/                     # Player stats components
│   ├── PlayerStatsViewer.luau        # Main stats screen viewer
│   ├── CurrencyUpdater.luau          # Real-time currency updates
│   └── TrophyUpdater.luau            # Real-time trophy updates
└── ChestGameUI/                       # Chest game UI components
    ├── ChestGameViewer.luau          # Chest game screen viewer
    ├── ChestGameBillboardUI.luau     # Participant count billboards
    ├── ChestGameTimeObjective.luau   # Timer and objective display
    └── ChestGameHealth.luau          # Health display billboards
```

### TLib UILib Integration

The UI System is built on TLib's UILib framework which provides:

#### Core Viewer Class
```lua
-- Create a new viewer
local viewer = UILib.Viewer()

-- Hydrate with UI prefab
viewer:Hydrate(uiPrefabInstance)

-- Auto-parent to PlayerGui
viewer:AutoParent()

-- Update labels by ID
viewer:SetLabel("PrimaryCurrencyAmount", "1000")
viewer:SetLabelVisible("Objective", true)
```

#### Label System
- **LabelID Attribute**: Applied to TextLabel, TextBox, or ImageLabel instances
- **Automatic Discovery**: Viewer automatically scans for LabelID attributes
- **Type-Aware**: Handles text for TextLabel/TextBox, images for ImageLabel
- **Visibility Control**: Built-in methods for showing/hiding labels

#### Reference System
- **RefID Attribute**: References to any UI instance
- **Hierarchical Access**: Get instances and their children/descendants
- **Exclusion Support**: RefExcludeDescendants for selective scanning

## Data Structures

### Viewer Component
```lua
type Viewer = {
    Tree: Instance?,                    -- Root UI instance
    InteractionContext: InteractionContext,
    _labels: {[string]: TextLabel | TextBox | ImageLabel},
    _refs: {[string]: Instance},
    _trove: Trove                       -- Cleanup management
}
```

### UI Prefab Structure
```lua
-- ScreenGui with LabelID attributes
ScreenGui
├── Frame
│   ├── TextLabel (LabelID: "PrimaryCurrencyAmount")
│   ├── TextLabel (LabelID: "TrophyAmount")
│   └── TextLabel (LabelID: "Objective", Visible: false)
└── BillboardGui (Adornee: Mat part)
    └── TextLabel (LabelID: "ParticipantCount")
```

### State Integration
```lua
-- ProfileState reactive data
type Profile = {
    Currencies: {
        Primary: number
    },
    Trophies: number,
    Wins: number,
    WinStreak: number
}

-- ChestGameState reactive data
type ChestGame = {
    State: ChestGameState,
    Participants: {[string]: ChestGameParticipant},
    TimerMax: number?
}
```

## API Reference

### Core Viewer Methods

#### SetLabel
```lua
viewer:SetLabel(labelID: string, content: string)
```
Updates the content of a labeled UI element.

#### SetLabelVisible
```lua
viewer:SetLabelVisible(labelID: string, isVisible: boolean)
```
Controls the visibility of labeled UI elements.

#### GetLabel
```lua
local content = viewer:GetLabel(labelID: string)
```
Retrieves the current content of a labeled element.

#### FromRef
```lua
local instance = viewer:FromRef(refID: string)
```
Retrieves UI instances by RefID attribute.

#### AutoParent
```lua
viewer:AutoParent()
```
Automatically parents the UI to the local player's PlayerGui.

#### Destroy
```lua
viewer:Destroy()
```
Cleans up the viewer and all associated resources.

### Reactive Components

#### CurrencyUpdater
```lua
-- Reacts to ProfileState currency changes
ProfileState.incrementCurrency.listen(function(profileID: string)
    if profileID == localPlayerID then
        updateCurrencyDisplay()
    end
end)
```

#### TrophyUpdater
```lua
-- Reacts to ProfileState trophy changes
ProfileState.incrementShallowValue.listen(function(profileID: string)
    if profileID == localPlayerID then
        updateTrophyDisplay()
    end
end)
```

#### ChestGameBillboardUI
```lua
-- Stream-aware billboard creation
StreamingLibClient.listenToInstanceStreamedIn(
    chestGame.InstanceStreamableID, 
    onStreamIn
)

-- Reactive participant count updates
ChestGameState.addParticipant.listen(updateBillboardUI)
ChestGameState.removeParticipant.listen(updateBillboardUI)
```

## Configuration

### UI Prefab Requirements
1. **LabelID Attributes**: Add to TextLabel, TextBox, or ImageLabel instances
2. **RefID Attributes**: Add to instances that need programmatic access
3. **Resource Location**: Prefabs in `ReplicatedStorage.Resources.UIPrefabs/`
   - `Screens/` for ScreenGui instances
   - `Billboards/` for BillboardGui instances

### Required Prefabs
```lua
-- Player Stats
ReplicatedStorage.Resources.UIPrefabs.Screens.PlayerStats
├── PrimaryCurrencyAmount (LabelID)
└── TrophyAmount (LabelID)

-- Chest Game UI
ReplicatedStorage.Resources.UIPrefabs.Screens.ChestGame
├── Objective (LabelID)
└── Time (LabelID)

-- Chest Game Billboards
ReplicatedStorage.Resources.UIPrefabs.Billboards.ChestGamePlot
└── ParticipantCount (LabelID)

ReplicatedStorage.Resources.UIPrefabs.Billboards.ChestGameHealth
└── Health (LabelID)
```

## Integration Patterns

### State Container Integration
```lua
BootEvents.NetworkStarted:Connect(function()
    -- Initial UI update
    updateUI()
    
    -- Listen for state changes
    ProfileState.addProfile.listen(onProfileChange)
    ProfileState.incrementCurrency.listen(onCurrencyChange)
    ProfileState.incrementShallowValue.listen(onValueChange)
end)
```

### Streaming-Aware UI
```lua
-- Handle instance streaming
local function onStreamIn(instance: Instance)
    createUIForInstance(instance)
end

local function onStreamOut(instance: Instance)
    cleanupUIForInstance(instance)
end

StreamingLibClient.listenToInstanceStreamedIn(streamableID, onStreamIn)
StreamingLibClient.listenToInstanceStreamedOut(streamableID, onStreamOut)
```

### Real-time Updates
```lua
-- Heartbeat-based timer updates
RunService.Heartbeat:Connect(function()
    local activeGame = ChestGameHelper.getPlayerChestGame(player)
    if activeGame and activeGame.TimerMax then
        local timeString = `{(activeGame.TimerMax - TimeLib.getTime()) // 1}s`
        viewer:SetLabel("Time", timeString)
    end
end)
```

## Usage Examples

### Creating a Custom Reactive UI Component
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local ProfileState = require(ReplicatedStorage.GameCommon.ProfileSystem.ProfileState)
local UILib = require(ReplicatedStorage.TLib.UILib)

local CustomStatsViewer = UILib.Viewer()
CustomStatsViewer:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Screens.CustomStats:Clone())
CustomStatsViewer:AutoParent()

local LocalPlayer = Players.LocalPlayer
local LocalPlayerID = tostring(LocalPlayer.UserId)

local function updateStats()
    local profile = ProfileState.Data.Profiles[LocalPlayerID]
    if profile then
        CustomStatsViewer:SetLabel("Wins", tostring(profile.Wins or 0))
        CustomStatsViewer:SetLabel("WinStreak", tostring(profile.WinStreak or 0))
    else
        CustomStatsViewer:SetLabel("Wins", "?")
        CustomStatsViewer:SetLabel("WinStreak", "?")
    end
end

BootEvents.NetworkStarted:Connect(function()
    updateStats()
    
    ProfileState.addProfile.listen(function(profileID: string)
        if profileID == LocalPlayerID then
            updateStats()
        end
    end)
    
    ProfileState.incrementShallowValue.listen(function(profileID: string)
        if profileID == LocalPlayerID then
            updateStats()
        end
    end)
end)

return CustomStatsViewer
```

### Creating Dynamic Billboard UI
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StreamingLibClient = require(ReplicatedStorage.TLib.StreamingLib.StreamingLibClient)
local UILib = require(ReplicatedStorage.TLib.UILib)

local function createDynamicBillboard(targetInstance, data)
    local billboard = UILib.Viewer()
    billboard:Hydrate(ReplicatedStorage.Resources.UIPrefabs.Billboards.DynamicInfo:Clone())
    billboard:AutoParent()
    billboard.Tree.Adornee = targetInstance
    
    -- Update with data
    billboard:SetLabel("InfoText", data.text)
    billboard:SetLabelVisible("InfoText", data.visible)
    
    return billboard
end

-- Example usage with streaming awareness
local function onInstanceStreamIn(instance)
    local data = getInstanceData(instance)
    local billboard = createDynamicBillboard(instance, data)
    storeBillboard(instance, billboard)
end

StreamingLibClient.listenToInstanceStreamedIn(streamableID, onInstanceStreamIn)
```

### Creating Time-Based UI Updates
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TimeLib = require(ReplicatedStorage.TLib.TimeLib)

local function createTimerUI(viewer, timerLabelID, endTime)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local timeRemaining = endTime - TimeLib.getTime()
        
        if timeRemaining > 0 then
            local timeString = `{math.ceil(timeRemaining)}s`
            viewer:SetLabel(timerLabelID, timeString)
        else
            viewer:SetLabelVisible(timerLabelID, false)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    
    return connection
end

-- Usage
local timerConnection = createTimerUI(
    ChestGameViewer, 
    "Time", 
    activeChestGame.TimerMax
)
```

## Reactive UI Patterns

### State-Driven Updates
```lua
-- Pattern 1: Direct state subscription
local function setupReactiveUI(viewer, stateContainer, actionsToListen)
    local updateFunction = function(...)
        -- Update UI based on current state
        updateUIFromState(viewer, stateContainer.Data)
    end
    
    -- Subscribe to relevant state changes
    for _, actionName in actionsToListen do
        stateContainer[actionName].listen(updateFunction)
    end
    
    -- Initial update
    updateFunction()
end

-- Usage
setupReactiveUI(PlayerStatsViewer, ProfileState, {
    "addProfile", "incrementCurrency", "incrementShallowValue"
})
```

### Conditional Visibility
```lua
-- Pattern 2: Context-aware visibility
local function updateContextualUI(viewer, gameState)
    -- Show/hide UI based on game state
    if gameState == "ChoosingChests" then
        viewer:SetLabelVisible("Objective", true)
        viewer:SetLabel("Objective", "CHOOSE YOUR CHESTS!")
    elseif gameState == "InAction" then
        viewer:SetLabelVisible("Objective", false)
    end
end
```

### Multi-State Integration
```lua
-- Pattern 3: Cross-system data binding
local function setupMultiStateUI(viewer)
    local updateAll = function()
        local profile = ProfileState.Data.Profiles[LocalPlayerID]
        local chestGame = ChestGameHelper.getPlayerChestGame(LocalPlayer)
        
        -- Combine data from multiple state containers
        updatePlayerStats(viewer, profile)
        updateGameStatus(viewer, chestGame)
    end
    
    -- Subscribe to all relevant state changes
    ProfileState.addProfile.listen(updateAll)
    ProfileState.incrementCurrency.listen(updateAll)
    ChestGameState.changeState.listen(updateAll)
end
```

## Troubleshooting

### Common Issues

#### UI Not Updating
**Problem**: UI elements don't reflect state changes
**Solution**: 
- Verify `BootEvents.NetworkStarted` has fired
- Check if correct state actions are being listened to
- Ensure profile ID matches local player ID
- Verify LabelID attributes are correctly set

#### Prefab Loading Errors
**Problem**: UI prefab not found or fails to load
**Solution**:
- Check prefab path in `ReplicatedStorage.Resources.UIPrefabs/`
- Verify prefab instance is a valid GuiObject
- Ensure prefab has proper LabelID attributes
- Use `.Clone()` to avoid modifying the original prefab

#### Streaming UI Issues
**Problem**: Billboard UI doesn't appear on instances
**Solution**:
- Verify instance has `InstanceStreamableID` in state
- Check `StreamingLibClient.getInstance()` returns valid instance
- Ensure Adornee property is set correctly
- Verify stream in/out event listeners are connected

#### Memory Leaks
**Problem**: UI elements not cleaning up properly
**Solution**:
- Call `viewer:Destroy()` when UI is no longer needed
- Use viewer's `_trove` for resource cleanup
- Disconnect event listeners in cleanup functions
- Ensure streaming-aware cleanup on stream out

#### Performance Issues
**Problem**: UI updates causing lag
**Solution**:
- Batch multiple UI updates together
- Use `task.spawn()` for expensive updates
- Limit Heartbeat update frequency
- Implement debouncing for rapid state changes

### Debug Tools

#### Viewer Inspection
```lua
-- Check viewer state
print("Viewer tree:", viewer.Tree)
print("Labels:", viewer._labels)
print("Refs:", viewer._refs)

-- Test label updates
viewer:SetLabel("TestLabel", "DEBUG_TEXT")
viewer:SetLabelVisible("TestLabel", true)
```

#### State Monitoring
```lua
-- Monitor state changes
ProfileState.addProfile.listen(function(profileID)
    print("Profile added:", profileID)
    print("Profile data:", ProfileState.Data.Profiles[profileID])
end)

ChestGameState.changeState.listen(function(chestGameID, newState)
    print("Game state changed:", chestGameID, "→", newState)
end)
```

#### Event Connection Verification
```lua
-- Verify event connections
local function verifyConnections()
    local profile = ProfileState.Data.Profiles[LocalPlayerID]
    print("Profile exists:", profile ~= nil)
    print("Profile data:", profile)
    
    local gameID, game = ChestGameHelper.getPlayerChestGame(LocalPlayer)
    print("In chest game:", game ~= nil)
    print("Game state:", game and game.State)
end

BootEvents.NetworkStarted:Connect(verifyConnections)
```

## Performance Considerations

### Optimization Strategies

#### Event Debouncing
```lua
local function createDebouncedUpdate(delay: number)
    local isDebouncing = false
    
    return function()
        if isDebouncing then
            return
        end
        
        isDebouncing = true
        task.delay(delay, function()
            isDebouncing = false
        end)
        
        -- Perform update
        updateUI()
    end
end

local debouncedUpdate = createDebouncedUpdate(0.1)
ProfileState.incrementCurrency.listen(debouncedUpdate)
```

#### Batch UI Updates
```lua
local function batchUpdateUI(updates: {() -> ()})
    for _, update in updates do
        task.spawn(update)
    end
end

-- Usage
batchUpdateUI({
    function() viewer:SetLabel("Currency", currency) end,
    function() viewer:SetLabel("Trophies", trophies) end,
    function() viewer:SetLabel("Wins", wins) end
})
```

#### Memory Management
```lua
-- Proper cleanup pattern
local function setupReactiveUI(viewer)
    local connections = {}
    
    -- Store connections for cleanup
    table.insert(connections, 
        ProfileState.incrementCurrency.listen(updateUI)
    )
    
    -- Cleanup function
    local function cleanup()
        for _, connection in connections do
            if connection then
                connection:Disconnect()
            end
        end
        viewer:Destroy()
    end
    
    return cleanup
end
```

## Integration with Framework

### TLib Dependencies
- **UILib**: Core viewer and UI component framework
- **DataLib**: State container integration for reactive updates
- **StreamingLib**: Instance streaming awareness for dynamic UI
- **TimeLib**: Time utilities for timer-based UI updates
- **OrderedSignal**: Event ordering for boot system integration

### Framework Patterns
- **Reactive Architecture**: UI automatically responds to state changes
- **Component-Based**: Modular UI components with clear responsibilities
- **Streaming-Aware**: Handles instance streaming gracefully
- **Resource Management**: Automatic cleanup through Trove integration

### Boot System Integration
```lua
-- All UI components automatically initialize via BootEvents.NetworkStarted
BootEvents.NetworkStarted:Connect(function()
    -- Initialize PlayerStatsUI components
    -- Initialize ChestGameUI components
    -- Set up state listeners
    -- Perform initial UI updates
end)
```

## Best Practices

### Component Design
1. **Single Responsibility**: Each component handles one UI aspect
2. **State Isolation**: Components only listen to relevant state changes
3. **Clean Separation**: Viewer logic separate from state management
4. **Resource Cleanup**: Always provide cleanup methods

### Performance
1. **Minimal Updates**: Only update UI when relevant data changes
2. **Batch Operations**: Group multiple UI updates together
3. **Debounce Rapid Changes**: Prevent excessive update frequency
4. **Memory Awareness**: Clean up unused viewers and connections

### Maintainability
1. **Clear LabelIDs**: Use descriptive names for UI elements
2. **Consistent Patterns**: Follow established component structure
3. **Documentation**: Document complex UI interactions
4. **Type Safety**: Use Luau type annotations where possible

(End of file - total 458 lines)