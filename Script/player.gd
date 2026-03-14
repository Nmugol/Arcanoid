extends CharacterBody2D
class_name Player

@export var speed: float = 600.0
<<<<<<< HEAD
@export var acceleration: float = 20.0
@export var friction: float = 15.0
=======
>>>>>>> branch 'main' of git@github.com:Nmugol/Arcanoid.git

<<<<<<< HEAD
var normal_scale: Vector2

func _ready() -> void:
	normal_scale = scale

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		velocity.x = lerp(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)

	move_and_slide()
	
	# Ograniczenie pozycji gracza do ekranu (zakładając 1152px szerokości)
	var screen_size = get_viewport_rect().size
	var half_width = 50.0 * scale.x # Przybliżona połowa szerokości
	position.x = clamp(position.x, half_width, screen_size.x - half_width)

func extend_paddle() -> void:
	scale.x = 1.5
	# Reset po 10 sekundach
	await get_tree().create_timer(10.0).timeout
	scale.x = normal_scale.x
=======
func _physics_process(_delta: float) -> void:
	if State.game_state != State.GameStates.RUN: return
	
	velocity.x = 0
	
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		
	move_and_slide()
>>>>>>> branch 'main' of git@github.com:Nmugol/Arcanoid.git
