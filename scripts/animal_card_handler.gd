extends CardHandler
class_name AnimalCardHandler

@export_group("Internal Nodes")
@export var hp_label: Label
@export var atk_label: Label
@export var food_sprites: Array[Sprite2D]

const PLANT_TEXTURE = preload("res://assets/images/plant-icon.png")
const MEAT_TEXTURE = preload("res://assets/images/meat-icon.png")

signal dead

func match_card_stats(card: AnimalCard) -> void:
    hp_label.text = str(card.hp)
    atk_label.text = str(card.atk)

    if card.plant_cost > 0:
        for i in range(food_sprites.size()):
            if i == card.plant_cost:
                break
            food_sprites[i].texture = PLANT_TEXTURE
            food_sprites[i].show()
    else:
        for i in range(food_sprites.size()):
            if i == card.meat_cost:
                break
            food_sprites[i].texture = MEAT_TEXTURE
            food_sprites[i].show()

func die() -> void:
    dead.emit()
    queue_free()