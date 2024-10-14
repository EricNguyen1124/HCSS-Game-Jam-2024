class_name ComboLabel extends Label

@onready var delay_timer: Timer = $DelayTimer
@onready var combo_timer: Timer = $ComboTimer
@onready var progress_bar = $ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_combo: float = 0.0

var base_score: float = 0.0
var multi_kill_bonus: float = 0.0

signal combo_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	delay_timer.timeout.connect(collapse_score)
	combo_timer.timeout.connect(finish_combo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(combo_timer.time_left)
	progress_bar.value = (combo_timer.time_left / combo_timer.wait_time) * 100

func on_enemies_killed(count: int) -> void:
	base_score = count * 20
	multi_kill_bonus = pow((5 * count), 2)
	text = "{base} + {count} Zombie Bonus!".format({"base": base_score, "count": count})
	delay_timer.start()
	combo_timer.start()

func collapse_score() -> void:
	animation_player.play("collapse")

func show_final_score() -> void:
	var final_score = base_score + multi_kill_bonus
	current_combo += final_score
	text = str(final_score)

func finish_combo() -> void:
	combo_finished.emit(current_combo)