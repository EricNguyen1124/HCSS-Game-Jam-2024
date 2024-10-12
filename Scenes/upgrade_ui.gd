extends PanelContainer

class_name UpgradeUI

@onready var upgrade_title: Label = $VBox/HBox/VBox/UpgradeTitle
@onready var upgrade_description: Label = $VBox/HBox/VBox/UpgradeDescription
@onready var upgrade_texture = $VBox/HBox/Texture
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	modulate.a = 0.0
	#timer.timeout.connect(hide_ui)

func set_info(upgrade: Upgrade):
	upgrade_title.text = upgrade.display_name
	upgrade_description.text = upgrade.description
	upgrade_texture.texture = upgrade.texture

func show_ui():
	modulate.a = 1.0
	animation_player.play("fade")
	
