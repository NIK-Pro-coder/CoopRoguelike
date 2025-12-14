extends Accessory

var shield_ready: bool = false
var shield_hp: float = 0

func on_hit_taken(player: Player, _dmg: int):
  if !shield_ready :
    shield_hp = 0
    return
  
  shield_hp -= .5
  
  if shield_hp <= 0 :
    shield_hp = 0
    shield_ready = false
    player.HUD.matrixready = false
    
  player.HUD.matrix = shield_hp

func change_stats(_player: Player, stats: StatTracker):
  if shield_ready :
    stats.DAMAGE_TAKEN_PERCENT -= 100

func update_passive(player: Player):
  if shield_ready :
    return
  
  shield_hp += 0.005
  
  if shield_hp >= 1 :
    shield_ready = true
    shield_hp = 1
    player.HUD.matrixready = true
  
  player.HUD.matrix = shield_hp
