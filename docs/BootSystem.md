# Boot System Documentation

## Overview

The Boot System provides a centralized framework for initializing and managing all game systems in a structured, event-driven manner. It ensures predictable startup sequences for both client and server environments while providing robust error handling and timing diagnostics.

The system uses a convention-based approach where system folders can either define explicit startup logic through `#SYSTEMSTARTUP` modules or rely on automatic module loading. All systems are coordinated through ordered events that guarantee proper initialization order.

## Quick Start

### 1. Basic System Folder Structure
```
GameServer/MySystem/
├── Module1.luau           # Automatically loaded
├── Module2.luau           # Automatically loaded
└── #SYSTEMSTARTUP.luau   # Optional explicit startup control

GameClient/MySystem/
├── ClientModule.luau      # Automatically loaded
└── #SYSTEMSTARTUP.luau   # Optional explicit startup control
```

### 2. Boot Sequence Events
- **SystemStarting** → **SystemStarted**: Core system initialization
- **NetworkStarting** → **NetworkStarted**: Network layer activation
- All events fire in order on both client and server

### 3. Default Loading Pattern
```lua
-- All modules in system folders are automatically loaded
-- No #SYSTEMSTARTUP required for simple systems
```

## Architecture

### File Structure
```
GameCommons/BootSystem/
├── BootEvents.luau           # Event system for boot coordination
├── Load.luau                 # Single module loader with timing
├── LoadChildren.luau         # Batch module loader for folders
└── LoadErrHandler.luau       # Error handling for failed loads

GameServer/BootSystem/
└── SystemStartup.server.luau # Server boot sequence controller

GameClient/BootSystem/
└── SystemStartup.client.luau # Client boot sequence controller
```

### Event System

The Boot System uses OrderedSignal for precise event coordination:

```lua
return {
    SystemStarting = OrderedSignal.new(),   -- Core system init begins
    SystemStarted = OrderedSignal.new(),    -- Core system init complete
    NetworkStarting = OrderedSignal.new(),  -- Network layer init begins
    NetworkStarted = OrderedSignal.new(),   -- Network layer init complete
}
```

### Loading Conventions

#### #SYSTEMSTARTUP Pattern
System folders can contain a `#SYSTEMSTARTUP` module for explicit control:

```lua
-- GameServer/MySystem/#SYSTEMSTARTUP.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Subscribe to boot events
BootEvents.SystemStarting:Connect(function()
    -- Initialize system before network is ready
end)

BootEvents.NetworkStarted:Connect(function()
    -- Initialize system after network is ready
    -- Safe to use DataLib.Networking here
end)

return {} -- Module must return something
```

#### Automatic Loading
Folders without `#SYSTEMSTARTUP` use automatic loading:

```lua
-- All ModuleScript children are loaded in order
-- No explicit startup logic required
```

## API Reference

### BootEvents

#### Events
```lua
BootEvents.SystemStarting  -- Fired when core initialization begins
BootEvents.SystemStarted   -- Fired when core initialization completes (deferred)
BootEvents.NetworkStarting -- Fired when network initialization begins
BootEvents.NetworkStarted  -- Fired when network initialization completes (deferred)
```

#### Usage Example
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)

BootEvents.SystemStarted:Connect(function()
    print("All systems initialized")
end)

BootEvents.NetworkStarted:Connect(function()
    print("Network layer ready - safe to use DataLib.Networking")
end)
```

### Load Utility

#### Function Signature
```lua
Load(moduleScript: ModuleScript, failureFn?: (ModuleScript, string) -> (), warnFn?: (string) -> ())
```

#### Parameters
- `moduleScript`: The ModuleScript to load
- `failureFn`: Optional error handler (defaults to LoadErrHandler)
- `warnFn`: Optional warning function for long load times

#### Features
- Tracks loading time with 5-second warnings
- Uses pcall for safe loading
- Cancels timing thread after completion
- Calls failureFn on loading errors

#### Usage Example
```lua
local Load = require(ReplicatedStorage.GameCommon.BootSystem.Load)

