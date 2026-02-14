# GameDefinitions System Documentation

## Overview

The GameDefinitions system serves as the centralized configuration management layer for the HungryChests game, providing game constants, balance parameters, and external system integrations. It acts as the single source of truth for all game-wide settings, ensuring consistency across client and server systems.

The system is organized into modular subsystems, each responsible for specific configuration domains such as game mechanics and monetization features.

## Architecture

### File Structure
```
GameDefinitions/
├── ChestGameSystem/
│   └── ChestGameGeneral.luau        # Core game constants and balance parameters
└── GamepassSystem/
    └── GamepassIDMap.toml           # Gamepass configuration mapping
```

### Design Principles

- **Single Source of Truth**: All game constants centralized in one location
- **Modular Organization**: Related configurations grouped by subsystem
- **Format Flexibility**: Supports both Lua tables and TOML files
- **Cross-Platform Access**: Available to client, server, and common modules
- **Type Safety**: Proper typing for all configuration values
- **Performance Optimized**: Static values loaded once at runtime

### Integration Pattern

```lua
-- Standard import pattern for all systems
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChestGameGeneral = require(ReplicatedStorage.GameDefinitions.ChestGameSystem.ChestGameGeneral)
local GamepassIDMap = require(ReplicatedStorage.GameDefinitions.GamepassSystem.GamepassIDMap)
```

## Data Structures

### ChestGameGeneral Constants

The `ChestGameGeneral.luau` module exports a Lua table containing core game balance parameters:

```lua
export type ChestGameGeneral = {
    GRID_SIZE_X: number,          -- Width of the chest grid (columns)
    GRID_SIZE_Y: number,          -- Height of the chest grid (rows)  
    MAX_CHEST_CHOICE: number,     -- Maximum chests per participant
    TURN_TIMER: number,           -- Time limit per turn in seconds
}
```

### GamepassIDMap Configuration

The `GamepassIDMap.toml` file contains TOML-formatted gamepass mappings:

```toml
DoubleCoins = 1682948718
DoubleTrophies = 1684578672
DoubleWinStreak = 1683238704
VIPBundle = 1682855791
```

## Configuration Management

### Constants (ChestGameGeneral)

#### Grid Configuration
- **GRID_SIZE_X**: 5 - Number of columns in the chest selection grid
- **GRID_SIZE_Y**: 5 - Number of rows in the chest selection grid
- **Total Grid Size**: 25 chests (5×5)

#### Game Balance Parameters
- **MAX_CHEST_CHOICE**: 3 - Maximum number of chests each participant can select
- **TURN_TIMER**: 10 - Time limit for each participant's turn in seconds

#### Current Configuration Values
```lua
return {
    GRID_SIZE_X = 5,
    GRID_SIZE_Y = 5,
    MAX_CHEST_CHOICE = 3,
    TURN_TIMER = 10,
}
```

### Gamepass Configuration (GamepassIDMap.toml)

#### Available Gamepasses
- **DoubleCoins**: Doubles primary currency rewards (ID: 1682948718)
- **DoubleTrophies**: Doubles trophy rewards (ID: 1684578672)
- **DoubleWinStreak**: Doubles win streak bonuses (ID: 1683238704)
- **VIPBundle**: Combined VIP benefits (ID: 1682855791)

#### TOML Structure Benefits
- **Human-Readable**: Easy to understand and edit
- **External Integration**: Compatible with external tools
- **Comments Support**: Can include documentation within config
- **Type Safety**: Automatic type conversion when loaded

## API Reference

### Accessing Constants

#### ChestGameGeneral Constants
```lua
local ChestGameGeneral = require(ReplicatedStorage.GameDefinitions.ChestGameSystem.ChestGameGeneral)

-- Grid calculations
local totalChests = ChestGameGeneral.GRID_SIZE_X * ChestGameGeneral.GRID_SIZE_Y

-- Game logic validation
if #chosenChests >= ChestGameGeneral.MAX_CHEST_CHOICE then
    error("Maximum chest choices exceeded")
end

-- Timer management
ChestGameState:GetServer().startTimer(chestGameID, TimeLib.getTime(), ChestGameGeneral.TURN_TIMER)
```

