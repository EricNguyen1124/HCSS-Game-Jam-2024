extends Resource

class_name UpgradeDatabase

@export var upgrades: Array[Upgrade]

func _init(p_upgrades: Array[Upgrade] = []):
	upgrades = p_upgrades

func get_callable(name: String) -> Callable:
	match name:
		"Drift Damage":
			return func(): print("lmao")
		"Instant Chest":
			return func(): print("hi")
	
	return func(): print("update get_callable dummie lmao")
