# Cinematic System Documentation

## Overview

The Cinematic System is a client-side camera management framework built on TLib CineLib that provides professional camera control, smooth transitions, and game-aware cinematics. It supports priority-based modifiers, real-time camera manipulation, and seamless integration with game events and state changes.

## Quick Start

### 1. Basic Camera Setup
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CineLib = require(ReplicatedStorage.TLib.CineLib)
local MainCinematicController = require(ReplicatedStorage.GameClient.CinematicSystem.MainCinematicController)

-- Controller is automatically initialized with default settings
-- Camera follows player by default
```

### 2. Adding Custom Camera Behavior
```lua
-- Add a cinematic modifier with priority 10
MainCinematicController:AddModifier("MyCinematic@10", function(cameraChanges, dt: number)
    -- Smooth camera transition
    local goalCFrame = CFrame.lookAt(cameraPosition, targetPosition)
    cameraChanges.CFrame = cameraChanges.CFrame:Lerp(goalCFrame, dt * 2)
    cameraChanges.CameraType = Enum.CameraType.Scriptable
    cameraChanges.FOV = 45
end)
```

### 3. Camera Control Patterns
```lua
-- Basic follow behavior (Priority 1)
MainCinematicController:AddModifier("PlayerFollow@1", function(cameraChanges, dt)
    cameraChanges.CameraSubject = Players.LocalPlayer.Character
end)

-- Game cinematics (Priority 2-10)
MainCinematicController:AddModifier("GameCinematics@5", function(cameraChanges, dt)
    -- Game-specific camera logic
end)
```

## Architecture

### File Structure
```
GameClient/CinematicSystem/
└── MainCinematicController.luau           # Main controller instance and setup

GameClient/ChestGameSystem/
└── ChestGameCinematics.luau               # Game-specific camera implementation

TLib/CineLib/
├── init.luau                              # Library entry point
├── CinematicController.luau               # Core controller implementation
└── CineLibTypes.luau                      # Type definitions
```

### Core Components

#### MainCinematicController
- **Purpose**: Global camera controller for the entire game
- **Initialization**: Automatically starts with default player-follow behavior
- **Modifier System**: Priority-based camera behavior modification
- **Lifecycle**: Persistent throughout game session

#### ChestGameCinematics
- **Purpose**: Game-specific camera behavior for ChestGame system
- **Integration**: Automatically activates when player joins a game
- **Camera Positioning**: Isometric view of game board
- **State Awareness**: Responds to game state changes

## Data Structures

### CameraChanges
```lua
type CameraChanges = {
    CameraType: Enum.CameraType?,           -- Camera control mode
    CameraSubject: PVInstance?,              -- What camera follows
    FOV: number?,                            -- Field of view
    CFrame: CFrame?,                         -- Camera position and orientation
}
```

### CameraModifier
```lua
type CameraModifier = (cameraChanges: CameraChanges, dt: number) -> ()
```

### CinematicController
```lua
type CinematicController = {
    ID: string,                              -- Unique identifier
    TargetCamera: Camera,                    -- Controlled camera instance
    AddModifier: (self, modifierInfo: string, modifier: CameraModifier) -> (),
    RemoveModifier: (self, modifierID: string) -> (),
    Start: (self, defaultCameraSettings: CameraChanges) -> (),
    Destroy: (self) -> (),
}
```

## API Reference

### MainCinematicController Methods

#### AddModifier
```lua
MainCinematicController:AddModifier(modifierInfo: string, modifier: CameraModifier)
```
Adds a camera modifier with priority-based execution order.

**Parameters:**
- `modifierInfo`: String formatted as `"ModifierID@Priority"` (e.g., `"GameCinematics@5"`)
- `modifier`: Function that modifies camera properties

**Example:**
```lua
MainCinematicController:AddModifier("ZoomEffect@8", function(cameraChanges, dt)
    cameraChanges.FOV = math.lerp(cameraChanges.FOV or 70, 30, dt * 3)
end)
```

#### RemoveModifier
```lua
MainCinematicController:RemoveModifier(modifierID: string)
```
Removes a modifier by its ID (without priority).

**Example:**
```lua
MainCinematicController:RemoveModifier("ZoomEffect")
```

### TLib CineLib Core

#### CinematicController.new
```lua
local controller = CineLib.CinematicController.new(targetCamera: Camera)
```
Creates a new cinematic controller instance.

#### Start
```lua
controller:Start(defaultCameraSettings: CameraChanges?)
```
Binds the controller to render loop with optional default settings.

#### Destroy
```lua
controller:Destroy()
```
Stops the controller and cleans up render step binding.

## Configuration

### Default Camera Settings
```lua
MainCinematicController:Start({
    FOV = 70,
    CameraType = Enum.CameraType.Custom,
})
```

### Priority System
- **Priority 1-3**: Basic player follow and controls
- **Priority 4-6**: Game-specific cinematics
- **Priority 7-10**: Special effects and overrides
- **Priority 11+**: Emergency system overrides

### Modifier Naming Convention
```lua
-- Format: "ModifierID@Priority"
"Default@1"           -- Default player follow
"ChestGameCinematics@2" -- Game cinematics
"Cutscene@5"          -- Story sequences
"SpecialEffect@8"     -- Zoom effects, transitions
```

## Game Integration

### ChestGame Camera Implementation

The ChestGame system provides an example of game-specific camera control:

```lua
MainCinematicController:AddModifier("ChestGameCinematics@2", function(cameraChanges, dt: number)
    local activeChestGameID, activeChestGame, _ = ChestGameHelper.getPlayerChestGame(LocalPlayer)
    
    if activeChestGameID == nil then
        return -- Not in game, skip camera changes
    end
    
    local activeChestGameInstance = StreamingLibClient.getInstance(activeChestGame.InstanceStreamableID)
    
    if activeChestGameInstance then
        -- Calculate isometric view
        local origin = activeChestGameInstance.Mat.CFrame
        local originRotated = origin * CFrame.fromEulerAnglesYXZ(-math.pi * 0.75, math.pi, 0)
        local vantagePointCFrame = originRotated * CFrame.new(0, -10, 40)
        local focalPoint = origin.Position
        local goalCFrame = CFrame.lookAt(vantagePointCFrame.Position, focalPoint)
        
        -- Smooth interpolation
        cameraChanges.CFrame = MainCinematicController.TargetCamera.CFrame:Lerp(goalCFrame, dt * 2)
        cameraChanges.CameraType = Enum.CameraType.Scriptable
        cameraChanges.FOV = 45
    end
end)
```

### State-Aware Camera Behavior

```lua
-- React to game state changes
ChestGameState.changeState.listen(function(chestGameID: string, newState: ChestGameState)
    if chestGameID == activeGameID then
        if newState == "InAction" then
            -- Zoom in for action phase
            MainCinematicController:AddModifier("ActionZoom@6", actionZoomModifier)
        else
            -- Remove action zoom
            MainCinematicController:RemoveModifier("ActionZoom")
        end
    end
end)
```

## Camera Control Patterns

### Smooth Transitions
```lua
-- Linear interpolation (LERP)
cameraChanges.CFrame = currentCFrame:Lerp(goalCFrame, dt * speed)

