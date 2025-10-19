extends Node
class_name P2AI

@export_group("External Nodes")
@export var game_logic: GameLogic
@export var deck_sprite: Node2D
@export var hand_location: Node2D

func _ready() -> void:
    game_logic.draw_cards.connect(draw_cards)

const FOOD_CARD = preload("res://scenes/food_card.tscn")

func draw_cards(n_cards: int, player_1: bool) -> void:
    if player_1 == false:
        # Give the appearance of drawing the card
        var sc = FOOD_CARD.instantiate()
        sc.hidden_view.show()
        add_child(sc)
        sc.global_position = deck_sprite.global_position
        sc.move_to(hand_location.global_position)
        get_tree().create_timer(2).timeout.connect(sc.queue_free)
