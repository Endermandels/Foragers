extends Node
class_name GameLogic

enum GameState {
    DRAW,
    BUY,
    ATTACK
}

@export_group("Settings")
@export var is_player_1_turn: bool = true
@export var n_beginning_cards_p1: int = 3
@export var n_beginning_cards_p2: int = 3

var turn: int = 0
var state: GameState = GameState.DRAW

signal draw_cards(n: int, player_1: bool) ## Draw n cards
signal show_encounters_row()

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()

func _ready() -> void:
    get_tree().create_timer(0.2).timeout.connect(draw_phase)

func draw_phase() -> void:
    print("Draw state entered")
    state = GameState.DRAW

    if turn == 0 and is_player_1_turn:
        draw_cards.emit(n_beginning_cards_p1, true)
        draw_cards.emit(n_beginning_cards_p2, false)
    else:
        draw_cards.emit(1, is_player_1_turn)

func buy_phase() -> void:
    print("Buy state entered")
    state = GameState.BUY
    show_encounters_row.emit()

func attack_phase() -> void:
    print("Attack state entered")
    state = GameState.ATTACK
    
    

func progress_phase() -> void:
    if state == GameState.ATTACK:
        turn += 1
        is_player_1_turn = not is_player_1_turn
        draw_phase()
    elif state == GameState.DRAW:
        buy_phase()
    elif state == GameState.BUY:
        attack_phase()