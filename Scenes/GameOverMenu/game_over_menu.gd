class_name GameOverMenu extends Control

@onready var scoreUI: HBoxContainer = $ScoreInfoUI
@onready var retry_button: Button = $RetryButton
@onready var quit_button: Button = $QuitButton
@onready var leaderboard_scene: PackedScene = preload("res://addons/silent_wolf/Scores/Leaderboard.tscn")

@onready var name_line_edit: LineEdit = $NameLineEdit
@onready var submit_leaderboard_button: Button = $SubmitButton

var leaderboard_name: String = ""
var score_submitted: bool = false
var leaderboard

func _ready() -> void:
	retry_button.button_down.connect(retry_game)
	quit_button.button_down.connect(back_to_menu)

	name_line_edit.text_changed.connect(on_text_changed)
	name_line_edit.text_submitted.connect(submit_score)
	submit_leaderboard_button.button_down.connect(on_submit_score_button)

	leaderboard = leaderboard_scene.instantiate()
	add_child(leaderboard)

func _process(_delta: float) -> void:
	submit_leaderboard_button.disabled = leaderboard_name.is_empty() or score_submitted

func set_values(rings, zombies, score):
	PlayerVariables.final_score = score
	scoreUI.set_values(rings, zombies, score)

func on_text_changed(text: String) -> void:
	leaderboard_name = text

func on_submit_score_button() -> void:
	submit_score(leaderboard_name)

func submit_score(player_name: String) -> void:
	score_submitted = true
	await SilentWolf.Scores.save_score(player_name, PlayerVariables.final_score).sw_save_score_complete
	if leaderboard:
		leaderboard.queue_free()
		leaderboard = leaderboard_scene.instantiate()
		add_child(leaderboard)

func retry_game() -> void:
	get_tree().change_scene_to_file("res://World.tscn")
	
func back_to_menu() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")
