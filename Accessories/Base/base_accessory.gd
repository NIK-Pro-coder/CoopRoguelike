extends Resource
class_name Accessory

var NAME: String
var DESC: String
var ICON: Texture2D
var QUOTE: String

@export var ANIMATIONS: SpriteFrames

@export var PASSIVE_UPDATE_TIME: float = 1

func update_passive(_player: Player) :
  pass

func on_heal(_player: Player) :
  pass

func ally_take_hit(_player: Player, _ally: Player, _dmg: int) :
  # TODO: Implement this
  print("Ally take hit")
  
func on_dash(_player: Player) :
  pass
  
func on_hit_dealt(_player: Player, _atk: DamageArea, _enemy: Enemy) :
  pass

func on_kill(_player: Player, _enemy: Enemy) :
  pass

func wave_start(_player: Player) :
  pass

func on_atk(_player: Player, _atk: DamageArea) :
  pass

func change_stats(_player: Player, _stats: StatTracker) :
  pass

func on_hit_taken(_player: Player, _dmg: int) :
  pass
