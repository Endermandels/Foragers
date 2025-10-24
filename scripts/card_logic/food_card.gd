extends Card
class_name FoodCard

@export_group("Settings")
@export_subgroup("Stats")
@export var plant_amount: int = 0
@export var meat_amount: int = 0

var selected: bool = false