extends Node

# Constants
const DINO_START_POS := Vector2i(20, 350)
const DINO_CAM_START_POS := Vector2i(256, 226)
const START_SPEED : float = 5.0
const MAX_SPEED : int = 20
const SPEED_MODIFIER : int = 5000
const SCORE_MODIFIER : int = 10
const MAX_DIFFICULTY : int = 2

# Obstacles
var alien_scene = preload("res://scenes/alien.tscn")
var bug_scene = preload("res://scenes/bug.tscn")
var mushroom_scene = preload("res://scenes/mushroom.tscn")
var sign_scene = preload("res://scenes/sign.tscn")
var stump_scene = preload("res://scenes/stump.tscn")
var obstacle_types = [mushroom_scene, sign_scene, stump_scene]
var bug_spawn_heights = [175, 275]

# Variables
var obstacles : Array = []
var dino_speed : float = START_SPEED
var screen_size : Vector2i
var ground_height : int
var score : int = 0
var game_running : bool = false
var last_obstacle
var difficulty : int = 0

func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	%HUD/HighScoreLabel.text = "HIGHSCORE: " + str(GameManager.high_score)
	$GameOver/Button.pressed.connect(new_game)
	
func _process(_delta):
	#print("Volume:", Music.volume_db)
	if game_running:
		#print("Volume:", Music.volume_db)
		update_game()
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			%HUD/StartLabel.visible = false

func update_game():
	dino_speed = int(floor(START_SPEED) + floor(score) / floor(SPEED_MODIFIER))
	if dino_speed >= MAX_SPEED:
		dino_speed = MAX_SPEED
	
	adjust_difficulty()

	# Generate obstacles
	generate_obstacles()
	
	# Move dino and camera
	$Dino.position.x += dino_speed
	$DinoCamera.position.x += dino_speed
	
	# Update score
	score += int(dino_speed)
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
		if difficulty == MAX_DIFFICULTY:
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
	obstacle.queue_free()
	obstacles.erase(obstacle)
	
func hit_obstacle(body):
	if body.name == "Dino":
		game_over()
		
func show_score():
	%HUD/ScoreLabel.text = "SCORE: " + str(int(floor(score) / floor(SCORE_MODIFIER)))

func check_high_score():
	score = int(floor(score) / floor(SCORE_MODIFIER)) 
	if score >= GameManager.high_score:
		GameManager.high_score = score
		%HUD/HighScoreLabel.text = "HIGHSCORE: " + str(GameManager.high_score)
		
func new_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func adjust_difficulty():
	difficulty = int(floor(score) / floor(SPEED_MODIFIER))
	if difficulty >= MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	$GameOverSound.play()
	game_running = false
	$GameOver.show()
