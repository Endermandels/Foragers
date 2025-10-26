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

const CARDS = [
    [preload("res://scenes/animal_cards/squirrel_card.tscn"), preload("res://scenes/animal_cards/squirrel_card_stats.tscn"),    0.30],
    [preload("res://scenes/animal_cards/fox_card.tscn"), preload("res://scenes/animal_cards/fox_card_stats.tscn"),              0.20],
    [preload("res://scenes/animal_cards/porcupine_card.tscn"), preload("res://scenes/animal_cards/porcupine_card_stats.tscn"),  0.20],
    [preload("res://scenes/animal_cards/cat_card.tscn"), preload("res://scenes/animal_cards/cat_card_stats.tscn"),              0.15],
    [preload("res://scenes/animal_cards/red_panda_card.tscn"), preload("res://scenes/animal_cards/red_panda_card_stats.tscn"),  0.10],
    [preload("res://scenes/animal_cards/cobra_card.tscn"), preload("res://scenes/animal_cards/cobra_card_stats.tscn"),          0.05],
]

func _ready() -> void:
    game_logic.show_encounters_row.connect(fill_row)
    game_logic.attack_phase_entered.connect(disable_cards)
    game_logic.buy_phase_entered.connect(enable_cards)
    var isOne = 0
    for CARD in CARDS:
        isOne += CARD[2]
    if isOne != 1:
        push_warning("Card probabilities do not add to one: " + str(isOne))

func fill_row() -> void:
    while cards.get_child_count() < n_cards_in_row:
        spawn_card()

func get_animal_card() -> Array:
    var card_arr = null
    var chosen_card_type = null
    var common_card_type = null
    var same = 0

    var children = encounters_row.get_children()
    if children.size() == n_cards_in_row - 1:
        # Check if all cards are of the same type
        for child: AnimalCard in children:
            if common_card_type == null:
                common_card_type = child
                same = 1
                continue
            if child.type == common_card_type.type:
                same += 1
        if same < n_cards_in_row - 1:
            common_card_type = null

    while chosen_card_type == null or common_card_type != null:
        if chosen_card_type:
            chosen_card_type.queue_free()
        var rnd: float = randf()
        var pc = 0
        for CARD in CARDS:
            if rnd < CARD[2] + pc:
                card_arr = CARD
                break
            pc += CARD[2]
        chosen_card_type = card_arr[1].instantiate()
        if common_card_type and chosen_card_type.type != common_card_type.type:
            break

    return [card_arr[0].instantiate(), chosen_card_type]

func spawn_card() -> void:
    ## Spawn a random Animal card for the encounters row
    var animal_card_info = get_animal_card()
    var sc: AnimalCardHandler = animal_card_info[0]
    var card: AnimalCard = animal_card_info[1]
    
    encounters_row.add_child(card)

    card.sc_ref = sc
    cards.add_child(sc)
    sc.global_position = spawn.global_position
    sc.match_card_stats(card)
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
        game_logic.p1_saving_up = false
    elif not player_1:
        cards.remove_child(sc)
        encounters_row.remove_child(card)
        game_logic.p2_saving_up = false
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
