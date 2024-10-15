class_name GameOverMenu extends Control

@onready var scoreUI: HBoxContainer = $ScoreInfoUI
@onready var retry_button: Button = $RetryButton
@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	retry_button.button_down.connect(retry_game)
	quit_button.button_down.connect(back_to_menu)

func set_values(rings, zombies, score):
	scoreUI.set_values(rings, zombies, score)

func retry_game() -> void:
	get_tree().change_scene_to_file("res://World.tscn")
	
func back_to_menu() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")
