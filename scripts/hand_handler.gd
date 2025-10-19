extends Node2D
class_name HandHandler

## This is the hand handler for Player 1 ONLY
@export_group("Settings")
@export var card_spacing: float = 40.0

@export_group("External Nodes")
@export var game_logic: GameLogic
@export var blur_rect: ColorRect

@export_group("Internal Nodes")
@export var left_bound: Node2D
@export var right_bound: Node2D
@export var hidden_y: Node2D
@export var cards: Node2D

var interactible = false
var hand_shown = false

func _unhandled_input(event: InputEvent) -> void:
	if hand_shown and interactible and event.is_action("wheel_down"):
		fade_out_hand()
		if game_logic.state == GameLogic.GameState.DRAW:
			game_logic.progress_phase()
	if not hand_shown and interactible and event.is_action("wheel_up"):
		fade_in_hand()

func _arrange_cards():
	var total_width = (cards.get_child_count() - 1) * card_spacing
	var start_x = left_bound.global_position.x
	var end_x = start_x + total_width

	# If too wide, shift left so leftmost stays at left_bound
	var shift = 0.0
	if end_x > get_viewport_rect().size.x - left_bound.global_position.x:
		shift = (get_viewport_rect().size.x - left_bound.global_position.x) - end_x

	for i in range(cards.get_child_count()):
		var target_x = start_x + i * card_spacing + shift
		var card = cards.get_child(i)
		card.move_to(Vector2(target_x, position.y))  # smooth motion handled by card itself

func add_card_to_hand(card: CardHandler) -> void:
	if card == null:
		return

	cards.add_child(card)
	fade_in_hand()
	_arrange_cards()

func fade_in_hand() -> void:
	interactible = false
	blur_rect.show()
	get_tree().create_tween().tween_method(_set_blur_radius, 0.0, 1.0, 0.2).finished.connect(_fade_in_finished)
	for card: CardHandler in cards.get_children():
		card.move_to(Vector2(card.global_position.x, global_position.y))

func _set_blur_radius(value: float) -> void:
	blur_rect.material.set_shader_parameter("radius", value)

func fade_out_hand() -> void:
	interactible = false
	get_tree().create_tween().tween_method(_set_blur_radius, 1.0, 0.0, 0.2).finished.connect(_fade_out_finished)
	for card: CardHandler in cards.get_children():
		card.move_to(Vector2(card.global_position.x, hidden_y.global_position.y))

func _fade_in_finished() -> void:
	interactible = true
	hand_shown = true

func _fade_out_finished() -> void:
	blur_rect.hide()
	interactible = true
	hand_shown = false
