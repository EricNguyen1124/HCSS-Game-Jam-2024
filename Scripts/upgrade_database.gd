extends Resource

class_name UpgradeDatabase

@export var upgrades: Array[Upgrade]

func _init(p_upgrades: Array[Upgrade] = []):
	upgrades = p_upgrades

func get_callable(name: String) -> Callable:
	match name:
		"Drift Damage":
			return func(): PlayerVariables.ring_damage += 2
		"Instant Chest":
			return func(): PlayerVariables.instant_chest = true
		"Drift Pulse":
			return func(): PlayerVariables.ring_pulses += 2
		"Fire Trail":
			return func(): pass
		"Engine Tune Up":
			return func(): pass
		"Kansei Drift":
			return func(): pass
		
	
	return func(): print("update get_callable dummie lmao")
