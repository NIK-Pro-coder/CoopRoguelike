extends Weapon

func change_stats(_player: Player, stats: StatTracker):
  if isCharging :
    stats.SPEED_PERCENT -= .25 + .25 * get_charge_progress()

var activations: int = 0

func on_charge(player: Player):
  activations += 1
  
  var possible_targets: Array[Node2D] = []
  
  possible_targets.append_array(player.get_tree().get_nodes_in_group("enemy"))
  possible_targets.append_array(player.get_tree().get_nodes_in_group("ally").filter(func(x):
    if x is Player :
      return x.healtcomponent.health < x.healtcomponent.max_health
    
    return (x as PlayerSummon).healthcomponent.health < (x as PlayerSummon).healthcomponent.max_health
  ))
  possible_targets.erase(player)
  
  possible_targets.sort_custom(func(a: Node2D, b: Node2D): 
    return a.global_position.distance_squared_to(player.global_position) < b.global_position.distance_squared_to(player.global_position)
  )
  
  possible_targets = possible_targets.filter(func(x: Node2D) :
    return (x.global_position - player.global_position).normalized().dot(player.lastMoveDir) >= .8
  )
  
  possible_targets = possible_targets.filter(func(x: Node2D) :
    return player.global_position.distance_to(x.global_position) <= 670
  )
  
  if len(possible_targets) < 1 :
    return
  
  var target = possible_targets[0]
  
  for i in possible_targets :
    if i is Player or i is PlayerSummon :
      target = i
      break
  
  var pos = player.global_position + player.lastMoveDir.normalized() * 50
  var vel = player.lastMoveDir.normalized() * 5

  var hp: HealthComponent = Qol.findHpComp(target)
  
  if not hp :
    return
  
  var line: Array[Vector2] = []
  
  while pos.distance_to(target.global_position) >= 50 :
    vel *= .75;
    vel += (target.global_position - pos).normalized() * 2 + Vector2.from_angle(randf_range(0, PI * 2.0)) * 2
    pos += vel
    
    line.append(pos)
  line.append(target.global_position)
  
  var l := Line2D.new()
  l.points = line
  l.default_color = Color(1, 0, 0) if target is Enemy or target is Boss else Color(0, 1, 0)
  l.default_color.a = get_charge_progress() / 2 + .5
  if get_charge_progress() >= 1 :
    l.default_color = l.default_color * .75 + Color.WHITE * .25
  l.width = 5
  
  player.get_tree().get_root().add_child.call_deferred(l)
  Qol.create_timer(l.queue_free, .2)
  
  if activations % 5 != 0 :
    return
  
  var effect_strength: int = max(1, damage * get_charge_progress())
  
  if target is Enemy or target is Boss :
    hp.dealDmg(max(1, effect_strength / 2.0))
  else :
    hp.healDmg(effect_strength)
