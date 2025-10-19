extends Node2D
class_name DeckHandler

## This is the deck handler for Player 1 ONLY

@export_group("External Nodes")
@export var deck: Deck
@export var hand: Hand
@export var deck_button: TextureButton
@export var deck_sprite: CardHandler
@export var hand_handler: HandHandler

func _ready() -> void:
    deck_button.pressed.connect(draw_card)

const FOOD_CARD = preload("res://scenes/food_card.tscn")
const ANIMAL_CARD = preload("res://scenes/animal_card.tscn")

func spawn_card(card: Card) -> CardHandler:
    var sc: CardHandler = null

    if card is FoodCard:
        sc = FOOD_CARD.instantiate()
    elif card is AnimalCard:
        sc = ANIMAL_CARD.instantiate()
    else:
        push_warning("Unknown card type for spawn")
        return sc
    
    sc.add_child(card)
    sc.match_card_stats(card)
    sc.global_position = deck_sprite.global_position

    return sc

func draw_card() -> void:
    var card = deck.draw_card()

    if card == null:
        print("Empty Deck")
    elif card is FoodCard:
        print("Drew Food Card")
    elif card is AnimalCard:
        print("Drew Animal Card")
    else:
        push_warning("Drew Unknown Card")
    
    hand.add_child(card)
    hand_handler.add_card_to_hand(spawn_card(card))

    if deck.is_empty():
        deck_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
        deck_button.disabled = true