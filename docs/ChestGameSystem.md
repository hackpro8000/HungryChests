# ChestGame System Documentation

## Overview

The ChestGame system is a multiplayer minigame framework that allows players to select chests from a grid and participate in turn-based gameplay. It supports both human and AI participants with automatic conflict resolution and dynamic rendering.

## Quick Start

### 1. Setup Game Instance
```lua
-- In Roblox Studio, create a model and tag it with "ChestGame"
-- Add a folder named "SeatPositions" with position parts
-- Each position part should have a "ParticipantIndex" NumberValue attribute
-- Add a "Mat" part as the origin point for the grid
```

### 2. Player Participation
- Players sit on seats to join the game
- Minimum 2 participants required to start
- Each participant can choose up to 4 chests

### 3. Game Flow
1. **Dormant**: Waiting for participants
2. **ChoosingChests**: Players select chests from 5x5 grid
3. **InAction**: Game phase begins

## Architecture

### File Structure
```
GameCommons/ChestGameSystem/
├── ChestGameDataTypes.luau     # Core data structures
├── ChestGameState.luau         # State container with network sync
└── ChestGameHelper.luau        # Utility functions

GameServer/ChestGameSystem/
├── ChestGameCreator.luau                # Game instance creation
├── ChestGameSequence.luau               # Game flow management
├── ChestGameParticipantGatherer.luau    # Player management
├── ChestGameChoosingChests.luau         # Chest selection logic
├── ChestGameSeats.luau                  # Seat system setup
├── ChestGameAIParticipants.luau         # AI participant logic
├── ChestGameReset.luau                  # Game reset functionality
├── ChestGameAssignParticipantIndices.luau # Index assignment
├── ChestGameOpeningChests.luau          # Core chest opening and turn management
├── ChestGameRewards.luau                # Reward distribution system
├── ChestGameConclusion.luau              # Game conclusion handling
└── ChestGameTimer.luau                   # Timer expiration monitoring

GameClient/ChestGameSystem/
├── IChestGameRenderer.luau      # Rendering interface
├── ChestGameRendering.luau      # Main rendering controller
└── ChestGameCinematics.luau      # Camera cinematics

GameDefinitions/ChestGameSystem/
└── ChestGameGeneral.luau        # Game constants
```

### State Management
The system uses the framework's **State Container Pattern** with DataLib:

```lua
-- Network-synchronized state
return DataLib.StateContainer(Actions, Data)
    :SetTag("NetworkDiscriminator", "ChestGameState")
    :AddToNetwork()
```

## Data Structures

### ChestGame
```lua
type ChestGame = {
    InstanceStreamableID: string,           -- Unique identifier
    State: ChestGameState,                  -- Current game state
    TimerMin: number?,                      -- Optional timer start time
    TimerMax: number?,                      -- Optional timer end time
    CurrentTurnParticipantID: string?,       -- Current turn participant ID
    OpenedChests: {number},                 -- List of opened chest numbers
    DefaultChairType: string,               -- Default chair type for participants
    Participants: {[string]: ChestGameParticipant},
    WinnerPrimaryRewardRange: NumberRange,  -- Reward range for winners
    LoserPrimaryRewardRange: NumberRange,   -- Reward range for losers
    WinnerTrophyRewardRange: NumberRange,   -- Trophy reward range for winners
    LoserTrophyRewardRange: NumberRange     -- Trophy reward range for losers
}
```

### ChestGameParticipant
```lua
type ChestGameParticipant = {
    UserIDString: string,         -- Player's User ID
    HealthPoints: number,         -- Current health
    HealthPointsMax: number,      -- Maximum health
    ChosenChests: {number},       -- Selected chest indices
    ChestType: string,            -- Visual chest type
    ChairType: string,            -- Chair type for participant
    Index: number,                -- Turn order index
    MaxBadChests: number          -- Maximum bad chests participant may place
}
```

### Game States
```lua
export type ChestGameState = "Dormant" | "ChoosingChests" | "InAction" | "Conclusion"
```

## API Reference

### State Actions

#### createChestGame
```lua
Actions.createChestGame(chestGameID: string, chestGame: ChestGameDataTypes.ChestGame)
```
Creates a new ChestGame entry with the given chestGameID and chestGame data.

