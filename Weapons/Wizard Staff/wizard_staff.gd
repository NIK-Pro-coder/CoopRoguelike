extends Weapon

func change_stats(_player: Player, stats: StatTracker):
  stats.MAX_MANA_PERCENT += .25
  stats.MANA_GAIN_PERCENT += .1
  stats.SPELL_POWER += 1

func spawn_atk(player: Player, dir: Vector2):
  var tex := AtlasTexture.new()
  tex.atlas = load("res://Weapons/Rusty Sword/sword-slash.png")
  tex.region = Rect2(128, 0, 64, 32)
  
  var dmg: DamageArea = Qol.create_atk().set_rect_shape(Vector2(75, 200)).add_sprite(tex).instantiate()
  dmg.rotation = dir.angle()
  if combo < 2 :
    dmg.rotation_degrees += 90
  dmg.lifetime = .25
  dmg.global_position = player.global_position + dir * (150 if combo < 2 else 75)
  dmg.attacker = player
  dmg.knockback = dir.normalized() * (250 if combo < 2 else 500)
  
  stop_atk(.25)
  set_cooldown(.4)
  
  return [dmg]