#### Gamepass Configuration
```lua
local GamepassIDMap = require(ReplicatedStorage.GameDefinitions.GamepassSystem.GamepassIDMap)

-- Check gamepass ownership
local hasDoubleCoins = MarketplaceService:UserOwnsGamePassAsync(
    tonumber(userID), 
    GamepassIDMap.DoubleCoins
)

-- Apply multiplier based on gamepass
local currencyMultiplier = hasDoubleCoins and 2 or 1
local reward = baseReward * currencyMultiplier
```

## Configuration Patterns

### Adding New Constants

#### 1. Define in ChestGameGeneral.luau
```lua
return {
    -- Existing constants
    GRID_SIZE_X = 5,
    GRID_SIZE_Y = 5,
    MAX_CHEST_CHOICE = 3,
    TURN_TIMER = 10,
    
    -- New constants
    NEW_GAME_PARAMETER = 42,
    ANOTHER_SETTING = "value",
}
```

#### 2. Type Annotation Update (if using strict typing)
```lua
export type ChestGameGeneral = {
    GRID_SIZE_X: number,
    GRID_SIZE_Y: number,
    MAX_CHEST_CHOICE: number,
    TURN_TIMER: number,
    NEW_GAME_PARAMETER: number,
    ANOTHER_SETTING: string,
}
```

#### 3. Update Documentation
- Document the new parameter's purpose
- Add usage examples
- Note any dependent systems

### Adding New Gamepasses

#### 1. Update GamepassIDMap.toml
```toml
# Existing gamepasses
DoubleCoins = 1682948718
DoubleTrophies = 1684578672
DoubleWinStreak = 1683238704
VIPBundle = 1682855791

# New gamepass
SuperMegaPack = 1234567890
```

#### 2. Implement Gamepass Logic
```lua
-- In reward systems or other relevant modules
if MarketplaceService:UserOwnsGamePassAsync(tonumber(userID), GamepassIDMap.SuperMegaPack) then
    -- Apply special benefits
end
```

### Configuration Access Patterns

#### Direct Access Pattern
```lua
-- For frequently accessed constants
local GRID_SIZE = ChestGameGeneral.GRID_SIZE_X * ChestGameGeneral.GRID_SIZE_Y
```

#### Cached Access Pattern
```lua
-- For expensive operations or repeated access
local GamepassIDMap = require(ReplicatedStorage.GameDefinitions.GamepassSystem.GamepassIDMap)
local gamepassCache = {}

local function checkGamepass(userID: number, gamepassType: string): boolean
    local cacheKey = `${userID}_${gamepassType}`
    if gamepassCache[cacheKey] ~= nil then
        return gamepassCache[cacheKey]
    end
    
    local result = MarketplaceService:UserOwnsGamePassAsync(userID, GamepassIDMap[gamepassType])
    gamepassCache[cacheKey] = result
    return result
end
```

## Integration with Other Systems

### ChestGameSystem Integration

The GameDefinitions system is deeply integrated with the ChestGameSystem:

#### Grid System Usage
```lua
-- In IChestGameRenderer:169-171
for chestNum = 1, ChestGameGeneral.GRID_SIZE_X*ChestGameGeneral.GRID_SIZE_Y do
    local gridX = ((chestNum-1) % ChestGameGeneral.GRID_SIZE_X) * 4 - (ChestGameGeneral.GRID_SIZE_X-1) * 2
    local gridY = math.floor((chestNum-1) / ChestGameGeneral.GRID_SIZE_X) * 4 - (ChestGameGeneral.GRID_SIZE_Y-1) * 2
end
```

#### Choice Validation
```lua
-- In ChestGameChoosingChests:24
assert(#activeParticipant.ChosenChests < ChestGameGeneral.MAX_CHEST_CHOICE, 
    `Cannot choose more than {ChestGameGeneral.MAX_CHEST_CHOICE} chests!`)
```

#### Timer Management
```lua
-- In ChestGameOpeningChests:137
ChestGameState:GetServer().startTimer(chestGameID, TimeLib.getTime(), ChestGameGeneral.TURN_TIMER)
```

### GamepassSystem Integration

The GamepassIDMap is used in reward calculations and benefit systems:

#### Reward Multipliers
```lua
-- In ChestGameRewards:27-38
local primaryCurrencyGamepassMult = 1
local trophyGamepassMult = 1

if MarketplaceService:UserOwnsGamePassAsync(tonumber(participant.UserIDString), GamepassIDMap.DoubleCoins) then
    primaryCurrencyGamepassMult = 2
end

if MarketplaceService:UserOwnsGamePassAsync(tonumber(participant.UserIDString), GamepassIDMap.VIPBundle) then
    primaryCurrencyGamepassMult = 2
    trophyGamepassMult = 2
end
```

