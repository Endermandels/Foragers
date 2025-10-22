extends Control
class_name EndStateHandler

@export_group("Internal Nodes")
@export var shade_rect: ColorRect
@export var p1_win: PanelContainer
@export var p1_lose: PanelContainer

func handle_win(is_player_1: bool) -> void:
    show()
    var cont = p1_win if is_player_1 else p1_lose
    var tween = get_tree().create_tween().tween_property(shade_rect, "modulate:a", 0.6, 0.5)
    tween.finished.connect(_spawn_text.bind(cont))

func _spawn_text(cont: PanelContainer) -> void:
    get_tree().create_tween().tween_property(cont, "modulate:a", 1, 1)