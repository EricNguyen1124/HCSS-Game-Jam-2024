extends Control

@onready var menu_button: Button = $BackToMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_button.button_down.connect(on_menu_pressed)

func on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")
