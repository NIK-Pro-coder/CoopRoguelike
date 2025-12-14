extends Node2D

class_name MainCamera

@export var SAFE_PADDING = 300

@export var ZOOM_MIN = .5
@export var ZOOM_MAX = .2

@export var SCREENSHAKE_MULT: float = 2

var screenshake = Vector2.ZERO

func addScreenshake(intensity: float) :
  var vect = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
  
  screenshake += vect * intensity * SCREENSHAKE_MULT

@onready var camera = $Camera2D
@onready var lobby: LobbyManager = %lobby

var locked: bool = false
var lock_zoom: float = .5
var lock_pos: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
  
  var players = get_tree().get_nodes_in_group("player")
  
  var goto = Vector2.ZERO
  
  if locked :
    goto = lock_pos
  else :
    for i in players :
      goto += i.global_position / len(players)
  
  global_position.x = global_position.x + (goto.x - global_position.x) * .25
  global_position.y = global_position.y + (goto.y - global_position.y) * .25
  
  camera.position = screenshake
  
  screenshake *= -.75
  
  var desired_zoom = 1
    
  if locked :
    desired_zoom = lock_zoom
  else :
    var w = get_viewport_rect().size.x
    var h = get_viewport_rect().size.y

    for i in players :
      var diff = ((i as Player).global_position - goto)
      var onscreenx = abs(diff.x) < w/2 - SAFE_PADDING 
      var onscreeny = abs(diff.y) < h/2 - SAFE_PADDING

      if not onscreenx :
        # abs(diff.x) < w/2 - SAFE_PADDING  Solve for w
        # abs(diff.x) + SAFE_PADDING >= w/2
        # (abs(diff.x) + SAFE_PADDING) * 2 >= w
        # w = (abs(diff.x) + SAFE_PADDING) * 2
        
        desired_zoom = min(
          desired_zoom,
          (w / ((abs(diff.x) + SAFE_PADDING) * 2))
        )
      if not onscreeny :
        desired_zoom = min(
          desired_zoom,
          (h / ((abs(diff.y) + SAFE_PADDING) * 2))
        )
    
    desired_zoom = clamp(desired_zoom, ZOOM_MAX, ZOOM_MIN)
    
  camera.zoom = Vector2.ONE * desired_zoom
