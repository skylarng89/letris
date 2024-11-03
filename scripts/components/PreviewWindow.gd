extends Node2D

const CELL_SIZE = 24
const PREVIEW_SIZE = 5
const BACKGROUND_COLOR = Color(0.1, 0.1, 0.1, 1.0)
const GRID_COLOR = Color(0.2, 0.2, 0.2, 1.0)
const PADDING = 15
const LABEL_HEIGHT = 24  # Height for "NEXT" label
const TEXT_COLOR = Color(0.7, 0.7, 0.7, 1.0)  # Matching score display label color

@onready var game = get_parent()
var block_scene: PackedScene
var preview_blocks = {}

func _ready():
	block_scene = load("res://scenes/game/Block.tscn")
	await get_tree().process_frame
	position_preview_window()
	queue_redraw()

func _draw():
	var size = CELL_SIZE * PREVIEW_SIZE
	var total_height = size + LABEL_HEIGHT
	
	# Draw entire background including label area
	draw_rect(Rect2(0, 0, size, total_height), BACKGROUND_COLOR)
	
	# Draw "NEXT" text
	var font = ThemeDB.fallback_font
	var font_size = 12  # Matching score display size
	var text = "NEXT"
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var text_pos = Vector2(7, LABEL_HEIGHT/2 + 4)  # Matching score display padding
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	
	# Draw horizontal separator below text
	draw_line(Vector2(0, LABEL_HEIGHT), Vector2(size, LABEL_HEIGHT), GRID_COLOR)
	
	# Draw grid lines for preview area
	for i in range(PREVIEW_SIZE + 1):
		draw_line(
			Vector2(i * CELL_SIZE, LABEL_HEIGHT), 
			Vector2(i * CELL_SIZE, total_height), 
			GRID_COLOR
		)
		draw_line(
			Vector2(0, i * CELL_SIZE + LABEL_HEIGHT), 
			Vector2(size, i * CELL_SIZE + LABEL_HEIGHT), 
			GRID_COLOR
		)

func position_preview_window():
	var grid_node = get_parent().get_node("Grid")
	if grid_node:
		var grid_position = grid_node.position
		var grid_scale = grid_node.scale
		
		position = Vector2(
			grid_position.x + (game.GRID_WIDTH * game.CELL_SIZE * grid_scale.x) + PADDING,
			grid_position.y  # Align with top of grid
		)
		
		scale = grid_scale

func update_preview(piece_type: String):
	for block in preview_blocks.values():
		block.queue_free()
	preview_blocks.clear()
	
	if piece_type == "":
		return
	
	var piece = game.TETROMINOES[piece_type]
	
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
	
	var offset_x = (PREVIEW_SIZE - piece_width) / 2
	var offset_y = (PREVIEW_SIZE - piece_height) / 2
	
	for block_pos in piece:
		var adjusted_pos = Vector2i(
			block_pos.x - min_x + floor(offset_x),
			block_pos.y - min_y + floor(offset_y)
		)
		create_preview_block(adjusted_pos, piece_type)

func create_preview_block(pos: Vector2i, type: String):
	var block = block_scene.instantiate()
	block.position = Vector2(pos.x * CELL_SIZE, pos.y * CELL_SIZE + LABEL_HEIGHT)
	block.block_type = type
	block.scale = Vector2(CELL_SIZE / float(game.CELL_SIZE), 
						 CELL_SIZE / float(game.CELL_SIZE))
	preview_blocks[pos] = block
	add_child(block)

func _on_viewport_size_changed():
	position_preview_window()
	queue_redraw()
