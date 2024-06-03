extends Area2D

func _physics_process(delta):
	position.x -= (get_parent().MAX_SPEED / 6) * delta
