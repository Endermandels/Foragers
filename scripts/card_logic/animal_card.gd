extends Card
class_name AnimalCard

@export_group("Settings")
@export_subgroup("Stats")
@export var type: String = ""
@export var hp: int = 1
@export var atk: int = 0
@export var plant_cost: int = 1
@export var meat_cost: int = 0

# Set elsewhere
var sc_ref: AnimalCardHandler = null

func take_damage(dmg: int) -> void:
    hp = clampi(hp - dmg, 0, hp)
    sc_ref.match_card_stats(self)
    if hp == 0:
        sc_ref.die()
        queue_free()