#### changeState
```lua
Actions.changeState(chestGameID: string, state: ChestGameDataTypes.ChestGameState)
```
Transitions the chest game to a new state.

#### chooseChest
```lua
Actions.chooseChest(chestGameID: string, participantID: string, chestNum: number)
```
Adds a chest to a participant's selection list.

#### unchooseChest
```lua
Actions.unchooseChest(chestGameID: string, participantID: string, chestNum: number)
```
Removes a chest from a participant's selection list.

#### addParticipant
```lua
Actions.addParticipant(chestGameID: string, participantID: string, participant: ChestGameDataTypes.ChestGameParticipant)
```
Adds a new participant to the game.

#### removeParticipant
```lua
Actions.removeParticipant(chestGameID: string, participantID: string)
```
Removes a participant from the game.

#### setParticipantIndex
```lua
Actions.setParticipantIndex(chestGameID: string, participantID: string, index: number)
```
Assigns turn order index to a participant.

#### setParticipantMaxBadChests
```lua
Actions.setParticipantMaxBadChests(chestGameID: string, participantID: string, maxBadChests: number)
```
Sets the maximum number of bad chests a participant may place.

#### stopTimer
```lua
Actions.stopTimer(chestGameID: string)
```
Stops the timer for a chest game by clearing TimerMin and TimerMax. Automatically called when TimerMax <= TimeLib.getTime().

#### startTimer
```lua
Actions.startTimer(chestGameID: string, startTime: number, duration: number)
```
Starts a timer for the chest game with specified start time and duration. Sets TimerMin to startTime and TimerMax to startTime + duration.

#### cancelTimer
```lua
Actions.cancelTimer(chestGameID: string)
```
Cancels the current timer by delegating to stopTimer action.

#### timeoutTimer
```lua
Actions.timeoutTimer(chestGameID: string)
```
Handles timer expiration by delegating to stopTimer action. Called when timer expires without player action.

#### openChest
```lua
Actions.openChest(chestGameID: string, participantID: string, chestNum: number)
```
Opens a chest for a participant and adds it to the OpenedChests list. Core gameplay action during InAction state.

#### setCurrentTurnParticipant
```lua
Actions.setCurrentTurnParticipant(chestGameID: string, participantID: string?)
```
Sets the current turn participant ID. Pass nil to clear the current turn participant.

#### reduceHealthPoints
```lua
Actions.reduceHealthPoints(chestGameID: string, participantID: string, damage: number)
```
Reduces a participant's health points by the specified damage amount. Health cannot go below 0.

#### eliminateParticipant
```lua
Actions.eliminateParticipant(chestGameID: string, participantID: string)
```
Sets a participant's health points to 0, eliminating them from the game.

#### resetGame
```lua
Actions.resetGame(chestGameID: string)
```
Resets the game state for the next round: clears OpenedChests, CurrentTurnParticipantID, and timer values.

### Helper Functions

#### getPlayerChestGame
```lua
local chestGameID, chestGame, participantID = ChestGameHelper.getPlayerChestGame(player)
```
Finds the active game for a specific player. Returns the chestGameID, the chestGame object, and the player's participantID (or nils if not in a game).

#### countParticipants
```lua
local count = ChestGameHelper.countParticipants(chestGame: ChestGame)
```
Returns the number of participants in a game.

#### getParticipantByIndex
```lua
local participantID, participant = ChestGameHelper.getParticipantByIndex(chestGameID: string, index: number)
```
Retrieves a participant by their turn order index.

#### getAvailableChests
```lua
local availableChests = ChestGameHelper.getAvailableChests(chestGameID: string)
```
Returns a list of chest indices that are still available for selection (not conflicting with other participants).

#### countParticipantsByID
```lua
local count = ChestGameHelper.countParticipantsByID(chestGameID: string)
```
Returns the number of participants in a game using the game ID instead of the game object.

#### isChestOpened
```lua
local isOpened = ChestGameHelper.isChestOpened(chestGameID: string, chestNum: number)
```
Returns whether a specific chest number has already been opened in the game.

#### getActiveParticipants
```lua
local activeIDs = ChestGameHelper.getActiveParticipants(chestGameID: string)
```
Returns a list of participant IDs for participants who still have health points > 0.

