extends Node

const DINO_START_POS := Vector2i(20, 343)
const DINO_CAM_START_POS := Vector2i(213, 249)

const START_SPEED = 5
const MAX_SPEED = 20
const SPEED_MODIFIER = 5000

const SCORE_MODIFIER = 10

var dino_speed

var screen_size

var score

var game_running
func _ready():
	screen_size = get_window().size
	new_game()
	
func _process(_delta):
	if game_running:
		dino_speed = START_SPEED * score / SPEED_MODIFIER
		if dino_speed >= MAX_SPEED:
			dino_speed = MAX_SPEED
		
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
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			%HUD/StartLabel.visible = false
	
func show_score():
	%HUD/ScoreLabel.text = "SCORE: " + str(score / SCORE_MODIFIER)
	
func new_game():
	score = 0
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$DinoCamera.position = DINO_CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	%HUD/StartLabel.visible = true
