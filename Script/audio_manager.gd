extends Node

@export_group("Music")
@export var music_track: AudioStream

@export_group("SFX")
@export var block_hit_sfx: AudioStream
@export var block_destroyed_sfx: AudioStream
@export var powerup_collected_sfx: AudioStream
@export var failure_sfx: AudioStream

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var max_sfx_players = 8
var _destroyed_sound_played_this_frame = false
var _powerup_sound_played_this_frame = false

func _ready() -> void:
	# Setup music player
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"
	music_player.stream = music_track
	if music_track:
		music_player.play()
	
	# Setup SFX players pool
	for i in range(max_sfx_players):
		var p = AudioStreamPlayer.new()
		add_child(p)
		p.bus = "SFX"
		sfx_players.append(p)
	
	# Connect signals
	GlobalSignals.block_hit.connect(_on_block_hit)
	GlobalSignals.powerup_collected.connect(_on_powerup_collected)
	GlobalSignals.update_life.connect(_on_update_life)

func play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return

func _on_block_hit(destroyed: bool) -> void:
	if destroyed:
		if not _destroyed_sound_played_this_frame:
			play_sfx(block_destroyed_sfx)
			_destroyed_sound_played_this_frame = true
			# Resetujemy flagę w następnej klatce
			get_tree().process_frame.connect(func(): _destroyed_sound_played_this_frame = false, CONNECT_ONE_SHOT)
	else:
		play_sfx(block_hit_sfx)

func _on_powerup_collected() -> void:
	if not _powerup_sound_played_this_frame:
		play_sfx(powerup_collected_sfx)
		_powerup_sound_played_this_frame = true
		# Resetujemy flagę w następnej klatce
		get_tree().process_frame.connect(func(): _powerup_sound_played_this_frame = false, CONNECT_ONE_SHOT)

func _on_update_life(lives: int) -> void:
	var last_lives = -1
	if last_lives == -1:
		last_lives = lives
		return
	
	if lives < last_lives:
		play_sfx(failure_sfx)
	
	last_lives = lives
