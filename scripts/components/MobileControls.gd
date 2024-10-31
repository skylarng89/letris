extends CanvasLayer

signal move_left
signal move_right
signal rotate
signal soft_drop
signal soft_drop_released
signal hold_piece

# Touch state tracking
var touch_start_position = null
var is_touching = false

func _ready():
	if !OS.has_feature("mobile"):
		hide()

func _on_left_button_pressed():
	emit_signal("move_left")

func _on_right_button_pressed():
	emit_signal("move_right")

func _on_rotate_button_pressed():
	emit_signal("rotate")

func _on_down_button_pressed():
	emit_signal("soft_drop")

func _on_down_button_released():
	emit_signal("soft_drop_released")

func _on_hold_button_pressed():
	emit_signal("hold_piece")
