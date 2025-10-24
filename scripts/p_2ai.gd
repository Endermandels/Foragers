extends Node
class_name P2AI

@export_group("External Nodes")
@export var game_logic: GameLogic
@export var deck_sprite: Node2D
@export var hand_location: Node2D
@export var deck: Deck
@export var hand: Hand
@export var animals_row: AnimalsRow
@export var encounters_row: EncountersRow
@export var encounters_row_handler: EncountersRowHandler
@export var animals_handler: AnimalsHandler
@export var deck_count_label: Label

func _ready() -> void:
    game_logic.draw_cards.connect(draw_cards)
    game_logic.buy_phase_entered.connect(_buy_phase)
    deck_count_label.text = str(deck.remaining())

const FOOD_CARD = preload("res://scenes/food_card.tscn")

func _show_card_draw() -> void:
    var sc = FOOD_CARD.instantiate()
    sc.hidden_view.show()
    add_child(sc)
    sc.global_position = deck_sprite.global_position
    sc.move_to(hand_location.global_position)
    get_tree().create_timer(2).timeout.connect(sc.queue_free)

func draw_cards(n_cards: int, player_1: bool) -> void:
    if player_1 == false:
        for i in range(n_cards):
            draw_card()

func draw_card() -> void:
    # Give the appearance of drawing the card
    var card = deck.draw_card()
    deck_count_label.text = str(deck.remaining())

    if card == null:
        print("P2 Empty Deck")
        game_logic.progress_phase()
        return
    elif card is FoodCard:
        print("P2 Drew Food Card")
    elif card is AnimalCard:
        print("P2 Drew Animal Card")
    else:
        push_warning("P2 Drew Unknown Card")
        return
    
    _show_card_draw()
    hand.add_child(card)

    if not game_logic.is_player_1_turn:
        get_tree().create_timer(randf_range(1, 3)).timeout.connect(game_logic.progress_phase)

func _select_all_food() -> void:
    for food: FoodCard in hand.get_children():
        food.selected = true

func _select_minimum_food_for_purchase(animal: AnimalCard) -> void:
    # TODO: Improve
    var foods: Array[Node] = hand.get_children()
    var meats = foods.filter(func (food): return food.meat_amount > 0)
    var plants = foods.filter(func (food): return food.plant_amount > 0)

    if animal.plant_cost == 0:
        for food: FoodCard in plants:
            food.selected = false
        foods = meats
    if animal.meat_cost == 0:
        for food: FoodCard in meats:
            food.selected = false
        foods = plants
    
    var n_selected = hand.n_selected()

    while hand.can_purchase(animal) and n_selected > 0 and foods.size() > 0:
        if foods[0].selected:
            foods[0].selected = false
            n_selected -= 1
            if not hand.can_purchase(animal):
                foods[0].selected = true
                return
        foods.pop_front()

func _buy_phase() -> void:
    if game_logic.is_player_1_turn:
        return
    
    # Basic AI: keep on buying the card with highest atk, then hp until no more food to spend
    var encounters: Array[Node] = encounters_row.get_children()
    var best_animal: AnimalCard = null
    
    _select_all_food()

    for animal: AnimalCard in encounters:
        if not hand.can_purchase(animal):
            continue
        if best_animal == null:
            best_animal = animal
            continue
        if animal.atk > best_animal.atk:
            best_animal = animal
            continue
        if animal.hp > best_animal.hp:
            best_animal = animal
    
    if best_animal:
        _select_minimum_food_for_purchase(best_animal)
        hand.purchase()
        encounters_row_handler.buy_card(best_animal.sc_ref, best_animal, false)
        animals_handler.add_card(best_animal.sc_ref)
        animals_row.add_child(best_animal)
        print("bought animal")
        get_tree().create_timer(randf_range(0.5, 1)).timeout.connect(_buy_phase)
    else:
        print("did not buy animal")
        get_tree().create_timer(1).timeout.connect(game_logic.progress_phase)
