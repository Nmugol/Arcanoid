extends StaticBody2D
class_name Block

@export_range(1,3,1) var hp = 1
@export var colors: Array[Color] = []
@export var sprite: Sprite2D

var start_hp = 1
const BASE_POINTS: int = 10

func _ready() -> void:
	start_hp = hp
	sprite.modulate = colors[hp-1]

func _hp_counter() -> void: 
	self.queue_free()
	State.points += BASE_POINTS * start_hp
	Signals.update_points.emit()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ball"):
		hp -= 1
		sprite.modulate = colors[hp-1]
		if hp <= 0: _hp_counter()
		
