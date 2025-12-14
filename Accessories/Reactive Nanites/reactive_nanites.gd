extends Accessory

var dmg_to_heal = 0
var heal_progress = 0

func update_passive(player: Player):
  if dmg_to_heal <= 0 :
    return
    
  heal_progress += .02
  
  if heal_progress >= 1 :
    player.healtcomponent.healDmg(dmg_to_heal)
    heal_progress = 0
    dmg_to_heal = 0

func on_hit_taken(_player: Player, dmg: int):
  if dmg_to_heal > 0 :
    dmg_to_heal = 0
    return
  
  dmg_to_heal = int(dmg / 2.0)
  heal_progress = 0
