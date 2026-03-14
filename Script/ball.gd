extends CharacterBody2D
<<<<<<< HEAD

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
=======
class_name  Ball

@export var speed: float = 400.0
@export var acceleration: float = 20.0
@export var max_speed: float = 1000.0

const MIN_BOUNCE_ANGLE: float = 0.2
const START_ANGLE: float = 10
var direction: Vector2 = Vector2.ZERO

func _ready():
	State.ball_counter += 1
	Signals.start_game.connect(start_game)

func start_game() -> void:
	direction = Vector2(randf_range(-START_ANGLE,START_ANGLE), -1).normalized()


func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	
	if collision:
		direction = direction.bounce(collision.get_normal())
		if abs(direction.y) < MIN_BOUNCE_ANGLE:
			var y_sign = sign(direction.y)
			if y_sign == 0: y_sign = 1 
			direction.y = MIN_BOUNCE_ANGLE * y_sign
			direction = direction.normalized()
			
		if abs(direction.x) < MIN_BOUNCE_ANGLE:
			var x_sign = sign(direction.x)
			if x_sign == 0: x_sign = 1
			direction.x = MIN_BOUNCE_ANGLE * x_sign
			direction = direction.normalized()

		speed += acceleration
		speed = min(speed, max_speed)
>>>>>>> branch 'main' of git@github.com:Nmugol/Arcanoid.git