#### isBadChest
```lua
local isBad = ChestGameHelper.isBadChest(chestGameID: string, chestNum: number, excludeParticipantID: string?)
```
Returns whether a chest is "bad" (chosen by enemy participants). Optionally exclude a specific participant from the check.

## Configuration

### Game Instance Setup
1. **CollectionService Tag**: Add "ChestGame" tag to your model
2. **SeatPositions Folder**: Create folder with position parts
3. **ParticipantIndex**: Add NumberValue attribute to each position part
4. **Mat Part**: Add origin part for grid positioning

### Constants (ChestGameGeneral)
```lua
GRID_SIZE_X = 5,           -- Grid width
GRID_SIZE_Y = 5,           -- Grid height  
MAX_CHEST_CHOICE = 3,      -- Maximum chests per participant
TURN_TIMER = 10            -- Turn time limit in seconds
```

### Required Resources
- **Chest Prefabs**: `/ReplicatedStorage/Resources/Prefabs/Chests/`
  - "IronChest" (default for players)
  - "ObsidianChest" (for AI participant)
- **Chair Prefabs**: `/ReplicatedStorage/Resources/Prefabs/Chairs/`
  - Chair types referenced by DefaultChairType property
- **VFX Prefabs**: Chosen/Allow/Forbid indicators
- **UI Prefabs**: Billboard UI for participant count

## Network Communication

### Remote Events
- **ChestGameSystem/ChooseChest**: Client-to-server chest selection (ChoosingChests phase)
- **ChestGameSystem/OpenChest**: Client-to-server chest opening (InAction phase)

### State Synchronization
- **Network Discriminator**: "ChestGameState"
- **Automatic Sync**: All state changes sync to clients
- **Event-Driven**: Clients respond to state changes for rendering

### Network Flow
1. Server creates game → State syncs to clients
2. Players join seats → Participants added to state
3. State changes to "ChoosingChests" → Clients render interactive grid
4. Players select chests → Choices sync via state
5. State changes to "InAction" → Game phase begins
6. Players open chests → Actions via "ChestGameSystem/OpenChest" remote event
7. State changes to "Conclusion" → Rewards distributed, game resets

## Client Rendering

### Rendering System
The client uses a modular rendering system:

```lua
-- Main renderer controller
local ChestGameRendering = require(ReplicatedStorage.GameClient.ChestGameSystem.ChestGameRendering)

-- Interface for custom renderers
local IChestGameRenderer = require(ReplicatedStorage.GameClient.ChestGameSystem.IChestGameRenderer)
```

### Visual Features
- **Dynamic Grid**: 5x5 chest grid with participant-specific chest types
- **Interactive Selection**: ClickDetector with infinite range
- **Visual Indicators**: Chosen/Allow/Forbid VFX
- **Billboard UI**: Billboard UI for participant count
- **Cinematics**: Camera control for game events

### Stream-Aware Rendering
- Automatically cleans up when instances stream out
- Handles streaming interruptions gracefully
- Re-renders when instances stream back in

## Core Gameplay Mechanics

### Game Flow
The chest game follows a structured flow from setup to completion:

1. **Dormant**: Waiting for participants to join
2. **ChoosingChests**: Players select dangerous chests from the grid
3. **InAction**: Turn-based chest opening phase
4. **Conclusion**: Game ends, rewards distributed, game resets

### Turn-Based Gameplay
- **Turn Management**: Each participant takes turns opening chests
- **Timer System**: Each turn has a time limit (TURN_TIMER)
- **Auto-Selection**: If timer expires, a random valid chest is automatically selected
- **Turn Cycling**: Automatically advances to the next alive participant

### Chest Opening Mechanics
- **Dangerous Chests**: Each participant secretly chooses dangerous chests
- **Damage System**: Opening an enemy's dangerous chest deals 1 damage
- **Elimination**: Participants are eliminated when health reaches 0
- **Win Conditions**: Game ends when 0 or 1 participants remain alive

### Health System
- **Starting Health**: All participants start with HealthPointsMax health
- **Damage Calculation**: Each bad chest deals 1 damage point
- **Health Tracking**: Current health is tracked in real-time
- **Elimination**: Health = 0 means elimination from the current round

