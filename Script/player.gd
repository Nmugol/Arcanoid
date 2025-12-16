extends CharacterBody2D
class_name Player

@export var speed: float = 600.0

func _physics_process(_delta: float) -> void:
	if State.game_state != State.GameStates.RUN: return
	
	velocity.x = 0
	
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		
	move_and_slide()
