class_name TireLine2D extends Line2D

var areaList: Array[Area2D]

var areaGranularity = 20
var pointsAdded = 0

var startPoint: Vector2
var firstPoint = true

var currentArea: Area2D = null

var pointByAreaId = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

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
		
		add_child(area)
		area.add_child(collisionShape)
		
		currentArea = area

		areaList.append(area)

		pointByAreaId[area.get_instance_id()] = points.size()
		
		pointsAdded = 0
	else:
		pointsAdded += 1

	add_point(pos)

func _physics_process(_delta: float) -> void:
	if currentArea != null:
		var overlappingAreas = currentArea.get_overlapping_areas();
		if overlappingAreas.size() > 1:

			overlappingAreas.sort_custom(func(a,b): return a.get_instance_id() < b.get_instance_id())
			var overlapAreaId = overlappingAreas[0].get_instance_id()
			var overlapPointIndex = pointByAreaId[overlapAreaId]

			var area = Area2D.new()

			area.collision_layer = 4
			var collisionShape = CollisionPolygon2D.new();
			
			var polygonPoints = points.slice(overlapPointIndex, points.size() - 12)
			collisionShape.polygon = polygonPoints
			
			add_child(area)
			area.add_child(collisionShape)
			area.connect("area_entered", _on_area_enter)
			currentArea = null

func _on_area_enter(area: Area2D):
	print("enemy!")
	print(area)
	pass
