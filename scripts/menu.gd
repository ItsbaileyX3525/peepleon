extends Control

var main_scene: PackedScene = preload("res://scenes/Main.tscn")
var tutorial_scene: PackedScene = preload("res://scenes/welcome.tscn")
@onready var transition: ColorRect = $Transition
@onready var click: AudioStreamPlayer = $click

var default_save: Dictionary = {
	"coins" : 100,
	"completed_tutorial" : false
}

var completed_tutorial: bool = false

func loadGame() -> Dictionary:
	var loadedData
	if not FileAccess.file_exists("user://gameData.json"): 
		return default_save
	else:
		var gameSave = FileAccess.get_file_as_string("user://gameData.json")

		loadedData = JSON.parse_string(gameSave)
	
	return loadedData

var data

var is_tranistioning: bool = false

func _physics_process(delta: float) -> void:
	if is_tranistioning and transition.color.a <= 1.0:
		transition.color.a += .03
	
	if transition.color.a >= 1 and is_tranistioning:
		is_tranistioning = false
		print("doing transition!!!")
		await get_tree().create_timer(.3).timeout
		if "completed_tutorial" in data:
			completed_tutorial = bool(data["completed_tutorial"])
		else:
			completed_tutorial = false
		if not completed_tutorial:
			get_tree().change_scene_to_packed(tutorial_scene)
		else:
			get_tree().change_scene_to_packed(main_scene)


func _ready() -> void:
	data = loadGame()

func _on_button_button_up() -> void:
	click.play()
	is_tranistioning = true
