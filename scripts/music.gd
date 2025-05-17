extends Node

@onready var music_player: AudioStreamPlayer = $MusicStream

const MUSIC_DIR = "res://Stracks/"

var tracks: Array[String] = []
var current_track_index: int = -1
var is_muted: bool = false

func _ready() -> void:
	randomize()
	tracks = load_music_tracks()
	if tracks.size() > 0:
		play_random_track()
	
	music_player.finished.connect(_on_music_finished)

func load_music_tracks() -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(MUSIC_DIR)
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".ogg") or file_name.ends_with(".wav") or file_name.ends_with(".mp3"):
				files.append(MUSIC_DIR + file_name)
	return files

func play_random_track() -> void:
	if tracks.is_empty():
		return
	var new_index = randi() % tracks.size()
	while new_index == current_track_index and tracks.size() > 1:
		new_index = randi() % tracks.size()
	current_track_index = new_index

	var audio_stream = load(tracks[current_track_index])
	if audio_stream:
		music_player.stream = audio_stream
		music_player.play()

func _on_music_finished() -> void:
	play_random_track()

# 🔇 Mute / Unmute function
func mute_music(mute: bool) -> void:
	is_muted = mute
	if music_player:
		music_player.volume_db = -80.0 if mute else 0.0
