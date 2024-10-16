class_name TireLine2D extends Line2D

@onready var ringEffectScene: PackedScene = preload("res://Scenes/RingEffect.tscn")
@onready var expiration_timer: Timer = $Timer
@onready var fire_scene: PackedScene = preload("res://Scenes/fire.tscn")
@onready var ring_attack_scene: PackedScene = preload("res://Scenes/RingAttack.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal enemies_killed
signal chest_circled
signal ring_completed

var area_list: Array[Area2D]

var area_granularity: int = 3
var points_added: int = 0

var start_point: Vector2	
var first_point: bool = true

var current_area: Area2D = null

var point_index_by_area_id: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	expiration_timer.timeout.connect(fade_and_delete)

func _physics_process(_delta: float) -> void:
	if current_area != null:
		var overlapping_areas = current_area.get_overlapping_areas();
		if overlapping_areas.size() > 1:
			for area in area_list:
				area.queue_free()
			area_list.clear()
			overlapping_areas.sort_custom(func(a, b): return a.get_instance_id() < b.get_instance_id())
			var overlap_area_id = overlapping_areas[0].get_instance_id()
			var overlap_point_index = point_index_by_area_id[overlap_area_id]
			
			var polygon_points: PackedVector2Array = points.slice(overlap_point_index, point_index_by_area_id[current_area.get_instance_id()] - 6)
			
			current_area = null

			var ring_attack: RingAttack = ring_attack_scene.instantiate()
			ring_attack.enemies_killed.connect(enemies_killed.emit)
			ring_attack.chest_attacked.connect(chest_circled.emit)
			add_child(ring_attack)

			ring_attack.set_polygon(polygon_points)
			ring_attack.do_damage()
			ring_completed.emit()
	

func add_drift_point(pos: Vector2):
	if first_point:
			start_point = pos
			first_point = false
	
	if points_added > area_granularity:
		var area = Area2D.new()
		var collision_shape = CollisionShape2D.new();
		var shape = SegmentShape2D.new()
		
		shape.a = start_point
		shape.b = pos
		start_point = shape.b
		
		collision_shape.shape = shape
		
		area.set_collision_layer(0b1000)
		area.set_collision_mask(0b1000)

		add_child(area)
		area.add_child(collision_shape)
		
		current_area = area

		area_list.append(area)

		point_index_by_area_id[area.get_instance_id()] = points.size()
		
		points_added = 0
		if PlayerVariables.drift_fire:
			spawn_fire(pos)
	else:
		points_added += 1

	add_point(pos)

func spawn_fire(point: Vector2) -> void:
	var fire = fire_scene.instantiate()
	fire.global_position = point
	add_child(fire)

func end_drift():
	for area in area_list:
		area.queue_free()
	area_list.clear()
	expiration_timer.start()

func fade_and_delete():
	animation_player.play("fade")
