extends AnimatedSprite2D

@onready var hitbox = $Area2D
@onready var extinguish_timer = $ExtinguishTimer
@onready var damage_timer = $DamageTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	extinguish_timer.timeout.connect(extinguish)
	extinguish_timer.wait_time = PlayerVariables.drift_fire_duration
	damage_timer.timeout.connect(deal_damage)

func deal_damage() -> void:
	var zombies = hitbox.get_overlapping_bodies()
	for zombie in zombies:
		# deal damage until 1 damage remaining
		if zombie.health - PlayerVariables.drift_fire_damage < 1:
			zombie.health = 1
		else:
			zombie.deal_damage(PlayerVariables.drift_fire_damage)

func extinguish() -> void:
	queue_free()
