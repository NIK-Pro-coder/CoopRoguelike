extends Accessory

func on_kill(player: Player, _enemy: Enemy):
  player.healtcomponent.add_shield(int(player.healtcomponent.max_health*.05))
