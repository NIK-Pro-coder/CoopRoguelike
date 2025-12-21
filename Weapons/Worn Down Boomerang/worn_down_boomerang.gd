extends Weapon

func move_boomerang(dmg: DamageArea, player: Player) :
  if dmg.global_position.distance_to(player.global_position) <= 100 :
    hasCooldown = false
    dmg.queue_free()
    return
  
  dmg.damage = int(damage * 1.5 * player.stat_changes.DAMAGE_PERCENT) + player.stat_changes.DAMAGE
  dmg.direction = (player.global_position - dmg.global_position).normalized() * 35
  dmg.knockback = -dmg.direction.normalized() * 150
  
  Qol.create_timer(move_boomerang.bind(dmg, player), .1)

func spawn_atk(player: Player, dir: Vector2) -> Array[DamageArea]:
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(75, 75)).add_animation(load("res://Weapons/Worn Down Boomerang/worn_down_boomerang_fly.tres")).instantiate()
  dmg.lifetime = -1
  dmg.global_position = player.global_position
  dmg.attacker = player
  dmg.direction = dir * 25
  dmg.knockback = dir * 150
  
  Qol.create_timer(move_boomerang.bind(dmg, player), .5)
  
  isAttacking = false
  
  return [dmg]
