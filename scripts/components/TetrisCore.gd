extends Node2D

# Constants
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32
const MIN_SWIPE_DISTANCE = 50

# Tetrominoes definitions
const TETROMINOES = {
	"I": [Vector2i(0,-1), Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)],
	"O": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"T": [Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(0,1)],
	"S": [Vector2i(-1,0), Vector2i(0,0), Vector2i(0,-1), Vector2i(1,-1)],
	"Z": [Vector2i(-1,-1), Vector2i(0,-1), Vector2i(0,0), Vector2i(1,0)],
	"J": [Vector2i(-1,-1), Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0)],
	"L": [Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1)]
}

# Game state
var grid: Array = []
var current_piece = null
var current_piece_pos = Vector2i(0, 0)
var current_piece_type = ""
var next_piece_type = ""
var held_piece_type = ""
var can_hold = true
var score = 0
var level = 1
var lines_cleared = 0

# Game settings and timers
var normal_drop_time = 1.0
var fast_drop_time = 0.05
var drop_time = normal_drop_time
var drop_timer = 0.0
var fast_drop_delay = 0.5
var fast_drop_timer = 0.0
var is_fast_dropping = false

# Touch input handling
var touch_start_pos = null
var is_paused = false
var game_started = false

# Initialization and Setup
func _ready():
	setup_platform_specific()
	initialize_grid()
	setup_responsive_layout()
	if !OS.has_feature("mobile"):
		start_game()
	get_tree().root.size_changed.connect(_on_viewport_size_changed)

func setup_platform_specific():
	if OS.has_feature("mobile"):
		setup_mobile_controls()
	else:
		setup_keyboard_controls()

func setup_mobile_controls():
	if has_node("MobileControls"):
		$MobileControls.show()
		$MobileControls.move_left.connect(_on_mobile_move_left)
		$MobileControls.move_right.connect(_on_mobile_move_right)
		$MobileControls.rotate.connect(_on_mobile_rotate)
		$MobileControls.soft_drop.connect(_on_mobile_soft_drop)
		$MobileControls.soft_drop_released.connect(_on_mobile_soft_drop_released)
		$MobileControls.hold_piece.connect(_on_mobile_hold)

func setup_keyboard_controls():
	if has_node("MobileControls"):
		$MobileControls.hide()

