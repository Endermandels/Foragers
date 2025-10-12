extends Node2D
class_name DeckHandler

## This is the deck handler for Player 1 ONLY

@export_group("External Nodes")
@export var deck: Deck
@export var deck_button: TextureButton
@export var hand_handler: HandHandler

func _ready() -> void:
    deck_button.pressed.connect(_add_card_to_hand)

func _add_card_to_hand() -> void:
    var card = deck.draw_card()
    if card == null:
        print("Empty Deck")
    elif card is FoodCard:
        print("Drew Food Card")
    elif card is AnimalCard:
        print("Drew Animal Card")
    else:
        push_warning("Drew Unknown Card")
    
    if deck.is_empty():
        deck_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
        deck_button.disabled = true