extends Node
class_name MusciPlayer

@onready var track1: AudioStreamPlayer = %track1
@onready var track2: AudioStreamPlayer = %track2

@onready var anim: AnimationPlayer = %anim

func play_track(stream: AudioStream) :
  track2.stream = stream
  track2.volume_db = -80
  track2.play()

  anim.play("fade_in_new")

func _on_anim_animation_finished(_anim_name: StringName) -> void:
  track1.stream = track2.stream
  track1.play(track2.get_playback_position())
  track1.volume_db = 0
  
  track2.volume_db = -80
  track2.playing = false

func _ready() -> void:
  play_track(load("res://Music/coop_roguelike_theme.wav"))
