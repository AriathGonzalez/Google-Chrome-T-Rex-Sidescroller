extends Node

# Obstacles
var alien_scene = preload("res://scenes/alien.tscn")
var bug_scene = preload("res://scenes/bug.tscn")
var mushroom_scene = preload("res://scenes/mushroom.tscn")
var sign_scene = preload("res://scenes/sign.tscn")
var stump_scene = preload("res://scenes/stump.tscn")
var obstacle_types = [mushroom_scene, sign_scene, stump_scene]
var obstacles : Array
var bug_spawn_heights = [175, 275]

const DINO_START_POS := Vector2i(20, 350)
const DINO_CAM_START_POS := Vector2i(256, 226)

const START_SPEED = 5
const MAX_SPEED = 20
const SPEED_MODIFIER = 5000

const SCORE_MODIFIER = 10

const MAX_DIFFICULTY = 2

var dino_speed

var screen_size
var ground_height

var score

var game_running

var last_obstacle

var difficulty = 0

func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()
	
func _process(_delta):
	if game_running:
		dino_speed = START_SPEED + score / SPEED_MODIFIER
		if dino_speed >= MAX_SPEED:
			dino_speed = MAX_SPEED
		
		adjust_difficulty()
		
		# Generate obstacles
		generate_obstacles()
		
		# Move dino and camera
		$Dino.position.x += dino_speed
		$DinoCamera.position.x += dino_speed
		
		# Update score
		score += dino_speed
		show_score()
		
		# Update ground position
		# Camera has moved on too far and now the ground is about to go off
		# the side of the screen.
		if $DinoCamera.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		# Clean up obstacles
		for obstacle in obstacles:
			if obstacle.position.x < ($DinoCamera.position.x - screen_size.x):
				remove_obstacle(obstacle)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			%HUD/StartLabel.visible = false

func generate_obstacles():
	# Generate ground obstacles
	if obstacles.is_empty() or last_obstacle.position.x < score + randi_range(300, 500):
		var obstacle_type = obstacle_types[randi() % obstacle_types.size()]
		var obstacle
		var max_obstacles = difficulty + 1
		for i in range(randi() % max_obstacles + 1):
			obstacle = obstacle_type.instantiate()
			# var obstacle_height = obstacle.get_node("Sprite2D").texture.get_height()
			# var obstacle_scale = obstacle.get_node("Sprite2D").scale
			var obstacle_x = screen_size.x + score + 150 + (i * 50)
			var obstacle_y = screen_size.y - ground_height  + 5 # screen_size.y - ground_height - (obstacle_height * obstacle_scale.y / 2) + 15
			last_obstacle = obstacle
			add_obstacle(obstacle, obstacle_x, obstacle_y)
			
		# Generate flying obstacles if max difficulty reached
		if difficulty >= 0:
			if (randi() % 2) == 0:
				obstacle = bug_scene.instantiate()
				var obstacle_x = screen_size.x + score + 150
				var obstacle_y = bug_spawn_heights[randi() % bug_spawn_heights.size()]
				add_obstacle(obstacle, obstacle_x, obstacle_y)
				
func add_obstacle(obstacle, x, y):
	obstacle.position = Vector2i(x, y)
	obstacle.body_entered.connect(hit_obstacle)
	add_child(obstacle)
	obstacles.append(obstacle)
	
func remove_obstacle(obstacle):
	queue_free()
	obstacles.erase(obstacle)
	
func hit_obstacle(body):
	if body.name == "Dino":
		game_over()
		
func show_score():
	%HUD/ScoreLabel.text = "SCORE: " + str(score / SCORE_MODIFIER)
	
func new_game():
	score = 0
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$DinoCamera.position = DINO_CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	%HUD/StartLabel.visible = true

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty >= MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	get_tree().paused = true
	game_running = false
