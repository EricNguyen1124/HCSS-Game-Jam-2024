class_name ComboLabel extends Label

@onready var delay_timer: Timer = $DelayTimer
@onready var combo_timer: Timer = $ComboTimer
@onready var progress_bar = $ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var combo_in_progress = false

var ring_count: int = 0

var current_combo: float = 0.0

var base_score: float = 0.0
var multi_kill_bonus: float = 0.0

signal combo_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	delay_timer.timeout.connect(collapse_score)
	combo_timer.timeout.connect(finish_combo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if PlayerVariables.combo_timer != combo_timer.wait_time:
		combo_timer.wait_time = PlayerVariables.combo_timer
		
	progress_bar.value = (combo_timer.time_left / combo_timer.wait_time) * 100
	
	visible = combo_in_progress

func on_enemies_killed(count: int) -> void:
	ring_count += 1

	if !combo_in_progress:
		combo_in_progress = true
		
	if !delay_timer.is_stopped():
		current_combo += base_score + multi_kill_bonus
		delay_timer.stop()
		delay_timer.start()

	base_score = count * 20
	multi_kill_bonus = pow((5 * count), 2) * ring_count
	var combo_string = ""
	
	if current_combo > 0.0:
		combo_string += str(snapped(current_combo, 1)) + " + "
	
	combo_string += "{count} Zombies!".format({"base": base_score, "count": count})
	
	if ring_count > 1:
		combo_string += " x {count} Rings!".format({"count": ring_count})

	text = combo_string
	delay_timer.start()
	combo_timer.start()

func collapse_score() -> void:
	animation_player.play("collapse")

func reset_combo_timer() -> void:
	if !combo_timer.is_stopped():
		combo_timer.stop()
		combo_timer.start()

func show_final_score() -> void:
	var final_score = base_score + multi_kill_bonus
	current_combo += final_score
	text = str(current_combo)

func finish_combo() -> void:
	combo_in_progress = false
	combo_finished.emit(current_combo)
	current_combo = 0.0
	base_score = 0.0
	multi_kill_bonus = 0.0
	ring_count = 0
