
class_name RingAttack extends Area2D

@onready var timer: Timer = $Timer
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var ring_effect: RingEffect = $RingEffect

@onready var zombie_hurt_sound: AudioStreamPlayer = $ZombieHurtSoundEffect
@onready var attack_sound: AudioStreamPlayer = $AttackSoundEffect

signal enemies_killed
signal chest_attacked

var first_attack_done: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ring_effect.ring_effect_completed.connect(check_collisions)
	ring_effect.done_pulsing.connect(timer.start)
	timer.timeout.connect(queue_free_after_delay)

func set_polygon(polygon: PackedVector2Array) -> void:
	collision_polygon.polygon = polygon
	var curve = Curve2D.new()

	for point in polygon:
		curve.add_point(point)
			
	ring_effect.set_curve(curve)


func do_damage() -> void:
	ring_effect.queue_attacks(PlayerVariables.ring_pulses)


func check_collisions() -> void:
	attack_sound.play()
	
	var damage = PlayerVariables.ring_damage
	var zombie_damaged = false
	var chest_hurted = false
	
	if first_attack_done:
		damage = damage / 1.5

	var kill_count = 0

	var enemies = get_overlapping_bodies()
	for enemy: Enemy in enemies.filter(func(e: Enemy): return !e.dead):
		enemy.deal_damage(damage)
		zombie_damaged = true
		if enemy.dead:
			kill_count += 1

	var chests = get_overlapping_areas()
	for chest: Chest in chests.filter(func(c: Chest): return !c.opened):
		chest.deal_damage()
		chest_hurted = true

	if zombie_damaged:
		zombie_hurt_sound.play()
	
	if chest_hurted:
		chest_attacked.emit()
	
	if kill_count > 0:
		enemies_killed.emit(kill_count)

	first_attack_done = true

func queue_free_after_delay():
	queue_free()
