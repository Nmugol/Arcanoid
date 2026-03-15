extends CharacterBody2D

@export var speed: float = 400.0
var active: bool = false
var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	# Początkowy kierunek
	direction = Vector2(randf_range(-0.5, 0.5), -1).normalized()

func _physics_process(delta: float) -> void:
	if not active:
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			global_position = player.global_position + Vector2(0, -32)
		
		if Input.is_action_just_pressed("start"):
			active = true
			direction = Vector2(randf_range(-0.5, 0.5), -1).normalized()
			GlobalSignals.hide_info_screen.emit()
		return
		
	var collision = move_and_collide(direction * speed * delta)
	
	if collision:
		# Odbicie
		direction = direction.bounce(collision.get_normal())
		
		# Logika niszczenia bloków
		var collider = collision.get_collider()
		if collider.is_in_group("Block"):
			var destroyed = false
			if collider.has_method("hit"):
				destroyed = collider.hit()
			else:
				# Failsafe jeśli skryptu by nie było
				collider.queue_free()
				destroyed = true
			
			GlobalSignals.block_hit.emit(destroyed)
			
			if destroyed:
				# Szansa na bonus (np. 20%) tylko przy całkowitym zniszczeniu
				if randf() < 0.2:
					get_tree().current_scene.spawn_powerup(collider.global_position)
				
				# Powiadom grę o zniszczeniu bloku
				if get_tree().current_scene.has_method("on_block_destroyed"):
					get_tree().current_scene.on_block_destroyed()
		elif collider.is_in_group("Player"):
			# Możemy dodać wpływ ruchu paletki na kierunek piłki
			var paddle_width = 100.0 * collider.scale.x # Dynamiczna szerokość
			var hit_pos = (global_position.x - collider.global_position.x) / (paddle_width / 2)
			direction = Vector2(hit_pos, -1).normalized()
