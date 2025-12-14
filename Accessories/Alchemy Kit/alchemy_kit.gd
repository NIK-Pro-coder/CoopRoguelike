extends Accessory

func change_stats(_player: Player, stats: StatTracker):
  stats.POTION_AMOUNT += 1
  stats.POTION_HEALING_PERCENT -= 0.15
