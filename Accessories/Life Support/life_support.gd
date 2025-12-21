extends Accessory

func update_passive(player: Player):
  if player.healtcomponent.health <= player.healtcomponent.max_health / 2.0 :
    return
  
  var players = player.get_tree().get_nodes_in_group("player")
  
  var closest: Player = null
  var min_dist = -1
  
  for i in players :
    var dst = i.global_position.distance_squared_to(player.global_position)
    
    var can_heal = true
    for k in (i as Player).accessories :
      if k and k.get_script() == load("res://Accessories/Life Support/life_support.gd") :
        can_heal = false
        break

    if !can_heal :
      continue
    
    if i != player and (i as Player).healtcomponent.health > 0 and (dst < min_dist or min_dist < 0) and (i as Player).healtcomponent.health < (i as Player).healtcomponent.max_health :
      min_dist = dst
      closest = i

  if closest :
    player.healtcomponent.dealDmg(1)
    closest.healtcomponent.healDmg(2)
