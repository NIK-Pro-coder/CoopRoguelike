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

var decor_precision: int = 256

func place_features(dungeon: DungeonMngr) -> void :
  var room_size = get_room_size(dungeon)
  
  noise = FastNoiseLite.new()
  noise.seed = randi()
  
  placed_features.clear()
  
  for i in ROOM_FEATURES :
    placed_features.push_back(i.duplicate(true))
    
    i.place_feature(dungeon, self)
  
  for y in range(-room_size, room_size, decor_precision) :
    for x in range(-room_size, room_size, decor_precision) :
      if randf() <= .5 * (noise.get_noise_2d(x / float(decor_precision), y / float(decor_precision))) :
        continue
      
      var decor: Sprite2D = Sprite2D.new()
      var tex: AtlasTexture = AtlasTexture.new()
      tex.atlas = load("res://Dungeon Manager/floor-decor.png")
      tex.region.size = Vector2(16, 16)
      tex.region.position = Vector2(randi_range(0, int(tex.atlas.get_size().x/16)-1)*16, 0)
      
      decor.texture = tex
      decor.scale = Vector2.ONE * 4
      decor.global_position = Vector2(x,y) + Vector2.from_angle(deg_to_rad(randi_range(-180, 180))) * randi_range(0, 250)
      decor.z_index = -100
      add_to_storage(decor)
      
      dungeon.get_tree().get_root().add_child.call_deferred(decor)
  
  unload_features(dungeon)

func add_to_storage(what: Node2D) :
  feature_storage[what.get_instance_id()] = what.global_position

func load_features(_dungeon: DungeonMngr) -> void :
  for i in feature_storage :
    if !is_instance_valid(instance_from_id(i)) :
      feature_storage.erase(i)
      continue
    
    instance_from_id(i).global_position = feature_storage[i]

func unload_features(dungeon: DungeonMngr) -> void :
  for i in feature_storage :
    if !is_instance_valid(instance_from_id(i)) :
      feature_storage.erase(i)
      continue
    
    feature_storage[i] = instance_from_id(i).global_position
    instance_from_id(i).global_position = -Vector2.ONE * dungeon.ROOM_SIZE * 5
