class_name RingAttack extends Area2D

@onready var timer: Timer = $Timer
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var ring_effect: RingEffect = $RingEffect

signal enemies_killed

var first_attack_done: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ring_effect.ring_effect_completed.connect(check_collisions)
	ring_effect.done_pulsing.connect(queue_free)

func set_polygon(polygon: PackedVector2Array) -> void:
	collision_polygon.polygon = polygon
	var curve = Curve2D.new()

	for point in polygon:
		curve.add_point(point)
			
	ring_effect.set_curve(curve)


func do_damage() -> void:
	ring_effect.queue_attacks(PlayerVariables.ring_pulses)


func check_collisions() -> void:
	var damage = PlayerVariables.ring_damage

	if first_attack_done:
		damage = damage / 2.0

	var kill_count = 0

	var enemies = get_overlapping_bodies()
	for enemy: Enemy in enemies:
		enemy.deal_damage(damage)
		if enemy.dead:
			kill_count += 1

	var chests = get_overlapping_areas()
	for chest: Chest in chests:
		chest.deal_damage()

	if kill_count > 0:
		# spawn orbs
		enemies_killed.emit(kill_count)

	first_attack_done = true
