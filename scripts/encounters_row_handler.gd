extends Node2D
class_name EncountersRowHandler

@export_group("Settings")
@export var card_spacing: float = 40.0
@export var n_cards_in_row: int = 5

@export_group("External Nodes")
@export var game_logic: GameLogic
@export var hand: Hand
@export var encounters_row: EncountersRow
@export var animals_handler: AnimalsHandler
@export var animals_row: AnimalsRow

@export_group("Internal Nodes")
@export var left_bound: Node2D
@export var spawn: Node2D
@export var cards: Node2D

var interactible = false

const FOX_CARD = preload("res://scenes/animal_cards/fox_card.tscn")
const FOX_CARD_STATS = preload("res://scenes/animal_cards/fox_card_stats.tscn")

func _ready() -> void:
    game_logic.show_encounters_row.connect(fill_row)
    game_logic.attack_phase_entered.connect(disable_cards)
    game_logic.buy_phase_entered.connect(enable_cards)

func fill_row() -> void:
    while cards.get_child_count() < n_cards_in_row:
        spawn_card()

func get_animal_card() -> Array:
    # var rnd = randi_range(0, 0)
    return [FOX_CARD.instantiate(), FOX_CARD_STATS.instantiate()]

func spawn_card() -> void:
    ## Spawn a random Animal card for the encounters row
    var animal_card_info = get_animal_card()
    var sc: AnimalCardHandler = animal_card_info[0]
    var card: AnimalCard = animal_card_info[1]
    
    encounters_row.add_child(card)

    card.sc_ref = sc
    cards.add_child(sc)
    sc.global_position = spawn.global_position
    sc.match_card_stats(card) # Currently doesn't do anything
    sc.button.pressed.connect(buy_card.bind(sc, card, true))
    _arrange_cards()
    get_tree().create_timer(1).timeout.connect(enable_cards)

func buy_card(sc: AnimalCardHandler, card: AnimalCard, player_1: bool) -> void:
    if player_1 and hand.can_purchase(card):
        hand.purchase()
        cards.remove_child(sc)
        encounters_row.remove_child(card)
        animals_handler.add_card(sc)
        animals_row.add_child(card)
    elif not player_1:
        cards.remove_child(sc)
        encounters_row.remove_child(card)
    fill_row()

func enable_cards() -> void:
    if game_logic.is_player_1_turn:
        for card: AnimalCardHandler in cards.get_children():
                card.enable_click()

func disable_cards() -> void:
    for card: AnimalCardHandler in cards.get_children():
            card.disable_click()

func _arrange_cards() -> void:
    var start_x = left_bound.global_position.x

    for i in range(cards.get_child_count()):
        var target_x = start_x + i * card_spacing
        var card: AnimalCardHandler = cards.get_child(i)
        card.move_to(Vector2(target_x, card.global_position.y))  # smooth motion handled by card itself
