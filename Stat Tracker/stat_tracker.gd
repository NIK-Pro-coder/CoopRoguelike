extends Resource
class_name StatTracker

enum Stats {
  DAMAGE,
  DAMAGE_PERCENT,
  DASH_COOLDOWN,
  DASH_COOLDOWN_PERCENT,
  DASH_DURATION,
  DASH_DURATION_PERCENT,
  DASH_SPEED,
  DASH_SPEED_PERCENT,
  KNOCKBACK,
  KNOCKBACK_PERCENT,
  MANA_GAIN,
  MANA_GAIN_PERCENT,
  MAX_MANA,
  MAX_MANA_PERCENT,
  MAX_HP,
  MAX_HP_PERCENT,
  POTION_COOLDOWN,
  POTION_COOLDOWN_PERCENT,
  POTION_HEALING,
  POTION_HEALING_PERCENT,
  SPEED,
  SPEED_PERCENT,
  POTION_AMOUNT,
  POTION_AMOUNT_PERCENT,
  DAMAGE_TAKEN,
  DAMAGE_TAKEN_PERCENT,
  SPELL_POWER,
}

@export var DAMAGE: int = 0
@export_range(0, 1, 0.01, "or_greater") var DAMAGE_PERCENT: float = 1

@export var DASH_COOLDOWN: int = 0
@export_range(0, 1, 0.01, "or_greater") var DASH_COOLDOWN_PERCENT: float = 1

@export var DASH_DURATION: int = 0
@export_range(0, 1, 0.01, "or_greater") var DASH_DURATION_PERCENT: float = 1

@export var DASH_SPEED: int = 0
@export_range(0, 1, 0.01, "or_greater") var DASH_SPEED_PERCENT: float = 1

@export var KNOCKBACK: int = 0
@export_range(0, 1, 0.01, "or_greater") var KNOCKBACK_PERCENT: float = 1

@export var MANA_GAIN: int = 0
@export_range(0, 1, 0.01, "or_greater") var MANA_GAIN_PERCENT: float = 1

@export var MAX_MANA: int = 0
@export_range(0, 1, 0.01, "or_greater") var MAX_MANA_PERCENT: float = 1

@export var MAX_HP: int = 0
@export_range(0, 1, 0.01, "or_greater") var MAX_HP_PERCENT: float = 1

@export var POTION_COOLDOWN: int = 0
@export_range(0, 1, 0.01, "or_greater") var POTION_COOLDOWN_PERCENT: float = 1

@export var POTION_HEALING: int = 0
@export_range(0, 1, 0.01, "or_greater") var POTION_HEALING_PERCENT: float = 1

@export var SPEED: int = 0
@export_range(0, 1, 0.01, "or_greater") var SPEED_PERCENT: float = 1

@export var POTION_AMOUNT: int = 0
@export_range(0, 1, 0.01, "or_greater") var POTION_AMOUNT_PERCENT: float = 1

@export var DAMAGE_TAKEN: int = 0
@export_range(0, 1, 0.01, "or_greater") var DAMAGE_TAKEN_PERCENT: float = 1

@export var SPELL_POWER: int = 0

func reset() :
  for i in Stats :
    self[i] = 1 if (i as String).ends_with("PERCENT") else 0