func setup_responsive_layout():
	var screen_size = get_viewport().get_visible_rect().size
	var scale = min(screen_size.x / (GRID_WIDTH * CELL_SIZE * 1.5),
				   screen_size.y / (GRID_HEIGHT * CELL_SIZE * 1.2))
	scale = min(scale, 2.0)
	$Grid.scale = Vector2(scale, scale)
	var grid_size = Vector2(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
	$Grid.position = (screen_size - (grid_size * scale)) / 2

# Main Game Loop
func _process(delta):
	if current_piece == null or is_paused:
		return
	
	# Handle fast drop when down key is held
	if Input.is_action_pressed("ui_down"):
		if is_fast_dropping:
			drop_timer += delta
			if drop_timer >= fast_drop_time:
				drop_timer = 0
				move_down()
		else:
			# Start counting towards fast drop
			fast_drop_timer += delta
			if fast_drop_timer >= fast_drop_delay:
				is_fast_dropping = true
				drop_timer = 0
	else:
		# Normal dropping
		is_fast_dropping = false
		fast_drop_timer = 0
		drop_timer += delta
		if drop_timer >= normal_drop_time * pow(0.8, level - 1):
			drop_timer = 0
			move_down()
	
	$Grid.update_blocks()

# Input Handling
func _input(event):
	if current_piece == null:
		return
	if event.is_action_pressed("ui_left"):
		move_horizontal(-1)
	elif event.is_action_pressed("ui_right"):
		move_horizontal(1)
	elif event.is_action_pressed("ui_up"):
		rotate_piece()
	elif event.is_action_pressed("ui_down"):
		# Single tap moves piece down one step
		move_down()
		drop_timer = 0  # Reset drop timer to prevent immediate automatic drop
	elif event.is_action_pressed("ui_select"):  # Space bar
		hard_drop()

func handle_touch_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			if !game_started:
				start_game()
		else:
			touch_start_pos = null
			end_fast_drop()
	elif event is InputEventScreenDrag and touch_start_pos != null:
		var drag = event.position - touch_start_pos
		if abs(drag.x) > MIN_SWIPE_DISTANCE:
			move_horizontal(1 if drag.x > 0 else -1)
			touch_start_pos = event.position
		if drag.y > MIN_SWIPE_DISTANCE:
			start_fast_drop()
			touch_start_pos = event.position

# Grid Management
func initialize_grid():
	grid.clear()
	for y in range(GRID_HEIGHT):
		var row = []
		row.resize(GRID_WIDTH)
		for x in range(GRID_WIDTH):
			row[x] = null
		grid.append(row)

func get_grid_value(x: int, y: int) -> Variant:
	if y >= 0 and y < grid.size() and x >= 0 and x < grid[y].size():
		return grid[y][x]
	return null

func set_grid_value(x: int, y: int, value: Variant) -> void:
	if y >= 0 and y < grid.size() and x >= 0 and x < grid[y].size():
		grid[y][x] = value

# Piece Management
func spawn_new_piece():
	if next_piece_type == "":
		next_piece_type = TETROMINOES.keys()[randi() % TETROMINOES.size()]
	
	current_piece_type = next_piece_type
	current_piece = TETROMINOES[current_piece_type].duplicate()
	next_piece_type = TETROMINOES.keys()[randi() % TETROMINOES.size()]
	current_piece_pos = Vector2i(GRID_WIDTH / 2, 1)
	
	# Update preview
	if has_node("PreviewWindow"):
		$PreviewWindow.update_preview(next_piece_type)
	
	if !can_move_to(current_piece, current_piece_pos):
		game_over()

func move_horizontal(direction):
	var new_pos = current_piece_pos + Vector2i(direction, 0)
	if can_move_to(current_piece, new_pos):
		current_piece_pos = new_pos
		return true
	return false

func move_down():
	var new_pos = current_piece_pos + Vector2i(0, 1)
	if can_move_to(current_piece, new_pos):
		current_piece_pos = new_pos
		return true
	else:
		lock_piece()
		clear_lines()
		spawn_new_piece()
		return false

func hard_drop():
	while move_down():
		pass

func rotate_piece():
	var rotated_piece = []
	for block in current_piece:
		rotated_piece.append(Vector2i(-block.y, block.x))
	
	if can_move_to(rotated_piece, current_piece_pos):
		current_piece = rotated_piece

func can_move_to(piece, pos):
	for block in piece:
		var grid_pos = pos + block
		if grid_pos.x < 0 or grid_pos.x >= GRID_WIDTH or grid_pos.y >= GRID_HEIGHT:
			return false
		if grid_pos.y >= 0 and grid[grid_pos.y][grid_pos.x] != null:
			return false
	return true

func lock_piece():
	for block in current_piece:
		var grid_pos = current_piece_pos + block
		if grid_pos.y >= 0:
			grid[grid_pos.y][grid_pos.x] = current_piece_type

# Line Clearing and Scoring
func clear_lines():
	var lines_to_clear = []
	
	for y in range(GRID_HEIGHT):
		var line_full = true
		for x in range(GRID_WIDTH):
			if grid[y][x] == null:
				line_full = false
				break
		if line_full:
			lines_to_clear.append(y)
	
	if lines_to_clear.size() > 0:
		remove_lines(lines_to_clear)
		update_score(lines_to_clear.size())

func remove_lines(lines):
	lines.sort()
	for line in lines:
		for y in range(line, 0, -1):
			for x in range(GRID_WIDTH):
				grid[y][x] = grid[y-1][x]
		for x in range(GRID_WIDTH):
			grid[0][x] = null

func update_score(num_lines):
	var points = pow(2, num_lines - 1) * 100
	score += points
	lines_cleared += num_lines
	
	var new_level = (lines_cleared / 10) + 1
	if new_level != level:
		level = new_level
		normal_drop_time = max(0.1, 1.0 - (level - 1) * 0.1)
		drop_time = fast_drop_time if is_fast_dropping else normal_drop_time
	
	if has_node("ScoreDisplay"):
		$ScoreDisplay.update_display()

# Piece Holding
func hold_piece():
	if !can_hold:
		return
		
	can_hold = false
	var temp = current_piece_type
	
	if held_piece_type == "":
		held_piece_type = temp
		spawn_new_piece()
	else:
		current_piece_type = held_piece_type
		held_piece_type = temp
		current_piece = TETROMINOES[current_piece_type].duplicate()
		current_piece_pos = Vector2i(GRID_WIDTH / 2, 1)

# Drop Speed Management
func start_fast_drop():
	is_fast_dropping = true
	drop_time = fast_drop_time
	drop_timer = drop_time

func end_fast_drop():
	is_fast_dropping = false
	fast_drop_timer = 0
	drop_time = normal_drop_time * pow(0.8, level - 1)

# Mobile Control Handlers
func _on_mobile_move_left():
	move_horizontal(-1)

func _on_mobile_move_right():
	move_horizontal(1)

func _on_mobile_rotate():
	rotate_piece()

func _on_mobile_soft_drop():
	start_fast_drop()

func _on_mobile_soft_drop_released():
	end_fast_drop()

func _on_mobile_hold():
	hold_piece()

# Game State Management
func start_game():
	game_started = true
	spawn_new_piece()
	$Grid.update_blocks()

func game_over():
	print("Game Over!")
	reset_game()

func pause_game():
	is_paused = true
	set_process(false)

func resume_game():
	is_paused = false
	set_process(true)

func reset_game():
	score = 0
	level = 1
	lines_cleared = 0
	normal_drop_time = 1.0
	drop_time = normal_drop_time
	is_fast_dropping = false
	initialize_grid()
	held_piece_type = ""
	can_hold = true
	game_started = false
	is_paused = false
	current_piece = null
	next_piece_type = ""
	if has_node("ScoreDisplay"):
		$ScoreDisplay.update_display()
	if has_node("PreviewWindow"):
		$PreviewWindow.update_preview("")

func _on_viewport_size_changed():
	setup_responsive_layout() 
