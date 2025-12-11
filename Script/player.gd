extends CharacterBody2D

@export_category("player settings")
@export var speed: float = 5.0

const ACCELERATIONS: float = 100

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("move_left"):
		velocity.x += -(speed*ACCELERATIONS) * delta

	if Input.is_action_pressed("move_right"):
		velocity.x += (speed*ACCELERATIONS) * delta

	velocity.y = 0
	move_and_slide()