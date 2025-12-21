extends ProgressBar

var progressTimer: Timer

func _ready() -> void:
  add_theme_stylebox_override("fill", get_theme_stylebox("fill").duplicate())

func _process(_delta: float) -> void:
  value = (1 - progressTimer.time_left / progressTimer.wait_time) * max_value

  if progressTimer.time_left <= .3 :
    (get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color(1.0, 0.252, 0.637)
  else :
    (get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color(0.984, 0.0, 0.91)
