extends Node2D
class_name CardHandler

@export_group("Internal Nodes")
@export var button: TextureButton

var target_pos: Vector2
var moving: bool = false

func _ready() -> void:
	disable_click()

func match_card_stats(card) -> void:
	# Updates card visuals to match the card stats
	pass

func move_to(pos: Vector2) -> void:
	target_pos = pos
	moving = true

func _process(delta: float) -> void:
	if moving:
		global_position = global_position.lerp(target_pos, delta * 10.0) # Smooth slide

func enable_click() -> void:
	if button:
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.disabled = false

func disable_click() -> void:
	if button:
		button.mouse_default_cursor_shape = Control.CURSOR_ARROW
		button.disabled = true
