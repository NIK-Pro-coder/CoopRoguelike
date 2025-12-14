extends Resource
class_name StatChange

@export var AFFECTED_STAT: StatTracker.Stats
@export var CHANGE: float = 0

var stack_level: int = 0

func apply(stats: StatTracker) :
  var string_stat: String = StatTracker.Stats.keys()[AFFECTED_STAT]
  stats[string_stat] += (CHANGE if !string_stat.ends_with("PERCENT") else CHANGE / 100) * stack_level
