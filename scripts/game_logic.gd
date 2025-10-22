extends Node
class_name GameLogic

enum GameState {
    DRAW,
    BUY,
    ATTACK,
    END
}

@export_group("Settings")
@export var is_player_1_turn: bool = true
@export var n_beginning_cards_p1: int = 3
@export var n_beginning_cards_p2: int = 3
@export var p1_hp: int = 20
@export var p2_hp: int = 20

@export_group("External Nodes")
@export var p1_hp_label: Label
@export var p2_hp_label: Label
@export var end_state_handler: EndStateHandler

@export_group("Internal Nodes")
@export var p1_animals: AnimalsRow
@export var p2_animals: AnimalsRow

var turn: int = 0
var state: GameState = GameState.DRAW

signal draw_cards(n: int, player_1: bool) ## Draw n cards
signal show_encounters_row()

signal draw_phase_entered
signal buy_phase_entered
signal attack_phase_entered

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()

func _ready() -> void:
    get_tree().create_timer(0.2).timeout.connect(draw_phase)
    p1_hp_label.text = str(p1_hp)
    p2_hp_label.text = str(p2_hp)

func draw_phase() -> void:
    print("Draw state entered")
    state = GameState.DRAW
    draw_phase_entered.emit()

    if turn == 0 and is_player_1_turn:
        draw_cards.emit(n_beginning_cards_p1, true)
        draw_cards.emit(n_beginning_cards_p2, false)
    else:
        draw_cards.emit(1, is_player_1_turn)

func buy_phase() -> void:
    print("Buy state entered")
    state = GameState.BUY
    show_encounters_row.emit()
    buy_phase_entered.emit()

func attack_phase() -> void:
    print("Attack state entered")
    state = GameState.ATTACK
    attack_phase_entered.emit()
    
    if is_player_1_turn:
        for animal: AnimalCard in p1_animals.get_children():
            p2_hp = clampi(p2_hp - animal.atk, 0, p2_hp)
            # TODO: Add attacking animals instead of player directly
        p2_hp_label.text = str(p2_hp)
        if p2_hp == 0:
            end_state_handler.handle_win(true)
            state = GameState.END
            return
    else:
        for animal: AnimalCard in p2_animals.get_children():
            p1_hp = clampi(p1_hp - animal.atk, 0, p1_hp)
        p1_hp_label.text = str(p1_hp)
        if p1_hp == 0:
            end_state_handler.handle_win(false)
            state = GameState.END
            return
    
    get_tree().create_timer(1).timeout.connect(progress_phase)

func progress_phase() -> void:
    if state == GameState.ATTACK:
        turn += 1
        is_player_1_turn = not is_player_1_turn
        draw_phase()
    elif state == GameState.DRAW:
        buy_phase()
    elif state == GameState.BUY:
        attack_phase()