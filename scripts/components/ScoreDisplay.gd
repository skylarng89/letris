extends Node2D

const PADDING = 15
const BACKGROUND_COLOR = Color(0.1, 0.1, 0.1, 1.0)
const TEXT_COLOR = Color(0.9, 0.9, 0.9, 1.0)
const HIGHLIGHT_COLOR = Color(1, 0.8, 0, 1)
const BORDER_COLOR = Color(0.2, 0.2, 0.2, 1.0)
const LABEL_COLOR = Color(0.7, 0.7, 0.7, 1.0)
const VERTICAL_SPACING = 10
const ROW_HEIGHT = 24
const LEFT_PADDING = 7     # Padding for labels
const RIGHT_PADDING = 55   # Increased padding for values
const COLUMN_DIVIDER = 0.42  # Equal split between labels and values

@onready var game = get_parent()
var box_width = 120
var box_height = ROW_HEIGHT * 4
var high_score = 0

func _ready():
	await get_tree().process_frame
	load_high_score()
	position_display()
	queue_redraw()

func _draw():
	# Draw main background exactly matching preview width
	draw_rect(Rect2(0, 0, box_width, box_height), BACKGROUND_COLOR)
	
	var font = ThemeDB.fallback_font
	var label_size = 12
	var value_size = 14
	
	# Calculate column positions
	var label_width = box_width * COLUMN_DIVIDER
	var value_section_start = label_width  # Where the values section begins
	
	# Draw vertical divider
	draw_line(Vector2(label_width, 0), Vector2(label_width, box_height), BORDER_COLOR)
	
	# Draw horizontal dividers
	for i in range(4):
		var y = i * ROW_HEIGHT
		draw_line(Vector2(0, y), Vector2(box_width, y), BORDER_COLOR)
	draw_line(Vector2(0, box_height), Vector2(box_width, box_height), BORDER_COLOR)
	
	var rows = [
		["SCORE", str(game.score).pad_zeros(6), TEXT_COLOR],
		["HIGH", str(high_score).pad_zeros(6), HIGHLIGHT_COLOR],
		["LEVEL", str(game.level).pad_zeros(2), TEXT_COLOR],
		["LINES", str(game.lines_cleared).pad_zeros(3), TEXT_COLOR]
	]
	
	for i in range(rows.size()):
		var y_pos = i * ROW_HEIGHT + ROW_HEIGHT/2 + 4
		
		# Draw label (left aligned)
		draw_string(font, Vector2(LEFT_PADDING, y_pos), 
				   rows[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 
				   label_size, LABEL_COLOR)
		
		# Draw value (right aligned)
		var value_pos = Vector2(box_width - RIGHT_PADDING, y_pos)
		draw_string(font, value_pos, 
				   rows[i][1], HORIZONTAL_ALIGNMENT_RIGHT, -1, 
				   value_size, rows[i][2])

func position_display():
	var preview_node = get_parent().get_node("PreviewWindow")
	if preview_node:
		var preview_pos = preview_node.position
		var preview_scale = preview_node.scale
		
		# Match width exactly with preview
		box_width = preview_node.PREVIEW_SIZE * preview_node.CELL_SIZE
		
		position = Vector2(
			preview_pos.x,
			preview_pos.y + ((preview_node.PREVIEW_SIZE * preview_node.CELL_SIZE + preview_node.LABEL_HEIGHT) * preview_scale.y) + VERTICAL_SPACING
		)
		
		scale = preview_scale

func update_display():
	if game.score > high_score:
		high_score = game.score
		save_high_score()
	queue_redraw()

func save_high_score():
	var save_file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	save_file.store_64(high_score)

func load_high_score():
	if FileAccess.file_exists("user://highscore.save"):
		var save_file = FileAccess.open("user://highscore.save", FileAccess.READ)
		high_score = save_file.get_64()

func _on_viewport_size_changed():
	position_display()
	queue_redraw()
