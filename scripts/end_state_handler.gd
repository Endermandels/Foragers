extends Control
class_name EndStateHandler

@export_group("Internal Nodes")
@export var shade_rect: ColorRect
@export var p1_win: PanelContainer
@export var p1_lose: PanelContainer
@export var play_again_btn: Button

func _ready() -> void:
	hide()
	p1_win.modulate = Color(1, 1, 1, 0)
	p1_lose.modulate = Color(1, 1, 1, 0)
	play_again_btn.modulate = Color(1, 1, 1, 0)

func handle_win(is_player_1: bool) -> void:
	show()
	p1_win.show()
	p1_lose.show()
	play_again_btn.show()
	var cont = p1_win if is_player_1 else p1_lose
	var tween = get_tree().create_tween().tween_property(shade_rect, "modulate:a", 0.6, 0.5)
	tween.finished.connect(_spawn_text.bind(cont))
	play_again_btn.pressed.connect(_reset)
	play_again_btn.disabled = true

func _spawn_text(cont: PanelContainer) -> void:
	get_tree().create_tween().tween_property(cont, "modulate:a", 1, 1).finished.connect(_show_play_again_btn)

func _show_play_again_btn() -> void:
	get_tree().create_tween().tween_property(play_again_btn, "modulate:a", 1, 0.5).finished.connect(func (): play_again_btn.disabled = false)

func _reset() -> void:
	get_tree().reload_current_scene()