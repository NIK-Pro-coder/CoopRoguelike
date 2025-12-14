extends Accessory

var progress: float = 0

func update_passive(player: Player):
  if len(player.get_tree().get_nodes_in_group("enemy")) == 0 or player.healtcomponent.health >= player.healtcomponent.max_health :
    progress = 0
    player.HUD.honey = 0
    return
  
  progress += .01
  
  if progress >= 1 :
    progress = 0
    player.healtcomponent.healDmg(10)
    
  player.HUD.honey = progress

func on_hit_taken(_player: Player, _amt: int):
  progress = 0
