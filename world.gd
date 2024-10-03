extends Node2D

@onready var car = $Car
@onready var carLeftTire = $Car/Icon/LeftTireMarker
@onready var tireScene = preload("res://Scenes/TireLine2D.tscn")
@onready var enemyScene = preload("res://Scenes/Enemy.tscn")
@onready var enemy = $Enemy

var currentLine: TireLine2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.start_drift.connect(_on_car_startDrift)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var car_is_drifting = car.current_state == CarState.DRIFTING_LEFT or car.current_state == CarState.DRIFTING_RIGHT

	if currentLine != null and car_is_drifting:
		currentLine.add_drift_point(carLeftTire.global_position)
	elif currentLine != null and !car_is_drifting:
		currentLine.end_drift()
		currentLine = null

	#enemy.target_position = car.global_position

func _on_car_startDrift():
	currentLine = tireScene.instantiate()
	add_child(currentLine)
