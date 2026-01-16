# AGENTS.md - HotLogistics Project Guide

This file contains essential information for agentic coding agents working on the HotLogistics Roblox game project.

## Project Overview

**HotLogistics** is a Roblox vehicle combat and logistics game built with modern Luau practices and enterprise-level architecture.

### CORE-GAMEPLAY:

In this round-based vehicular chaos game, players will spawn in each round seated within their vehicles,
they will be tasked with delivering procedurally positioned packages to a procedurally positioned destination.
there will be a limited amount of packages, this amount will always be less than the total number of participants
in the current game round. Because there is a limited supply of packages, players will be able to fight and steal
packages from eachother. Players may purchase weapons from the shop in between rounds and use them in combat,
additionally, they may also use their vehicles as weapons (ramming/collision damage), vehicles may also have
weapons mounted to them.

### ECONOMICS & PER-PLAYER MECHANICS:

The game currency will be called "Bucks", which is a very original and unique name choice for this game. /irony
Players will be able to purchase new vehicles and modify them.

- **Language**: Luau (Roblox's typed variant of Lua)
- **Architecture**: Data-oriented with modular design
- **Build System**: Rojo v7.5.1
- **Package Manager**: Wally (**Deprecated** - packages will be removed soon)
- **Toolchain**: Aftman

## Build Commands

```bash
# Build the project
rojo build

# Start development server (syncs to place ID 71165933671730)
rojo serve

# Install dependencies (deprecated - packages will be removed soon)
wally install

# Install specific dependency (deprecated - packages will be removed soon)
wally install <package-name>
```

## Testing

The project uses **TestEZ** framework for testing.

```bash
# Run all tests
# Note: TestEZ is typically run through Roblox Studio or a test runner

# Test file patterns:
# - *.test.luau
# - *.spec.lua
# - Test files should be placed alongside modules or in test directories
```

**Example test file**: `GameServer/VehicleSystem/VehicleSpawnerTest.luau`

## Code Style Guidelines

### File Organization

```
hot-logistics/
├── GameClient/          # Client-side code only
├── GameServer/          # Server-side code only  
├── GameCommons/         # Shared code between client/server
├── GameDefinitions/     # Game data and configuration
├── TLib/               # Custom library collection (submodule)
├── Packages/           # Shared dependencies
└── ServerPackages/    # Server-only dependencies
```

### Type System

- **Use `--!strict` directive** for type-critical modules (TLib libraries, core systems)
- **Use `--!nocheck` directive** sparingly for legacy/compatibility code
- **Export types** using `export type` for public APIs
- **Type annotations** required for function parameters and returns in strict modules

```luau
--!strict
export type VehicleData = {
    ID: string,
    Weight: number,
    Engine: EngineData,
}

local function createVehicle(data: VehicleData): Vehicle
    -- Implementation
end
```

### Naming Conventions

- **PascalCase** for types, classes, and modules
- **camelCase** for functions, variables, and properties
- **UPPER_SNAKE_CASE** for constants
- **Descriptive names** - avoid abbreviations unless widely understood

```luau
export type EngineData = {...}
local VehicleAssemblyLine = {}
local function spawnVehicle(vehicleID: string)
local MAX_VEHICLE_WEIGHT = 50000
```

### Import Patterns

```luau
-- Service imports at top
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local imports next, grouped by source
local BootEvents = require(ReplicatedStorage.GameCommons.BootSystem.BootEvents)
local DataLib = require(ReplicatedStorage.TLib.DataLib)

-- Relative imports for local modules
local VehicleData = require(script.Parent.VehicleData)
```

### Module Structure

```luau
--!strict or --!nocheck (choose appropriately)
local Dependencies = require(...)
local OtherDeps = require(...)

-- Type definitions
export type ModuleType = {...}

-- Module table
local Module = {}

-- Public functions
function Module.publicFunction(param: Type): ReturnType
    -- Implementation
end

-- Return module
return Module
```

### Error Handling

- Use `pcall()` for operations that may fail
- Implement proper error propagation
- Use assertions for developer errors
- Log warnings for non-critical issues

```luau
local success, result = pcall(require, moduleScript)
if not success then
    warn(`Failed to load module: {result}`)
    return
end

assert(moduleScript:IsA("ModuleScript"), "Expected ModuleScript")
```

### Event-Driven Architecture

- Use custom signals for events
- Follow the pattern: `OnEvent`, `FireEvent`, `EventDone`
- Use deferred firing for startup events

```luau
BootEvents.SystemStarting:Fire()
-- ... initialization code ...
BootEvents.SystemStarted:FireDeferred()
```

### Performance Patterns

- Use **struct of arrays** for performance-intensive systems
- Optimize data layout for cache efficiency
- Batch operations when possible

```luau
-- Struct of arrays pattern for vehicle data
local VehicleSystem = {
    positions = {},
    velocities = {},
    rotations = {},
    -- Store data in separate arrays for better cache locality
}

local function updateVehicles(deltaTime: number)
    for i = 1, #VehicleSystem.positions do
        -- Process all vehicle data in tight loops
        VehicleSystem.positions[i] += VehicleSystem.velocities[i] * deltaTime
    end
end
```

### State Management

The project uses multiple state management solutions:

- **DataLib**: Custom state management with actions and containers
- **Rodux**: Redux-like state management
- **SPR**: Simple state management

Choose the appropriate solution based on the use case.

### Networking

- Use **Comm** for remote communication
- Use **NetLib** (TLib) for advanced networking
- Follow client-server validation patterns

### Promises & Async

- Use **Promise** library for async operations
- Chain promises properly
- Handle promise rejections

```luau
local Promise = require(ReplicatedStorage.Packages.Promise)

Promise.new(function(resolve, reject)
    -- Async operation
end):andThen(function(result)
    -- Handle success
end):catch(function(err)
    -- Handle error
end)
```

### Memory Management

- Use **Trove** for object cleanup
- Implement proper destruction patterns
- Clean up event connections

```luau
local trove = Trove.new()

trove:Connect(someEvent, function()
    -- Handler
end)

-- Cleanup
trove:Clean()
```

## Development Workflow

1. **Install dependencies**: `wally install` (deprecated - packages will be removed soon)
2. **Start development**: `rojo serve`
3. **Test in Roblox Studio**: Connect to the serve session
4. **Build for production**: `rojo build`

## Key Libraries & Dependencies

- **Matter**: ECS framework
- **Promise**: Async operations
- **Comm**: Remote communication
- **Signal**: Event system
- **Trove**: Object cleanup
- **Rodux**: State management
- **ProfileStore**: Data persistence
- **TLib**: Custom utility library (extensive)

## Testing Guidelines

- Write tests for core systems and vehicle logic
- Use TestEZ assertions and test patterns
- Test both success and failure cases
- Mock external dependencies when needed

## Performance Considerations

- Use ECS for performance-critical systems
- Implement proper object pooling
- Optimize network communication
- Profile with Roblox's tools

## Security Notes

- Validate all client input on server
- Use proper filtering for text/chat
- Secure remote function calls
- Implement exploit detection where appropriate

## Common Patterns

### Module Initialization
```luau
local Module = {}

function Module.new()
    local self = setmetatable({}, Module)
    -- Initialize
    return self
end

return Module
```

### Service Pattern
```luau
local Service = {}
Service.__index = Service

function Service:init()
    -- Service initialization
end

return Service
```

### Data Container Pattern
```luau
local container = DataLib.DataContainer(initialData)
container:SetAction("update", function(self, newData)
    self:Overwrite(newData)
end)
```

Remember: This is a sophisticated, enterprise-level Roblox project. Follow the established patterns and maintain high code quality standards.