extends Accessory

func change_stats(_player: Player, stats: StatTracker):
  stats.DAMAGE_TAKEN_PERCENT -= 0.17
