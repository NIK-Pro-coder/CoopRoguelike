extends Item
class_name Weapon

var isAttacking: bool = false
var hasCooldown: bool = false

@export var damage: int = 0
@export var combo_length: int = -1

func stop_atk(time: float) :
  Qol.create_timer(func():
    isAttacking = false
  , time)

func set_cooldown(time: float) :
  Qol.create_timer(func():
    hasCooldown = false
  , time)

func spawn_atk(_player: Player, _dir: Vector2) -> Array[DamageArea] :
  return []

var combo: int = 0

func attack(player: Player, dir: Vector2) :
  if hasCooldown :
    return
  
  isAttacking = true
  hasCooldown = true
  
  var areas: Array = spawn_atk(player, dir)
  for i in areas :
    i.damage = damage
  
  if combo_length <= 0 :
    combo = 0
  else :
    combo = (combo + 1) % combo_length
