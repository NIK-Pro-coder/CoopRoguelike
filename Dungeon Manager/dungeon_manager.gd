extends Node2D
class_name DungeonMngr

@export_range(1, 10, 1, "or_greater") var GRID_SIZE_X = 9
@export_range(1, 10, 1, "or_greater") var GRID_SIZE_Y = 9

@export_range(1, 4, 1) var DIRECTIONS = 3

@export_range(1, 50, 1, "or_greater") var MAX_ROOMS = 15

@export var ROOM_SIZE = 2500
@export var CALM_ROOM_SIZE = 1500

@export_category("Dungeon Rooms")
@export var DUNGEON_ROOMS: Array[DungeonRoom]

enum DIRECTION {
  UP = 1,
  LEFT = 2,
  DOWN = 4,
  RIGHT = 8
}

var currentRoom: Vector2
var grid: Array[Array] = []
var posToRoom: Dictionary[Vector2, DungeonRoom] = {}

@onready var minimap: GridContainer = %minimap
@onready var vCorridor: GridContainer = %corridorV
@onready var hCorridor: GridContainer = %corridorH

var posToRect: Dictionary[Vector2, ColorRect] = {}
var posToIcon: Dictionary[Vector2, TextureRect] = {}

var downCorridor: Dictionary[Vector2, ColorRect] = {}
var upCorridor: Dictionary[Vector2, ColorRect] = {}
var rightCorridor: Dictionary[Vector2, ColorRect] = {}
var leftCorridor: Dictionary[Vector2, ColorRect] = {}

var MINIMAP_CELL_SIZE: int = 16

@export_category("Minimap Colors")
@export var HIDDEN: Color
@export var UNDISCOVERED: Color
@export var DISCOVERED: Color
@export var ACTIVE: Color

func _ready() -> void:
  generateGrid()

func getRandomRoom(x: float, y: float) :
  var w_sum: float = 0
  
  for i in DUNGEON_ROOMS :
    w_sum += i.get_room_weight(x, y)
  
  var r = randf_range(0, w_sum)
  
  for i in DUNGEON_ROOMS :
    if r <= i.get_room_weight(x, y) :
      return i.duplicate()
    
    r -= i.get_room_weight(x, y)
  
  return DUNGEON_ROOMS[0].duplicate()

