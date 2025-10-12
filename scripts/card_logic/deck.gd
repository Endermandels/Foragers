extends Node
class_name Deck

@export_group("Settings")
@export var is_player_1: bool = false

var cards: Array[Card] = []

func _ready() -> void:
    # Grab all child Cards and put them in the array
    for child in get_children():
        if child is Card:
            cards.append(child)

func draw_card() -> Card:
    if cards.size() == 0:
        return null
    return cards.pop_at(randi_range(0, cards.size() - 1))

func is_empty() -> bool:
    return cards.size() == 0