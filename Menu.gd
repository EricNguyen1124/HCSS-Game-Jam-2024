class_name MainMenu
extends Control

@onready var play_button: Button = $MarginContainer/VBoxContainer/Play
@onready var controls_button: Button = $MarginContainer/VBoxContainer/Controls
@onready var quit_button: Button = $MarginContainer/VBoxContainer/Quit
@onready var controls_menu: ControlsMenu = $Controls_Menu
@onready var margin_container: MarginContainer = $MarginContainer

@onready var world: PackedScene = preload("res://World.tscn")

func _ready():
	handle_connecting_signals()
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(world)
	
func on_controls_pressed() -> void:
	margin_container.visible = false
	controls_menu.set_process(true)
	controls_menu.visible = true
	
func on_quit_pressed() -> void:
	get_tree().quit()
	
func on_exit_controls_menu() -> void:
	margin_container.visible = true
	controls_menu.visible = false
	
func handle_connecting_signals() -> void:
	play_button.button_down.connect(on_start_pressed)
	controls_button.button_down.connect(on_controls_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	controls_menu.exit_controls_menu.connect(on_exit_controls_menu)
