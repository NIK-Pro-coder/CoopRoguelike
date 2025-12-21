extends Accessory

func update_passive(player: Player):
  if len(player.get_tree().get_nodes_in_group("enemy")) == 0 :
    return
  
  player.mana = min(player.mana+1, player.get_actual_stat("max_mana"))
