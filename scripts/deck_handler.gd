extends Node2D
class_name DeckHandler

@export_group("Settings")
@export var is_player_1: bool = false

@export_group("External Nodes")
@export var game_logic: GameLogic
@export var deck: Deck
@export var hand: Hand
@export var deck_button: TextureButton ## Leave blank for P2
@export var deck_sprite: CardHandler
@export var hand_handler: HandHandler ## Leave blank for P2

func _ready() -> void:
    if deck_button:
        deck_button.pressed.connect(draw_card)
        disable_click()
    game_logic.draw_cards.connect(draw_cards)

const FOOD_CARD = preload("res://scenes/food_card.tscn")
const ANIMAL_CARD = preload("res://scenes/animal_card.tscn")

func spawn_card(card: Card) -> CardHandler:
    var sc: CardHandler = null

    if card is FoodCard:
        sc = FOOD_CARD.instantiate()
    elif card is AnimalCard:
        sc = ANIMAL_CARD.instantiate() # Not used currently
    else:
        push_warning("Unknown card type for spawn")
        return sc
    
    sc.match_card_stats(card)
    sc.global_position = deck_sprite.global_position

    return sc

func draw_cards(n_cards: int, player_1: bool) -> void:
    if player_1 == is_player_1:
        for i in range(n_cards):
            draw_card()

func draw_card() -> void:
    var card = deck.draw_card()

    if card == null:
        print("Empty Deck")
        disable_click()
        return
    elif card is FoodCard:
        print("Drew Food Card")
    elif card is AnimalCard:
        print("Drew Animal Card")
    else:
        push_warning("Drew Unknown Card")
        return
    
    hand.add_child(card)
    if hand_handler:
        hand_handler.add_card_to_hand(spawn_card(card))

    if deck.is_empty():
        disable_click()

func enable_click() -> void:
    if deck_button:
        deck_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        deck_button.disabled = false

func disable_click() -> void:
    if deck_button:
        deck_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
        deck_button.disabled = true