func generateGrid() -> void:
  currentRoom = Vector2(int(GRID_SIZE_X/2.0), int(GRID_SIZE_Y/2.0))
  
  for i in get_tree().get_nodes_in_group("player") :
    i.global_position = Vector2.ZERO
  
  clearedRooms.clear()
  
  grid.clear()

  minimap.columns = GRID_SIZE_X
  minimap.add_theme_constant_override("h_separation", int(MINIMAP_CELL_SIZE/2.0))
  minimap.add_theme_constant_override("v_separation", int(MINIMAP_CELL_SIZE/2.0))
  
  for i in minimap.get_children() :
    i.queue_free()
  
  for y in range(GRID_SIZE_Y) :
    var row = []
    
    for x in range(GRID_SIZE_X) :
      var rect := ColorRect.new()
      
      rect.custom_minimum_size = Vector2(MINIMAP_CELL_SIZE, MINIMAP_CELL_SIZE)
      rect.color = HIDDEN
      
      posToRect[Vector2(x, y)] = rect
      
      minimap.add_child(rect)
      
      var icon := TextureRect.new()
      icon.custom_minimum_size = Vector2.ONE * MINIMAP_CELL_SIZE
      
      posToIcon[Vector2(x, y)] = icon
      
      rect.add_child(icon)
      
      row.append(0)
    
    grid.append(row)
  
  vCorridor.columns = GRID_SIZE_X
  vCorridor.add_theme_constant_override("h_separation", MINIMAP_CELL_SIZE)
  vCorridor.add_theme_constant_override("v_separation", MINIMAP_CELL_SIZE)
  %marginV.add_theme_constant_override("margin_top", MINIMAP_CELL_SIZE)
  %marginV.add_theme_constant_override("margin_right", (MINIMAP_CELL_SIZE - MINIMAP_CELL_SIZE/2.0)/2)
  
  for i in vCorridor.get_children() :
    i.queue_free()
    
  for y in range(GRID_SIZE_Y-1) :
    for x in range(GRID_SIZE_X) :
      var rect := ColorRect.new()
      rect.color = HIDDEN
      rect.custom_minimum_size = Vector2(MINIMAP_CELL_SIZE/2.0,MINIMAP_CELL_SIZE/2.0)
      vCorridor.add_child(rect)
      downCorridor[Vector2(x,y)] = rect
      upCorridor[Vector2(x,y+1)] = rect
  
  hCorridor.columns = GRID_SIZE_X-1
  hCorridor.add_theme_constant_override("h_separation", MINIMAP_CELL_SIZE)
  hCorridor.add_theme_constant_override("v_separation", MINIMAP_CELL_SIZE)
  %marginH.add_theme_constant_override("margin_top", (MINIMAP_CELL_SIZE - MINIMAP_CELL_SIZE/2.0)/2)
  %marginH.add_theme_constant_override("margin_right", MINIMAP_CELL_SIZE)
  
  for i in hCorridor.get_children() :
    i.queue_free()
  
  for y in range(GRID_SIZE_Y) :
    for x in range(GRID_SIZE_X-1) :
      var rect := ColorRect.new()
      rect.color = HIDDEN
      rect.custom_minimum_size = Vector2(MINIMAP_CELL_SIZE/2.0,MINIMAP_CELL_SIZE/2.0)
      hCorridor.add_child(rect)
      rightCorridor[Vector2(x,y)] = rect
      leftCorridor[Vector2(x+1,y)] = rect
  
  var frontier = [Vector2(int(GRID_SIZE_X/2.0), int(GRID_SIZE_Y/2.0))]
  
  var rooms = 0
  
  while len(frontier) > 0 :
    var f = frontier.pop_at(0)
    
    rooms += 1
    
    if rooms > MAX_ROOMS :
      continue

    var dirs = DIRECTION.values()
    dirs.shuffle()

    for i in randi_range(2, DIRECTIONS) :
      var d = dirs[i]
      
      if d == DIRECTION.UP and f.y > 0 and grid[f.y-1][f.x] == 0 :
        frontier.append(Vector2(f.x,f.y-1))
        grid[f.y][f.x] = grid[f.y][f.x] | d
        grid[f.y-1][f.x] = DIRECTION.DOWN
      elif d == DIRECTION.DOWN and f.y < GRID_SIZE_Y-1 and grid[f.y+1][f.x] == 0 :
        frontier.append(Vector2(f.x,f.y+1))
        grid[f.y][f.x] = grid[f.y][f.x] | d
        grid[f.y+1][f.x] = DIRECTION.UP
      elif d == DIRECTION.RIGHT and f.x < GRID_SIZE_X-1 and grid[f.y][f.x+1] == 0 :
        frontier.append(Vector2(f.x+1,f.y))
        grid[f.y][f.x] = grid[f.y][f.x] | d
        grid[f.y][f.x+1] = DIRECTION.LEFT
      elif d == DIRECTION.LEFT and f.x > 0 and grid[f.y][f.x-1] == 0 :
        frontier.append(Vector2(f.x-1,f.y))
        grid[f.y][f.x] = grid[f.y][f.x] | d
        grid[f.y][f.x-1] = DIRECTION.RIGHT
  
  var possible_room_positions: Array[Vector2] = []
  
  for y in range(GRID_SIZE_Y) :
    for x in range(GRID_SIZE_X) :
      if grid[y][x] > 0 :
        posToRect[Vector2(x, y)].color = HIDDEN
        possible_room_positions.push_back(Vector2(x,y))
  
  possible_room_positions.erase(currentRoom)
  posToRoom[currentRoom] = load("res://Dungeon Rooms/campfire_room.tres").duplicate()
  
  for i in DUNGEON_ROOMS :
    for _f in range(i.REQUIRED_AMT) :
      var pos = possible_room_positions.pick_random()
      possible_room_positions.erase(pos)
      
      posToRoom[pos] = i.duplicate()
  
  for i in possible_room_positions :
    var room = getRandomRoom(i.x, i.y)
    posToRoom[i] = room
  
  for i in posToRoom :
    posToRoom[i].place_features(self)
  
  clearedRooms.append(currentRoom)
  
  for i in posToRoom :
    if posToRoom[i].HIGHLIGHT_ON_MAP :
      posToRect[i].color = UNDISCOVERED
      posToIcon[i].texture = posToRoom[i].ROOM_ICON
  
  loadCurrentRoom()

