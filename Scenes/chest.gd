extends Area2D

class_name Chest

@export var upgrade_database: UpgradeDatabase

var health = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func deal_damage() -> void:
	health -= 1
	if health > 0:
		roll_and_apply_upgrade()
	else:
		roll_and_apply_upgrade()
		
func roll_and_apply_upgrade() -> void:
	var upgrade: Upgrade = upgrade_database.upgrades.pick_random()

	# display name and description to user

	upgrade_database.get_callable(upgrade.display_name).call()
