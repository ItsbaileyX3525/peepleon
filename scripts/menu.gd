extends Control

var main_scene: PackedScene = preload("res://scenes/Main.tscn")
var tutorial_scene: PackedScene = preload("res://scenes/welcome.tscn")

var default_save: Dictionary = {}

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

func _ready() -> void:
	data = loadGame()

func _on_button_button_up() -> void:
	if "completed_tutorial" in data:
		completed_tutorial = bool(data["completed_tutorial"])
	else:
		completed_tutorial = false
	if not completed_tutorial:
		get_tree().change_scene_to_packed(tutorial_scene)
	else:
		get_tree().change_scene_to_packed(main_scene)
