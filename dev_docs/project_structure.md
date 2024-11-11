# CubiDrop Project Structure

## File Organization
```
CubiDrop/
├── docs/
│   ├── IMPLEMENTATION.md
│   ├── FEATURES.md
│   ├── DEBUGGING.md
│   ├── DEVLOG.md
│   ├── PROJECT_STRUCTURE.md
│   ├── CODE_REFERENCE.md
│   └── DECISIONS.md
├── assets/
│   ├── sprites/
│   ├── sounds/
│   ├── music/
│   └── fonts/
├── scenes/
│   ├── game/
│   │   ├── Game.tscn
│   │   ├── Block.tscn
│   │   └── ResetDialog.tscn
│   └── ui/
├── scripts/
│   ├── components/
│   │   ├── TetrisCore.gd
│   │   ├── TetrisGrid.gd
│   │   ├── TetrisBlock.gd
│   │   ├── PreviewWindow.gd
│   │   └── ScoreDisplay.gd
│   └── ui/
│       └── ResetDialog.gd
└── README.md
```

## Scene Hierarchy
```
Game (Node2D)
├── Grid (Node2D)
│   └── TetrisGrid.gd
├── PreviewWindow (Node2D)
│   └── PreviewWindow.gd
├── ScoreDisplay (Node2D)
│   └── ScoreDisplay.gd
└── ResetDialog (CanvasLayer)
    └── ConfirmationDialog