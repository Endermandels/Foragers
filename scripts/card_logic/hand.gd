extends Node
class_name Hand

@export_group("Settings")
@export var is_player_1: bool = false

signal consume_selected_food()

func get_plants_available() -> int:
    var plants = 0
    for food: FoodCard in get_children():
        if food.selected:
            plants += food.plant_amount
    return plants

func get_meat_available() -> int:
    var meat = 0
    for food: FoodCard in get_children():
        if food.selected:
            meat += food.meat_amount
    return meat

func can_purchase(card: AnimalCard) -> bool:
    return get_plants_available() >= card.plant_cost and get_meat_available() >= card.meat_cost

func purchase() -> void:
    for food: FoodCard in get_children():
        if food.selected:
            consume_selected_food.emit()
            food.queue_free()
