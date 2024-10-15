extends Node

@onready var static_player: AudioStreamPlayer = $StaticPlayer

const RADIO_VOL = -12


const NUM_STATIONS = 4
var current_station: int = 0

@onready var rock_station: RadioStation = $RockStation
@onready var chip_station: RadioStation = $ChipStation
@onready var classic_station: RadioStation = $ClassicStation
@onready var tech_station: RadioStation = $TechStation

@onready var stations: Array[RadioStation] = [rock_station, chip_station, classic_station, tech_station]

func _ready() -> void:
	current_station = randi_range(0,3)
	stations[current_station].volume_db = RADIO_VOL
	static_player.finished.connect(resume_next_station)

func _input(event) -> void:
	var proposed_station = current_station 
	if event.is_action_pressed("next_station"):
		proposed_station += 1
		proposed_station = proposed_station % NUM_STATIONS
		
	if event.is_action_pressed("prev_station"):
		proposed_station -= 1
		if proposed_station < 0:
			proposed_station = NUM_STATIONS - 1
	
	if proposed_station != current_station:
		stations[current_station].volume_db = -80
		current_station = proposed_station
		static_player.play()
		
func resume_next_station() -> void:
	stations[current_station].volume_db = RADIO_VOL
