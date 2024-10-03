class_name TireLine2D extends Line2D

@onready var ringEffectScene: PackedScene = preload("res://Scenes/RingEffect.tscn")

var areaList: Array[Area2D]

var areaGranularity = 15
var pointsAdded = 0

var startPoint: Vector2	
var firstPoint = true

var currentArea: Area2D = null

var pointIndexByAreaId = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

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

			var area = Area2D.new()
			var collisionShape = CollisionPolygon2D.new();
			
			area.set_collision_layer(0b10000)
			area.set_collision_mask(0b100)

			var polygonPoints = points.slice(overlapPointIndex, pointIndexByAreaId[currentArea.get_instance_id()] - 12)
			collisionShape.polygon = polygonPoints
			add_child(area)
			area.add_child(collisionShape)

			area.body_entered.connect(_on_area_enter)
			currentArea = null

			var ringEffect: Path2D = ringEffectScene.instantiate()

			var curve = Curve2D.new()
			for point in polygonPoints:
				curve.add_point(point)
			ringEffect.set_curve(curve)
			add_child(ringEffect)
			ringEffect.start_animation()

func _on_area_enter(body):
	print("enemy!")
	print(body)
	body.queue_free()

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

func end_drift():
	for area in areaList:
		area.queue_free()
	areaList.clear()
