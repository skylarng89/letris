extends Node2D

const BACKGROUND_COLOR = Color(0.1, 0.1, 0.1, 1.0)
const GRID_COLOR = Color(0.2, 0.2, 0.2, 1.0)

@onready var game = get_parent()
var blocks = {}  # Dictionary to store active block instances

func _ready():
	update_blocks()

func _draw():
	# Draw background
	draw_rect(Rect2(0, 0, game.GRID_WIDTH * game.CELL_SIZE, 
					game.GRID_HEIGHT * game.CELL_SIZE), BACKGROUND_COLOR)
	
	# Draw grid lines
	for x in range(game.GRID_WIDTH + 1):
		draw_line(Vector2(x * game.CELL_SIZE, 0),
				 Vector2(x * game.CELL_SIZE, game.GRID_HEIGHT * game.CELL_SIZE),
				 GRID_COLOR)
	
	for y in range(game.GRID_HEIGHT + 1):
		draw_line(Vector2(0, y * game.CELL_SIZE),
				 Vector2(game.GRID_WIDTH * game.CELL_SIZE, y * game.CELL_SIZE),
				 GRID_COLOR)

func update_blocks():
	# Clear existing blocks
	for block in blocks.values():
		block.queue_free()
	blocks.clear()
	
	# Draw locked blocks
	for y in range(game.GRID_HEIGHT):
		for x in range(game.GRID_WIDTH):
			var value = game.get_grid_value(x, y)
			if value != null:
				create_block(Vector2i(x, y), value)
	
	# Draw current piece
	if game.current_piece != null:
		for block_pos in game.current_piece:
			var pos = game.current_piece_pos + block_pos
			if pos.y >= 0:  # Only draw if block is inside the grid
				create_block(pos, game.current_piece_type)

func create_block(pos: Vector2i, type: String):
	# Load the block scene
	var block_scene = load("res://scenes/game/Block.tscn")
	var block = block_scene.instantiate()
	block.position = Vector2(pos.x * game.CELL_SIZE, pos.y * game.CELL_SIZE)
	block.block_type = type
	blocks[pos] = block
	add_child(block)
