extends Area2D

func _process(delta):
	position.x -= (get_parent().MAX_SPEED / 4) * delta
