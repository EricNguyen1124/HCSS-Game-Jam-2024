extends Node3D

@onready var arrow: Node3D = $Arrow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	arrow.rotate_y(delta * 0.7)

func set_arrow_rotation(angle: float) -> void:
	arrow.set_rotation(Vector3(0.0, -angle, 0.0))
