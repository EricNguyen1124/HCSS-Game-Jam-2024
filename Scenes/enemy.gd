extends CharacterBody2D


const SPEED = 1800.0

var target_position = Vector2(0, 0)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var target_direction = (target_position - global_position).normalized()
	
	velocity = target_direction * SPEED * delta
	move_and_slide()
