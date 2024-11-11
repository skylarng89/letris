# CubiDrop Code Reference

## Core Constants
```gdscript
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32
const MIN_SWIPE_DISTANCE = 50
```

## Tetrominoes Definition
```gdscript
const TETROMINOES = {
    "I": [Vector2i(0,-1), Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)],
    "O": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
    "T": [Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(0,1)],
    "S": [Vector2i(-1,0), Vector2i(0,0), Vector2i(0,-1), Vector2i(1,-1)],
    "Z": [Vector2i(-1,-1), Vector2i(0,-1), Vector2i(0,0), Vector2i(1,0)],
    "J": [Vector2i(-1,-1), Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0)],
    "L": [Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1)]
}
```

## Game Settings
```gdscript
# Timing Constants
normal_drop_time = 1.0
fast_drop_time = 0.05
fast_drop_delay = 0.5

# UI Constants
PADDING = 15
BACKGROUND_COLOR = Color(0.1, 0.1, 0.1, 1.0)
TEXT_COLOR = Color(0.9, 0.9, 0.9, 1.0)
HIGHLIGHT_COLOR = Color(1, 0.8, 0, 1)
```

## Key Functions Reference

### Grid Management
- `initialize_grid()`: Creates empty game grid
- `get_grid_value(x, y)`: Safe grid access
- `set_grid_value(x, y, value)`: Safe grid value setting

### Piece Management
- `spawn_new_piece()`: Creates new active piece
- `move_horizontal(direction)`: Horizontal movement
- `move_down()`: Downward movement
- `rotate_piece()`: Piece rotation
- `can_move_to(piece, pos)`: Collision detection

### Scoring System
- `update_score(num_lines)`: Updates score and level
- `save_high_score()`: Persists high score
- `load_high_score()`: Loads saved high score

### Display Management
- `update_display()`: Updates score display
- `update_preview(piece_type)`: Updates preview window
- `setup_responsive_layout()`: Handles screen scaling

## Controls Configuration
```gdscript
# Keyboard
ui_left: Move left
ui_right: Move right
ui_up: Rotate
ui_down: Soft drop
ui_select: Hard drop
ui_cancel: Reset game

# Mobile (Planned)
Swipe left/right: Move
Swipe down: Soft drop
Tap: Rotate
```