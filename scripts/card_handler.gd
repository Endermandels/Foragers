extends Node2D
class_name CardHandler

var target_pos: Vector2
var moving: bool = false

func match_card_stats(card) -> void:
    # Updates card visuals to match the card stats
    pass        

func move_to(pos: Vector2) -> void:
    target_pos = pos
    moving = true

func _process(delta: float) -> void:
    if moving:
        global_position = global_position.lerp(target_pos, delta * 10.0) # Smooth slide