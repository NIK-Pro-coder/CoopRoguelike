extends Accessory

var dodge_chance: int = 0
var dodge_next_hit: bool = false

func change_stats(_player: Player, stats: StatTracker):
  if dodge_next_hit :
    stats.DAMAGE_TAKEN_PERCENT -= 100

func on_hit_taken(_player: Player, _dmg: int):
  dodge_chance += 10
  
  if randi_range(0, 100) <= dodge_chance :
    dodge_next_hit = true
    dodge_chance = 0
  else :
    dodge_next_hit = false
