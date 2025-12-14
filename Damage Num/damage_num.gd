extends Node2D

class_name DamageNum

@export var DAMAGE: int = 0
@export var LIFETIME: float = 2.5

var velocity = 64

func _ready() -> void:
  $Timer.start(LIFETIME)
  
  position.x += randf_range(-10, 10)
  position.y += randf_range(-10, 10)

func _process(_delta: float) -> void:
  $textNum.text = str(abs(DAMAGE))
  
  var alpha = max(0, $Timer.time_left - LIFETIME*.75) / (LIFETIME*.25)
  $textNum.add_theme_color_override("default_color", Color(1,0,0,alpha) if DAMAGE > 0 else Color(0,1,0,alpha))
  
  position.y -= velocity
  
  velocity /= 2

func _on_timer_timeout() -> void:
  queue_free()
