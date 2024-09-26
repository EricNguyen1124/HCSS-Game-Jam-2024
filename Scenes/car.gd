extends CharacterBody2D

const STEERING_CENTERING_FORCE = 30.0
const STEERING_TURN_RATE = 40.0
const STEERING_MAX_TURN = 3.4
const DRIFTING_TURN = 30.0

const ACCELERATION_RATE = 150.0
const BRAKING_FORCE = 400.0
const ENGINE_BRAKING = 65.0
const MAX_SPEED = 500.0

var heading = 0.0
var steering = 0.0
var speed = 0.0

signal start_drift

@onready var animation_player = $AnimationPlayer
@onready var car_sprite = $Icon

var current_state = CarState.NORMAL

func _process(delta: float) -> void:
	#ImGui.Begin("Current Car State")
	#ImGui.Text(str(current_state))
	#ImGui.Text(str(speed))
	
	car_sprite.rotation = heading
	
	var max_steer = STEERING_MAX_TURN
	var steer_rate = STEERING_TURN_RATE
	
	if current_state == CarState.DRIFTING_LEFT:
		car_sprite.rotation -= PI/4
		max_steer *= 1.5
		steer_rate *= 5
		steering = -STEERING_MAX_TURN
	
	if current_state == CarState.DRIFTING_RIGHT:
		car_sprite.rotation += PI/4
		max_steer *= 1.5
		steer_rate *= 5
		steering = STEERING_MAX_TURN
		
	if Input.is_key_pressed(KEY_A):
		steering = maxf(-max_steer, steering - (steer_rate * delta))
	elif Input.is_key_pressed(KEY_D):
		steering = minf(max_steer, steering + (steer_rate * delta))
	else:
		if steering < 0:
			steering += STEERING_CENTERING_FORCE * delta
		elif steering > 0:
			steering -= STEERING_CENTERING_FORCE * delta
	
	if Input.is_key_pressed(KEY_W):
		if speed < MAX_SPEED:
			speed += ACCELERATION_RATE * delta
	elif Input.is_key_pressed(KEY_S):
		speed -= BRAKING_FORCE * delta
	else:
		if speed > 0:
			speed -= ENGINE_BRAKING * delta
	
	if Input.is_key_pressed(KEY_SPACE):
		current_state = CarState.HOPPING
		animation_player.play("Hop")
	
	#ImGui.Text(str(steering))
	#ImGui.End()
	
	heading += steering * delta

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(heading)
	move_and_slide()

func on_hop_land():
	if Input.is_key_pressed(KEY_A):
		current_state = CarState.DRIFTING_LEFT
		start_drift.emit()
	elif Input.is_key_pressed(KEY_D):
		current_state = CarState.DRIFTING_RIGHT
		start_drift.emit()
	else:
		current_state = CarState.NORMAL
