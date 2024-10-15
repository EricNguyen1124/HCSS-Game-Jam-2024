extends CharacterBody2D

class_name Enemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var hitbox: Area2D = $Area2D

@onready var audio_timer: Timer = $AudioTimer
@onready var idle_sound: AudioStreamPlayer2D = $IdleSoundPlayer

var SPEED: float = 2000.0
const DIR_4 = [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]

var target_position: Vector2 = Vector2(0, 0)
var initial_health: float = 15.0
var health: float  = 15.0
var dead: bool = false
var damage: float = 10.0

func _ready() -> void:
	audio_timer.wait_time = randf_range(2.0, 120.0)
	audio_timer.timeout.connect(play_idle_sound)
	audio_timer.start()

func _process(_delta) -> void:
	var cardinal_direction = Vector2()
	if velocity != Vector2.ZERO:
		var direction_id = int(4.0 * (velocity.rotated(PI / 4.0).angle() + PI) / TAU) % 4
		
		cardinal_direction = DIR_4[direction_id]
	
	if cardinal_direction == Vector2.LEFT:
		animated_sprite.play("right_to_left")
	
	if cardinal_direction == Vector2.RIGHT:
		animated_sprite.play("left_to_right")
	
	if cardinal_direction == Vector2.UP:
		animated_sprite.play("bot_to_top")
	
	if cardinal_direction == Vector2.DOWN:
		animated_sprite.play("top_to_bot")

func _physics_process(delta: float) -> void:
	var target_direction = (target_position - global_position).normalized()
	
	velocity = target_direction * SPEED * delta
	move_and_slide()

func deal_damage(dmg: float) -> void:
	health -= dmg

	health_bar.value = (health / initial_health) * 100

	if health > 0:
		animation_player.play("hurt")
	else:
		dead = true
		particles.emitting = true
		set_process(false)
		animated_sprite.pause()
		animation_player.play("die")
		
func play_idle_sound() -> void:
	if randf() < 0.2:
		idle_sound.play()
	audio_timer.wait_time = randf_range(2.0, 60.0)
	audio_timer.start()
