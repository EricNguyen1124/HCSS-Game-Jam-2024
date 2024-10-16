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

var dead: bool = false
var invincible: bool = false

var heading: float = 0.0
var steering: float = 0.0
var speed: float = 0.0

signal start_drift
signal damage_taken
signal died

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var car_sprite: Sprite2D = $Icon
@onready var car_hurtbox: Area2D = $Area2D
@onready var car_scene: Node3D = $SubViewport/CarScene
@onready var car_3d_sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var fire_animation: AnimatedSprite2D = $AnimatedFire

@onready var engine_sound: AudioStreamPlayer = $EngineSoundPlayer
@onready var idle_sound: AudioStreamPlayer = $IdleEngineSoundPlayer
@onready var tire_sound: AudioStreamPlayer = $TireScreechSoundPlayer

var foot_on_gas: bool = false

var current_state = CarState.NORMAL

func _ready() -> void:
	car_hurtbox.area_entered.connect(on_area_entered)
	invincibility_timer.timeout.connect(anim_hurt_finished)
	
func _process(delta: float) -> void:
	if dead:
		particles.emitting = true
		if speed > 0:
			speed -= 130 * delta
		current_state = CarState.NORMAL
		return
	
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
		tire_sound.volume_db = -80
		if Input.is_key_pressed(KEY_A):
			steering = maxf(-STEERING_MAX_TURN, steering - (STEERING_TURN_RATE * delta))
		elif Input.is_key_pressed(KEY_D):
			steering = minf(STEERING_MAX_TURN, steering + (STEERING_TURN_RATE * delta))
		else:
			if steering < 0:
				steering += STEERING_CENTERING_FORCE * delta
			elif steering > 0:
				steering -= STEERING_CENTERING_FORCE * delta


	engine_sound.volume_db = -13
	idle_sound.volume_db = -80
	
	if speed < MAX_SPEED + PlayerVariables.speed_bonus:
		speed += (ACCELERATION_RATE + PlayerVariables.acceleration_bonus) * delta
	#if Input.is_key_pressed(KEY_W) or current_state in [CarState.DRIFTING_LEFT, CarState.DRIFTING_RIGHT]:
		#engine_sound.volume_db = -13
		#idle_sound.volume_db = -80
		#
		#if speed < MAX_SPEED + PlayerVariables.speed_bonus:
			#speed += (ACCELERATION_RATE + PlayerVariables.acceleration_bonus) * delta
	#elif Input.is_key_pressed(KEY_S):
		#engine_sound.volume_db = -80
		#idle_sound.volume_db = -4
		#speed -= BRAKING_FORCE * delta
	#else:
		#if speed > 0:
			#speed -= ENGINE_BRAKING * delta
#
		#engine_sound.volume_db = -80
		#idle_sound.volume_db = -4
	
	if Input.is_key_pressed(KEY_SPACE) and current_state == CarState.NORMAL and !animation_player.is_playing():
		current_state = CarState.HOPPING
		animation_player.play("Hop")
	
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


func on_area_entered(area: Area2D) -> void:
	if invincible: return
	
	invincible = true
	car_3d_sprite.modulate = Color.FIREBRICK
	
	var enemy: Enemy = area.get_parent()

	health -= enemy.damage 
	damage_taken.emit(health)
	
	if health <= 0 and !dead:
		dead = true
		died.emit()
		fire_animation.visible = true
		engine_sound.queue_free()
		idle_sound.queue_free()
		tire_sound.queue_free()
	
	invincibility_timer.start()

func anim_hurt_finished() -> void:
	car_3d_sprite.modulate = Color.WHITE
	invincible = false

func heal_damage(heal_amount: float) -> void:
	health += heal_amount

	if health > 100:
		health = 100

	damage_taken.emit(health)
