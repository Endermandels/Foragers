extends Node2D
class_name HandHandler

## This is the hand handler for Player 1 ONLY
@export_group("Settings")
@export var card_spacing: float = 90.0

@export_group("External Nodes")
@export var game_logic: GameLogic
@export var hand: Hand
@export var blur_rect: ColorRect

@export_group("Internal Nodes")
@export var left_bound: Node2D
@export var right_bound: Node2D
@export var hidden_y: Node2D
@export var cards: Node2D
@export var sfx: AudioStreamPlayer

var interactible = false
var hand_shown = false

func _ready() -> void:
	hand.consume_selected_food.connect(_consume_selected_foods)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for card in cards.get_children():
			if card.button.get_global_rect().has_point(get_global_mouse_position()) and is_highest_z(card):
				_arrange_cards(card)
				break

func _unhandled_input(event: InputEvent) -> void:
	if hand_shown and interactible and event.is_action("wheel_down"):
		fade_out_hand()
		sfx.pitch_scale = 0.8
		sfx.play()
		if game_logic.state == GameLogic.GameState.DRAW and game_logic.is_player_1_turn:
			game_logic.progress_phase()
	if not hand_shown and interactible and event.is_action("wheel_up"):
		fade_in_hand()
		sfx.pitch_scale = 1
		sfx.play()

func _arrange_cards(card_on_top: FoodCardHandler = null):
	var total_width = (cards.get_child_count() - 1) * card_spacing
	var start_x = left_bound.global_position.x
	var end_x = start_x + total_width

	var z = 100 # Z Index
	var moving_up = true

	# If too wide, shift left so leftmost stays at left_bound
	var shift = 0.0
	while end_x > right_bound.global_position.x:
		shift += 1
		total_width = (cards.get_child_count() - 1) * (card_spacing - shift)
		end_x = start_x + total_width

	var y_pos = global_position.y
	if not hand_shown:
		y_pos = hidden_y.global_position.y

	for i in range(cards.get_child_count()):
		var target_x = start_x + i * (card_spacing - shift)
		var card: FoodCardHandler = cards.get_child(i)
		card.move_to(Vector2(target_x, y_pos))  # smooth motion handled by card itself
		card.z_index = z
		if card == card_on_top:
			moving_up = false
			card.button.show()
		else:
			card.button.hide()
		z += 1 if moving_up else -1

func is_highest_z(card: FoodCardHandler) -> bool:
	var mouse_pos = get_global_mouse_position()
	for c: FoodCardHandler in cards.get_children():
		if c == card:
			continue
		if c.button.get_global_rect().has_point(mouse_pos):
			if card.z_index < c.z_index:
				return false
	return true

func add_card_to_hand(card: FoodCardHandler) -> void:
	fade_in_hand()
	if card == null:
		return

	card.hand_handler = self
	cards.add_child(card)
	_arrange_cards()

func fade_in_hand() -> void:
	interactible = false
	hand_shown = true
	blur_rect.show()
	get_tree().create_tween().tween_method(_set_blur_radius, 0.0, 1.0, 0.2).finished.connect(_fade_in_finished)
	for card: FoodCardHandler in cards.get_children():
		card.move_to(Vector2(card.global_position.x, global_position.y))

func _set_blur_radius(value: float) -> void:
	blur_rect.material.set_shader_parameter("radius", value)

func fade_out_hand() -> void:
	interactible = false
	hand_shown = false
	get_tree().create_tween().tween_method(_set_blur_radius, 1.0, 0.0, 0.2).finished.connect(_fade_out_finished)
	for card: FoodCardHandler in cards.get_children():
		card.disable_click()
		card.move_to(Vector2(card.global_position.x, hidden_y.global_position.y))

func _fade_in_finished() -> void:
	interactible = true
	for card: FoodCardHandler in cards.get_children():
		card.enable_click()

func _fade_out_finished() -> void:
	blur_rect.hide()
	interactible = true

func _consume_selected_foods() -> void:
	for food: FoodCardHandler in cards.get_children():
		if food.selected:
			food.queue_free()
	get_tree().create_timer(0.1).timeout.connect(_arrange_cards)