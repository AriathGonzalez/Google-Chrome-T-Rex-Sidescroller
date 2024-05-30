extends CharacterBody2D

const GRAVITY = 20000
const JUMP_SPEED = -1800

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		$MoveCollision.disabled = false
		if Input.is_action_pressed("ui_accept"):
			velocity.y = JUMP_SPEED
			$JumpSound.play()
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("Sneak")
			$MoveCollision.disabled = true
		else:
			$AnimatedSprite2D.play("Move")
	else:
		$AnimatedSprite2D.play("Jump")
	move_and_slide()