var room_cleared = true

signal start_waves

var clearedRooms: Array[Vector2] = []

@onready var timer = $Timer

signal room_changed

func changeRoom(_body: Node2D, dir: Vector2) :
  if !room_cleared :
    return
  
  if !timer.is_stopped() :
    return
    
  if len(get_tree().get_nodes_in_group("boss")) > 0 :
    return
    
  room_changed.emit()
  
  clearedRooms.append(currentRoom)
  
  posToRoom[currentRoom].unload_features(self)
  posToRect[currentRoom].color = DISCOVERED
  
  if dir == Vector2(-1,0) :
    leftCorridor[currentRoom].color = DISCOVERED
  if dir == Vector2(1,0) :
    rightCorridor[currentRoom].color = DISCOVERED
  if dir == Vector2(0,-1) :
    upCorridor[currentRoom].color = DISCOVERED
  if dir == Vector2(0,1) :
    downCorridor[currentRoom].color = DISCOVERED
  
  currentRoom += dir
  
  # Remove all walls & exits from last room
  for i in get_tree().get_nodes_in_group("roompart") :
    i.queue_free()
    
  var room_size: float = ROOM_SIZE
  
  if !posToRoom[currentRoom].IS_HOSTILE and !posToRoom[currentRoom].NEEDS_BIG_ROOM :
    room_size = CALM_ROOM_SIZE
    
  # Load current room's walls & exits
  loadCurrentRoom()
  
  for i in get_tree().get_nodes_in_group("player") :
    i.global_position = -dir * room_size
  
  if !posToRoom[currentRoom].IS_HOSTILE :
    return
  
  for i in clearedRooms :
    if i.x == currentRoom.x and i.y == currentRoom.y :
      return
  
  room_cleared = false
  emit_signal("start_waves")

var dirToVec: Dictionary[DIRECTION, Vector2] = {
  DIRECTION.UP: Vector2(0, -1),
  DIRECTION.DOWN: Vector2(0, 1),
  DIRECTION.LEFT: Vector2(-1, 0),
  DIRECTION.RIGHT: Vector2(1, 0),
}

func revealRoomsAround() :
  posToRect[currentRoom].color = UNDISCOVERED
  
  
  for i in DIRECTION :
    if !grid[currentRoom.y][currentRoom.x] & DIRECTION[i] > 0 :
      continue
    
    var dir = dirToVec[DIRECTION[i]]
    
    posToIcon[currentRoom + dir].texture = posToRoom[currentRoom + dir].ROOM_ICON
    
    if posToRect[currentRoom + dir].color == HIDDEN :
      posToRect[currentRoom + dir].color = UNDISCOVERED
    
    if dir == Vector2(-1,0) and leftCorridor[currentRoom].color == HIDDEN :
      leftCorridor[currentRoom].color = UNDISCOVERED
    if dir == Vector2(1,0) and rightCorridor[currentRoom].color == HIDDEN :
      rightCorridor[currentRoom].color = UNDISCOVERED
    if dir == Vector2(0,-1) and upCorridor[currentRoom].color == HIDDEN :
      upCorridor[currentRoom].color = UNDISCOVERED
    if dir == Vector2(0,1) and downCorridor[currentRoom].color == HIDDEN :
      downCorridor[currentRoom].color = UNDISCOVERED

var doors: Array[AnimatedSprite2D] = []