local function customErrorHandler(moduleScript, errorMessage)
    warn(`Custom error handler: {moduleScript.Name} failed: {errorMessage}`)
end

Load(myModule, customErrorHandler)
```

### LoadChildren Utility

#### Function Signature
```lua
LoadChildren(parent: Instance, failureFn?: (ModuleScript, string) -> (), warnFn?: (string) -> ())
```

#### Parameters
- `parent`: Parent instance containing ModuleScript children
- `failureFn`: Optional error handler (defaults to LoadErrHandler)
- `warnFn`: Optional warning function for long load times

#### Features
- Loads all ModuleScript children in sequence
- Same timing and error handling as Load utility
- Filters non-ModuleScript children automatically

#### Usage Example
```lua
local LoadChildren = require(ReplicatedStorage.GameCommon.BootSystem.LoadChildren)

LoadChildren(game.ServerScriptService.MySystem)
```

### LoadErrHandler

#### Function Signature
```lua
LoadErrHandler(childModule: ModuleScript, errorMessage: string)
```

#### Default Behavior
- Warns with module full name
- Warns with detailed error message
- Used as default error handler for Load/LoadChildren

#### Usage Example
```lua
local LoadErrHandler = require(ReplicatedStorage.GameCommon.BootSystem.LoadErrHandler)

-- Use as default handler
Load(myModule, LoadErrHandler)

-- Or use with custom logic
local function customHandler(module, error)
    LoadErrHandler(module, error)  -- Call default
    -- Add custom handling
end
```

## Configuration

### System Registration

Systems are automatically discovered by folder location:

```
GameServer/
├── MySystem1/           # Automatically discovered
├── MySystem2/           # Automatically discovered
└── BootSystem/          # Boot controller (not a regular system)

GameClient/
├── UISystem/            # Automatically discovered
├── ProfileSystem/       # Automatically discovered
└── BootSystem/          # Boot controller (not a regular system)
```

### Loading Priority

1. **SystemStarting Event**: All systems begin loading
2. **#SYSTEMSTARTUP Modules**: Load first if present
3. **Automatic Loading**: Load remaining modules
4. **SystemStarted Event**: All systems loaded (deferred)
5. **NetworkStarting Event**: Network layer initialization
6. **NetworkStarted Event**: Network ready (deferred)

### Error Handling Configuration

Default error handling can be customized per system:

```lua
-- Custom error handler for specific system
local function systemErrorHandler(moduleScript, errorMessage)
    -- Custom logging, metrics, or recovery logic
    warn(`System ${moduleScript.Parent.Name} failed to load ${moduleScript.Name}`)
    -- Could trigger fallback systems or graceful degradation
end

Load(systemModule, systemErrorHandler)
```

## Boot Sequences

### Server Boot Sequence

The server boot sequence (`SystemStartup.server.luau`):

```lua
BootEvents.SystemStarting:Fire(); do
    for _, systemFolder in script.Parent.Parent:GetChildren() do
        local systemStartupModule = systemFolder:FindFirstChild("#SYSTEMSTARTUP")
        
        if systemStartupModule then
            Load(systemStartupModule, LoadErrHandler)  -- Explicit startup
        else
            LoadChildren(systemFolder, LoadErrHandler)  -- Automatic loading
        end
    end
end; BootEvents.SystemStarted:FireDeferred()

BootEvents.NetworkStarting:Fire(); do
    DataLib.Networking:Start()    -- Initialize network layer
