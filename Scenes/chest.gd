extends Area2D

class_name Chest

@export var upgrade_database: UpgradeDatabase

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var pause_timer: Timer = $PauseTimer

signal chest_opened(upgrade: Upgrade)

var health = 3

func _ready() -> void:
	pause_timer.timeout.connect(resume_game)

func deal_damage() -> void:
	health -= 1
	if health > 0:
		animation_player.play("hurt")
	else:
		roll_and_apply_upgrade()
		
func roll_and_apply_upgrade() -> void:
	
	var valid_upgrades: Array[Upgrade] = upgrade_database.upgrades.filter(func(u: Upgrade): return u.level < u.max_level)
	
	if valid_upgrades.is_empty():
		return
	
	var upgrade: Upgrade = valid_upgrades.pick_random()
		
	upgrade.level += 1
	audio.play()
	
	get_tree().paused = true
	
	chest_opened.emit(upgrade)
	
	upgrade_database.get_callable(upgrade.display_name).call()
	pause_timer.start()
	
func resume_game() -> void:
	get_tree().paused = false
	queue_free()
