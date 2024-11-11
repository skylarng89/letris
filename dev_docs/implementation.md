# CubiDrop Implementation Documentation

## Core Game Structure
Implemented key game files:
- `TetrisCore.gd`: Main game logic
- `TetrisGrid.gd`: Grid rendering and management
- `TetrisBlock.gd`: Individual block rendering
- `PreviewWindow.gd`: Next piece preview
- `ScoreDisplay.gd`: Score and statistics display
- `ResetDialog.gd`: Game reset functionality

## Key Implementations

### 1. Grid System
```gdscript
# Constants
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32
```
- Implemented 10x20 grid
- Cell-based movement and collision
- Safe grid access methods

### 2. Piece Management
- Seven standard Tetromino pieces (I, O, T, S, Z, J, L)
- Piece rotation and movement
- Collision detection
- Preview system

### 3. Scoring System
- Progressive scoring based on lines cleared
- High score persistence
- Level progression
- Lines cleared tracking

### 4. Movement Controls
```gdscript
# Movement speeds
var normal_drop_time = 1.0
var fast_drop_time = 0.05
var fast_drop_delay = 0.5
```
- Basic movement (left/right)
- Rotation
- Soft drop with delay
- Hard drop

### 5. Visual Components
- Grid rendering
- Block styling with 3D effect
- Preview window
- Score display
- Reset button UI

## File Organization
```
CubiDrop/
├── assets/
│   ├── sprites/
│   ├── sounds/
│   ├── music/
│   └── fonts/
├── scenes/
│   ├── game/
│   ├── ui/
│   └── menus/
└── scripts/
    ├── autoload/
    └── components/
```