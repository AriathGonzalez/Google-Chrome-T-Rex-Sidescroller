extends Area2D

func _process(delta):
	position.x -= (get_parent().dino_speed / 2) * delta