end; BootEvents.NetworkStarted:FireDeferred()
```

#### Server Characteristics
- **Error Handling**: Full error reporting with LoadErrHandler
- **Network Init**: Starts DataLib.Networking for state synchronization
- **System Discovery**: Scans GameServer/ folder for system folders
- **Deferred Events**: Uses deferred execution for proper ordering

### Client Boot Sequence

The client boot sequence (`SystemStartup.client.luau`):

```lua
BootEvents.SystemStarting:Fire(); do
    for _, systemFolder in script.Parent.Parent:GetChildren() do
        local systemStartupModule = systemFolder:FindFirstChild("#SYSTEMSTARTUP")
        
        if systemStartupModule then
            Load(systemStartupModule)  -- No error handler by default
        else
            LoadChildren(systemFolder)  -- No error handler by default
        end
    end
end; BootEvents.SystemStarted:FireDeferred()

BootEvents.NetworkStarting:Fire(); do
    DataLib.Networking:Start()    -- Initialize network layer
end; BootEvents.NetworkStarted:FireDeferred()
```

#### Client Characteristics
- **Silent Loading**: No default error handling (fails silently)
- **Network Init**: Starts DataLib.Networking for state synchronization
- **System Discovery**: Scans GameClient/ folder for system folders
- **Deferred Events**: Uses deferred execution for proper ordering

### Event Flow

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ SystemStarting  │───▶│ System Loading   │───▶│ SystemStarted   │
│   (Immediate)   │    │  (All Systems)   │    │   (Deferred)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│NetworkStarting  │───▶│ Network Init     │───▶│ NetworkStarted  │
│   (Immediate)   │    │(DataLib.Networking)│   │   (Deferred)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Integration with Framework

### TLib Dependencies

The Boot System integrates with several TLib components:

#### DataLib Integration
```lua
BootEvents.NetworkStarted:Connect(function()
    -- DataLib.Networking is now available
    -- Safe to use StateContainer.AddToNetwork()
    -- State synchronization is active
end)
```

#### OrderedSignal Integration
```lua
-- BootEvents uses OrderedSignal for priority-based execution
-- Systems can register with specific priorities if needed
```

### Framework Patterns

#### Event-Driven Architecture
```lua
-- Systems respond to boot events rather than direct calls
BootEvents.NetworkStarted:Connect(function()
    -- Initialize network-dependent systems
end)
```

#### Convention over Configuration
```lua
-- System folders automatically discovered
-- #SYSTEMSTARTUP modules optional
-- Default loading behavior works for most cases
```

#### Type Safety
```lua
-- All boot utilities use proper type annotations
-- Luau strict typing where critical
-- Error messages include type information
```

### System Lifecycle

#### Initialization Phases
1. **Discovery**: System folders scanned
2. **Loading**: Modules required and executed
3. **Network Ready**: DataLib.Networking started
4. **Runtime**: Systems operate normally

#### Cleanup Patterns
```lua
-- Systems should implement cleanup for proper shutdown
local function cleanup()
    -- Cleanup resources, disconnect events
end

-- Connect cleanup to appropriate events or game shutdown
game:BindToClose(cleanup)
```

## Usage Examples

### Simple System (Automatic Loading)

```lua
-- GameServer/MySystem/MyModule.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataLib = require(ReplicatedStorage.TLib.DataLib)

-- System logic - automatically loaded by boot system
local MySystem = {}

function MySystem.initialize()
    print("MySystem initialized automatically")
end

-- Wait for network before using DataLib.Networking
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
BootEvents.NetworkStarted:Connect(MySystem.initialize)

return MySystem
```

### Complex System (#STARTUP Control)

```lua
-- GameClient/MyComplexSystem/#SYSTEMSTARTUP.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)

local System = {}

function System.initializeCore()
    -- Initialize core components before network
    print("Complex system core initialized")
end

function System.initializeNetwork()
    -- Initialize network-dependent components
    print("Complex system network components ready")
end

-- Subscribe to boot events with proper ordering
BootEvents.SystemStarting:Connect(System.initializeCore)
BootEvents.NetworkStarted:Connect(System.initializeNetwork)

return System
```

### Custom Error Handling

```lua
-- GameServer/CriticalSystem/CriticalModule.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Load = require(ReplicatedStorage.GameCommon.BootSystem.Load)

