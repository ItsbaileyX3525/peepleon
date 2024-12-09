extends Node2D
@onready var background: AudioStreamPlayer = $"../Background"

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var music: Array = [
	preload("res://assets/music/background1.ogg"),
	preload("res://assets/music/background2.ogg"),
	preload("res://assets/music/background3.ogg")
]

func _ready() -> void:
	rng.seed = int(Time.get_unix_time_from_system())
	background.stream = music[rng.randi_range(0,2)]
	background.play()

func _on_background_finished() -> void:
	background.stream = music[rng.randi_range(0,2)]
	background.play()
