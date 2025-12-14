extends Node2D
class_name GenericTelegraph

@export var TELEGRAPH_TIME: float = 1
@export var SHAPE_SIZE: Vector2

@onready var timer: Timer = %Timer

var shape: ColorRect
var shape_complete: ColorRect

func _ready() -> void:
  timer.start(TELEGRAPH_TIME)
  
  shape = ColorRect.new()
  shape.size = SHAPE_SIZE
  shape.position -= SHAPE_SIZE / 2
  shape.color = Color(.95, .1, 0, .25)
  
  shape_complete = shape.duplicate()
  
  add_child(shape_complete)
  add_child(shape)
  
func _process(_delta: float) -> void:
  shape.scale = Vector2.ONE * (TELEGRAPH_TIME - timer.time_left) / TELEGRAPH_TIME
  shape.position = -SHAPE_SIZE/2 * shape.scale.x

signal telegraph_finished

func _on_timer_timeout() -> void:
  emit_signal("telegraph_finished")