-- Smooth damping
local function smoothDamp(current: Vector3, target: Vector3, velocity: Vector3, smoothTime: number)
    return current + (target - current) * (dt / smoothTime)
end
```

### Camera Composition
```lua
-- Look-at positioning
local goalCFrame = CFrame.lookAt(cameraPosition, targetPosition, upVector)

-- Offset positioning
local goalCFrame = targetCFrame * CFrame.new(offsetX, offsetY, offsetZ)

-- Rotated positioning
local goalCFrame = targetCFrame * CFrame.fromEulerAnglesYXZ(pitch, yaw, roll)
```

### Dynamic Zoom
```lua
local function zoomEffect(cameraChanges, dt, targetFOV, speed)
    local currentFOV = cameraChanges.FOV or 70
    cameraChanges.FOV = math.lerp(currentFOV, targetFOV, dt * speed)
end
```

## Advanced Usage Examples

### Multi-Phase Cinematic Sequence
```lua
local function createCutsceneSequence()
    local phase = 1
    
    MainCinematicController:AddModifier("Cutscene@5", function(cameraChanges, dt)
        if phase == 1 then
            -- Wide establishing shot
            cameraChanges.CFrame = CFrame.lookAt(
                Vector3.new(0, 50, 100),
                Vector3.new(0, 0, 0)
            )
            cameraChanges.FOV = 60
            
        elseif phase == 2 then
            -- Zoom in to action
            local targetCFrame = CFrame.lookAt(
                Vector3.new(10, 20, 30),
                Vector3.new(0, 10, 0)
            )
            cameraChanges.CFrame = cameraChanges.CFrame:Lerp(targetCFrame, dt * 2)
            cameraChanges.FOV = math.lerp(cameraChanges.FOV or 60, 40, dt * 2)
            
        elseif phase == 3 then
            -- Return to player
            cameraChanges.CameraSubject = Players.LocalPlayer.Character
            cameraChanges.CameraType = Enum.CameraType.Custom
            cameraChanges.FOV = math.lerp(cameraChanges.FOV or 40, 70, dt * 3)
        end
    end)
    
    -- Advance phases
    task.delay(3, function() phase = 2 end)
    task.delay(6, function() phase = 3 end)
    task.delay(9, function()
        MainCinematicController:RemoveModifier("Cutscene")
    end)
