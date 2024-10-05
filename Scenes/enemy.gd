extends CharacterBody2D

class_name Enemy

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const SPEED: float = 1800.0
const DIR_4 = [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]

var target_position: Vector2 = Vector2(0, 0)
var health = 15
var dead = false

func _process(_delta) -> void:
	var cardinal_direction = Vector2()
	if velocity != Vector2.ZERO:
		var direction_id = int(4.0 * (velocity.rotated(PI / 4.0).angle() + PI) / TAU)
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

func deal_damage(dmg: int) -> void:
	health -= dmg
	if health > 0:
		animation_player.play("hurt")
	else:
		dead = true
		set_process(false)
		animated_sprite.pause()
		animation_player.play("die")
