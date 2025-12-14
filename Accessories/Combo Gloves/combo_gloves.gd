extends Accessory

var damage_bonuses: Dictionary[Enemy, float] = {}

func on_hit_dealt(_player: Player, atk: DamageArea, enemy: Enemy):
  if enemy in damage_bonuses :
    damage_bonuses[enemy] += 0.1
  else :
    damage_bonuses[enemy] = 0
  
  enemy.healthcomponent.dealDmg(int(atk.damage * damage_bonuses[enemy]))