### Network Integration

Configuration values are automatically available to all contexts through the ReplicatedStorage structure:

- **Server Access**: Full access for game logic and validation
- **Client Access**: Available for UI rendering and player feedback
- **Common Access**: Shared utilities and helper functions

## Usage Examples

### Basic Configuration Access

#### Calculating Grid Positions
```lua
local function getChestPosition(chestNumber: number): Vector3
    local gridX = ((chestNumber-1) % ChestGameGeneral.GRID_SIZE_X) * 4 - (ChestGameGeneral.GRID_SIZE_X-1) * 2
    local gridY = math.floor((chestNumber-1) / ChestGameGeneral.GRID_SIZE_X) * 4 - (ChestGameGeneral.GRID_SIZE_Y-1) * 2
    return Vector3.new(gridX, 0, gridY)
end
```

#### Validating Player Choices
```lua
local function validateChestChoice(participant: ChestGameParticipant, newChestNumber: number): boolean
    -- Check maximum choices
    if #participant.ChosenChests >= ChestGameGeneral.MAX_CHEST_CHOICE then
        return false
    end
    
    -- Check if chest already chosen
    for _, existingChest in participant.ChosenChests do
        if existingChest == newChestNumber then
            return false
        end
    end
    
    return true
end
```

#### Gamepass Benefit Application
```lua
local function calculateRewards(baseReward: number, userID: string): number
    local multiplier = 1
    
    -- Check individual gamepasses
    if MarketplaceService:UserOwnsGamePassAsync(tonumber(userID), GamepassIDMap.DoubleCoins) then
        multiplier = multiplier * 2
    end
    
    -- Check VIP bundle (includes all benefits)
    if MarketplaceService:UserOwnsGamePassAsync(tonumber(userID), GamepassIDMap.VIPBundle) then
        multiplier = multiplier * 2
    end
    
    return baseReward * multiplier
end
```

### Advanced Configuration Management

#### Dynamic Configuration Loading
```lua
local ConfigurationCache = {}

local function getConfiguration(systemName: string)
    if not ConfigurationCache[systemName] then
        local success, config = pcall(require, `ReplicatedStorage.GameDefinitions.{systemName}`)
        if not success then
            error(`Failed to load configuration for {systemName}: {config}`)
        end
        ConfigurationCache[systemName] = config
    end
    return ConfigurationCache[systemName]
end
```

#### Configuration Validation
```lua
local function validateChestGameConstants()
    assert(ChestGameGeneral.GRID_SIZE_X > 0, "GRID_SIZE_X must be positive")
    assert(ChestGameGeneral.GRID_SIZE_Y > 0, "GRID_SIZE_Y must be positive")
    assert(ChestGameGeneral.MAX_CHEST_CHOICE > 0, "MAX_CHEST_CHOICE must be positive")
    assert(ChestGameGeneral.TURN_TIMER > 0, "TURN_TIMER must be positive")
    
    local totalChests = ChestGameGeneral.GRID_SIZE_X * ChestGameGeneral.GRID_SIZE_Y
    assert(totalChests >= ChestGameGeneral.MAX_CHEST_CHOICE, 
        "Not enough chests for maximum choices per participant")
end
```

## Troubleshooting

### Common Configuration Issues

#### Constants Not Loading
**Symptoms**: `attempt to index nil` or `module not found` errors

**Solutions**:
- Verify file paths are correct in require statements
- Check that files exist in GameDefinitions directory
- Ensure ReplicatedStorage service is available
- Validate Rojo project structure in `default.project.json`

#### Gamepass IDs Not Working
**Symptoms**: Gamepass benefits not applying, incorrect reward calculations

**Solutions**:
- Verify TOML syntax is correct
- Check gamepass IDs match Roblox developer console values
- Ensure MarketplaceService is available on server
- Validate user ID conversion (tonumber) is successful

#### Configuration Value Type Errors
**Symptoms**: Type mismatch errors, unexpected behavior

**Solutions**:
- Verify constant types match expected usage
- Check for accidental string/number confusion in TOML
- Validate numeric ranges are appropriate
- Ensure boolean values are properly formatted

### Debug Tools

