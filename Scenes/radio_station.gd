class_name RadioStation extends AudioStreamPlayer

@export var song: AudioStream
@export var commercials: Commercials

var commercial_next: bool = true
var volume_adjusted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream = song
	play()
	finished.connect(play_next_song)

func _process(_delta: float) -> void:
	if volume_db != -80 && commercial_next == false && !volume_adjusted:
		volume_db += 5
		volume_adjusted = true

func play_next_song() -> void:
	if !commercial_next:
		play_song()
	else:
		play_commercial()
	
	commercial_next = !commercial_next

func play_commercial() -> void:
	var commercial = commercials.streams.pick_random()
	stream = commercial
	play()

func play_song() -> void:
	stream = song
	if volume_adjusted:
		volume_db -= 5
		volume_adjusted = false
	play()