end
```

### Event-Driven Camera Control
```lua
-- React to player interactions
local function setupReactiveCamera()
    MainCinematicController:AddModifier("Reactive@3", function(cameraChanges, dt)
        local character = Players.LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
            -- Player is moving - dynamic follow
            local lookVector = humanoid.MoveDirection.Unit
            local offset = lookVector * 5 + Vector3.new(0, 2, 0)
            local goalPosition = character.PrimaryPart.Position + offset
            local currentCFrame = cameraChanges.CFrame or workspace.CurrentCamera.CFrame
            
            cameraChanges.CFrame = CFrame.lookAt(goalPosition, character.PrimaryPart.Position)
        else
            -- Player is idle - standard follow
            cameraChanges.CameraSubject = character
            cameraChanges.CameraType = Enum.CameraType.Custom
        end
    end)
end
```

## Integration with Framework

### TLib Dependencies
- **CineLib**: Core camera management and cinematic control
- **StreamingLib**: Instance synchronization for game objects
- **DataLib**: State change event handling
- **TimeLib**: Time-based animation calculations

### Framework Patterns
- **Modifier System**: Priority-based behavior modification
- **Event-Driven**: Reactive to game state changes
- **State Container Integration**: Responds to state updates
- **Streaming-Aware**: Handles instance streaming gracefully

### Boot System Integration
```lua
-- Cinematic system loads automatically via GameClient structure
-- MainCinematicController is initialized when module is required
-- Game-specific cinematics load when their respective systems initialize
```

## Performance Considerations

### Optimization Guidelines
- **Modifier Efficiency**: Keep modifier functions lightweight
- **Conditional Updates**: Only modify when necessary
- **Memory Management**: Remove modifiers when not needed
- **Smooth Interpolation**: Use appropriate interpolation speeds

### Memory Management
```lua
-- Clean up modifiers properly
local function cleanupCinematics()
    MainCinematicController:RemoveModifier("GameCinematics")
    MainCinematicController:RemoveModifier("Cutscene")
    MainCinematicController:RemoveModifier("SpecialEffect")
end

-- Clean up on game end
game.Players.LocalPlayer.CharacterRemoving:Connect(cleanupCinematics)
```

## Troubleshooting

### Common Issues

#### Camera Not Responding
- **Check**: MainCinematicController is properly initialized
- **Check**: Modifier priority is correct and conflicts aren't occurring
- **Check**: Camera type is set appropriately (Custom vs Scriptable)

#### Jerky Camera Movement
- **Check**: Interpolation speed is reasonable (dt * 2 is common)
- **Check**: Goal CFrame calculations are correct
- **Check**: Multiple modifiers aren't conflicting

#### Game Camera Not Activating
- **Check**: Game state is properly detected
- **Check**: StreamingLib instance is available
- **Check**: Modifier priority allows override

#### Performance Issues
- **Check**: Modifier functions are efficient
- **Check**: Unnecessary math operations are optimized
- **Check**: Cleanup is happening when modifiers are removed

### Debug Tools
```lua
-- Debug modifier execution
MainCinematicController:AddModifier("Debug@0", function(cameraChanges, dt)
    print("Camera Changes:", cameraChanges)
    print("Camera CFrame:", MainCinematicController.TargetCamera.CFrame)
end)

-- Check active modifiers
print("Active Modifiers:", MainCinematicController._modifiers)
print("Modifier Order:", MainCinematicController._modifierOrder)
```

### Testing Guidelines
1. **Test in Roblox Studio**: Verify camera behavior in play mode
2. **Multi-player Testing**: Ensure cinematics work for all players
3. **Streaming Tests**: Verify camera handles instance streaming
4. **State Testing**: Test camera responses to game state changes

## Best Practices

### Modifier Design
- **Single Responsibility**: Each modifier handles one camera aspect
- **Conditional Logic**: Only modify when necessary
- **Priority Awareness**: Use appropriate priority levels
- **Clean Transitions**: Ensure smooth interpolation

### Game Integration
- **State Awareness**: React to game state changes appropriately
- **Streaming Safety**: Handle instance streaming gracefully
- **Performance**: Minimize computational overhead
- **User Experience**: Maintain comfortable camera movement

### Code Organization
- **Descriptive Names**: Use clear modifier identifiers
- **Documentation**: Document complex camera behaviors
- **Modularity**: Keep game-specific cinematics separate
- **Maintainability**: Design for easy modification and extension

## Future Enhancements

### Potential Features
- **Camera Shake**: Impact and cinematic effects
- **Path Following**: Predefined camera paths and sequences
- **Multi-Camera**: Support for camera switching and blending
- **Recording**: Camera path recording and playback
- **Advanced Transitions**: Custom easing functions and effects

### Extensibility Points
- **Custom Modifiers**: Implement specialized camera behaviors
- **Game Integration**: Add cinematics for new game systems
- **Visual Effects**: Combine camera control with VFX
- **UI Integration**: Coordinate camera with UI elements
- **Network Sync**: Synchronize camera for multiplayer experiences

---

*End of documentation - total 284 lines*