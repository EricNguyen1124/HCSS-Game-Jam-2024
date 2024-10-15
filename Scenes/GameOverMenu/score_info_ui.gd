extends HBoxContainer

@onready var rings_completed: Label = $VBoxContainer2/RingsCompletedValue
@onready var zombies_killed: Label = $VBoxContainer2/ZombiesEliminatedValue
@onready var final_score: Label = $VBoxContainer2/FinalScoreValue

func set_values(rings, zombies, score):
	rings_completed.text = str(rings)
	zombies_killed.text = str(zombies)
	final_score.text = str(score)
