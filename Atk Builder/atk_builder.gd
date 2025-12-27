extends Node
class_name AtkBuilder

var enemyDamageScene = preload("res://DamageAreas/enemy_damage_area.tscn")
var playerDamageArea = preload("res://DamageAreas/player_damage_area.tscn")

var tree: SceneTree
var area: DamageArea

func create_atk(scene_tree: SceneTree, enemy: bool = false) -> AtkBuilder :
  tree = scene_tree
  
  if enemy :
    area = enemyDamageScene.instantiate()
  else :
    area = playerDamageArea.instantiate()

  return self

func set_shape(shape: CollisionShape2D) -> AtkBuilder :
  area.add_child(shape)
  
  return self

func set_rect_shape(size: Vector2) -> AtkBuilder :
  var shape := CollisionShape2D.new()
  shape.shape = RectangleShape2D.new()
  size.x = abs(size.x)
  size.y = abs(size.y)
  (shape.shape as RectangleShape2D).size = size
  
  return set_shape(shape)

func add_sprite(tex: Texture2D, scaling: float = 4) -> AtkBuilder :
  var spr := Sprite2D.new()
  spr.texture = tex
  spr.scale = Vector2.ONE * scaling
  
  area.add_child(spr)
  
  return self

func add_animation(anim: SpriteFrames, scaling: float = 4) -> AtkBuilder :
  var spr := AnimatedSprite2D.new()
  spr.sprite_frames = anim
  spr.scale = Vector2.ONE * scaling
  spr.autoplay = "default"
  
  area.add_child(spr)
  
  return self

func instantiate() -> DamageArea :
  tree.get_root().add_child.call_deferred(area)
  
  return area
