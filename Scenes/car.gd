extends CharacterBody2D

class_name Car

const STEERING_CENTERING_FORCE: float = 30.0
const STEERING_TURN_RATE: float = 40.0
const STEERING_MAX_TURN: float = 4.0
const DRIFTING_TURN: float = 30.0

const MAX_SPEED: float = 700.0
const ACCELERATION_RATE: float = 300.0
const ENGINE_BRAKING: float = 65.0
const BRAKING_FORCE: float = 400.0

const DRIFT_IN: float = 1.35
const DRIFT_OUT: float = 1.65

var health: float = 100.0

var heading: float = 0.0
var steering: float = 0.0
var speed: float = 0.0

signal start_drift
signal damage_taken

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var car_sprite: Sprite2D = $Icon
@onready var car_hurtbox: Area2D = $Area2D
@onready var car_scene: Node3D = $SubViewport/CarScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D

var current_state = CarState.NORMAL

func _ready() -> void:
	car_hurtbox.area_entered.connect(on_area_entered)

func _process(delta: float) -> void:
	#ImGui.Begin("Current Car State")
	#ImGui.Text(str(current_state))
	#ImGui.Text(str(speed))
	
	# car_hurtbox.set_rotation(heading)
	car_sprite.rotation = heading
		
	# SHIT CODE FIX LATER LMAOO
	if current_state in [CarState.DRIFTING_LEFT, CarState.DRIFTING_RIGHT]:
		if !Input.is_key_pressed(KEY_SPACE):
			current_state = CarState.NORMAL
		var direction = 1 if current_state == CarState.DRIFTING_RIGHT else -1
		car_sprite.rotation += direction * PI / 4
		steering = direction * STEERING_MAX_TURN
		if Input.is_key_pressed(KEY_A):
			steering -= DRIFT_OUT + PlayerVariables.drift_bonus if direction == 1 else DRIFT_IN + PlayerVariables.drift_bonus
		elif Input.is_key_pressed(KEY_D):
			steering += DRIFT_IN + PlayerVariables.drift_bonus if direction == 1 else DRIFT_OUT + PlayerVariables.drift_bonus
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
		if speed < MAX_SPEED + PlayerVariables.speed_bonus:
			speed += (ACCELERATION_RATE + PlayerVariables.acceleration_bonus) * delta
	elif Input.is_key_pressed(KEY_S):
		speed -= BRAKING_FORCE * delta
	else:
		if speed > 0:
			speed -= ENGINE_BRAKING * delta
	
	if Input.is_key_pressed(KEY_SPACE) and current_state == CarState.NORMAL and !animation_player.is_playing():
		current_state = CarState.HOPPING
		animation_player.play("Hop")
	
	#ImGui.Text(str(steering))
	#ImGui.End()
	set_sprite_rotation()
	handle_particles()
	
	particles.set_rotation(velocity.angle() - PI/2)
	
	heading += steering * delta
	
func set_sprite_rotation() -> void:
	var model_angle = heading - PI/2 - 0.50
	var hurtbox_angle = heading

	if current_state == CarState.DRIFTING_LEFT:
		model_angle -= PI/2
		hurtbox_angle -= PI/2
	elif current_state == CarState.DRIFTING_RIGHT:
		model_angle += PI/2
		hurtbox_angle += PI/2

	car_hurtbox.set_rotation(hurtbox_angle)
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

func handle_particles() -> void:
	if current_state == CarState.DRIFTING_LEFT or current_state == CarState.DRIFTING_RIGHT:
		particles.emitting = true
		var angle = velocity.angle() - PI/2
		if current_state == CarState.DRIFTING_LEFT:
			angle -= PI
		elif current_state == CarState.DRIFTING_RIGHT:
			angle += PI
		particles.set_rotation(angle)
	else:
		particles.emitting = false

func _physics_process(_delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(heading)
	move_and_slide()

func on_hop_land() -> void:
	if Input.is_key_pressed(KEY_A):
		current_state = CarState.DRIFTING_LEFT
		start_drift.emit()
	elif Input.is_key_pressed(KEY_D):
		current_state = CarState.DRIFTING_RIGHT
		start_drift.emit()
	else:
		current_state = CarState.NORMAL

func on_area_entered(_area: Area2D) -> void:
	health -= 10
	damage_taken.emit(health)
	print(health)
