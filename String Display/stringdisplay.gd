extends RichTextLabel
class_name StringDisplay

@onready var lifeTimer: Timer = %lifetime

@export var LIFETIME: float = 1.0
@export var STRING: String = "Test String"

func _ready() -> void:
  lifeTimer.start(LIFETIME)
  
  position.x -= 384
  position.y -= 24

func _process(_delta: float) -> void:
  global_position.y -= 5
  text = STRING

func _on_lifetime_timeout() -> void:
  queue_free()
