extends CharacterBody2D
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
