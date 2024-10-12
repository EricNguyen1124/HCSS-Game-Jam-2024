class_name ControlsMenu
extends Control

@onready var exit_button: Button = $MarginContainer/VBoxContainer/Exit_Button

signal exit_controls_menu

func _ready():
	exit_button.button_down.connect(on_exit_pressed)
	set_process(false)
	
func on_exit_pressed() -> void:
	exit_controls_menu.emit()
	set_process(false)
