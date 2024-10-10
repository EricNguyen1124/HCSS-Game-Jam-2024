extends Node3D

@onready var car: Node3D = $car

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_car_rotation(angle: float) -> void:
	car.set_rotation(Vector3(0.0, -angle, 0.0))
