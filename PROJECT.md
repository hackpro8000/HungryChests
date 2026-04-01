# AGENTS.md - Roblox Framework Development Guide

## Project Overview

**Roblox Framework** is a minimal, enterprise-level Roblox development framework built with modern Luau practices. It provides the core infrastructure for building Roblox games and applications without any gameplay-specific code.

**Framework Core:**
- TLib utility library with comprehensive tools
- Boot system for organized startup/shutdown
- State container pattern for data management
- Network synchronization infrastructure
- Event-driven architecture

- **Platform**: Roblox Engine
- **Language**: Luau (.luau files)
- **Architecture**: Data-oriented design
- **Build System**: Rojo v7.5.1
- **Toolchain**: Aftman
- **Package Manager**: Wally (deprecated - packages will be removed soon)

## Development Commands

```bash
# Sync project to Roblox Studio (handled by Rojo integration)
# Start development server (syncs to place ID 71165933671730)
rojo serve

# Build for production
rojo build

# Install dependencies (deprecated)
wally install
wally install <package-name>
```

## Code Architecture Patterns

### State Container Pattern (Required)

All new systems MUST use the State Container pattern with DataLib:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataLib = require(ReplicatedStorage.TLib.DataLib)

local Actions, Data = {}, {
    SystemData = {} :: {[string] : any}
}

Actions.addSystemData = DataLib.Action(function(key: string, value: any)
    assert(key, "Parameter `key` cannot be nil!")
    assert(value, "Parameter `value` cannot be nil!")
    Data.SystemData[key] = value
end)

return DataLib.StateContainer(Actions, Data)
    :SetTag("NetworkDiscriminator", "SystemState")
    :AddToNetwork()
```

### Module Structure

```
GameClient/          # Client-only code
GameServer/          # Server-only code
GameCommons/         # Shared code
TLib/                # Custom utility library
Packages/            # Shared dependencies
ServerPackages/      # Server-only dependencies
```

## Coding Conventions

### Type Safety

- **Use `--!strict`** for type-critical modules (TLib, core systems)
- **Use `--!nocheck`** sparingly for legacy code
- **Type annotations** required for all function parameters and returns
- **Export types** with `export type` for shared APIs

```lua
--!strict
export type SystemData = {
    ID: string,
    Properties: {[string]: any},
}

local function processSystem(data: SystemData): string
    assert(data, "Parameter `data` cannot be nil!")
    -- implementation
end
```

### Naming Conventions

- **Files**: PascalCase with `.luau` extension
- **State Containers**: `[SystemName]State.luau`
- **Functions/Variables**: camelCase
- **Constants**: UPPER_SNAKE_CASE
- **Types/Classes**: PascalCase
- **Type Properties**: PascalCase

### Import Structure

```lua
-- Service imports first
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- TLib imports
local DataLib = require(ReplicatedStorage.TLib.DataLib)

-- Project imports (absolute paths from ReplicatedStorage)
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)

-- Relative imports for local modules
local LocalModule = require(script.Parent.LocalModule)
```

## Error Handling

### Required Assertions

```lua
local function processSystem(systemID: string, data: SystemData)
    assert(systemID, "Parameter `systemID` cannot be nil!")
    assert(data, "Parameter `data` cannot be nil!")
    assert(typeof(systemID) == "string", `systemID must be string, got ${typeof(systemID)}`)
    -- Process logic
end
```

## Framework State

This is a **clean framework** with core infrastructure systems. The project provides:
- Complete TLib utility library with 13 specialized sub-libraries
- Boot system for organized client/server initialization
- Profile system for player data and currency management
- UI system with reactive components and TLib UILib integration
- Cinematic system for camera control and visual effects
- Game definitions for centralized configuration management
- Essential Roblox development packages
- Enterprise-grade architecture patterns

All systems follow the framework patterns and provide comprehensive documentation in the `docs/` directory.

### Module Loading

```lua
local success, result = pcall(require, moduleScript)
if not success then
    warn(`Failed to load module: {result}`)
    return
end

assert(moduleScript:IsA("ModuleScript"), "Expected ModuleScript")
```

## TLib Framework Library

The framework includes comprehensive utility libraries organized by domain:

### Core Libraries
- **DataLib**: State containers, Actions, Data structures, networking
- **NetLib**: Client-server communication utilities
- **ModuleLib**: Module loading and dependency management
- **TimeLib**: Time measurement and utilities
- **OrderedSignal**: Priority-ordered event system

### Specialized Libraries
- **BatchLib**: Batched operation processing
- **CleanerLib**: Object cleanup and memory management
- **CineLib**: Cinematic controller and camera utilities
- **FilterLib**: Data filtering and predicates
- **InputLib**: Input handling abstraction
- **PromiseLib**: Async operation utilities
- **StreamingLib**: Instance/ID streaming for network efficiency
- **ToolLib**: Tool encapsulation system
- **UILib**: UI component utilities

## Performance Guidelines

- Use **struct of arrays** for performance-critical systems
- Implement **object pooling** for frequently created/destroyed instances
- Batch operations when possible
- Optimize for mobile devices
- Use **CleanerLib** for proper cleanup

## Testing

- All testing will be done manually by the user.

## Commit Standards

### Message Format
```
[feature/fix/refactor]: brief description

