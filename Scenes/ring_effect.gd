extends Path2D

class_name RingEffect

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles2D = $PathFollow2D/GPUParticles2D

signal ring_effect_completed

var pulses_count: int = 0

func start_animation(number: int) -> void:
	pulses_count = number
	for i in number:
		animation_player.queue("ring_complete")
	
func hide_particles() -> void:
	if pulses_count == 0:
		particles.visible = false
	
func emit_ring_effect_completed() -> void:
	pulses_count -= 1
	ring_effect_completed.emit(curve.get_baked_points())
