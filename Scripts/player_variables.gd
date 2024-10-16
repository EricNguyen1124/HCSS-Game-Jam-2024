extends Node

var ring_damage: float = 6

var instant_chest = false

var ring_pulses: int = 1

var drift_fire = false
var drift_fire_damage: float = 0.0
var drift_fire_duration : float= 0.0

var speed_bonus: float = 0.0
var acceleration_bonus: float = 0.0

var drift_bonus: float = 0.0

var combo_timer: float = 5.5

var healing_factor: float = 1.7

func reset() -> void:
	ring_damage = 6
	instant_chest = false
	ring_pulses = 1
	drift_fire = false
	drift_fire_damage = 0.0
	drift_fire_duration = 0.0
	speed_bonus = 0.0
	acceleration_bonus = 0.0
	drift_bonus = 0.0
	combo_timer = 5.5
	healing_factor = 1.7
