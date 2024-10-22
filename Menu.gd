class_name MainMenu
extends Control

@onready var buttons_container = $MarginContainer

@onready var play_button: Button = $MarginContainer/VBoxContainer/Play
@onready var options_button: Button = $MarginContainer/VBoxContainer/Options
@onready var quit_button: Button = $MarginContainer/VBoxContainer/Quit
@onready var tutorial_button: Button = $HowToPlay

@onready var options_menu: OptionsMenu = $Options_Menu
@onready var margin_container: MarginContainer = $MarginContainer

@onready var sparkle_particles: GPUParticles2D = $GPUParticles2D
@onready var logo_texture: TextureRect = $TextureRect
@onready var smoke_particles: GPUParticles2D = $GPUParticles2D2

@onready var world: PackedScene = preload("res://World.tscn")

func _ready():
	handle_connecting_signals()
	
	SilentWolf.configure({
		"api_key": "u6B7Tvhz2r288aSsdBPFi8b8ULetTUTn9KKL9Zsc",
		"game_id": "DonutZ",
		"log_level": 1
	})

	SilentWolf.configure_scores({
		"open_scene_on_close": "res://Menu.tscn"
	})
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(world)
	
func on_options_pressed() -> void:
	toggle_menu_visibility(false)
	options_menu.set_process(true)
	options_menu.visible = true
	
func on_quit_pressed() -> void:
	get_tree().quit()
	
func on_exit_options_menu() -> void:
	toggle_menu_visibility(true)
	options_menu.visible = false
	
func on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TutorialMenu/TutorialMenu.tscn")
	
func handle_connecting_signals() -> void:	
	play_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	tutorial_button.button_down.connect(on_tutorial_pressed)
	
func toggle_menu_visibility(view: bool) -> void:
	margin_container.visible = view
	sparkle_particles.visible = view
	logo_texture.visible = view
	smoke_particles.visible = view 
