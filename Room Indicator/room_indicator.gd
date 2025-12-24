extends Sprite2D
class_name RoomIndicator

@export var DOOR_POS: Vector2
@export var ICON: Texture2D

var l: Line2D
var l2: Line2D
var l3: Line2D

func _ready() -> void:
  global_position = DOOR_POS
  texture = ICON
  
  l = Line2D.new()
  l.end_cap_mode = Line2D.LINE_CAP_ROUND
  l.begin_cap_mode = Line2D.LINE_CAP_ROUND
  l.add_to_group("roompart")
  
  get_tree().get_root().add_child.call_deferred(l)
  
  l2 = Line2D.new()
  l2.end_cap_mode = Line2D.LINE_CAP_ROUND
  l2.begin_cap_mode = Line2D.LINE_CAP_ROUND
  l2.add_to_group("roompart")
  
  get_tree().get_root().add_child.call_deferred(l2)
  
  l3 = Line2D.new()
  l3.end_cap_mode = Line2D.LINE_CAP_ROUND
  l3.begin_cap_mode = Line2D.LINE_CAP_ROUND
  l3.add_to_group("roompart")
  
  get_tree().get_root().add_child.call_deferred(l3)

var on_screen = false

func _on_visible_screen_entered() -> void:
  on_screen = true

func _on_visible_screen_exited() -> void:
  on_screen = false

func _process(_delta: float) -> void:
  visible = len(get_tree().get_nodes_in_group("enemy")) == 0
  l.visible = !on_screen and visible
  l2.visible = l.visible
  l3.visible = l.visible
  
  if on_screen :
    global_position = DOOR_POS
    $visible.position = Vector2.ZERO
    return
  
  var p: Player
  var d: float = -1
  
  for i in get_tree().get_nodes_in_group("player") :
    var dist = (i as Player).global_position.distance_squared_to(DOOR_POS)
    
    if dist < d or d < 0 :
      d = dist
      p = i
  
  if not p :
    return
  
  global_position = p.global_position
  global_position = global_position + (DOOR_POS - global_position).normalized() * 250

  var delta = (DOOR_POS - global_position).normalized() * 50

  l.points = [global_position - delta, global_position - delta * 2.5]

  l2.points = [l.points[0], l.points[0] + delta.rotated( PI/1.2) * .5]
  l3.points = [l.points[0], l.points[0] + delta.rotated(-PI/1.2) * .5]

  $visible.global_position = DOOR_POS
  
