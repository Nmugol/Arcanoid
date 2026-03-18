extends Node2D

@onready var ball_scene = preload("res://Scene/ball.tscn")
@onready var powerup_scene = preload("res://Scene/power_up.tscn")
@onready var block_scene = preload("res://Scene/block.tscn")

var current_level = 0
var blocks_parent: Node2D
@export var max_lives = 3
var lives = 3
var score = 0

@export var rows = 6
@export var cols = 8
@export var block_width = 96
@export var block_height = 32
@export var padding = 6

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	lives = max_lives
	score = 0
	GlobalSignals.update_life.emit(lives)
	GlobalSignals.update_score.emit(score)
	$DeathZone.body_entered.connect(_on_death_zone_body_entered)
	
	# Szukamy kontenera na bloki lub tworzymy go
	if has_node("Blocks"):
		blocks_parent = get_node("Blocks")
	else:
		blocks_parent = Node2D.new()
		blocks_parent.name = "Blocks"
		add_child(blocks_parent)
	
	# Usuwamy bloki które mogły być w scenie edytora
	var existing_blocks = get_tree().get_nodes_in_group("Block")
	for b in existing_blocks:
		b.queue_free()
	
	# Rozpoczynamy pierwszy poziom
	generate_level()


func _on_death_zone_body_entered(body: Node) -> void:
	if body.is_in_group("Ball"):
		body.queue_free()
		# Sprawdzamy czy zostały jakieś piłki (po tym jak ta zostanie usunięta)
		await get_tree().process_frame
		var balls = get_tree().get_nodes_in_group("Ball")
		if balls.size() == 0:
			lives -= 1
			GlobalSignals.update_life.emit(lives)
			print("Stracono życie! Pozostało: ", lives)
			
			if lives <= 0:
				game_over()
			else:
				# Zresetujmy piłkę
				spawn_ball()

func game_over() -> void:
	print("KONIEC GRY | FINAŁOWY WYNIK: ", score)
	GlobalSignals.show_end_screen.emit(score)
	# Możesz tu dodać UI, na razie restartujemy scenę
	get_tree().paused = true # Opcjonalnie pauzujemy grę
	# get_tree().reload_current_scene() # Zakomentowane, by UI mogło wyświetlić wynik

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("reset"):
		get_tree().paused = false
		get_tree().reload_current_scene()

func spawn_powerup(pos: Vector2) -> void:
	var pwrup = powerup_scene.instantiate()
	pwrup.global_position = pos
	add_child(pwrup)

func spawn_ball(pos: Vector2 = Vector2.ZERO) -> CharacterBody2D:
	var new_ball = ball_scene.instantiate()
	var player = get_tree().get_first_node_in_group("Player")
	
	if pos == Vector2.ZERO:
		new_ball.global_position = player.global_position + Vector2(0, -32)
		new_ball.active = false
	else:
		new_ball.global_position = pos
		new_ball.active = true
	
	add_child.call_deferred(new_ball)
	return new_ball

func multiply_balls() -> void:
	var balls = get_tree().get_nodes_in_group("Ball")
	for ball in balls:
		for i in range(2):
			var new_ball = ball_scene.instantiate()
			new_ball.global_position = ball.global_position
			new_ball.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			new_ball.active = true
			add_child.call_deferred(new_ball)

func generate_level() -> void:
	current_level += 1
	
	# Czyścimy stare bloki
	for child in blocks_parent.get_children():
		child.free()
	
	var total_width = (cols * (block_width + padding)) - padding
	var start_x = (get_viewport_rect().size.x - total_width) / 2 + block_width/2.0
	var start_y = 80
	
	# Wybieramy kształt na podstawie numeru poziomu (7 rodzajów)
	var shape_type = (current_level - 1) % 7
	
	for r in range(rows):
		for c in range(cols):
			var should_spawn = false
			
			# Normalizacja rzędu do zakresu 0.0 - 1.0 dla obliczeń matematycznych
			var nr = float(r) / (rows - 1) if rows > 1 else 0.0
			
			match shape_type:
				0: # X
					var target_c = nr * (cols - 1)
					if abs(c - target_c) < 1.1 or abs(c - (cols - 1 - target_c)) < 1.1:
						should_spawn = true
				1: # V
					var target_c = nr * (cols - 1) / 2.0
					if abs(c - target_c) < 1.1 or abs(c - (cols - 1 - target_c)) < 1.1:
						should_spawn = true
				2: # W
					var half_cols = cols / 2.0
					var c_in_half = c % int(half_cols)
					var target_c = nr * (half_cols - 1) / 2.0
					if abs(c_in_half - target_c) < 1.1 \
							or abs(c_in_half - (half_cols - 1 - target_c)) < 1.1:
						should_spawn = true
				3: # Kwadrat pełen
					should_spawn = true
				4: # Trójkąt (skierowany w dół)
					var margin = int(round(nr * (cols - 1) / 2.0))
					if c >= margin and c <= (cols - 1 - margin):
						should_spawn = true
				5: # Kwadrat pusty (ramka)
					if r < 2 or r >= rows - 2 or c < 2 or c >= cols - 2:
						should_spawn = true
				6: # Dwa kwadraty po bokach (4x4 na krawędziach dla lepszego efektu)
					if (c < 4 or c >= cols - 4) and r < 4:
						should_spawn = true

			
			if should_spawn:
				var block = block_scene.instantiate()
				block.position = Vector2(
					start_x + c * (block_width + padding), 
					start_y + r * (block_height + padding)
				)
				blocks_parent.add_child(block)
				
				# Przypisujemy twardość (zwiększona szansa na trudniejsze bloki z poziomem)
				var hardness_chance = randf()
				if hardness_chance > 0.8:
					block.hardness = 3
				elif hardness_chance > 0.5:
					block.hardness = 2
				else:
					block.hardness = 1
	
	reset_balls()

func reset_balls() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	var balls = get_tree().get_nodes_in_group("Ball")
	
	# Jeśli nie ma piłek, stwórz jedną
	if balls.size() == 0:
		spawn_ball()
	else:
		for ball in balls:
			ball.active = false
			ball.global_position = player.global_position + Vector2(0, -32)

func on_block_destroyed(points: int = 100) -> void:
	score += points
	GlobalSignals.update_score.emit(score)
	print("PUNKTY: ", score)
	
	# Czekamy na koniec klatki, aż silnik przetworzy queue_free()
	await get_tree().process_frame
	
	# Filtrujemy tylko te bloki, które nie są właśnie usuwane
	var blocks = get_tree().get_nodes_in_group("Block").filter(
			func(node): return !node.is_queued_for_deletion()
			)
	
	if blocks.size() == 0:
		# Nowy poziom generujemy po chwili
		call_deferred("generate_level")
