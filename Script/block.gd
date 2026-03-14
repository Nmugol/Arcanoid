extends StaticBody2D

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
