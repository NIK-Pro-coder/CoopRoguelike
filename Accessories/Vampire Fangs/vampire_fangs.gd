extends Accessory

func on_hit_dealt(player: Player, atk: DamageArea, _enemy: Enemy):
  player.healtcomponent.healDmg(floor(atk.damage * .1))
