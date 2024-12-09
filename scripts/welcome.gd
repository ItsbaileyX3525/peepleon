extends Node2D

var main_scene: PackedScene = preload("res://scenes/Main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func save_game() -> void:
	var gameFile = FileAccess.open("user://gameData.json", FileAccess.WRITE)
	var save: Dictionary = {
		"completed_tutorial" : true,
		"coins" : 100
	}
	var jsonString = JSON.stringify(save)
	gameFile.store_line(jsonString)

func _on_button_button_up() -> void:
	save_game()
	get_tree().change_scene_to_packed(main_scene)
