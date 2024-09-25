extends Node2D

@onready var car = $Car
@onready var carLeftTire = $Car/Icon/LeftTireMarker
@onready var tireScene = preload("res://Scenes/TireLine2D.tscn")

var currentLine
var areaList: Array[Area2D]

var areaGranularity = 15
var pointsAdded = 0

var startPoint
var firstPoint = true

var currentArea = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.start_drift.connect(_on_car_startDrift)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currentLine != null and car.current_state == CarState.DRIFTING_LEFT or car.current_state == CarState.DRIFTING_RIGHT:
		if firstPoint:
			startPoint = carLeftTire.global_position
			firstPoint = false
		
		if pointsAdded > areaGranularity:
			var area = Area2D.new()
			var collisionShape = CollisionShape2D.new();
			var shape = SegmentShape2D.new()
			
			shape.a = startPoint
			shape.b = carLeftTire.global_position
			startPoint = shape.b
			
			collisionShape.shape = shape
			
			add_child(area)
			area.add_child(collisionShape)
			
			currentArea = area
			
			areaList.append(area)
			
			pointsAdded = 0
		else:
			pointsAdded += 1
		
		if currentArea != null && currentArea.has_overlapping_areas():
			print("yipee")
			currentArea = null
		
		currentLine.add_point(carLeftTire.global_position)

func _on_car_startDrift():
	currentLine = tireScene.instantiate()
	add_child(currentLine)
