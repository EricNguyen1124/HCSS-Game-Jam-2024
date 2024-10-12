extends Resource

class_name UpgradeDatabase

@export var upgrades: Array[Upgrade]

func _init(p_upgrades: Array[Upgrade] = []):
	upgrades = p_upgrades

func get_callable(name: String) -> Callable:
	match name:
		"Drift Damage":
			return func():
				PlayerVariables.ring_damage += 2
		"Instant Chest":
			return func():
				PlayerVariables.instant_chest = true
		"Drift Pulse":
			return func():
				PlayerVariables.ring_pulses += 1
		"Fire Trail":
			return func(): 
				PlayerVariables.drift_fire = true 
				PlayerVariables.drift_fire_damage += 2.0
				PlayerVariables.drift_fire_duration += 0.25
		"Engine Tune Up":
			return func():
				PlayerVariables.speed_bonus += 210
				PlayerVariables.acceleration_bonus += 110
		"Kansei Drift":
			return func():
				PlayerVariables.drift_bonus += 0.8
	
	return func(): print("update get_callable dummie lmao")
