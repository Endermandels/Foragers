extends Node
class_name Hand

@export_group("Settings")
@export var is_player_1: bool = false

func get_plants_available() -> int:
    var plants = 0
    for food: FoodCard in get_children():
        plants += food.plant_amount
        print("added another plant")
    return plants

func get_meat_available() -> int:
    var meat = 0
    for food: FoodCard in get_children():
        meat += food.meat_amount
        print("added another meat")
    return meat
