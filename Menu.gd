class_name MainMenu
extends Control

@onready var play_button: Button = $MarginContainer/VBoxContainer/Play
@onready var options_button: Button = $MarginContainer/VBoxContainer/Options
@onready var quit_button: Button = $MarginContainer/VBoxContainer/Quit
@onready var options_menu: OptionsMenu = $Options_Menu
@onready var margin_container: MarginContainer = $MarginContainer

@onready var world: PackedScene = preload("res://World.tscn")

func _ready():
	handle_connecting_signals()
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(world)
	
func on_options_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	
func on_quit_pressed() -> void:
	get_tree().quit()
	
func on_exit_options_menu() -> void:
	margin_container.visible = true
	options_menu.visible = false
	
func handle_connecting_signals() -> void:
	play_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
