extends Path2D

class_name RingEffect

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles2D = $PathFollow2D/GPUParticles2D

signal ring_effect_completed

func start_animation() -> void:
	animation_player.play("ring_complete")
	
func hide_particles() -> void:
	particles.visible = false
	
func emit_ring_effect_completed() -> void:
	ring_effect_completed.emit(curve.get_baked_points())
