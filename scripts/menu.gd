extends Control

var main_scene: PackedScene = preload("res://scenes/Main.tscn")

func _on_button_button_up() -> void:
	get_tree().change_scene_to_packed(main_scene)
