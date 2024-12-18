extends Node2D

var main_scene: PackedScene = preload("res://scenes/Main.tscn")
@onready var transition: ColorRect = $Transition

var is_transitioning: bool = false

func _physics_process(delta: float) -> void:
	if transition.color.a >= 0 and not is_transitioning:
		transition.color.a -= 0.03
		
	if is_transitioning and transition.color.a <= 1:
		transition.color.a += 0.03
	if is_transitioning and transition.color.a >= 1:
		get_tree().change_scene_to_packed(main_scene)

func _ready() -> void:
	transition.color.a = 1

func save_game() -> void:
	var gameFile = FileAccess.open("user://gameData.json", FileAccess.WRITE)
	var save: Dictionary = {
		"completed_tutorial" : true,
		"coins" : 100,
		"cards" : [
			["nya-man", 0],
			["kutti-gal", 0],
			["nein-nein", 0],
			["blank", 0],
			["ursina-dev", 0],
			["UWU-femboy", 0],
			["cave-thing", 0]
		]
	}
	var jsonString = JSON.stringify(save)
	gameFile.store_line(jsonString)

func _on_button_button_up() -> void:
	save_game()
	is_transitioning = true
