extends Sprite2D

var hue: float = 0

func _ready() -> void:
  material = material.duplicate()

func _process(_delta: float) :
  material.set_shader_parameter("hue_shift", hue)
  
  modulate.a = $lifetime.time_left / $lifetime.wait_time
  
  if $lifetime.time_left == 0 :
    queue_free()
