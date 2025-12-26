extends Resource
class_name DungeonRoom

@export var ROOM_ICON: Texture2D
@export var ROOM_NAME: String

@export var IS_HOSTILE: bool = false
@export var NEEDS_BIG_ROOM: bool = false

@export var HIGHLIGHT_ON_MAP: bool = false

@export var ROOM_FEATURES: Array[RoomFeature]

## The weight of this room, if this is negative the room will never spawn
@export var ROOM_WEIGHT: float = 100

## The amount of this room that are needed for this dungeon, 0 means no rooms required, but more may be generated
@export var REQUIRED_AMT: int = 0

var noise: FastNoiseLite

var placed_features: Array[RoomFeature]
var feature_storage: Dictionary[int, Vector2] = {}

func get_room_size(dungeon: DungeonMngr) :
  return dungeon.ROOM_SIZE if IS_HOSTILE or NEEDS_BIG_ROOM else dungeon.CALM_ROOM_SIZE

func get_room_weight(_x: float, _y: float) -> float :
  return ROOM_WEIGHT

var decor_precision: int = 64
var decor_position_mult: float = 5
var decor_min_noise: float = .65

var loaded_room: bool = false

func place_features(dungeon: DungeonMngr) -> void :
  loaded_room = true
  
  var room_size = get_room_size(dungeon)
  
  noise = FastNoiseLite.new()
  noise.seed = randi()
  
  placed_features.clear()
  
  for i in ROOM_FEATURES :
    placed_features.push_back(i.duplicate(true))
    
    i.place_feature(dungeon, self)
  
  var tilemap := TileMapLayer.new()
  tilemap.tile_set = load("res://Dungeon Rooms/dungeon_tileset.tres")
  tilemap.scale = Vector2.ONE * 4
  tilemap.z_index = -100
  
  for y in range(-room_size, room_size, decor_precision) :
    for x in range(-room_size, room_size, decor_precision) :
      var n = noise.get_noise_2d(x, y)
      n = (n + 1) / 2.0
            
      @warning_ignore("integer_division")
      var cell_coords := Vector2i(x / 64, y / 64)
      
      tilemap.set_cell(cell_coords, 0, Vector2(0, 0))
  
      if n < decor_min_noise :
        continue
      
      tilemap.set_cell(cell_coords, 0, Vector2(randi_range(1, 3), 0))
  
  add_to_storage(tilemap)
  dungeon.get_tree().get_root().add_child.call_deferred(tilemap)
  
  unload_features(dungeon)

func clear_room() :
  for i in feature_storage :
    if !is_instance_valid(instance_from_id(i)) :
      continue
      
    instance_from_id(i).queue_free()

func add_to_storage(what: Node2D) :
  feature_storage[what.get_instance_id()] = what.global_position

func load_features(dungeon: DungeonMngr) -> void :
  if !loaded_room :
    place_features(dungeon)
  
  for i in feature_storage :
    if !is_instance_valid(instance_from_id(i)) :
      feature_storage.erase(i)
      continue
      
    (instance_from_id(i) as Node).process_mode = Node.PROCESS_MODE_INHERIT
    
    instance_from_id(i).global_position = feature_storage[i]

func unload_features(dungeon: DungeonMngr) -> void :
  for i in feature_storage :
    if !is_instance_valid(instance_from_id(i)) :
      feature_storage.erase(i)
      continue
    
    (instance_from_id(i) as Node).process_mode = Node.PROCESS_MODE_DISABLED
    
    feature_storage[i] = instance_from_id(i).global_position
    instance_from_id(i).global_position = -Vector2.ONE * dungeon.ROOM_SIZE * 5
