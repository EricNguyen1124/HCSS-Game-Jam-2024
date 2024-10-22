class_name WinScreen extends Control

@onready var scoreUI: HBoxContainer = $ScoreInfoUI
@onready var retry_button: Button = $RetryButton
@onready var quit_button: Button = $QuitButton
@onready var leaderboard_scene: PackedScene = preload("res://addons/silent_wolf/Scores/Leaderboard.tscn")

func _ready() -> void:
	retry_button.button_down.connect(retry_game)
	quit_button.button_down.connect(back_to_menu)
	scoreUI.set_values(PlayerVariables.rings_completed, PlayerVariables.zombies_killed, PlayerVariables.final_score)

	if !PlayerVariables.player_name.is_empty() and PlayerVariables.final_score != 0:
		await SilentWolf.Scores.save_score(PlayerVariables.player_name, PlayerVariables.final_score).sw_save_score_complete

	var leaderboard = leaderboard_scene.instantiate()
	add_child(leaderboard)

func retry_game() -> void:
	get_tree().change_scene_to_file("res://World.tscn")
	
func back_to_menu() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")
