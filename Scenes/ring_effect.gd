extends Path2D

@onready var animation_player = $AnimationPlayer
@onready var particles = $PathFollow2D/GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_animation():
	animation_player.play("ring_complete")
	
func hide_particles():
	particles.visible = false
