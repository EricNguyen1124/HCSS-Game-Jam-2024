extends Path2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles2D = $PathFollow2D/GPUParticles2D

func start_animation():
	animation_player.play("ring_complete")
	
func hide_particles():
	particles.visible = false
