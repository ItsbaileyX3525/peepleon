extends Node
@onready var pack_icon: Sprite2D = $"../PackIcon"
@onready var pack_icon_swipe: Button = $"../Open Pack/PackIconSwipe"

var pack_icon_swipe_location_default: Vector2 = Vector2(888,888)
var pack_icon_swipe_location_open: Vector2 = Vector2(467,47)

@onready var elements_to_hide: Array = [
	$".",$"../Previous",$"../Next",$"../price",$"../OtherUI"
]

var is_dragging: bool = false

var pack_type: String = "basic"

var has_clicked: bool = false

var show_silly_text: bool = false
var show_broke_text: bool = false

var shown_broke_text: bool = false

@onready var coin_counter: Label = $"../OtherUI/Coins/Counter"

var pack_tween
var swipe_location: Vector2 = Vector2(1000,301)
var pack_default_location: Vector2 = Vector2(640,301)
var default_mouse_pos: Vector2

var opening_pack: bool = false

var on_card: int = 0

@onready var cards_chosen: Array = []

var card_textures: Dictionary = {
	"Card A" : preload("res://assets/peepleon/Nya-man.png"),
	"Card B" : preload("res://assets/peepleon/Kutti-gal.png"),
	"Card C" : preload("res://assets/peepleon/Nein-Nein man.png"),
	"Card D" : preload("res://assets/peepleon/Nya-man.png"),
	"Card E" : preload("res://assets/peepleon/Nya-man.png"),
	"Card F" : preload("res://assets/peepleon/Nya-man.png"),
	"Card G" : preload("res://assets/peepleon/Nya-man.png"),
	"Card H" : preload("res://assets/peepleon/Nya-man.png"),
	"Card I" : preload("res://assets/peepleon/Nya-man.png"),
	"Card J" : preload("res://assets/peepleon/Nya-man.png"),
	"Card K" : preload("res://assets/peepleon/Nya-man.png"),
	"Card L" : preload("res://assets/peepleon/Nya-man.png"),
}

var cards = [
	{"name": "Card A", "chance": 50},
	{"name": "Card B", "chance": 25}, # Base chance as percentage
	{"name": "Card C", "chance": 13},
	{"name": "Card D", "chance": 6},
	{"name": "Card E", "chance": 3},
	{"name": "Card F", "chance": 2},
	{"name": "Card G", "chance": 1},
	{"name": "Card H", "chance": .6},
	{"name": "Card I", "chance": .3},
	{"name": "Card J", "chance": .2},
	{"name": "Card K", "chance": .1},
	{"name": "Card L", "chance": .06},
	{"name": "Card M", "chance": .03},
	{"name": "Card N", "chance": .02},
	{"name": "Card O", "chance": .01},
	{"name": "Card P", "chance": .006},
	{"name": "Card R", "chance": .003},
	{"name": "Card S", "chance": .002},
	{"name": "Card T", "chance": .001},
	
]

@onready var cards_to_show: Array = [
	$"../Open Pack/Cards/Card",$"../Open Pack/Cards/Card2",$"../Open Pack/Cards/Card3",$"../Open Pack/Cards/Card4",
	$"../Open Pack/Cards/Card5",$"../Open Pack/Cards/Card6",$"../Open Pack/Cards/Card7",$"../Open Pack/Cards/Card8",
	$"../Open Pack/Cards/Card9",$"../Open Pack/Cards/Card10",$"../Open Pack/Cards/Card11",$"../Open Pack/Cards/Card12",
]

@onready var silly_label: Label = $"../Open Pack/Silly label"
@onready var broke_label: Label = $"../OtherUI/Broke/BrokeLabel"

var step_timer: float = 0

var cards_to_open: int = 0

var has_enough: bool = false

var has_removed_packet: bool = false

# Player's luck value (higher = luckier)
var luck = 1.0  #1.0 = neutral

func open_pack() -> void:
	pass

func save_game() -> void:
	var gameFile = FileAccess.open("user://gameData.json", FileAccess.WRITE)
	var save = data
	var jsonString = JSON.stringify(save)
	gameFile.store_line(jsonString)

func loadGame() -> Dictionary:
	var loadedData
	if not FileAccess.file_exists("user://gameData.json"): 
		print("How are you playing then?")
	else:
		var gameSave = FileAccess.get_file_as_string("user://gameData.json")

		loadedData = JSON.parse_string(gameSave)
	
	return loadedData

var data

func _ready() -> void:
	pack_tween = create_tween()
	randomize()
	data = loadGame()

func remove_broke_text() -> void:
	await get_tree().create_timer(3.1).timeout
	show_broke_text = false
	shown_broke_text = false

