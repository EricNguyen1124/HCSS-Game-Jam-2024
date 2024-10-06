extends Area2D

class_name Chest

@export var upgrade_database: UpgradeDatabase

var health = 3

func deal_damage() -> void:
	health -= 1
	if health > 0:
		roll_and_apply_upgrade()
	else:
		roll_and_apply_upgrade()
		
func roll_and_apply_upgrade() -> void:
	
	var valid_upgrades: Array[Upgrade] = upgrade_database.upgrades.filter(func(u: Upgrade): return u.level < u.max_level)
	
	if valid_upgrades.is_empty():
		# display no upgrade anim
		return
	
	var upgrade = valid_upgrades.pick_random()
		
	upgrade.level += 1
	
	# display name and description to user

	upgrade_database.get_callable(upgrade.display_name).call()