#### Configuration Inspector
```lua
local function inspectGameDefinitions()
    print("=== ChestGameGeneral Constants ===")
    for key, value in pairs(ChestGameGeneral) do
        print(`${key}: ${value} (${typeof(value)})`)
    end
    
    print("\n=== GamepassIDMap ===")
    for key, value in pairs(GamepassIDMap) do
        print(`${key}: ${value} (${typeof(value)})`)
    end
end
```

#### Runtime Validation
```lua
local function validateConfigurationIntegrity()
    -- Test grid calculations
    local totalChests = ChestGameGeneral.GRID_SIZE_X * ChestGameGeneral.GRID_SIZE_Y
    assert(totalChests > 0, "Invalid grid size calculation")
    
    -- Test gamepass IDs are valid numbers
    for name, id in pairs(GamepassIDMap) do
        assert(type(id) == "number", `Gamepass ${name} ID must be number`)
        assert(id > 0, `Gamepass ${name} ID must be positive`)
    end
    
    print("✓ Configuration validation passed")
end
```

## Performance Considerations

### Optimization Strategies

#### Singleton Pattern
- Configuration modules are loaded once and cached
- Avoid repeated require() calls in hot paths
- Use local variables for frequently accessed constants

#### Pre-computation
```lua
-- Pre-compute derived values at startup
local TOTAL_CHESTS = ChestGameGeneral.GRID_SIZE_X * ChestGameGeneral.GRID_SIZE_Y
local MAX_PARTICIPANT_CHOICES = 4 * ChestGameGeneral.MAX_CHEST_CHOICE
```

#### Gamepass Caching
```lua
-- Cache gamepass ownership checks
local GamepassOwnershipCache = {}

local function getCachedGamepassStatus(userID: number, gamepassID: number): boolean
    local cacheKey = `${userID}_${gamepassID}`
    local cached = GamepassOwnershipCache[cacheKey]
    
    if cached ~= nil then
        return cached
    end
    
    local result = MarketplaceService:UserOwnsGamePassAsync(userID, gamepassID)
    GamepassOwnershipCache[cacheKey] = result
    return result
end
```

### Memory Management

- Configuration data is relatively small and static
- No dynamic allocation during gameplay
- Cache invalidation for gamepass ownership on gamepass purchase events
- Memory footprint is minimal compared to game state data

## Future Enhancements

### Planned Features

#### Environment-Specific Configurations
```lua
-- Support for development vs production settings
local environment = game:GetService("RunService"):IsStudio() and "dev" or "prod"
return {
    TURN_TIMER = environment == "dev" and 5 or 10,
    DEBUG_MODE = environment == "dev",
}
```

#### Dynamic Configuration Updates
- Hot-reloading of configuration changes during development
- Admin commands to modify certain values at runtime
- Configuration versioning and migration support

#### Advanced TOML Features
```toml
[game_balance]
grid_size = { x = 5, y = 5 }
max_choices = 3
turn_timer = 10

[gamepasses.double_coins]
id = 1682948718
multiplier = 2.0
description = "Doubles all coin rewards"
```

#### Configuration Validation Framework
- Schema validation for TOML files
- Automatic type checking and conversion
- Integration with build pipeline for configuration validation

#### Analytics Integration
- Configuration change tracking
- A/B testing support for different balance values
- Performance metrics collection for configuration impact

### Extensibility Points

#### New Configuration Subsystems
- Add new folders under GameDefinitions for different game systems
- Follow established patterns for Lua and TOML configuration
- Maintain consistent API across all configuration modules

#### Custom Configuration Formats
- Support for JSON configuration files
- YAML integration for complex nested structures
- Database-driven configuration for live updates

## Best Practices

### Development Guidelines

1. **Centralized Changes**: All game balance changes should go through GameDefinitions
2. **Documentation Updates**: Update documentation when adding new constants
3. **Type Safety**: Always include type annotations for new configuration values
4. **Validation**: Add validation for configuration values at startup
5. **Version Control**: Track configuration changes in version control system

### Testing Considerations

1. **Unit Tests**: Test configuration loading and validation
2. **Integration Tests**: Verify configuration usage in game systems
3. **Performance Tests**: Measure impact of configuration access patterns
4. **Environment Testing**: Test configurations in both studio and production

### Maintenance Procedures

1. **Regular Audits**: Review and clean up unused configuration values
2. **Documentation Sync**: Keep documentation aligned with actual configuration
3. **Performance Monitoring**: Monitor configuration access patterns for optimization opportunities
4. **Security Review**: Ensure sensitive configuration is properly protected

(End of file)