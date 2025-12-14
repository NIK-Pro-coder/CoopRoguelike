extends Accessory

func on_atk(player: Player, atk: DamageArea):
  atk.damage *= 2 - (float(player.healtcomponent.health)/float(player.healtcomponent.max_health))
