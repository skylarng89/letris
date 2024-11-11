extends CanvasLayer

signal confirmed
signal cancelled

# Style constants
const DIALOG_WIDTH = 300
const DIALOG_HEIGHT = 120
const BACKGROUND_COLOR = Color(0.13, 0.13, 0.13, 0.95)
const BORDER_COLOR = Color(0.3, 0.3, 0.3, 1.0)
const TEXT_COLOR = Color(0.9, 0.9, 0.9, 1.0)
const BUTTON_COLOR = Color(0.2, 0.2, 0.2, 1.0)
const BUTTON_HOVER_COLOR = Color(0.25, 0.25, 0.25, 1.0)

@onready var dialog = $ConfirmationDialog

func _ready():
	await get_tree().process_frame  # Wait for one frame
	setup_dialog()
	hide()

func setup_dialog():
	if not dialog:
		return
		
	# Set size and position
	dialog.size = Vector2(DIALOG_WIDTH, DIALOG_HEIGHT)
	dialog.position = (get_viewport().size - dialog.size) / 2
	
	# Set text and title
	dialog.dialog_text = "Reset game and all scores?"
	dialog.title = "Confirm Reset"
	
	# Style the dialog
	var style = StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = BORDER_COLOR
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	dialog.add_theme_stylebox_override("panel", style)
	dialog.add_theme_color_override("font_color", TEXT_COLOR)
	
	# Style the buttons
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = BUTTON_COLOR
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	
	var button_hover_style = button_style.duplicate()
	button_hover_style.bg_color = BUTTON_HOVER_COLOR
	
	dialog.get_ok_button().add_theme_stylebox_override("normal", button_style)
	dialog.get_ok_button().add_theme_stylebox_override("hover", button_hover_style)
	dialog.get_cancel_button().add_theme_stylebox_override("normal", button_style)
	dialog.get_cancel_button().add_theme_stylebox_override("hover", button_hover_style)
	
	# Connect signals
	if not dialog.confirmed.is_connected(_on_confirmation_dialog_confirmed):
		dialog.confirmed.connect(_on_confirmation_dialog_confirmed)
	if not dialog.canceled.is_connected(_on_confirmation_dialog_canceled):
		dialog.canceled.connect(_on_confirmation_dialog_canceled)

func show_dialog():
	if dialog:
		dialog.popup_centered()
		dialog.grab_focus()

func _on_confirmation_dialog_confirmed():
	emit_signal("confirmed")

func _on_confirmation_dialog_canceled():
	emit_signal("cancelled")

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		if dialog:
			dialog.position = (get_viewport().size - dialog.size) / 2
