extends PanelContainer

class_name Upgrade_UI

@onready var upgrade_title: Label = $VBox/HBox/VBox/UpgradeTitle
@onready var upgrade_description: Label = $VBox/HBox/VBox/UpgradeDescription
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	modulate.a = 0.0
	timer.timeout.connect(hide_ui)

func set_text(title: String, description: String):
	upgrade_title.text = title
	upgrade_description.text = description

func show_ui():
	modulate.a = 1.0
	
func hide_ui():
	animation_player.play("fade")
