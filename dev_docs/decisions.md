# Development Decisions and Rationale

## Design Decisions

### 1. Grid System
- **Decision**: 10x20 grid size
- **Rationale**: Standard Tetris dimensions, proven gameplay experience
- **Implementation**: Using 2D array with null values for empty cells

### 2. Piece Movement
- **Decision**: Delayed fast drop (500ms)
- **Rationale**: Prevents accidental fast drops while maintaining responsive controls
- **Impact**: Better player control and gameplay feel

### 3. Visual Style
- **Decision**: Modern, minimalist UI with 3D-like blocks
- **Rationale**: Clean look that scales well on different devices
- **Implementation**: Using StyleBoxFlat for UI elements, custom block drawing

### 4. Score System
- **Decision**: Exponential scoring (pow(2, num_lines - 1) * 100)
- **Rationale**: Rewards clearing multiple lines simultaneously
- **Storage**: Local file persistence for high scores

### 5. Cross-Platform Support
- **Decision**: Built-in mobile support from start
- **Rationale**: Easier to implement during initial development
- **Implementation**: Responsive layout and touch input support

## Technical Choices

### 1. File Structure
- Organized by functionality (scenes, scripts, assets)
- Separate component scripts for maintainability
- UI elements in dedicated folders

### 2. Code Organization
- Constants at top of files
- Grouped related functions
- Clear separation of concerns between scripts

### 3. Scene Setup
- Node2D for main game objects
- CanvasLayer for UI elements
- Separate scenes for reusable elements

## Future Considerations

### 1. Planned Features
- Sound system design
- Particle effect implementation
- Menu system structure
- Mobile controls layout

### 2. Potential Challenges
- Mobile performance optimization
- Touch control responsiveness
- UI scaling on different devices

### 3. Extension Points
- Additional game modes
- Online features
- Achievement system