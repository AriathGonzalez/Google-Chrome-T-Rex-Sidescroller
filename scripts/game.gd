extends Node

const DINO_START_POS := Vector2i(28, 343)
const DINO_CAM_START_POS := Vector2i(213, 249)

const START_SPEED = 10.0
const MAX_SPEED = 25
var dino_speed

var screen_size

var score

func _ready():
	screen_size = get_window().size
	new_game()
	
func _process(delta):
	dino_speed = START_SPEED
	
	# Move dino and camera
	$Dino.position.x += dino_speed
	$DinoCamera.position.x += dino_speed
	
	# Update score
	score += dino_speed
	
	# Update ground position
	# Camera has moved on too far and now the ground is about to go off
	# the side of the screen.
	if $DinoCamera.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x
	
func new_game():
	score = 0
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$DinoCamera.position = DINO_CAM_START_POS
	$Ground.position = Vector2i(0, 0)
