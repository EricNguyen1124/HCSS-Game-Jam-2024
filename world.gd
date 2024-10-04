extends Node2D

@onready var car: CharacterBody2D = $Car
@onready var carLeftTire: Marker2D = $Car/Icon/LeftTireMarker
@onready var tireScene: PackedScene = preload("res://Scenes/TireLine2D.tscn")
@onready var enemyScene: PackedScene = preload("res://Scenes/Enemy.tscn")
@onready var spawn_timer: Timer = $EnemySpawnTimer

var currentLine: TireLine2D

var enemies: Array[Enemy]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.start_drift.connect(_on_car_startDrift)
	spawn_timer.timeout.connect(spawn_enemies)

func _process(_delta: float) -> void:
	if Engine.get_frames_drawn() % 5 == 0:
		for enemy in enemies:
			if enemy != null:
				enemy.target_position = car.global_position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var car_is_drifting: bool = car.current_state == CarState.DRIFTING_LEFT or car.current_state == CarState.DRIFTING_RIGHT

	if currentLine != null and car_is_drifting:
		currentLine.add_drift_point(carLeftTire.global_position)
	elif currentLine != null and !car_is_drifting:
		currentLine.end_drift()
		currentLine = null

	#enemy.target_position = car.global_position

func _on_car_startDrift():
	currentLine = tireScene.instantiate()
	add_child(currentLine)

func spawn_enemies() -> void:
	var random_angle = randf_range(0.0, 2*PI)
	var spawn_vector = (Vector2(0.0, 1.0).rotated(random_angle) * 800) + car.global_position
	
	var random_number_of_enemies = randi_range(3,7)
	
	for i in random_number_of_enemies:
		var enemy: CharacterBody2D = enemyScene.instantiate()
		enemy.global_position = spawn_vector + Vector2(randf_range(100.0, 200.0),randf_range(100.0, 200.0))
		enemies.append(enemy)
		add_child(enemy)
	
