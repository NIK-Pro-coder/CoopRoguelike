extends Weapon

var javelins: Array[DamageArea] = []
var moving: bool = false

func update_javelins(player: Player) :
  for i in javelins :
    i.direction = (player.global_position - i.global_position).normalized() * 35
    i.rotation = i.direction.angle()
    i.rotation_degrees += 90
    i.damage = damage * player.stat_changes.DAMAGE_PERCENT + player.stat_changes.DAMAGE
  
    if i.global_position.distance_to(player.global_position) <= 250 :
      i.queue_free()
      javelins.erase(i)
  
  if len(javelins) == 0 :
    moving = false
    return

  Qol.create_timer(update_javelins.bind(player), .1)

func on_unequip(_player: Player):
  for i in javelins :
    i.queue_free()
  javelins.clear()

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  if moving :
    isAttacking = false
    hasCooldown = false
    return []
  
  if len(javelins) >= 5 :
    moving = true
    
    isAttacking = false
    hasCooldown = false
    
    update_javelins(player)
    
    return []
  
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(75, 200)).add_sprite(load("res://Weapons/Javelin/javelin_thrown.png")).instantiate()
  dmg.rotation = dir.angle()
  dmg.rotation_degrees += 90
  dmg.lifetime = -1
  dmg.global_position = player.global_position + dir * 150
  dmg.attacker = player
  dmg.knockback = dir.normalized() * 200
  dmg.direction = dir * 35
  
  Qol.create_timer(func() :
    dmg.direction = Vector2.ZERO
    dmg.damage = 0
    dmg.knockback = Vector2.ZERO
  , .5)
  
  stop_atk(.25)
  set_cooldown(.4)
  
  javelins.append(dmg)
  
  return [dmg]
