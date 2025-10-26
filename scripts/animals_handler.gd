extends Node2D
class_name AnimalsHandler

@export_group("Settings")
@export var card_spacing: float = 90.0

@export_group("Internal Nodes")
@export var left_bound: Node2D
@export var right_bound: Node2D
@export var y_value: Node2D
@export var cards: Node2D
@export var animal_join_sfx: AudioStreamPlayer

func add_card(card: AnimalCardHandler) -> void:
    if card == null:
        return

    if animal_join_sfx:
        animal_join_sfx.play()
    cards.add_child(card)
    card.dead.connect(_delayed_arrange_cards.bind(0.2))
    _arrange_cards()

func _delayed_arrange_cards(t: float) -> void:
    get_tree().create_timer(t).timeout.connect(_arrange_cards)

func _arrange_cards():
    var total_width = (cards.get_child_count() - 1) * card_spacing
    var start_x = left_bound.global_position.x
    var end_x = start_x + total_width

    # If too wide, shift left so leftmost stays at left_bound
    var shift = 0.0
    while end_x > right_bound.global_position.x:
        shift += 1
        total_width = (cards.get_child_count() - 1) * (card_spacing - shift)
        end_x = start_x + total_width

    for i in range(cards.get_child_count()):
        var target_x = start_x + i * (card_spacing - shift)
        var card = cards.get_child(i)
        card.move_to(Vector2(target_x, y_value.global_position.y))  # smooth motion handled by card itself