local function criticalErrorHandler(moduleScript, errorMessage)
    -- Critical system failure handling
    warn(`CRITICAL: Failed to load ${moduleScript:GetFullName()}`)
    warn(`Error: ${errorMessage}`)
    
    -- Could trigger system shutdown, fallback modes, etc.
    -- For now, just escalate the error
    error(`Critical system ${moduleScript.Parent.Name} failed to initialize`)
end

-- Module would be loaded with custom error handler
-- Load(script, criticalErrorHandler)

local CriticalModule = {}

function CriticalModule.initialize()
    print("Critical system initialized with custom error handling")
end

return CriticalModule
```

### Network-Dependent System

```lua
-- GameServer/NetworkSystem/NetworkModule.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataLib = require(ReplicatedStorage.TLib.DataLib)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)

local NetworkSystem = {}

function NetworkSystem.setupState()
    -- Only setup network state after DataLib.Networking is ready
    local Actions, Data = {}, {
        NetworkData = {} :: {[string]: any}
    }
    
    Actions.setNetworkData = DataLib.Action(function(key: string, value: any)
        Data.NetworkData[key] = value
    end)
    
    return DataLib.StateContainer(Actions, Data)
        :SetTag("NetworkDiscriminator", "NetworkSystem")
        :AddToNetwork()
end

function NetworkSystem.initialize()
    -- Wait for network to be ready
    BootEvents.NetworkStarted:Connect(function()
        local stateContainer = NetworkSystem.setupState()
        print("Network system initialized with state container")
    end)
end

NetworkSystem.initialize()

return NetworkSystem
```

### Client-Side System with UI

```lua
-- GameClient/UISystem/UIManager.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)

local UIManager = {}

function.UIManager.setupPlayerUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create UI elements after systems are loaded
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui
    screenGui.Name = "SystemUI"
    
    print("UI initialized for player:", player.Name)
end

function UIManager.initialize()
    -- Initialize UI after all systems are loaded
    BootEvents.SystemStarted:Connect(UIManager.setupPlayerUI)
end

UIManager.initialize()

return UIManager
```

## Troubleshooting

### Common Issues

#### System Not Loading
**Symptoms**: System code doesn't execute, no output from modules

**Causes & Solutions**:
- **Wrong folder location**: Ensure system folders are in GameServer/ or GameClient/
- **No ModuleScript files**: Check that .luau files exist and are ModuleScript type
- **Boot system not running**: Verify SystemStartup scripts are executing

```lua
-- Debug: Check if boot events fire
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
BootEvents.SystemStarted:Connect(function()
    print("Boot system completed successfully")
end)
```

#### Network Features Not Working
**Symptoms**: DataLib.Networking errors, state not syncing

**Causes & Solutions**:
- **Premature network use**: Using DataLib.Networking before NetworkStarted
- **Missing event subscription**: Not connecting to NetworkStarted event

```lua
-- Debug: Check network status
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
BootEvents.NetworkStarted:Connect(function()
    print("Network is ready")
    -- Safe to use DataLib.Networking here
end)
```

#### Silent Failures on Client
**Symptoms**: Client systems fail without error messages

**Causes & Solutions**:
- **No error handler**: Client boot doesn't use LoadErrHandler by default
- **Module not found**: Check module paths and names

```lua
-- Add custom error handling for debugging
local Load = require(ReplicatedStorage.GameCommon.BootSystem.Load)
local function debugErrorHandler(module, error)
    warn(`Client module ${module:GetFullName()} failed: ${error}`)
end

-- Test specific module
Load(myModule, debugErrorHandler)
```

#### Long Loading Times
**Symptoms**: Warning messages about slow loading

**Causes & Solutions**:
- **Heavy initialization**: Move expensive operations to later events
- **Infinite loops**: Check for loops that don't terminate
- **Waiting indefinitely**: Use timeout patterns for waits

```lua
-- Use timeout for expensive operations
local success, result = pcall(function()
    return someExpensiveOperation():Wait(30) -- 30 second timeout
end)

