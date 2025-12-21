extends Sprite2D
class_name RoomIndicator

@export var DOOR_POS: Vector2
@export var ICON: Texture2D

var l: Line2D

func _ready() -> void:
  global_position = DOOR_POS
  texture = ICON
  
  l = Line2D.new()
  l.end_cap_mode = Line2D.LINE_CAP_ROUND
  l.begin_cap_mode = Line2D.LINE_CAP_ROUND
  l.add_to_group("roompart")
  
  get_tree().get_root().add_child.call_deferred(l)

var on_screen = false

func _on_visible_screen_entered() -> void:
  on_screen = true

func _on_visible_screen_exited() -> void:
  on_screen = false

func _process(_delta: float) -> void:
  visible = len(get_tree().get_nodes_in_group("enemy")) == 0
  l.visible = !on_screen and visible
  
  if on_screen :
    global_position = DOOR_POS
    $visible.position = Vector2.ZERO
    return
  
  global_position = get_viewport().get_camera_2d().global_position
  global_position = global_position + (DOOR_POS - global_position).normalized() * 250

  var delta = (DOOR_POS - global_position).normalized() * 50

  l.points = [global_position - delta, global_position - delta * 2]

  $visible.global_position = DOOR_POS
  