func loadCurrentRoom() :
  revealRoomsAround()
  
  opened = false
  doors.clear()
  
  posToRoom[currentRoom].load_features(self)
  
  posToRect[currentRoom].color = ACTIVE
  
  posToIcon[currentRoom].texture = posToRoom[currentRoom].ROOM_ICON
  
  var x = currentRoom.x
  var y = currentRoom.y
  
  var room = grid[y][x] as int
  
  var wall_offsets = [
    Vector2(-1,0),
    Vector2(1,0),
    Vector2(0,-1),
    Vector2(0,1)
  ]
  
  var room_size: float = ROOM_SIZE
  
  if !posToRoom[currentRoom].IS_HOSTILE and !posToRoom[currentRoom].NEEDS_BIG_ROOM :
    room_size = CALM_ROOM_SIZE
  
  for o in wall_offsets :
    var staticbody := StaticBody2D.new()
    var s_shape := CollisionShape2D.new()
    
    s_shape.shape = WorldBoundaryShape2D.new()
    s_shape.rotation = (o as Vector2).angle()
    s_shape.rotation_degrees -= 90
    
    staticbody.add_child(s_shape)
    staticbody.global_position = o * room_size
    staticbody.collision_layer = 1
    staticbody.collision_mask = 0
    staticbody.add_to_group("roompart")
    
    add_child.call_deferred(staticbody)
    
    var wall := ColorRect.new()
    wall.size = Vector2.ONE * room_size * 3
    wall.global_position = o * room_size * 2.5 - wall.size / 2
    wall.color = Color8(69, 40, 60)
    wall.add_to_group("roompart")
    
    add_child.call_deferred(wall)
  
  var exit_offsets = [
    Vector2(-1,0) if room & DIRECTION.LEFT > 0 else Vector2.ZERO,
    Vector2(1,0) if room & DIRECTION.RIGHT > 0 else Vector2.ZERO,
    Vector2(0,-1) if room & DIRECTION.UP > 0 else Vector2.ZERO,
    Vector2(0,1) if room & DIRECTION.DOWN > 0 else Vector2.ZERO
  ]
  
  for o in exit_offsets :
    if o == Vector2.ZERO : continue
    
    var area := Area2D.new()
    var a_shape := CollisionShape2D.new()
    
    a_shape.shape = RectangleShape2D.new()
    (a_shape.shape as RectangleShape2D).size = Vector2(100, 100)
    
    area.add_child(a_shape)
    area.global_position = o * room_size
    area.collision_layer = 0
    area.collision_mask = 2
    area.connect("body_entered", changeRoom.bind(o))
    area.add_to_group("roompart")
    
    add_child.call_deferred(area)
    
    var spr : AnimatedSprite2D = $door.duplicate()
    spr.global_position = o * room_size
    spr.visible = true
    spr.play_backwards("open")
    spr.add_to_group("roompart")
    doors.append(spr)

    add_child.call_deferred(spr)
    
    var room_icon := Sprite2D.new()
    room_icon.texture = posToRoom[currentRoom + o].ROOM_ICON
    room_icon.scale = Vector2.ONE * 4
    room_icon.global_position = spr.global_position
    room_icon.global_position.y += 160
    room_icon.add_to_group("roompart")
    
    add_child.call_deferred(room_icon)
    
  timer.start()

@warning_ignore("unused_signal")
signal spawn_boss

func _on_wave_manager_room_clear() -> void:
  room_cleared = true

var boss_defeated = false
var opened = false

func _process(_delta: float) -> void:
  if room_cleared and !opened :
    for i in doors :
      i.play("open")
    opened = true
  
  if !boss_defeated :
    return
  
  if len(get_tree().get_nodes_in_group("xporb")) > 0 :
    return
    
  %xpManager.emitLevelUpSignal()
  clearedRooms.clear()
  generateGrid()
  boss_defeated = false
  
  var chest: Chest = %waveManager.wave_end_rewards.pick_random().instantiate()
  
  posToRoom[currentRoom].add_to_storage(chest)
  
  add_child.call_deferred(chest)

func _on_wave_manager_boss_defeated() -> void:
  boss_defeated = true
