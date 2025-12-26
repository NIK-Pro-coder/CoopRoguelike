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

## Taken from https://www.jeffreythompson.org/collision-detection/line-rect.php 
func lineRect(x1: float, y1: float, x2: float, y2: float, rx: float, ry: float, rw: float, rh: float) -> Vector2 :
  # check if the line has hit any of the rectangle's sides
  # uses the Line/Line function below
  var left: Vector2 =   lineLine(x1,y1,x2,y2, rx,ry,rx, ry+rh)
  var right: Vector2 =  lineLine(x1,y1,x2,y2, rx+rw,ry, rx+rw,ry+rh)
  var top: Vector2 =    lineLine(x1,y1,x2,y2, rx,ry, rx+rw,ry)
  var bottom: Vector2 = lineLine(x1,y1,x2,y2, rx,ry+rh, rx+rw,ry+rh)

  # if ANY of the above are true, the line
  # has hit the rectangle
  if left != Vector2(PI, PI) :
    return left
  if right != Vector2(PI, PI) :
    return right
  if top != Vector2(PI, PI) :
    return top
  if bottom != Vector2(PI, PI) :
    return bottom
    
  return Vector2(PI, PI)

# LINE/LINE
func lineLine(x1: float, y1: float, x2: float, y2: float, x3: float, y3: float, x4: float, y4: float) -> Vector2 :
  # calculate the direction of the lines
  var uA: float = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  var uB: float = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  # if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) :
    # optionally, draw a circle where the lines meet
    var intersectionX: float = x1 + (uA * (x2-x1))
    var intersectionY: float = y1 + (uA * (y2-y1))
    
    return Vector2(intersectionX, intersectionY)
  
  return Vector2(PI, PI)

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
  
  global_position = DOOR_POS

  var bounds: Vector2 = get_viewport().get_visible_rect().size
  var cam_pos: Vector2 = get_viewport().get_camera_2d().get_parent().global_position
  
  global_position = lineRect(
    global_position.x, global_position.y, 
    cam_pos.x, cam_pos.y, 
    
    cam_pos.x - bounds.x + 100, cam_pos.y - bounds.y + 100, 
    bounds.x * 2 - 200, bounds.y * 2 - 200
  )
  
  var delta = (DOOR_POS - global_position).normalized() * 50

  l.points = [global_position - delta, global_position - delta * 2.5]

  l2.points = [l.points[0], l.points[0] + delta.rotated( PI/1.2) * .5]
  l3.points = [l.points[0], l.points[0] + delta.rotated(-PI/1.2) * .5]

  $visible.global_position = DOOR_POS
  
