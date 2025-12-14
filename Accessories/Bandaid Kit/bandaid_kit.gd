extends Accessory

@export var HEAL_RADIUS: float = 500

func on_heal(player: Player):
  var players = player.get_tree().get_nodes_in_group("player")
  
  for i in players :
    var dst = i.global_position.distance_squared_to(player.global_position)
    
    if i != player and dst <= HEAL_RADIUS * HEAL_RADIUS :
      i.healtcomponent.healDmg(ceil(player.get_actual_stat("potion_healing")))