- What was changed
- Why the change was necessary
- Any breaking changes
```

### Required Checks Before Commit
- All type annotations complete
- State container pattern properly implemented
- Network discriminator tags set
- No debug prints left in code

## Documentation Requirements

### Mandatory Documentation Reading
- All agents must read all files under `docs/` before starting any work
- The following directory is an important documentation source for TLib:
  - `/home/major-scale/Dev 2025/TLib/Documentation` as an important directory containing all necessary documentation for the TLib libraries. This path should be treated as a mandatory read. (ONLY use shell to access)

**ALL AGENTS MUST READ ALL FILES UNDER `docs/` BEFORE STARTING ANY WORK**

- Read all documentation files in the `docs/` directory
- Understand existing system documentation before making changes
- Use documentation as primary source of truth for system behavior
- Reference documentation when implementing features or fixes

### Available System Documentation

The following comprehensive documentation is available in the `docs/` directory:

#### Core Systems
- **[ProfileSystem.md](docs/ProfileSystem.md)** - Complete player data and currency management system
- **[BootSystem.md](docs/BootSystem.md)** - Framework initialization and module loading
- **[UISystem.md](docs/UISystem.md)** - UI components and TLib UILib integration
- **[CinematicSystem.md](docs/CinematicSystem.md)** - Camera control and cinematic sequences

#### Game Systems  
- **[ChestGameSystem.md](docs/ChestGameSystem.md)** - Multiplayer chest selection minigame
- **[GameDefinitions.md](docs/GameDefinitions.md)** - Configuration management and constants

#### Design Documents
- **[GameDesign.md](docs/GameDesign.md)** - High-level game concept and mechanics

### System Documentation Updates

**INDIVIDUAL SYSTEMS MUST HAVE DOCUMENTATION UPDATED**

- When creating new systems: Create corresponding documentation in `docs/`
- When modifying existing systems: Update relevant documentation
- Documentation must include:
  - System overview and purpose
  - API reference with all public functions
  - Configuration requirements
  - Usage examples
  - Integration patterns with framework
  - Troubleshooting guide

### Documentation Standards

- Use Markdown format (`.md` files)
- Follow existing documentation structure and style
- Include code examples with proper syntax highlighting
- Document all public APIs with parameter types and descriptions
- Update table of contents when adding new sections

## Roblox Studio MCP Restrictions

### ABSOLUTELY FORBIDDEN: Script Creation and Editing

**ROBLOX STUDIO MCP MAY NOT BE USED TO CREATE OR EDIT ANY SCRIPTS - NO EXCEPTIONS**

All script operations, including but not limited to:
- Creating new scripts (Script, LocalScript, ModuleScript)
- Editing existing script source code
- Modifying script properties
- Deleting scripts

**MANDATORY**: Use file system tools (Read, Edit, Write, Glob, Grep) for all script operations.

### Enforcement

This rule applies to ALL scripts in the Roblox Studio instance, regardless of location, scope, or purpose. The file system is the single source of truth for all code in this project.

**Use Rojo for Development**:
```bash
rojo serve  # Sync file system changes to Studio
```

### Allowed Roblox Studio MCP Operations

Only non-script operations are permitted:
- Reading instance properties and hierarchy
- Creating/editing non-script instances (Parts, Models, Folders, etc.)
- Setting instance properties (except script source)
- Managing CollectionService tags
- Working with attributes on non-script instances

## Boot System Pattern

The project uses a centralized boot system with `#SYSTEMSTARTUP` modules:

```lua
local BootEvents = require(ReplicatedStorage.GameCommon.BootSystem.BootEvents)
local Load = require(ReplicatedStorage.GameCommon.BootSystem.Load)
local LoadChildren = require(ReplicatedStorage.GameCommon.BootSystem.LoadChildren)

BootEvents.SystemStarting:Fire(); do
    for _, systemFolder in script.Parent.Parent:GetChildren() do
        local systemStartupModule = systemFolder:FindFirstChild("#SYSTEMSTARTUP")
        if systemStartupModule then
            Load(systemStartupModule)
        else
            LoadChildren(systemFolder)
        end
    end
end; BootEvents.SystemStarted:FireDeferred()
```
