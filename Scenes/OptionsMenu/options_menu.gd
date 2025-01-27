class_name OptionsMenu
extends Control

@onready var exit_button: Button = $MarginContainer/VBoxContainer/Exit_Button

signal exit_options_menu

func _ready():
	exit_button.button_down.connect(on_exit_pressed)
	set_process(false)

func _process(delta: float) -> void:
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	
func on_exit_pressed() -> void:
	exit_options_menu.emit()
	set_process(false)
