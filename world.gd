extends Node2D

@onready var car = $Car
@onready var carLeftTire = $Car/Icon/LeftTireMarker
@onready var tireScene = preload("res://Scenes/TireLine2D.tscn")

var currentLine: TireLine2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.start_drift.connect(_on_car_startDrift)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if currentLine != null and car.current_state == CarState.DRIFTING_LEFT or car.current_state == CarState.DRIFTING_RIGHT:
		currentLine.add_drift_point(carLeftTire.global_position)

func _on_car_startDrift():
	currentLine = tireScene.instantiate()
	add_child(currentLine)
