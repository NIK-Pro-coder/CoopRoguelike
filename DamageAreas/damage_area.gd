extends Area2D
class_name DamageArea

@export var damage = 5
@export var lifetime: float = .2
@export var knockback: Vector2 = Vector2.ZERO
@export var direction: Vector2 = Vector2.ZERO

@export var iframe_group: String = ""
@export var iframe_amount: float = .5

@export var apply_effects: Array[Potion]

@export var piercing: int = -1
var pierced = 0

var friendly_fire: bool = false

@onready var lifetimeTimer: Timer = $lifetimeTimer

var attacker: Node2D
var powers: Array[Power] = []
var enchants: Array[Glyph] = []

func recursiveHealthComponentSearch(startnode: Node) :
  if startnode is HealthComponent :
    return startnode
  
  for i in startnode.get_children() :
    var node = recursiveHealthComponentSearch(i)
    
    if node is HealthComponent :
      return node
  
  return null

signal on_hit(body: Node2D)

func dealDamageToBody(body: Node2D) :
  if body == attacker :
    return
  
  var healthcomponent: HealthComponent = recursiveHealthComponentSearch(body)
  
  if not healthcomponent :
    return
  
  var i_group = iframe_group if iframe_group != "" else str(get_instance_id())
  
  if healthcomponent.has_iframes(i_group) :
    return
  
  pierced += 1
    
  var effect: EffectComponent = Qol.findEffectComp(body)
  if effect :
    for i in apply_effects :
      effect.add_potion(i)
  
  if is_instance_valid(attacker) and attacker is Player :
    (attacker as Player).damageDone += damage
    
  healthcomponent.add_iframes(i_group, iframe_amount)
  
  if "knockback" in body and healthcomponent.shield <= 0 :
    body.knockback += knockback * (body.knockback_mult if "knockback_mult" in body else 1)
  
  healthcomponent.dealDmg(damage)
  
  on_hit.emit(body)
  
  if is_instance_valid(attacker) and attacker is Player :
    (attacker as Player).potion_charge_progress += damage
    
    for i in attacker.accessories :
      if !i or !body is Enemy :
        continue
      
      (i as Accessory).on_hit_dealt(attacker, self, body)
      if healthcomponent.health <= 0 :
        (i as Accessory).on_kill(attacker, body)

func _ready() -> void:
  if attacker is Player :
    damage *= attacker.get_actual_stat("damage")
    knockback *= attacker.get_actual_stat("knockback")
  
  if friendly_fire :
    collision_layer = 24
    collision_mask = 6
  
  if lifetime > 0 :
    lifetimeTimer.start(lifetime)
  
  if monitoring :
    for i in get_overlapping_bodies() :
      dealDamageToBody(i)

var overlappingEnemies: Array[Node2D] = []

func onDeath(enemy: Node2D, health: HealthComponent) :
  if is_instance_valid(attacker) and attacker is Player :
    if enemy is Boss :
      (attacker as Player).bossKills += 1
    elif enemy is Enemy :
      (attacker as Player).enemyKills += 1
  
  health.death.disconnect(onDeath.bind(enemy, health))

func _on_body_entered(body: Node2D) -> void:
  var health: HealthComponent = recursiveHealthComponentSearch(body)
  health.connect("death", onDeath.bind(body, health))

func _on_body_exited(body: Node2D) -> void:
  var health: HealthComponent = recursiveHealthComponentSearch(body)
  if health.death.is_connected(onDeath.bind(body, health)) :
    health.death.disconnect(onDeath.bind(body, health))

func _on_lifetime_timer_timeout() -> void:
  queue_free()

func _physics_process(_delta: float) -> void:
  global_position += direction
  
  if monitoring :
    for body in get_overlapping_bodies() :
      dealDamageToBody(body)

      if piercing >= 0 and pierced > piercing :
        queue_free()
        break
