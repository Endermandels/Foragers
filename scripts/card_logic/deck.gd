extends Node
class_name Deck

@export_group("Settings")
@export var is_player_1: bool = false
@export var randomize_deck: bool = false # Doesn't do anything anymore
@export var deck_size: int = 30 # Doesn't do anything anymore
@export var plant_requested: bool = false
@export var meat_requested: bool = false

var last_drew_plant: bool = false

var cards: Array[Card] = []

const FOOD_CARD_STATS = preload("res://scenes/food_card_stats.tscn")

func _ready() -> void:
    if randomize_deck:
        # Start from a clean slate
        for child in get_children():
            remove_child(child)
        
        # Add random cards in
        for i in range(deck_size):
            var fc = _get_random_food_card()
            cards.append(fc)
            add_child(fc)
    else:
        for child in get_children():
            if child is Card:
                cards.append(child)

func _get_random_food_card() -> FoodCard:
    var sc: FoodCard = FOOD_CARD_STATS.instantiate()
    var rnd: float = randf()
    var amount: int = 1
    
    if rnd < 0.6:
        # Plant 60%
        # rnd = randf()
        # if rnd < 0.1: 
        #     # 10%
        #     amount = 3
        # elif rnd < 0.8: 
        #     # 70%
        #     amount = 2
        # else: 
        #     # 20%
        #     amount = 1
        sc.plant_amount = amount
    else:
        # Meat 40%
        # rnd = randf()
        # if rnd < 0.05: 
        #     # 5%
        #     amount = 3
        # elif rnd < 0.55: 
        #     # 55%
        #     amount = 2
        # else: 
        #     # 45%
        #     amount = 1
        sc.meat_amount = amount
    
    return sc

func draw_card() -> Card:
    if cards.size() == 0:
        return null
    
    var card = FOOD_CARD_STATS.instantiate()
    
    if plant_requested and meat_requested:
        card.plant_amount = 0 if last_drew_plant else 1
        card.meat_amount = 1 if last_drew_plant else 0
        last_drew_plant = not last_drew_plant
        return card
    if plant_requested:
        card.plant_amount = 1
        card.meat_amount = 0
        last_drew_plant = true
        return card
    if meat_requested:
        card.plant_amount = 0
        card.meat_amount = 1
        last_drew_plant = false
        return card

    if randi_range(0, 1):
        card.plant_amount = 1
        card.meat_amount = 0
        last_drew_plant = true
        return card
    
    card.plant_amount = 0
    card.meat_amount = 1
    last_drew_plant = false
    return card

func remaining() -> int:
    return cards.size()

func is_empty() -> bool:
    return cards.size() == 0