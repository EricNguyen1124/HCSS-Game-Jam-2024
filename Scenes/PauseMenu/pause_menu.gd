class_name PauseMenu
extends Control

@onready var panel: Panel = $Panel
@onready var margin_container: MarginContainer = $MarginContainer
@onready var options_menu: OptionsMenu = $Options_Menu

func _on_continue_button_down() -> void:
	get_tree().paused = false
	queue_free()
	
func _ready():
	handle_connecting_signals()
	get_tree().paused = true

func _process(delta: float) -> void:
	if Input.is_action_pressed("exit"):
		get_tree().quit()
		
func on_exit_options_menu() -> void:
	panel.visible = true
	margin_container.visible = true
	options_menu.visible = false

func _on_settings_button_down() -> void:
	panel.visible = false
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true

func _on_quit_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu.tscn")

func handle_connecting_signals() -> void:
	options_menu.exit_options_menu.connect(on_exit_options_menu)
