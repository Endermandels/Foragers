extends Node2D
class_name HandHandler

## This is the hand handler for Player 1 ONLY
@export_group("External Nodes")
@export var blur_rect: ColorRect

func add_card_to_hand(card: CardHandler) -> void:
    if card == null:
        return

    add_child(card)
    fade_in_hand()

func fade_in_hand() -> void:
    blur_rect.show()
    get_tree().create_tween().tween_method(set_blur_radius, 0.0, 1.0, 0.2)

func set_blur_radius(value: float) -> void:
    blur_rect.material.set_shader_parameter("radius", value)
