extends Accessory

func wave_start(player: Player):
  player.healtcomponent.add_shield(int(player.healtcomponent.max_health*.25))
