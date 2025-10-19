extends CardHandler
class_name FoodCardHandler

@export_group("Internal Nodes")
@export var food_label: Label
@export var plant_sprite: Sprite2D
@export var meat_sprite: Sprite2D
@export var selected_rect: ColorRect
@export var hidden_view: Node2D

var selected: bool = false
var card_ref: FoodCard

func _ready() -> void:
    button.pressed.connect(click)

func match_card_stats(card: FoodCard):
    if card.plant_amount > 0:
        # Plant card
        food_label.text = str(card.plant_amount)
        plant_sprite.show()
        meat_sprite.hide()
    if card.meat_amount > 0:
        # Meat card
        food_label.text = str(card.meat_amount)
        plant_sprite.hide()
        meat_sprite.show()

func click() -> void:
    if selected:
        selected = false
        selected_rect.hide()
    else:
        selected = true
        selected_rect.show()
    card_ref.selected = selected
