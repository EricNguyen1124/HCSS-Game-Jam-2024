class_name TireLine2D extends Line2D

@onready var ringEffectScene: PackedScene = preload("res://Scenes/RingEffect.tscn")
@onready var hitbox_timer: Timer = $Timer

var areaList: Array[Area2D]

var areaGranularity: int = 3
var pointsAdded: int = 0

var startPoint: Vector2	
var firstPoint: bool = true

var currentArea: Area2D = null

var pointIndexByAreaId: Dictionary = {}

var current_hitbox: Area2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox_timer.timeout.connect(_remove_hitbox)

func _physics_process(_delta: float) -> void:
	if currentArea != null:
		var overlappingAreas = currentArea.get_overlapping_areas();
		if overlappingAreas.size() > 1:
			for area in areaList:
				area.queue_free()
			areaList.clear()
			overlappingAreas.sort_custom(func(a, b): return a.get_instance_id() < b.get_instance_id())
			var overlapAreaId = overlappingAreas[0].get_instance_id()
			var overlapPointIndex = pointIndexByAreaId[overlapAreaId]

			var polygonPoints: PackedVector2Array = points.slice(overlapPointIndex, pointIndexByAreaId[currentArea.get_instance_id()] - 12)

			currentArea = null

			var ringEffect: RingEffect = ringEffectScene.instantiate()

			var curve = Curve2D.new()
			for point in polygonPoints:
				curve.add_point(point)
			ringEffect.set_curve(curve)
			ringEffect.ring_effect_completed.connect(do_area_damage)
			add_child(ringEffect)
			ringEffect.start_animation()

func do_area_damage(polygon: PackedVector2Array) -> void:
	var area = Area2D.new()
	var collisionShape = CollisionPolygon2D.new();
	
	area.set_collision_layer(0b10000)
	area.set_collision_mask(0b1000100)

	
	collisionShape.polygon = polygon
	add_child(area)
	area.add_child(collisionShape)

	area.area_entered.connect(_on_area_enter)
	area.body_entered.connect(_on_body_enter)
	
	current_hitbox = area
	hitbox_timer.start()

func _on_area_enter(area: Chest) -> void:
	area.deal_damage()

func _on_body_enter(body: Enemy) -> void:
	body.deal_damage(PlayerVariables.ring_damage)

func add_drift_point(pos: Vector2):
	if firstPoint:
			startPoint = pos
			firstPoint = false
		
	if pointsAdded > areaGranularity:
		var area = Area2D.new()
		var collisionShape = CollisionShape2D.new();
		var shape = SegmentShape2D.new()
		
		shape.a = startPoint
		shape.b = pos
		startPoint = shape.b
		
		collisionShape.shape = shape
		
		area.set_collision_layer(0b1000)
		area.set_collision_mask(0b1000)

		add_child(area)
		area.add_child(collisionShape)
		
		currentArea = area

		areaList.append(area)

		pointIndexByAreaId[area.get_instance_id()] = points.size()
		
		pointsAdded = 0
	else:
		pointsAdded += 1

	add_point(pos)

func _remove_hitbox() -> void:
	current_hitbox.queue_free()
	current_hitbox = null

func end_drift():
	for area in areaList:
		area.queue_free()
	areaList.clear()