if not success then
    warn("Operation timed out or failed")
end
```

#### Event Ordering Issues
**Symptoms**: Systems initializing in wrong order

**Causes & Solutions**:
- **Immediate vs Deferred**: SystemStarted/NetworkStarted are deferred
- **Event subscription timing**: Subscribe to events before they fire

```lua
-- Correct: Subscribe early
BootEvents.SystemStarting:Connect(function()
    print("System starting")
end)

-- Incorrect: Subscribe after event may have fired
-- BootEvents.SystemStarted:Connect(function() -- Too late!)
```

### Debug Tools

#### Boot Event Monitoring
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)

-- Monitor all boot events
local events = {"SystemStarting", "SystemStarted", "NetworkStarting", "NetworkStarted"}

for _, eventName in events do
    BootEvents[eventName]:Connect(function()
        print(`Boot event fired: {eventName}`)
    end)
end
```

#### Module Loading Diagnostics
```lua
local Load = require(ReplicatedStorage.GameCommon.BootSystem.Load)

local function diagnosticErrorHandler(moduleScript, errorMessage)
    warn(`=== MODULE LOAD FAILURE ===`)
    warn(`Module: {moduleScript:GetFullName()}`)
    warn(`Parent: {moduleScript.Parent:GetFullName()}`)
    warn(`Error: {errorMessage}`)
    warn(`========================`)
end

-- Test load a specific module
Load(myModule, diagnosticErrorHandler)
```

#### System Discovery Check
```lua
-- Server: Check discovered systems
for _, systemFolder in game.ServerScriptService:GetChildren() do
    if systemFolder:IsA("Folder") then
        print(`Server system discovered: {systemFolder.Name}`)
        
        local startupModule = systemFolder:FindFirstChild("#SYSTEMSTARTUP")
        print(`  Has #SYSTEMSTARTUP: {startupModule ~= nil}`)
    end
end

-- Client: Check discovered systems  
for _, systemFolder in game.StarterPlayer.StarterPlayerScripts:GetChildren() do
    if systemFolder:IsA("Folder") then
        print(`Client system discovered: {systemFolder.Name}`)
    end
end
```

### Performance Considerations

#### Loading Time Optimization
- **Defer expensive work**: Move heavy initialization to NetworkStarted
- **Avoid blocking waits**: Use async patterns where possible
- **Batch operations**: Group related work together
- **Module size**: Keep individual modules focused and small

#### Memory Management
- **Clean up event connections**: Disconnect events when no longer needed
- **Avoid circular references**: Be careful with module dependencies
- **Resource cleanup**: Implement cleanup patterns for shutdown

#### Network Efficiency
- **State container patterns**: Use DataLib efficiently for network sync
- **Batch state changes**: Group multiple state updates
- **Minimal network data**: Keep synchronized data small

## Best Practices

### System Design
- **Single responsibility**: Each system should have one clear purpose
- **Loose coupling**: Minimize dependencies between systems
- **Event-driven communication**: Use boot events for coordination
- **Graceful degradation**: Handle failures gracefully

### Module Organization
- **Clear naming**: Use descriptive names for modules and systems
- **Consistent structure**: Follow established folder patterns
- **Type safety**: Use proper Luau type annotations
- **Documentation**: Document system purpose and usage

### Error Handling
- **Server logging**: Always use error handlers on server
- **Client resilience**: Handle client failures gracefully
- **Recovery patterns**: Implement fallback where appropriate
- **User feedback**: Provide meaningful error messages

### Performance
- **Lazy loading**: Defer expensive operations until needed
- **Event timing**: Use appropriate boot events for initialization
- **Resource cleanup**: Properly clean up resources
- **Monitoring**: Track loading times and system performance

The Boot System provides a robust foundation for building scalable, maintainable Roblox applications with predictable initialization patterns and comprehensive error handling.