extends Node2D

@onready var car: CharacterBody2D = $Car
@onready var carLeftTire: Marker2D = $Car/Icon/LeftTireMarker
@onready var tireScene: PackedScene = preload("res://Scenes/TireLine2D.tscn")
@onready var enemyScene: PackedScene = preload("res://Scenes/Enemy.tscn")
@onready var chestScene: PackedScene = preload("res://Scenes/Chest.tscn")
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var chest_spawn_timer: Timer = $ChestSpawnTimer
@onready var upgrade_ui: UpgradeUI = $CanvasLayer/UpgradeUI
@onready var world_bounds: Marker2D = $Marker2D



var currentLine: TireLine2D

var enemies: Array[Enemy]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.start_drift.connect(_on_car_startDrift)
	enemy_spawn_timer.timeout.connect(spawn_enemies)
	chest_spawn_timer.timeout.connect(spawn_chest)
	
	#chest.chest_opened.connect(_on_chest_open)

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

func _on_car_startDrift():
	currentLine = tireScene.instantiate()
	add_child(currentLine)

func spawn_enemies() -> void:
	var random_angle = randf_range(0.0, 2 * PI)
	var spawn_vector = (Vector2(0.0, 1.0).rotated(random_angle) * 800) + car.global_position
	
	var random_number_of_enemies = randi_range(3,7)
	
	for i in random_number_of_enemies:
		var enemy: CharacterBody2D = enemyScene.instantiate()
		enemy.global_position = spawn_vector + Vector2(randf_range(100.0, 200.0),randf_range(100.0, 200.0))
		enemies.append(enemy)
		add_child(enemy)
		
func spawn_chest() -> void:
	var randX: float = randf_range(0.0, world_bounds.global_position.x)
	var randY: float = randf_range(0.0, world_bounds.global_position.y)
	var spawn_vector: Vector2 = Vector2(randX, randY)
	
	var chest: Chest = chestScene.instantiate()
	
	print(spawn_vector)
	
	chest.global_position = spawn_vector
	add_child(chest)
	
func _on_chest_open(upgrade: Upgrade) -> void:
	upgrade_ui.set_text(upgrade.display_name, upgrade.description)
	upgrade_ui.show_ui()
