extends CharacterBody2D

const GRAVITY = 2400
const JUMP_SPEED = -800

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		# Get variable from parent 'game' to check if game running
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$MoveCollision.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				$JumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("sneak")
				$MoveCollision.disabled = true
			else:
				$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.play("jump")
	move_and_slide()
