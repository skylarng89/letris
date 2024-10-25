extends Node2D

# Constants
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32

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

# Game settings
var drop_time = 1.0
var drop_timer = 0.0

func _ready():
	initialize_grid()
	spawn_new_piece()
	$Grid.update_blocks()

func initialize_grid():
	grid.clear()
	# Initialize with a 2D array filled with null values
	for y in range(GRID_HEIGHT):
		var row = []
		row.resize(GRID_WIDTH)
		for x in range(GRID_WIDTH):
			row[x] = null
		grid.append(row)

func spawn_new_piece():
	if next_piece_type == "":
		next_piece_type = TETROMINOES.keys()[randi() % TETROMINOES.size()]
	
	current_piece_type = next_piece_type
	current_piece = TETROMINOES[current_piece_type].duplicate()
	next_piece_type = TETROMINOES.keys()[randi() % TETROMINOES.size()]
	
	# Start position (center-top of grid)
	current_piece_pos = Vector2i(GRID_WIDTH / 2, 1)
	
	if !can_move_to(current_piece, current_piece_pos):
		game_over()

func _process(delta):
	if current_piece == null:
		return
		
	drop_timer += delta
	if drop_timer >= drop_time:
		drop_timer = 0
		move_down()
	$Grid.update_blocks()

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
		move_down()

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
	
	# Update level every 10 lines
	var new_level = (lines_cleared / 10) + 1
	if new_level != level:
		level = new_level
		drop_time = max(0.1, 1.0 - (level - 1) * 0.1)

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

func game_over():
	print("Game Over!")
	score = 0
	level = 1
	lines_cleared = 0
	drop_time = 1.0
	initialize_grid()
	held_piece_type = ""
	can_hold = true
	spawn_new_piece()

func get_grid_value(x: int, y: int) -> Variant:
	if y >= 0 and y < grid.size() and x >= 0 and x < grid[y].size():
		return grid[y][x]
	return null

func set_grid_value(x: int, y: int, value: Variant) -> void:
	if y >= 0 and y < grid.size() and x >= 0 and x < grid[y].size():
		grid[y][x] = value
