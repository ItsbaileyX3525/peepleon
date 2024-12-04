extends Node
@onready var pack_icon: Sprite2D = $"../PackIcon"

@onready var elements_to_hide: Array = [
	$".",$"../Previous",$"../Next"
]

var is_dragging: bool = false

var pack_type: String = "basic"

var has_clicked: bool = false

var show_silly_text: bool = false

var pack_tween
var swipe_location: Vector2 = Vector2(822,301)
var pack_default_location: Vector2 = Vector2(640,301)
var default_mouse_pos: Vector2

var opening_pack: bool = false

var cards_chosen: Array = []

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
@onready var silly_label: Label = $"../Open Pack/Silly label"

var step_timer: float = 0

# Player's luck value (higher = luckier)
var luck = 1.0  #1.0 = neutral

func _ready() -> void:
	pack_tween = create_tween()
	randomize()

func step() -> void:
	if show_silly_text and not has_clicked:
		if not silly_label.visible:
			silly_label.visible = true
		if silly_label.modulate.a < 1:
			silly_label.modulate.a += .01
		else:
			show_silly_text = false

func _process(delta: float) -> void:
	if default_mouse_pos.x < get_viewport().get_mouse_position().x and is_dragging and opening_pack:
		pack_icon.position.x = pack_default_location.x + (get_viewport().get_mouse_position().x - default_mouse_pos.x)
	elif is_dragging:
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
	#logic
	opening_pack = true
	get_tree().create_tween().tween_property(pack_icon, "scale",Vector2(0.596,0.596),1)
	for e in elements_to_hide:
		e.visible = false
	if pack_type == "basic":
		for e in range(4):
			cards_chosen.append(pick_card())
		print("chosen cards:", cards_chosen)
	await get_tree().create_timer(2.5).timeout
	show_silly_text = true

func _on_stupid_checker_timeout() -> void:
	silly_label.visible=true

func _on_pack_icon_swipe_button_down() -> void:
	if opening_pack:
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
		is_dragging = false
		if pack_tween and pack_tween.is_valid():
			pack_tween.stop() 
		pack_tween = get_tree().root.create_tween() 
		pack_tween.tween_property(pack_icon, "position", pack_default_location, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
