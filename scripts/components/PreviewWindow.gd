extends Node2D

const CELL_SIZE = 24  # Smaller than main grid for preview
const PREVIEW_SIZE = 4  # 4x4 grid for preview
const BACKGROUND_COLOR = Color(0.1, 0.1, 0.1, 1.0)
const GRID_COLOR = Color(0.2, 0.2, 0.2, 1.0)
const PREVIEW_PADDING = 10  # Padding from main grid

@onready var game = get_parent()
var block_scene: PackedScene
var preview_blocks = {}

func _ready():
	block_scene = load("res://scenes/game/Block.tscn")
	
	# Wait one frame to ensure the grid is properly positioned
	await get_tree().process_frame
	position_preview_window()
	queue_redraw()

func position_preview_window():
	# Calculate position based on main grid's position and size
	var grid_node = get_parent().get_node("Grid")
	if grid_node:
		var grid_position = grid_node.position
		var grid_scale = grid_node.scale
		
		# Force initial positioning if grid_scale is zero or very small
		if grid_scale.x < 0.1:
			grid_scale = Vector2(1, 1)
			
		# Position the preview window to the right of the grid
		position = Vector2(
			grid_position.x + (game.GRID_WIDTH * game.CELL_SIZE * grid_scale.x) + PREVIEW_PADDING,
			grid_position.y  # Align with top of grid
		)
		
		# Match the grid's scale
		scale = grid_scale

func _draw():
	# Draw preview box background
	var size = CELL_SIZE * PREVIEW_SIZE
	draw_rect(Rect2(0, 0, size, size), BACKGROUND_COLOR)
	
	# Draw grid lines
	for i in range(PREVIEW_SIZE + 1):
		draw_line(Vector2(i * CELL_SIZE, 0), 
				 Vector2(i * CELL_SIZE, size), 
				 GRID_COLOR)
		draw_line(Vector2(0, i * CELL_SIZE), 
				 Vector2(size, i * CELL_SIZE), 
				 GRID_COLOR)
	
	# Draw "NEXT" text
	var font = ThemeDB.fallback_font
	var font_size = 16
	var text = "NEXT"
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos = Vector2(
		(size - text_size.x) / 2,
		-text_size.y - 5
	)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)

func update_preview(piece_type: String):
	# Clear existing preview
	for block in preview_blocks.values():
		block.queue_free()
	preview_blocks.clear()
	
	if piece_type == "":
		return
	
	# Get piece data
	var piece = game.TETROMINOES[piece_type]
	
	# Calculate piece bounds for centering
	var min_x = 999
	var max_x = -999
	var min_y = 999
	var max_y = -999
	
	for block_pos in piece:
		min_x = min(min_x, block_pos.x)
		max_x = max(max_x, block_pos.x)
		min_y = min(min_y, block_pos.y)
		max_y = max(max_y, block_pos.y)
	
	var piece_width = max_x - min_x + 1
	var piece_height = max_y - min_y + 1
	
	# Calculate offset to center the piece
	var offset_x = (PREVIEW_SIZE - piece_width) / 2
	var offset_y = (PREVIEW_SIZE - piece_height) / 2
	
	# Create preview blocks
	for block_pos in piece:
		var adjusted_pos = Vector2i(
			block_pos.x - min_x + floor(offset_x),
			block_pos.y - min_y + floor(offset_y)
		)
		create_preview_block(adjusted_pos, piece_type)

func create_preview_block(pos: Vector2i, type: String):
	var block = block_scene.instantiate()
	block.position = Vector2(pos.x * CELL_SIZE, pos.y * CELL_SIZE)
	block.block_type = type
	block.scale = Vector2(CELL_SIZE / float(game.CELL_SIZE), 
						 CELL_SIZE / float(game.CELL_SIZE))
	preview_blocks[pos] = block
	add_child(block)

# Add this to handle viewport changes
func _on_viewport_size_changed():
	position_preview_window()
	queue_redraw()