### Conflict Resolution
- **Chest Assignment**: During ChoosingChests phase, conflicting choices are automatically reassigned
- **Turn-Based Cycling**: Chest assignments cycle through participants to ensure fair distribution
- **Validation**: System ensures all chest selections are valid before game start

### Timeout Handling
- **Automatic Action**: Expired turns trigger automatic chest selection
- **Random Selection**: System chooses from available unopened, non-dangerous chests
- **Safety Checks**: Prevents selecting the player's own dangerous chest

## Server Systems

### Game Creation
- **Automatic Discovery**: Finds all instances with "ChestGame" tag
- **Unique IDs**: Generates GUID for each game instance
- **Streaming Integration**: Uses StreamingLib for instance sync

### Participant Management
- **Player Detection**: Monitors seat occupancy
- **AI Participants**: Auto-adds "Player1" with UserID "0"
- **Index Assignment**: Assigns turn order to participants

### Chest Selection Logic
- **Conflict Resolution**: Automatic reassignment for conflicting choices
- **Turn-Based Cycling**: Chest assignment cycles through participants
- **Validation**: Ensures valid chest selections

### Reward Distribution
- **Winner/Loser Rewards**: Different reward ranges for winners vs losers
- **Gamepass Multipliers**: Double coins, trophies, and win streak bonuses
- **Profile Integration**: Direct integration with ProfileSystem for reward distribution
- **VIP Bundle**: Comprehensive multiplier package for premium players

### Game Flow Control
- **State Transitions**: Manages game state changes
- **Timer Management**: Optional timer functionality with automatic expiration
- **Reset System**: Cleans up game after completion

## Reward System

### Reward Categories
The system distributes two types of rewards based on game outcome:

#### Winners (HealthPoints > 0)
- **Primary Currency**: Random amount from WinnerPrimaryRewardRange
- **Trophies**: Random amount from WinnerTrophyRewardRange  
- **Win Streak**: +1 win streak bonus

#### Losers (HealthPoints = 0)
- **Primary Currency**: Random amount from LoserPrimaryRewardRange
- **Trophies**: Random amount from LoserTrophyRewardRange
- **No Win Streak**: No win streak bonus for losers

### Gamepass Integration
The system supports multiple gamepass multipliers:

#### Available Gamepasses
```lua
-- From GameDefinitions/MarketplaceSystem/GamepassIDMap.toml
DoubleCoins        -- 2x primary currency multiplier
DoubleTrophies     -- 2x trophies multiplier  
DoubleWinStreak    -- 2x win streak multiplier
VIPBundle          -- All multipliers combined (2x everything)
```

#### Multiplier Application
```lua
local primaryCurrencyGamepassMult = 1  -- Default multiplier
local trophyGamepassMult = 1            -- Default multiplier
local winStreakMult = 1                 -- Default multiplier

-- VIP Bundle applies all multipliers
if ownsVIPBundle then
    primaryCurrencyGamepassMult = 2
    trophyGamepassMult = 2
    winStreakMult = 2
end

-- Final calculation
finalReward = baseReward * multiplier
```

### Profile System Integration
- **winChestGame()**: Called for winners with all rewards
- **loseChestGame()**: Called for losers with consolation rewards
- **Direct Integration**: No intermediate reward storage needed

### Reward Processing Flow
1. **Game Conclusion**: State changes to "Conclusion"  
2. **Reward Calculation**: Base rewards calculated from ranges
3. **Multiplier Application**: Gamepass bonuses applied
4. **Profile Update**: ProfileSystem methods called with final amounts
5. **Game Reset**: Game prepared for next round

## Integration with Framework

### TLib Dependencies
- **DataLib**: State container pattern and networking
- **StreamingLib**: Instance synchronization
- **NetLib**: Remote event communication
- **UILib**: Billboard UI management
- **CineLib**: Camera control and cinematics
- **TimeLib**: Time measurement and timer management

### Marketplace Integration
- **Gamepass Definitions**: `/GameDefinitions/MarketplaceSystem/GamepassIDMap.toml`
- **Supported Gamepasses**: DoubleCoins, DoubleTrophies, DoubleWinStreak, VIPBundle
- **Format**: TOML configuration file with numeric gamepass IDs

