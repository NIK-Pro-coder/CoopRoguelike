extends Item
class_name Spell

@export var COOLDOWN: float = 1.0
@export var MANA_COST: int = 10

var canCast: bool = true
var cooldownTimer: Timer

var powerMultiplier: float = 1

func get_closest_enemy(player: Player) -> Node2D :
  var enemy: Node2D
  var dist: float = -1
  
  for i in player.get_tree().get_nodes_in_group("enemy") :
    var d = (i as Node2D).global_position.distance_squared_to(player.global_position)
    
    if d < dist or dist < 0 :
      dist = d
      enemy = i
  
  return enemy

func get_closest_player(player: Player) -> Player :
  var p: Player = null
  var dist: float = -1
  
  for i in player.get_tree().get_nodes_in_group("player") :
    var d = (i as Node2D).global_position.distance_squared_to(player.global_position)
    
    if (p == null or p != player) and (d < dist or dist < 0) :
      dist = d
      p = i
  
  return p
  
func get_closest_ally(player: Player) -> Node2D :
  var ally: Node2D = null
  var dist: float = -1
  
  for i in player.get_tree().get_nodes_in_group("ally") :
    var d = (i as Node2D).global_position.distance_squared_to(player.global_position)
    
    if (ally == null or ally != player) and (d < dist or dist < 0) :
      dist = d
      ally = i
  
  return ally

@warning_ignore("unused_parameter")
func cast_action(player: Player) -> bool :
  print("Spell cast")
  return false

func cast(player: Player) :
  if !canCast :
    return
  
  if player.mana < MANA_COST :
    return
  
  powerMultiplier = 1 + player.stat_changes.SPELL_POWER
  var successfulCast = cast_action(player)
  
  if !successfulCast :
    return
  
  canCast = false
  cooldownTimer = Qol.create_timer(func() :
    canCast = true
  , COOLDOWN)
  
  player.mana -= MANA_COST
