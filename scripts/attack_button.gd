extends Button
class_name AttackButton

@export_group("External Nodes")
@export var game_logic: GameLogic

@export_group("Internal Nodes")
@export var sfx: AudioStreamPlayer

func _ready() -> void:
    pressed.connect(click)
    game_logic.buy_phase_entered.connect(enable_click)
    disable_click()

func click() -> void:
    if game_logic.state == GameLogic.GameState.BUY and game_logic.is_player_1_turn:
        sfx.play()
        game_logic.progress_phase()
        disable_click()

func enable_click() -> void:
    if game_logic.is_player_1_turn:
        mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        disabled = false

func disable_click() -> void:
    mouse_default_cursor_shape = Control.CURSOR_ARROW
    disabled = true