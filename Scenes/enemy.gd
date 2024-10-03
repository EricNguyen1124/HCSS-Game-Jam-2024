extends CharacterBody2D


const SPEED = 1200.0

var target_position = Vector2(0, 0)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var target_direction = (global_position - target_position).normalized()
	
	velocity = target_direction * SPEED * delta
	move_and_slide()
