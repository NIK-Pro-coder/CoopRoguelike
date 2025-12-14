extends Accessory

func update_passive(player: Player):
  player.mana = min(player.mana+1, player.get_actual_stat("max_mana"))
