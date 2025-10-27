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
@export var low_thresh: int = 5

@export_group("External Nodes")
@export var p1_hp_label: Label
@export var p2_hp_label: Label
@export var end_state_handler: EndStateHandler

@export_group("Internal Nodes")
@export var p1_animals: AnimalsRow
@export var p2_animals: AnimalsRow
@export var p1_attacked_sfx: AudioStreamPlayer
@export var p2_attacked_sfx: AudioStreamPlayer
@export var draw_sfx: AudioStreamPlayer
@export var battle_start: AudioStreamPlayer
@export var p1_low: AudioStreamPlayer
@export var p2_low: AudioStreamPlayer
@export var victory: AudioStreamPlayer
@export var defeat: AudioStreamPlayer

var turn: int = 0
var state: GameState = GameState.DRAW

var p1_saving_up: bool = false # Set externally
var p2_saving_up: bool = false # Set externally

signal draw_cards(n: int, player_1: bool) ## Draw n cards
signal show_encounters_row()

signal draw_phase_entered
signal buy_phase_entered
signal attack_phase_entered

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func _ready() -> void:
	get_tree().create_timer(0.2).timeout.connect(draw_phase)
	p1_hp_label.text = str(p1_hp)
	p2_hp_label.text = str(p2_hp)

func draw_phase() -> void:
	print("Draw state entered")
	state = GameState.DRAW
	draw_phase_entered.emit()

	if turn == 0 and is_player_1_turn:
		battle_start.play()
		draw_cards.emit(n_beginning_cards_p1, true)
		draw_cards.emit(n_beginning_cards_p2, false)
	else:
		var n_cards = 2
		if is_player_1_turn and p1_saving_up:
			n_cards = 3
		elif not is_player_1_turn and p2_saving_up:
			n_cards = 3
		draw_cards.emit(n_cards, is_player_1_turn)
	draw_sfx.play()

func buy_phase() -> void:
	print("Buy state entered")
	if is_player_1_turn:
		p1_saving_up = true
	else:
		p2_saving_up = true
	state = GameState.BUY
	show_encounters_row.emit()
	buy_phase_entered.emit()

func attack_phase() -> void:
	print("Attack state entered")
	state = GameState.ATTACK
	attack_phase_entered.emit()
	
	if is_player_1_turn:
		var p2_hp_save = p2_hp
		var attacked = false
		for animal: AnimalCard in p1_animals.get_children():
			if animal.atk == 0:
				continue
			var atkd = false
			for p2_animal: AnimalCard in p2_animals.get_children():
				if p2_animal.hp > 0:
					p2_animal.take_damage(animal.atk)
					attacked = true
					atkd = true
					break
			if not atkd:
				p2_hp = clampi(p2_hp - animal.atk, 0, p2_hp)

		if p2_hp < p2_hp_save or attacked:
			p2_attacked_sfx.play()
			if p2_hp <= low_thresh and battle_start.playing:
				p2_low.play()
				battle_start.stop()

		p2_hp_label.text = str(p2_hp)
		if p2_hp == 0:
			end_game(true)
			return
	else:
		var p1_hp_save = p1_hp
		var attacked = false
		for animal: AnimalCard in p2_animals.get_children():
			if animal.atk == 0:
				continue
			var atkd = false
			for p1_animal: AnimalCard in p1_animals.get_children():
				if p1_animal.hp > 0:
					p1_animal.take_damage(animal.atk)
					attacked = true
					atkd = true
					break
			if not atkd:
				p1_hp = clampi(p1_hp - animal.atk, 0, p1_hp)

		if p1_hp < p1_hp_save or attacked:
			p1_attacked_sfx.play()
			if p1_hp <= low_thresh and battle_start.playing:
				p1_low.play()
				battle_start.stop()

		p1_hp_label.text = str(p1_hp)
		if p1_hp == 0:
			end_game(false)
			return
	
	get_tree().create_timer(1).timeout.connect(progress_phase)

func end_game(p1_win: bool) -> void:
	end_state_handler.handle_win(p1_win)
	state = GameState.END
	p1_low.stop()
	p2_low.stop()
	battle_start.stop()
	if p1_win:
		victory.play()
	else:
		defeat.play()

func progress_phase() -> void:
	if state == GameState.ATTACK:
		turn += 1
		is_player_1_turn = not is_player_1_turn
		draw_phase()
	elif state == GameState.DRAW:
		buy_phase()
	elif state == GameState.BUY:
		attack_phase()
