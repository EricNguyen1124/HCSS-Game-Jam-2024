extends CharacterBody2D

const STEERING_CENTERING_FORCE: float = 30.0
const STEERING_TURN_RATE: float = 40.0
const STEERING_MAX_TURN: float = 4.0
const DRIFTING_TURN: float = 30.0

const ACCELERATION_RATE: float = 250.0
const BRAKING_FORCE: float = 400.0
const ENGINE_BRAKING: float = 65.0
const MAX_SPEED: float = 650.0
const DRIFT_IN: float = 1.2
const DRIFT_OUT: float = 2.5

var heading: float = 0.0
var steering: float = 0.0
var speed: float = 0.0

signal start_drift

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var car_sprite: Sprite2D = $Icon

@onready var car_scene: Node3D = $SubViewport/CarScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_state = CarState.NORMAL

func _process(delta: float) -> void:
	#ImGui.Begin("Current Car State")
	#ImGui.Text(str(current_state))
	#ImGui.Text(str(speed))
	
	car_sprite.rotation = heading
	
	# SHIT CODE FIX LATER LMAOO
	if current_state in [CarState.DRIFTING_LEFT, CarState.DRIFTING_RIGHT]:
		var direction = 1 if current_state == CarState.DRIFTING_RIGHT else -1
		car_sprite.rotation += direction * PI / 4
		steering = direction * STEERING_MAX_TURN
		if Input.is_key_pressed(KEY_A):
			steering -= DRIFT_OUT if direction == 1 else DRIFT_IN
		elif Input.is_key_pressed(KEY_D):
			steering += DRIFT_IN if direction == 1 else DRIFT_OUT
	else:
		if Input.is_key_pressed(KEY_A):
			steering = maxf(-STEERING_MAX_TURN, steering - (STEERING_TURN_RATE * delta))
		elif Input.is_key_pressed(KEY_D):
			steering = minf(STEERING_MAX_TURN, steering + (STEERING_TURN_RATE * delta))
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
	set_sprite_rotation()
	heading += steering * delta
	
func set_sprite_rotation() -> void:
	var model_angle = velocity.angle() - PI/4 + 0.25
	if current_state == CarState.DRIFTING_LEFT:
		model_angle -= PI/2
	elif current_state == CarState.DRIFTING_RIGHT:
		model_angle += PI/2
	car_scene.set_car_rotation(model_angle)

	var angle = velocity.angle()
	
	if angle < 0:
		angle += TAU
		
	var index = int(round(angle / (PI / 4))) % 8
	
	if current_state == CarState.DRIFTING_LEFT:
		index = (index + 8 - 2) % 8
	elif current_state == CarState.DRIFTING_RIGHT:
		index = (index + 8 + 2) % 8
		
	animated_sprite.set_frame(index)

func _physics_process(_delta: float) -> void:
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