### Framework Patterns
- **State Container Pattern**: Centralized state management
- **Event-Driven Architecture**: Reactive system updates
- **Streaming-Aware Design**: Handles instance streaming
- **Type Safety**: Strict typing with Luau annotations

### Boot System Integration
```lua
-- Components automatically load via BootEvents.NetworkStarted
BootEvents.NetworkStarted:Connect(function()
    -- Initialize ChestGame systems
end)
```

## Usage Examples

### Creating a Custom Game Instance
```lua
-- In Roblox Studio:
-- 1. Create a model named "MyChestGame"
-- 2. Add "ChestGame" CollectionService tag
-- 3. Add "SeatPositions" folder with position parts
-- 4. Add "Mat" part as origin
-- 5. Set ParticipantIndex attributes on position parts
```

### Accessing Game State
```lua
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
local ChestGameHelper = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameHelper)

-- Get player's current game
local player = game.Players.LocalPlayer
local chestGameID, chestGame, participantID = ChestGameHelper.getPlayerChestGame(player)

if chestGame then
    print("Game State:", chestGame.State)
    print("Participants:", ChestGameHelper.countParticipants(chestGame))
end
```

### Custom Renderer Implementation
```lua
local IChestGameRenderer = require(ReplicatedStorage.GameClient.ChestGameSystem.IChestGameRenderer)

local CustomRenderer = {}
CustomRenderer.__index = CustomRenderer
setmetatable(CustomRenderer, IChestGameRenderer)

function CustomRenderer.new()
    local self = setmetatable({}, CustomRenderer)
    -- Initialize custom renderer
    return self
end

function CustomRenderer:render(chestGame: ChestGame)
    -- Custom rendering logic
end

function CustomRenderer:cleanup()
    -- Cleanup resources
end
```

## Troubleshooting

### Common Issues

#### Game Not Starting
- **Check**: Model has "ChestGame" CollectionService tag
- **Check**: SeatPositions folder exists with position parts
- **Check**: Minimum 2 participants (players + AI)

#### Chest Selection Not Working
- **Check**: Game state is "ChoosingChests"
- **Check**: Player is properly seated and added as participant
- **Check**: Network events are properly connected

#### Rendering Issues
- **Check**: Required prefabs exist in Resources/Prefabs/Chests/
- **Check**: Mat part is properly positioned
- **Check**: Streaming is not interrupting the instance

#### AI Participant Not Added
- **Check**: ChestGameAIParticipants system is loaded
- **Check**: NetworkStarted event has fired
- **Check**: AI addition logic is not disabled

#### Timer Not Stopping
- **Check**: ChestGameTimerStopper system is loaded
- **Check**: TimeLib.getTime() is returning valid values
- **Check**: TimerMax is properly set and <= current time

### Debug Tools
```lua
-- Note: There is no ChestGameHelper.setDebugMode function in this codebase.
-- For debugging, inspect ChestGameState and ChestGameHelper internals instead.
local ChestGameState = require(ReplicatedStorage.GameCommons.ChestGameSystem.ChestGameState)
for id, game in pairs(ChestGameState.Data.ChestGameCollection) do
    print("Game", id, "State:", game.State, "Participants:", ChestGameHelper.countParticipants(game))
end
```

## Performance Considerations

### Optimization Tips
- Object Pooling: Reuse chest instances when possible
- Batch Operations: Group state changes for network efficiency
- Streaming Awareness: Design for instances streaming in/out
- Mobile Optimization: Use lightweight VFX and UI

### Memory Management
- Cleanup: Properly cleanup renderers and event connections
- Streaming: Handle streaming interruptions gracefully
- State Size: Keep state data minimal for network efficiency

## Future Enhancements

### Potential Features
- Custom Chest Types: Support for additional chest varieties
- Chair System: Dynamic chair assignment based on DefaultChairType
- Scoring System: Track player performance and statistics
- Game Variants: Different game modes and rulesets
- Spectator Mode: Allow non-participants to view games
- Tournament Support: Multi-game competitions

### Extensibility Points
- Custom Renderers: Implement new visual styles
- Game Logic: Extend chest selection and game phases
- AI Behavior: Advanced AI participant strategies
- UI Components: Custom user interface elements

(End of file - total 388 lines)