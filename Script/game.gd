extends Node2D

@onready var ball_scene = preload("res://Scene/ball.tscn")
@onready var powerup_scene = preload("res://Scene/power_up.tscn")
@onready var block_scene = preload("res://Scene/block.tscn")

var current_level = 0
var blocks_parent: Node2D
var noise: FastNoiseLite

@export var rows = 6
@export var cols = 8
@export var block_width = 96
@export var block_height = 32
@export var padding = 6

func _ready() -> void:
	$DeathZone.body_entered.connect(_on_death_zone_body_entered)
	
	# Inicjalizacja szumu do generowania poziomów
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.15 # Odpowiada za "skalę" wzorów
	
	# Szukamy kontenera na bloki lub tworzymy go
	if has_node("Blocks"):
		blocks_parent = get_node("Blocks")
	else:
		blocks_parent = Node2D.new()
		blocks_parent.name = "Blocks"
		add_child(blocks_parent)
	
	# Usuwamy bloki które mogły być w scenie edytora (nawet jeśli nie są w kontenerze)
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
			# Zamiast przeładowywać scenę, po prostu zresetujmy piłkę
			spawn_ball()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

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
	
	add_child(new_ball)
	return new_ball

func multiply_balls() -> void:
	var balls = get_tree().get_nodes_in_group("Ball")
	for ball in balls:
		for i in range(2):
			var new_ball = ball_scene.instantiate()
			new_ball.global_position = ball.global_position
			new_ball.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			new_ball.active = true
			add_child(new_ball)

func generate_level() -> void:
	current_level += 1
	
	# Czyścimy stare bloki (używamy free by natychmiast zwolnić miejsce przed liczeniem)
	for child in blocks_parent.get_children():
		child.free()
	
	# Zmieniamy parametry szumu dla urozmaicenia
	noise.seed = randi()
	
	# Próg decyduje o gęstości (im niższy, tym więcej bloków)
	var threshold = -0.15 + (current_level * 0.02) # Trudność: z czasem może być mniej bloków ale trudniej rozmieszczonych
	threshold = clamp(threshold, -0.4, 0.2)
	
	# Parametry siatki (zmniejszone dla bardziej zwartego układu)
	
	
	
	var total_width = (cols * (block_width + padding)) - padding
	var start_x = (get_viewport_rect().size.x - total_width) / 2 + block_width/2
	var start_y = 80
	
	for r in range(rows):
		for c in range(cols):
			# Pobieramy wartość szumu (-1.0 do 1.0)
			var val = noise.get_noise_2d(c * 10, r * 10)
			
			if val > threshold: 
				var block = block_scene.instantiate()
				block.position = Vector2(
					start_x + c * (block_width + padding), 
					start_y + r * (block_height + padding)
				)
				blocks_parent.add_child(block)
				
				# Przypisujemy twardość (1-3)
				# Na wyższych poziomach szansa na twardsze bloki rośnie
				var rand_h = randf()
				if rand_h > 0.8: # 20% szans na twardy
					block.hardness = 3
				elif rand_h > 0.5: # 30% szans na średni
					block.hardness = 2
				else:
					block.hardness = 1
	
	# Failsafe: jeśli szum wygenerował pusty poziom
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("Block").size() == 0:
		generate_level()
		return
	
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

func on_block_destroyed() -> void:
	# Czekamy na koniec klatki, aż silnik przetworzy queue_free()
	await get_tree().process_frame
	
	# Filtrujemy tylko te bloki, które nie są właśnie usuwane
	var blocks = get_tree().get_nodes_in_group("Block").filter(func(node): return !node.is_queued_for_deletion())
	
	if blocks.size() == 0:
		# Nowy poziom generujemy po chwili
		call_deferred("generate_level")
