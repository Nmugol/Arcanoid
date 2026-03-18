extends Control

@export var life_labe: Label
@export var score_labe: Label

@export var info_panel: NinePatchRect
@export var start_info: Label
@export var end_info: Label

func _ready() -> void:
	GlobalSignals.update_life.connect(_on_update_life)
	GlobalSignals.update_score.connect(_on_update_score)
	GlobalSignals.show_start_screen.connect(_on_show_start_screen)
	GlobalSignals.show_end_screen.connect(_on_show_end_screen)
	GlobalSignals.hide_info_screen.connect(_on_hide_info_screen)
	
	# Initial state
	_on_show_start_screen()

func _on_update_life(l: int) -> void:
	if life_labe:
		life_labe.text = str(l)

func _on_update_score(s: int) -> void:
	if score_labe:
		score_labe.text = str(s)

func _on_show_start_screen() -> void:
	info_panel.visible = true
	start_info.visible = true
	end_info.visible = false

func _on_show_end_screen(s: int) -> void:
	info_panel.visible = true
	start_info.visible = false
	end_info.visible = true
	end_info.text = "GAME OVER\nFINAL SCORE: " + str(s) + "\nPress 1 to reset" + "\nPress Y to exit"

func _on_hide_info_screen() -> void:
	info_panel.visible = false
	start_info.visible = false
	end_info.visible = false
