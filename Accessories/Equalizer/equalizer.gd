extends Accessory

func on_hit_dealt(player: Player, atk: DamageArea, enemy: Enemy):
  if enemy.healthcomponent.health > player.healtcomponent.health :
    enemy.healthcomponent.dealDmg(atk.damage)
