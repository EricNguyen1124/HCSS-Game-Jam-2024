extends Node2D


@onready var car: Car = $Car
@onready var carLeftTire: Marker2D = $Car/Icon/LeftTireMarker
@onready var tireScene: PackedScene = preload("res://Scenes/TireLine2D.tscn")
@onready var enemyScene: PackedScene = preload("res://Scenes/Enemy.tscn")
@onready var chestScene: PackedScene = preload("res://Scenes/Chest.tscn")
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var chest_spawn_timer: Timer = $ChestSpawnTimer
@onready var upgrade_ui: UpgradeUI = $CanvasLayer/UpgradeUI
@onready var world_bounds: Marker2D = $Marker2D
@onready var radio = $Radio
@onready var game_timer: Timer = $GameTimer

@onready var arrow = $CanvasLayer/SubViewportContainer/SubViewport/ArrowScene
@onready var health_bar: TextureProgressBar = $CanvasLayer/TextureProgressBar
@onready var combo_label: ComboLabel = $CanvasLayer/ComboLabel
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var timer_label: Label = $CanvasLayer/TimeLabel

@export var pause_menu_packed_scene : PackedScene = null
@onready var game_over_scene: PackedScene = preload("res://Scenes/GameOverMenu/GameOverMenu.tscn")
@onready var win_screen_scene: PackedScene = preload("res://Scenes/GameOverMenu/WinScreen.tscn")
@onready var ui_container: CanvasLayer = $CanvasLayer

@export var upgrade_database: UpgradeDatabase

var score: int = 0

var current_line: TireLine2D

var enemies: Array[Enemy]
var chest: Chest

var game_duration_in_seconds: float = 0.0

var enemies_killed: int = 0
var rings_completed: int = 0
var final_score: int = 0

var winned = false
var died = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.start_drift.connect(on_car_start_drift)
	car.damage_taken.connect(on_damage_taken)
	car.died.connect(game_over)
	
	score_label.text = str(score)

	combo_label.combo_finished.connect(on_combo_finished)

	enemy_spawn_timer.timeout.connect(spawn_enemies)
	chest_spawn_timer.timeout.connect(spawn_chest)
	game_timer.start()
	game_timer.timeout.connect(win_game)
	
	PlayerVariables.reset()
	upgrade_database.reset_upgrades()

func _process(delta: float) -> void:
	game_duration_in_seconds += delta

	if Engine.get_frames_drawn() % 5 == 0:
		for enemy in enemies:
			if enemy != null:
				enemy.target_position = car.global_position
				
	
	var seconds = int(game_timer.get_time_left()) % 60
	var minutes = (int(game_timer.get_time_left()) / 60) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	
	if chest != null:
		arrow.visible = true
		var angle_to_chest = (chest.global_position - car.global_position).angle()
		arrow.set_arrow_rotation(angle_to_chest)
	else:
		arrow.visible = false
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var car_is_drifting: bool = car.current_state == CarState.DRIFTING_LEFT or car.current_state == CarState.DRIFTING_RIGHT

	if current_line != null and car_is_drifting:
		current_line.add_drift_point(carLeftTire.global_position)
	elif current_line != null and !car_is_drifting:
		current_line.end_drift()
		current_line = null

func on_car_start_drift():
	current_line = tireScene.instantiate()
	current_line.enemies_killed.connect(on_enemies_killed)
	current_line.ring_completed.connect(on_ring_completed)
	current_line.chest_circled.connect(on_chest_attacked)
	add_child(current_line)

func spawn_enemies() -> void:
	if died: return

	var duration_in_minutes = game_duration_in_seconds / 60
	
	var random_angle = randf_range(0.0, 2 * PI)
	var spawn_vector = (Vector2(0.0, 1.0).rotated(random_angle) * 850) + car.global_position
	
	var random_number_of_enemies = randi_range(1,3) + ceil(duration_in_minutes) * 2
	
	for i in random_number_of_enemies:
		var enemy: Enemy = enemyScene.instantiate()
		
		enemy.initial_health = 15 + floor(duration_in_minutes)
		enemy.health = enemy.initial_health
		enemy.damage = duration_in_minutes * 0.33 + 7
		enemy.SPEED += randi_range(-75, 75)

		enemy.global_position = spawn_vector + Vector2(randf_range(20.0, 60.0),randf_range(20.0, 60.0))
		enemies.append(enemy)
		add_child(enemy)
		
	var new_spawn_wait_time = (-duration_in_minutes / 2.5) + 6
	enemy_spawn_timer.stop()
	enemy_spawn_timer.wait_time = new_spawn_wait_time
	enemy_spawn_timer.start()
		
func spawn_chest() -> void:
	if chest != null:
		return
		
	var randX: float = randf_range(0.0, world_bounds.global_position.x)
	var randY: float = randf_range(0.0, world_bounds.global_position.y)
	var spawn_vector: Vector2 = Vector2(randX, randY)
	
	var chest_instance: Chest = chestScene.instantiate()
	
	chest = chest_instance
	
	chest_instance.global_position = spawn_vector
	chest_instance.chest_opened.connect(on_chest_open)
	chest_instance.last_chest_opened.connect(stop_spawning_chests)
	add_child(chest_instance)
	
func on_chest_open(upgrade: Upgrade) -> void:
	chest = null
	upgrade_ui.set_info(upgrade)
	upgrade_ui.show_ui()

func stop_spawning_chests() -> void:
	chest_spawn_timer.stop()

func on_damage_taken(new_health: float) -> void:
	health_bar.value = new_health

func on_enemies_killed(count: int) -> void:
	combo_label.on_enemies_killed(count)
	enemies_killed += count
	
	var healing = PlayerVariables.healing_factor * count
	car.heal_damage(healing)

func on_chest_attacked() -> void:
	combo_label.reset_combo_timer()

func on_ring_completed() -> void:
	rings_completed +=1

func on_combo_finished(final_combo_score: int) -> void:
	score += final_combo_score
	score_label.text = str(score)
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("pause") && !car.dead:
		var new_pause_menu : PauseMenu = pause_menu_packed_scene.instantiate()
		
		ui_container.add_child(new_pause_menu)

func game_over() -> void:
	if died: return
	
	died = true
	health_bar.visible = false
	score_label.visible = false

	var current_combo = 0.0
	if combo_label != null and combo_label.combo_in_progress:
		current_combo = combo_label.show_final_score()
		combo_label.combo_in_progress = false

	var game_over_screen = game_over_scene.instantiate()
	ui_container.add_child(game_over_screen)
	game_over_screen.set_values(rings_completed, enemies_killed, score + current_combo)
	radio.queue_free()
	game_timer.set_paused(true)

func win_game() -> void:
	if winned: return
	winned = true
	
	car.dead = true
	car.invincible = true

	var current_combo = 0.0
	if combo_label != null and combo_label.combo_in_progress:
		current_combo = combo_label.show_final_score()
		combo_label.combo_in_progress = false

	PlayerVariables.rings_completed = rings_completed
	PlayerVariables.zombies_killed = enemies_killed
	PlayerVariables.final_score = score + current_combo

	get_tree().change_scene_to_packed(win_screen_scene)
