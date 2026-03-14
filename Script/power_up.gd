extends Area2D

enum Type { ADD_BALL, MULTIPLY, EXTEND }
var type: Type = Type.ADD_BALL

@export var fall_speed: float = 200.0

# Słownik do przypisania tekstur w edytorze
@export var type_textures: Dictionary[Type, Texture2D]

func _ready() -> void:
	# Losowy typ bonusu
	type = Type.values()[randi() % Type.size()]
	
	# Ustawienie tekstury ze słownika, jeśli została przypisana
	if type_textures.has(type) and type_textures[type] != null:
		$Sprite2D.texture = type_textures[type]
		modulate = Color.WHITE # Resetujemy kolor, jeśli mamy własną teksturę
	else:
		# Zmiana koloru tylko jeśli nie ma tekstury (tymczasowa wizualizacja)
		match type:
			Type.ADD_BALL: modulate = Color.GREEN
			Type.MULTIPLY: modulate = Color.GOLD
			Type.EXTEND: modulate = Color.CYAN

func _physics_process(delta: float) -> void:
	position.y += fall_speed * delta
	
	if position.y > get_viewport_rect().size.y:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		apply_powerup()
		queue_free()

func apply_powerup() -> void:
	var game = get_tree().current_scene
	match type:
		Type.ADD_BALL:
			game.spawn_ball()
		Type.MULTIPLY:
			game.multiply_balls()
		Type.EXTEND:
			var player = get_tree().get_first_node_in_group("Player")
			if player:
				player.extend_paddle()
