extends StaticBody2D
<<<<<<< HEAD

@export var hardness: int = 1:
	set(value):
		hardness = value
		update_appearance()

func _ready() -> void:
	update_appearance()

func update_appearance() -> void:
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return
		
	# Kolory dla różnych poziomów twardości
	match hardness:
		1:
			sprite.modulate = Color(0.5, 1.0, 0.5) # Zielony (miękki)
		2:
			sprite.modulate = Color(1.0, 0.8, 0.2) # Pomarańczowy/Złoty (średni)
		3:
			sprite.modulate = Color(1.0, 0.3, 0.3) # Czerwony (twardy)
		_:
			sprite.modulate = Color.WHITE

func hit() -> bool:
	hardness -= 1
	if hardness <= 0:
		queue_free()
		return true # Zniszczony
	else:
		update_appearance()
		return false # Jeszcze stoi
=======
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
		
>>>>>>> branch 'main' of git@github.com:Nmugol/Arcanoid.git
