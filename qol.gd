extends Node

var RARITY_COLORS: Dictionary[Item.Rarity, Color] = {
  Item.Rarity.COMMON: Color(1.0, 1.0, 1.0),
  Item.Rarity.UNCOMMON: Color(0.0, 0.78, 0.067),
  Item.Rarity.RARE: Color(0.0, 0.467, 1.0),
  Item.Rarity.EPIC: Color(0.765, 0.0, 1.0),
  Item.Rarity.MYTHIC: Color(1.0, 0.0, 0.0),
  Item.Rarity.LEGENDARY: Color(1.0, 0.851, 0.0),
}

func create_atk(enemy: bool = false) :
  var atk := AtkBuilder.new()
  
  return atk.create_atk(get_tree(), enemy)

func create_timer(timeout: Callable, time: float = 1) :
  var t := Timer.new()

  get_tree().get_root().add_child.call_deferred(t)
  
  t.wait_time = time
  t.one_shot = true
  t.autostart = true
  t.timeout.connect(func():
    if t.one_shot :
      t.queue_free()
    timeout.call()
  )
  
  return t

var strDisplayScene = preload("res://String Display/stringdisplay.tscn")

func display_string(pos: Vector2, text: String, time: float = 1.0) :
  var disp: StringDisplay = strDisplayScene.instantiate()
  disp.LIFETIME = time
  disp.STRING = text
  
  get_tree().get_root().add_child.call_deferred(disp)
  
  disp.global_position = pos
  
func findHpComp(from: Node) :
  if from is HealthComponent :
    return from
  
  for i in from.get_children() :
    var r = findHpComp(i)
    
    if r is HealthComponent :
      return r
  
  return null
  
func findEffectComp(from: Node) :
  if from is EffectComponent :
    return from
  
  for i in from.get_children() :
    var r = findEffectComp(i)
    
    if r is EffectComponent :
      return r
  
  return null

var teleScene = preload("res://Telegraphs/generic_telegraph.tscn")

func create_telegraph(size: Vector2, time: float = 1) :
  var t: GenericTelegraph = teleScene.instantiate()
  t.TELEGRAPH_TIME = time
  t.SHAPE_SIZE = size
  
  get_tree().get_root().add_child.call_deferred(t)
  
  return t
