extends Node2D

@onready var transition: ColorRect = $Transition

var is_transitioning: bool = false

var main_scene: PackedScene = preload("res://scenes/Main.tscn")

@onready var card_tiles = [
	$"SmoothScrollContainer/Card_deck/Row1/Nya-man",$"SmoothScrollContainer/Card_deck/Row2/Kutti-gal",$"SmoothScrollContainer/Card_deck/Row3/Nein-Nein",$SmoothScrollContainer/Card_deck/Row4/TextureRect,
	$"SmoothScrollContainer/Card_deck/Row5/Ursina-dev",$"SmoothScrollContainer/Card_deck/Row6/UWU-femboy",$"SmoothScrollContainer/Card_deck/Row1/Cave-thing"
]

@onready var card_textures = [
	preload("res://assets/peepleon/Nya-man.png"),
	preload("res://assets/peepleon/Kutti-gal.png"),
	preload("res://assets/peepleon/Nein-Nein man.png"),
	preload("res://assets/peepleon/Nya-man.png"),
	preload("res://assets/peepleon/Urinsa-dev.png"),
	preload("res://assets/peepleon/UWU-femboy.png"),
	preload("res://assets/peepleon/Cave-Thing.png")
]
@onready var click: AudioStreamPlayer = $click

@onready var blank_card = preload("res://assets/peepleon/no-card.png")

func loadGame() -> Dictionary:
	var loadedData
	if not FileAccess.file_exists("user://gameData.json"): 
		print("Yea you shouldn't see this print to console... If you do then something went wrong.......")
	else:
		var gameSave = FileAccess.get_file_as_string("user://gameData.json")

		loadedData = JSON.parse_string(gameSave)
	
	return loadedData

var data

func _ready() -> void:
	transition.color.a = 1
	data = loadGame()
	
	for e in len(data["cards"]):
		print(data["cards"][e][1])
		if data["cards"][e][1] > 0:
			card_tiles[e].texture = card_textures[e]
		else:
			card_tiles[e].texture = blank_card

func _physics_process(delta: float) -> void:
	if transition.color.a >= 0 and not is_transitioning:
		transition.color.a -= 0.03
		
	if is_transitioning and transition.color.a <= 1:
		transition.color.a += 0.03
	if is_transitioning and transition.color.a >= 1:
		get_tree().change_scene_to_packed(main_scene)

func _on_return_button_up() -> void:
	click.play()
	is_transitioning = true
