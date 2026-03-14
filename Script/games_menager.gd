extends Node2D

@export_category("GUI")
@export var start_screen: Control
@export var points_label: Label
@export var game_over_screen: Control
@export var final_score: Label
@export var play_screen: Control

@export_category("Object")
@export var block_parent: Node2D
@export var ball_parent: Node2D
@export var player: Player

@export_category("Default")
@export var ball_pos: Vector2
@export var player_pos: Vector2
@export var block: PackedScene
@export var ball: PackedScene
@export var time_to_shot_next_ball: float = 0.7


func _ready() -> void:
	randomize()
	add_ball()
	load_level()
	game_over_screen.hide()
	start_screen.show()
	play_screen.hide()
	Signals.update_points.connect(_update_points)


func _update_points() -> void:
	points_label.text = " Score: " + str(State.points)


func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	if Input.is_action_just_pressed("start") and State.game_state == State.GameStates.STOP:
		State.game_state = State.GameStates.RUN
		game_over_screen.hide()
		start_screen.hide()
		play_screen.show()
		Signals.start_game.emit()

	if State.game_state == State.GameStates.RUN and State.ball_counter <= 0:
		State.game_state = State.GameStates.GAME_OVER
		
		game_over_screen.show()
		start_screen.hide()
		play_screen.hide()

		final_score.text = "SCORE: " + str(State.points)

	if State.game_state != State.GameStates.STOP and Input.is_action_just_pressed("reset"):
		State.game_state = State.GameStates.STOP
		player.position = player_pos

		game_over_screen.hide()
		start_screen.show()
		play_screen.hide()

		for b in block_parent.get_children():
			b.queue_free()

		for b in ball_parent.get_children():
			b.queue_free()

		State.points = 0

		add_ball()
		load_level()

	if block_parent.get_child_count() == 0:
		State.game_state = State.GameStates.STOP

		player.position = player_pos

		load_level()

		for b: Ball in ball_parent.get_children():
			b.position = ball_pos
			b.start_game()
			await get_tree().create_timer(time_to_shot_next_ball).timeout


func _on_delete_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ball"):
		body.queue_free()
		State.ball_counter -= 1



var levels = {
	"1": [
		[80, 40, 1],
		[171, 40, 1],
		[262, 40, 1],
		[808, 40, 1],
		[899, 40, 1],
		[990, 40, 1],
		[80, 60, 1],
		[171, 60, 2],
		[262, 60, 1],
		[353, 60, 1],
		[444, 60, 1],
		[535, 60, 1],
		[626, 60, 1],
		[717, 60, 1],
		[808, 60, 1],
		[899, 60, 2],
		[990, 60, 1],
		[80, 80, 1],
		[171, 80, 3],
		[262, 80, 1],
		[353, 80, 1],
		[444, 80, 2],
		[535, 80, 1],
		[626, 80, 2],
		[717, 80, 1],
		[808, 80, 1],
		[899, 80, 3],
		[990, 80, 1],
		[80, 100, 1],
		[171, 100, 2],
		[262, 100, 1],
		[353, 100, 1],
		[444, 100, 3],
		[535, 100, 1],
		[626, 100, 3],
		[717, 100, 1],
		[808, 100, 1],
		[899, 100, 2],
		[990, 100, 1],
		[80, 120, 1],
		[171, 120, 1],
		[262, 120, 1],
		[353, 120, 1],
		[444, 120, 2],
		[535, 120, 1],
		[626, 120, 2],
		[717, 120, 1],
		[808, 120, 1],
		[899, 120, 1],
		[990, 120, 1],
		[353, 140, 1],
		[444, 140, 1],
		[535, 140, 1],
		[626, 140, 1],
		[717, 140, 1],
	],
}


func load_level() -> void:
	var level_values = levels.values()
	var data = level_values[randi() % level_values.size()]
	for b in data:
		var new_block = block.instantiate()
		new_block.position = Vector2(b[0], b[1])
		new_block.hp = b[2]
		block_parent.add_child(new_block)


func add_ball() -> void:
	var new_ball = ball.instantiate()
	new_ball.position = ball_pos
	ball_parent.add_child(new_ball)
