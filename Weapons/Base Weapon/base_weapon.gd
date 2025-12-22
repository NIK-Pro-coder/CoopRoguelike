extends Item
class_name Weapon

enum WeaponClasses {
  MELEE = 0,
  RANGED = 1,
  SUMMON = 2,
  SUPPORT = 3,
}

var isAttacking: bool = false
var hasCooldown: bool = false
var isCharging = false
var canSwap: bool = true

var chargeTimer: Timer

@export var damage: int = 0
@export var weapon_class: WeaponClasses = WeaponClasses.MELEE

@export var combo_length: int = -1

@export var can_charge: bool = false
@export var charge_time: float = 1.0

@warning_ignore("unused_parameter")
func change_stats(player: Player, stats: StatTracker) :
  pass

func stop_atk(time: float) :
  Qol.create_timer(func():
    isAttacking = false
  , time)

func set_cooldown(time: float) :
  Qol.create_timer(func():
    hasCooldown = false
  , time)

@warning_ignore("unused_parameter")
func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea] :
  isAttacking = false
  hasCooldown = false
  
  return []

var combo: int = 0
var damage_mult: float = 1.0

func attack_stop(player: Player, dir: Vector2) :
  if !can_charge :
    return
  
  finish_atk(player, dir)
  
  isCharging = false

func get_charge_progress() :
  if !can_charge :
    return 0
  
  if !isCharging :
    return 0
  
  var charge_progress = 1.0
  if is_instance_valid(chargeTimer) :
    charge_progress = 1.0 - chargeTimer.time_left / chargeTimer.wait_time
  
  return charge_progress

@warning_ignore("unused_parameter")
func on_charge(player: Player) :
  pass

func update_charge(player: Player) :
  on_charge(player)
  
  if !isCharging :
    return
  
  Qol.create_timer(update_charge.bind(player), .1)

func attack(player: Player, dir: Vector2) :
  if can_charge :
    if len(player.get_tree().get_nodes_in_group("enemy")) <= 0 :
      isCharging = false
      if chargeTimer :
        chargeTimer.queue_free()
        chargeTimer = null
    elif !isCharging :
      isCharging = true
      chargeTimer = Qol.create_timer(func(): pass, charge_time)
      Qol.create_timer(update_charge.bind(player), .1)
    
    return
  
  if hasCooldown :
    return
  
  finish_atk(player, dir)

func finish_atk(player: Player, dir: Vector2) :
  isAttacking = true
  hasCooldown = true
  
  var areas: Array = spawn_atk(player, dir)
  for i in areas :
    i.damage = max(1, damage * damage_mult)
    i.attacker = player
  
  if combo_length <= 0 :
    combo = 0
  else :
    combo = (combo + 1) % combo_length

@warning_ignore("unused_parameter")
func on_equip(player: Player) :
  pass

@warning_ignore("unused_parameter")
func on_unequip(player: Player) :
  pass
