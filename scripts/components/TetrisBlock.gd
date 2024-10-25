extends Node2D

@export var block_type: String = "" # Added default value

const COLORS = {
	"I": Color(0.0, 0.8, 0.8, 1.0),  # Cyan
	"O": Color(0.8, 0.8, 0.0, 1.0),  # Yellow
	"T": Color(0.8, 0.0, 0.8, 1.0),  # Purple
	"S": Color(0.0, 0.8, 0.0, 1.0),  # Green
	"Z": Color(0.8, 0.0, 0.0, 1.0),  # Red
	"J": Color(0.0, 0.0, 0.8, 1.0),  # Blue
	"L": Color(0.8, 0.4, 0.0, 1.0)   # Orange
}

@onready var size: int = 32  # Default size if parent isn't available

func _ready():
	if get_parent() and "CELL_SIZE" in get_parent():
		size = get_parent().CELL_SIZE
	queue_redraw()

func _draw():
	if block_type in COLORS:
		var color = COLORS[block_type]
		
		# Draw main block
		draw_rect(Rect2(1, 1, size-2, size-2), color)
		
		# Draw highlight (top-left)
		var highlight_color = color.lightened(0.3)
		var points = PackedVector2Array([
			Vector2(0, 0),
			Vector2(size, 0),
			Vector2(size-4, 4),
			Vector2(4, 4),
			Vector2(4, size-4),
			Vector2(0, size)
		])
		draw_colored_polygon(points, highlight_color)
		
		# Draw shadow (bottom-right)
		var shadow_color = color.darkened(0.3)
		points = PackedVector2Array([
			Vector2(size, 0),
			Vector2(size, size),
			Vector2(0, size),
			Vector2(4, size-4),
			Vector2(size-4, size-4),
			Vector2(size-4, 4)
		])
		draw_colored_polygon(points, shadow_color)