func step() -> void:
	if show_silly_text and not has_clicked:
		if not silly_label.visible:
			silly_label.visible = true
		if silly_label.modulate.a < 1:
			silly_label.modulate.a += .01
		else:
			show_silly_text = false
	if show_broke_text:
		if broke_label.modulate.a < 1:
			broke_label.modulate.a += .01
			if not shown_broke_text:
				remove_broke_text()
				shown_broke_text = true
	else:
		if broke_label.modulate.a >= 0:
			broke_label.modulate.a -= .01

	coin_counter.text = str (data["coins"])

func _process(delta: float) -> void:
	if default_mouse_pos.x < get_viewport().get_mouse_position().x and is_dragging and opening_pack:
		pack_icon.position.x = pack_default_location.x + (get_viewport().get_mouse_position().x - default_mouse_pos.x)
	elif is_dragging and opening_pack:
		pack_icon.position.x = pack_default_location.x
	
	
	step_timer += delta
	if step_timer >= 1/60:
		step()

func pick_card():
	randomize()
	var total_weight = 0.0
	var adjusted_cards = []
	
	for card in cards:
		var adjusted_chance = card["chance"] * (1 + luck / (card["chance"] + 1))
		total_weight += adjusted_chance
		adjusted_cards.append({"name": card["name"], "adjusted_chance": adjusted_chance})
	
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for card in adjusted_cards:
		current_weight += card["adjusted_chance"]
		if random_value < current_weight:
			return card["name"]
	
	return "null card? Something went wrong"

func _on_button_up() -> void:
	if not opening_pack:
		#Probably set the pack type here
		match pack_type:
			"basic":
				if data["coins"] >= 100:
					data["coins"] -= 100
					has_enough = true
					for e in range(4):
						cards_chosen.append(pick_card())
					print("Cards in pack: ", cards_chosen)
				else:
					show_broke_text = true
		if has_enough:
			get_tree().create_tween().tween_property(pack_icon, "scale",Vector2(0.596,0.596),1)
			for e in elements_to_hide:
				e.visible = false
			await get_tree().create_timer(1).timeout
			opening_pack = true
			has_removed_packet = false
			pack_icon_swipe.set_position(pack_icon_swipe_location_open)
			await get_tree().create_timer(2.5).timeout
			show_silly_text = true
			has_enough = false

func _on_stupid_checker_timeout() -> void:
	silly_label.visible=true

func add_card() -> void:
	var remove_pack = cards_to_show[on_card].get_tree().root.create_tween()
	remove_pack.tween_property(cards_to_show[on_card], "position:x", swipe_location.x+1060,.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

@onready var test: Button = $"../Open Pack/Cards/Card"

func finish_open() -> void:
	for e in cards_to_show:
		e.visible = false
		e.position = Vector2(495,47)
	for e in elements_to_hide:
		e.visible = true
	pack_icon.visible=true
	pack_icon.position = Vector2(640,301)
	pack_icon.scale = Vector2(.352,.352)
	on_card = 0
	cards_chosen.clear()
	

func pressed_card() -> void:
	if on_card+1 >= cards_to_open:
		cards_to_show[on_card].disconnect("button_down",pressed_card)
		add_card()
		await get_tree().create_timer(.7).timeout
		finish_open()
	else:
		cards_to_show[on_card].disconnect("button_down",pressed_card)
		add_card()
		on_card+=1
		await get_tree().create_timer(.5).timeout
		see_cards()

func see_cards() -> void:
	var button = cards_to_show[on_card]
	if button:
		button.button_down.connect(pressed_card)

func _on_pack_icon_swipe_button_down() -> void:
	if not opening_pack:
		return
	
	if pack_type == "basic":
		cards_to_open = 4
		for e in range(4):
			cards_to_show[e].visible = true
			cards_to_show[e].icon = card_textures[cards_chosen[e]]
			
	has_clicked = true
	show_silly_text = false
	
	if silly_label.visible:
		silly_label.visible = false
		
	is_dragging = true
	
	default_mouse_pos = get_viewport().get_mouse_position()
	if pack_tween and pack_tween.is_valid():
		pack_tween.stop()

func _on_pack_icon_swipe_button_up() -> void:
	if opening_pack:
		if pack_icon.position.x < swipe_location.x:
			is_dragging = false
			
			if pack_tween and pack_tween.is_valid():
				pack_tween.stop() 
				
			pack_tween = get_tree().root.create_tween() 
			pack_tween.tween_property(pack_icon, "position", pack_default_location, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			
		elif not has_removed_packet and pack_icon.position.x >= swipe_location.x:
			var remove_pack = pack_icon.get_tree().root.create_tween()
			
			opening_pack = false
			has_removed_packet = true
			
			pack_icon_swipe.set_position(pack_icon_swipe_location_default)
			remove_pack.tween_property(pack_icon, "position:x", swipe_location.x+1060,.2)

			see_cards()

func _on_save_timeout() -> void:
	save_game()
