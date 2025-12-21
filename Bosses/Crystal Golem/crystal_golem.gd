extends Boss

func _ready() -> void:
  super._ready()
  
  PHASE_PATTERNS = {
    0: [
      ["charge", "charge", "slam", "slam"],
      ["jump", "charge", "jump"],
      ["shockwave", "charge", "shockwave", "slam"],
      ["slam", "jump", "slam", "slam"]
    ],
    1: [
      ["rock_slide", "dig", "rock_slide"],
      ["dig", "rock_arena", "dig"],
      ["rock_arena", "rock_slide", "dig"]
    ],
    -1: [
      ["spikes", "rock_walls", "sans", "explosion"]
    ]
  }

var slam_num = 0
func slam() :
  if slam_num == 3 :
    attacking = false
    slam_num = 0
    return
    
  slam_num += 1
    
  var p: Player = get_closest_player()
  
  var telegraph: GenericTelegraph = telegraphScene.instantiate()
  telegraph.SHAPE_SIZE = Vector2(750, 750)
  telegraph.TELEGRAPH_TIME = .8
  telegraph.rotation = global_position.angle_to_point(p.global_position)
  
  if slam_num == 3 :
    telegraph.SHAPE_SIZE = Vector2(500, 1250)
    telegraph.TELEGRAPH_TIME = .65
    Icon.play("slam_left_raise")
  else :
    Icon.play("slam_right_raise")
  
  telegraph.global_position = global_position + (p.global_position - global_position).normalized() * min(1000, global_position.distance_to(p.global_position))
  
  get_tree().get_root().add_child.call_deferred(telegraph)
  
  telegraph.telegraph_finished.connect(func() :
    cam.addScreenshake(10)
    
    var a: DamageArea = get_square_damage_area(telegraph.SHAPE_SIZE)
    a.damage = 30
    a.global_position = telegraph.global_position
    a.rotation = telegraph.rotation
    
    var spr := Sprite2D.new()
    spr.texture = load("res://Bosses/Crystal Golem/Sprites/slam_sprite.png")
    spr.scale = Vector2.ONE * 4
    
    a.add_child(spr)
    
    spr.global_rotation = 0
    spr.y_sort_enabled = true
    
    get_tree().get_root().add_child.call_deferred(a)
    
    telegraph.queue_free()
    
    velocity = (get_closest_player().global_position - global_position).normalized() * 7000

    var t := Timer.new()
    add_child(t)
    
    t.timeout.connect(slam)
    t.timeout.connect(t.queue_free)
    t.one_shot = true
    
    t.start(.75)
    
    Icon.play("idle")
  )

var charge_dir: Vector2
var charge_area: DamageArea

func charge() :
  var p: Player = get_closest_player()
  
  var telegraph: GenericTelegraph = telegraphScene.instantiate()
  telegraph.SHAPE_SIZE = Vector2(5000, 1500)
  telegraph.TELEGRAPH_TIME = 1.5
  telegraph.global_position = global_position + (p.global_position - global_position).normalized() * telegraph.SHAPE_SIZE.x / 2
  telegraph.rotation = global_position.angle_to_point(p.global_position)

  get_tree().get_root().add_child.call_deferred(telegraph)
  
  telegraph.telegraph_finished.connect(func() :
    charge_dir = (telegraph.global_position - global_position).normalized()
    if charge_dir == Vector2.ZERO :
      charge_dir = Vector2.RIGHT
    telegraph.queue_free()
  )

func shockwave() :
  var p: Player = get_closest_player()
  
  var t := Timer.new()
  add_child(t)
  
  t.timeout.connect(func() :
    t.queue_free()
    attacking = false
  )
  t.one_shot = true
  
  t.start(3.5)
  
  for i in range(0, 5000, 250) :
    var pos = global_position + (p.global_position - global_position).normalized() * i

    var telegraph: GenericTelegraph = telegraphScene.instantiate()
    telegraph.SHAPE_SIZE = Vector2(500, 500)
    telegraph.TELEGRAPH_TIME = .25 + i / 1000.0
    telegraph.global_position = pos
    
    get_tree().get_root().add_child.call_deferred(telegraph)
    
    telegraph.telegraph_finished.connect(func() :
      cam.addScreenshake(5)
      
      telegraph.queue_free()
      var area: DamageArea = get_square_damage_area(telegraph.SHAPE_SIZE)
      area.global_position = telegraph.global_position
      area.damage = 30
      area.lifetime = 1
      area.iframe_group = "boss_shockwave"
        
      var spr := Sprite2D.new()
      spr.texture = load("res://Bosses/Crystal Golem/Sprites/charge_rock.png")
      spr.scale = Vector2.ONE * 4
      
      area.add_child(spr)
      
      spr.global_rotation = 0
      spr.y_sort_enabled = true
      
      get_tree().get_root().add_child.call_deferred(area)
    )

func jump() :
  visible = false
  HpComp.invincible = true
  
  var p: Player = get_tree().get_nodes_in_group("player").pick_random()
  
  var telegraph: GenericTelegraph = telegraphScene.instantiate()
  telegraph.SHAPE_SIZE = Vector2(1024, 1024)
  telegraph.TELEGRAPH_TIME = 2.5
  telegraph.global_position = p.global_position
  
  get_tree().get_root().add_child.call_deferred(telegraph)
  
  telegraph.telegraph_finished.connect(func() :
    cam.addScreenshake(25)
    
    telegraph.queue_free()
    
    global_position = telegraph.global_position
    visible = true
    HpComp.invincible = false
    
    for i in range(90) :
      for n in range(25) :
        var t_n := Timer.new()
        add_child(t_n)
        
        t_n.timeout.connect(func() :
          t_n.queue_free()
      
          var area: DamageArea = get_square_damage_area(Vector2(250, 250))
          
          area.rotation_degrees = i * 4
          area.global_position = global_position + Vector2.ONE.rotated(area.rotation + deg_to_rad(45)) * 200 * n
          area.damage = 25
          area.lifetime = .5
          area.iframe_group = "boss_land_shockwave"
        
          var spr := Sprite2D.new()
          spr.texture = load("res://Bosses/Crystal Golem/Sprites/jump_rocks.png")
          spr.scale = Vector2.ONE * 4
          
          area.add_child(spr)
          
          spr.global_rotation = 0
          spr.y_sort_enabled = true
          
          get_tree().get_root().add_child.call_deferred(area)
        )
        t_n.one_shot = true
        
        t_n.start(n*.3)
      
    var t := Timer.new()
    add_child(t)
    
    t.timeout.connect(func() :
      t.queue_free()
      attacking = false
    )
    t.one_shot = true
    
    t.start(5)
  )
  
func spawn_sliding_rock() :
  var pos = Vector2(
    randi_range(-2500, 2500),
    randi_range(-2500, 2500),
  )
  
  var telegraph: GenericTelegraph = telegraphScene.instantiate()
  telegraph.global_position = pos
  telegraph.SHAPE_SIZE = Vector2(150, 150)
  telegraph.TELEGRAPH_TIME = 1.5
  
  get_tree().get_root().add_child.call_deferred(telegraph)
  
  telegraph.telegraph_finished.connect(func() :
    cam.addScreenshake(10)
    
    telegraph.queue_free()
    
    var area: DamageArea = get_square_damage_area(telegraph.SHAPE_SIZE)
    area.global_position = telegraph.global_position
    area.damage = 30
    area.lifetime = 10
    area.iframe_group = "bossassi"
    
    var spr := Sprite2D.new()
    spr.texture = load("res://Bosses/Crystal Golem/Sprites/sliding_rock.png")
    spr.scale = Vector2.ONE * 4
    
    area.add_child(spr)
    
    spr.global_rotation = 0
    spr.y_sort_enabled = true
    
    var tn := Timer.new()
    add_child(tn)
    
    tn.timeout.connect(func() :
      var p: Player = get_closest_player()
      var dir: Vector2 = (p.global_position - area.global_position).normalized() * 50
      
      var tele_new: GenericTelegraph = telegraphScene.instantiate()
      tele_new.SHAPE_SIZE = Vector2(5000, 100)
      tele_new.TELEGRAPH_TIME = 1
      tele_new.global_position = area.global_position + (p.global_position - area.global_position).normalized() * tele_new.SHAPE_SIZE.x / 2
      tele_new.rotation = area.global_position.angle_to_point(p.global_position)

      get_tree().get_root().add_child.call_deferred(tele_new)
      
      tele_new.telegraph_finished.connect(func() :
        area.direction = dir
        tele_new.queue_free()
      )
    )
    tn.one_shot = true
    
    tn.start(1)
    
    get_tree().get_root().add_child.call_deferred(area)
  )
  

var walk_around: bool = false

func rock_slide() :
  var t_stop := Timer.new()
  t_stop.one_shot = true
  walk_around = true
  
  add_child(t_stop)
  
  t_stop.start(18)
  
  t_stop.timeout.connect(func() :
    t_stop.queue_free()
    attacking = false
    walk_around = false
  )
  
  for i in range(30) :
    var t := Timer.new()
    t.one_shot = true
    
    add_child(t)
    
    t.start(.5 + i * .5)
    
    t.timeout.connect(func() :
      t.queue_free()
      spawn_sliding_rock()
    )
    
var rock_shots: int = 0

func rock_arena() :
  walk_around = true
  
  if rock_shots >= 5 :
    rock_shots = 0
    attacking = false
    walk_around = false
    return
  
  rock_shots += 1
  
  var go_vertical = randf() >= .5
  
  for i in range(15) :
    var pos := Vector2(0, randi_range(-2500, 2500)) if !go_vertical else Vector2(randi_range(-2500, 2500), 0)
    
    var telegraph: GenericTelegraph = telegraphScene.instantiate()
    telegraph.global_position = pos
    telegraph.SHAPE_SIZE = Vector2(8000, 150) if !go_vertical else Vector2(150, 8000)
    telegraph.TELEGRAPH_TIME = 1
    
    get_tree().get_root().add_child.call_deferred(telegraph)
    
    telegraph.telegraph_finished.connect(func() :
      var a: DamageArea = get_square_damage_area(Vector2(150, 150))
      
      a.damage = 20
      a.global_position = telegraph.global_position
      var dir = randi_range(0, 1) * 2 - 1
      if go_vertical :
        a.global_position.y = (-3000 + randi_range(-500, 500)) * dir
        a.direction.y = 150 * dir
      else :
        a.global_position.x = (-3000 + randi_range(-500, 500)) * dir
        a.direction.x = 150 * dir
      a.lifetime = 5
      a.iframe_group = "boss_rock_arena"
    
      var spr := Sprite2D.new()
      spr.texture = load("res://Bosses/Crystal Golem/Sprites/sliding_rock.png")
      spr.scale = Vector2.ONE * 4
      
      a.add_child(spr)
      
      spr.global_rotation = 0
      spr.y_sort_enabled = true
      
      get_tree().get_root().add_child.call_deferred(a)
      
      telegraph.queue_free() 
      
    )
    
  var t := Timer.new()
  t.one_shot = true
  
  add_child(t)
  
  t.start(1.5)
  
  t.timeout.connect(func() :
    t.queue_free()
    rock_arena()
  )

var digging = false
var dig_pos: Vector2
var dig_num: int = 0

func dig() :
  %dig_time.stop()
  
  if dig_num >= 5 :
    attacking = false
    dig_num = 0
    return
  
  dig_num += 1
  
  dig_pos = get_closest_player().global_position
  dig_pos.x = clamp(dig_pos.x, -2000, 2000)
  dig_pos.y = clamp(dig_pos.y, -2000, 2000)

  var telegraph: GenericTelegraph = telegraphScene.instantiate()
  telegraph.global_position = dig_pos
  telegraph.SHAPE_SIZE = Vector2(1500, 1500)
  telegraph.TELEGRAPH_TIME = 1.5
  
  get_tree().get_root().add_child.call_deferred(telegraph)
  
  telegraph.telegraph_finished.connect(func() :
    digging = true
    HpComp.invincible = true
    scale /= 4
    telegraph.queue_free()
    %dig_sfx.play()
    %dig_time.start()
  )

var wall_height = 500
var walls: int = 0

func rock_walls() :
  if walls >= 15 :
    walls = 0
    
    var t_stop := Timer.new()
    t_stop.one_shot = true
    
    add_child(t_stop)
    
    t_stop.start(10)
    
    t_stop.timeout.connect(func() :
      attacking = false
    )
    return
  
  walls += 1
  
  var dir = 1
  
  for i in range(-4000, 4000, wall_height) :
    dir *= -1
    var telegraph: GenericTelegraph = telegraphScene.instantiate()
    telegraph.global_position = Vector2(0, i)
    telegraph.SHAPE_SIZE = Vector2(5000, wall_height)
    telegraph.TELEGRAPH_TIME = 2.5
    telegraph.visible = walls == 1
    
    get_tree().get_root().add_child.call_deferred(telegraph)
    
    telegraph.telegraph_finished.connect(func():
      var a: DamageArea = get_square_damage_area(Vector2(100, wall_height))
      
      a.damage = 45
      a.iframe_group = "boss_wall"
      a.direction.x = 10 * dir
      a.global_position = Vector2(0, i) + Vector2(-3000, 0) * dir
      a.lifetime = 10
    
      var spr := Sprite2D.new()
      spr.texture = load("res://Bosses/Crystal Golem/Sprites/rock_wall.png")
      spr.scale = Vector2.ONE * 4
      
      a.add_child(spr)
      
      spr.global_rotation = 0
      spr.y_sort_enabled = true
      
      get_tree().get_root().add_child.call_deferred(a)
      
      telegraph.queue_free()
    )
    
  var t := Timer.new()
  t.one_shot = true
  
  add_child(t)
  
  t.start(1.5)
  
  t.timeout.connect(func() :
    t.queue_free()
    rock_walls()
  )

var sanses: int = 0

func sans() :
  if sanses > 540 :
    sanses = 0
    var t_stop := Timer.new()
    t_stop.one_shot = true
    
    add_child(t_stop)
    
    t_stop.start(3)
    
    t_stop.timeout.connect(func() :
      t_stop.queue_free()
      attacking = false
    )
    return

  sanses += 1

  var telegraph: GenericTelegraph = telegraphScene.instantiate()
  telegraph.global_position = global_position
  telegraph.SHAPE_SIZE = Vector2(10000, 100)
  telegraph.TELEGRAPH_TIME = 1.5
  telegraph.rotation_degrees = sanses * 4 * ((int(sanses / 135.0) % 2) * 2 - 1)
  
  get_tree().get_root().add_child.call_deferred(telegraph)
    
  telegraph.telegraph_finished.connect(func():
    var a: DamageArea = get_square_damage_area(Vector2(10000, 100))
    
    a.damage = 45
    a.iframe_group = "boss_sans"
    a.global_position = telegraph.global_position
    a.lifetime = .5
    a.rotation = telegraph.rotation
    
    var spr := Sprite2D.new()
    spr.texture = load("res://Bosses/Crystal Golem/Sprites/rock_wall.png")
    spr.scale = Vector2.ONE * 4
    spr.scale.y = 200
    spr.rotation_degrees += 90
    
    a.add_child(spr)
    
    spr.y_sort_enabled = true
    
    get_tree().get_root().add_child.call_deferred(a)
    
    telegraph.queue_free()
  )
    
  var t := Timer.new()
  t.one_shot = true
  
  add_child(t)
  
  t.start(.075)
  
  t.timeout.connect(func() :
    t.queue_free()
    sans()
  )

var spike_num: int = 0

func spikes() :
  if spike_num >= 10 :
    spike_num = 0
    attacking = false
    return
  
  if spike_num == 0 :
    var t_start := Timer.new()
    t_start.one_shot = true
    
    add_child(t_start)
    
    t_start.start(3)
    
    t_start.timeout.connect(func() :
      t_start.queue_free()
      spikes()
    )
    
    spike_num = 1
    
    return
  
  spike_num += 1
  
  for i in get_tree().get_nodes_in_group("player") :
    var p: Player = i
    var telegraph: GenericTelegraph = telegraphScene.instantiate()
    telegraph.global_position = p.global_position + p.velocity.normalized() * 250
    telegraph.SHAPE_SIZE = Vector2(250, 250)
    telegraph.TELEGRAPH_TIME = .7
    
    get_tree().get_root().add_child.call_deferred(telegraph)
      
    telegraph.telegraph_finished.connect(func():
      cam.addScreenshake(10)
      
      var a: DamageArea = get_square_damage_area(Vector2(250, 250))
      
      a.damage = 45
      a.iframe_group = "boss_spike"
      a.global_position = telegraph.global_position
      a.lifetime = 15
    
      var spr := Sprite2D.new()
      spr.texture = load("res://Bosses/Crystal Golem/Sprites/jump_rocks.png")
      spr.scale = Vector2.ONE * 4
      
      a.add_child(spr)
      
      spr.global_rotation = 0
      spr.y_sort_enabled = true
      
      get_tree().get_root().add_child.call_deferred(a)
      
      telegraph.queue_free()
    )
  
  var t := Timer.new()
  t.one_shot = true
  
  add_child(t)
  
  t.start(1.3 + randf_range(-.15, .15))
  
  t.timeout.connect(func() :
    t.queue_free()
    spikes()
  )

func explosion() :
  var telegraph: GenericTelegraph = telegraphScene.instantiate()
  telegraph.global_position = global_position
  telegraph.SHAPE_SIZE = Vector2(3000, 3000)
  telegraph.TELEGRAPH_TIME = .45
  
  get_tree().get_root().add_child.call_deferred(telegraph)
    
  telegraph.telegraph_finished.connect(func():
    var a: DamageArea = get_square_damage_area(Vector2(3000, 3000))
    
    a.damage = 60
    a.global_position = telegraph.global_position
    a.lifetime = .5
    
    get_tree().get_root().add_child.call_deferred(a)
    
    telegraph.queue_free()
    var t := Timer.new()
    t.one_shot = true
    
    add_child(t)
    
    t.start(.6)
    
    t.timeout.connect(func() :
      attacking = false
    )
  )

var walk_pos: Vector2
var walk_wait: bool = false

func _process(delta: float) -> void:
  super._process(delta)
  
  if walk_around and !walk_wait :
    if walk_pos.distance_squared_to(global_position) <= 1000 * 1000 :
      var t := Timer.new()
      get_tree().get_root().add_child.call_deferred(t)
      t.wait_time = 2.5
      t.one_shot = true
      t.autostart = true
      t.timeout.connect(func(): 
        t.queue_free()
        walk_pos = Vector2(
          randi_range(-2000, 2000),
          randi_range(-2000, 2000),
        )
        walk_wait = false
      )
      walk_wait = true
    else :
      velocity = (walk_pos - global_position).normalized() * 1000
  
  if charge_dir :
    velocity = charge_dir * 6500
    
    if charge_area == null :
      charge_area = get_square_damage_area(Vector2(1500, 1500))
      
      charge_area.rotation = velocity.angle()
      charge_area.damage = 25
      charge_area.lifetime = .1
      charge_area.iframe_group = "boss_charge"
      
      get_tree().get_root().add_child.call_deferred(charge_area)
    
    charge_area.global_position = global_position
  
  if digging :
    velocity = (dig_pos - global_position).normalized() * 2500
    
    if global_position.distance_squared_to(dig_pos) < 1250 :
      global_position = dig_pos
      HpComp.invincible = false
      scale *= 4
      digging = false
      
      %dig_sfx.stop()
      cam.addScreenshake(25)
      
      var a: DamageArea = get_square_damage_area(Vector2(1500, 1500))
      
      a.damage = 30
      a.lifetime = .5
      a.global_position = global_position
      
      get_tree().get_root().add_child.call_deferred(a)
      for i in range(10) :
        var pos = Vector2(
          randi_range(-2500, 2500),
          randi_range(-2500, 2500),
        )
        
        var telegraph: GenericTelegraph = telegraphScene.instantiate()
        telegraph.global_position = pos
        telegraph.SHAPE_SIZE = Vector2(350, 350)
        telegraph.TELEGRAPH_TIME = 2 + randf_range(-.5, .5)
        
        get_tree().get_root().add_child.call_deferred(telegraph)
        
        telegraph.telegraph_finished.connect(func() :
          telegraph.queue_free()
          
          var area: DamageArea = get_square_damage_area(telegraph.SHAPE_SIZE)
          area.global_position = telegraph.global_position
          area.damage = 30
          area.lifetime = 5
          area.iframe_group = "bossassi"
    
          var spr := Sprite2D.new()
          spr.texture = load("res://Bosses/Crystal Golem/Sprites/charge_rock.png")
          spr.scale = Vector2.ONE * 4
          
          area.add_child(spr)
          
          spr.global_rotation = 0
          spr.y_sort_enabled = true
          
          get_tree().get_root().add_child.call_deferred(area)
        )
      
      dig()
  
  move_and_slide()
  
  if charge_dir != Vector2.ZERO and velocity != charge_dir * 6500 :
    cam.addScreenshake(25)
    
    charge_dir = Vector2.ZERO
    if charge_area :
      charge_area.queue_free()
      charge_area = null
    
    var t := Timer.new()
    add_child(t)
    
    t.timeout.connect(func() :
      t.queue_free()
      attacking = false
    )
    t.one_shot = true
    
    t.start(2.5)
    
    for i in range(50) :
      var pos = Vector2(
        randi_range(-2500, 2500),
        randi_range(-2500, 2500),
      )
      
      var telegraph: GenericTelegraph = telegraphScene.instantiate()
      telegraph.global_position = pos
      telegraph.SHAPE_SIZE = Vector2(500, 500)
      telegraph.TELEGRAPH_TIME = 1.5 + randf_range(-.5, .5)
      
      get_tree().get_root().add_child.call_deferred(telegraph)
      
      telegraph.telegraph_finished.connect(func() :
        telegraph.queue_free()
        
        var area: DamageArea = get_square_damage_area(telegraph.SHAPE_SIZE)
        area.global_position = telegraph.global_position
        area.damage = 30
        area.lifetime = 1
        area.iframe_group = "bossassi"
        
        var spr := Sprite2D.new()
        spr.texture = load("res://Bosses/Crystal Golem/Sprites/charge_rock.png")
        spr.scale = Vector2.ONE * 4
        
        area.add_child(spr)
        
        spr.global_rotation = 0
        spr.y_sort_enabled = true
        
        get_tree().get_root().add_child.call_deferred(area)
      )
  
  if velocity.length_squared() > 10 :
    velocity /= 2
  else :
    velocity = Vector2.ZERO

func _on_dig_time_timeout() -> void:
  HpComp.invincible = false
  scale *= 4
  digging = false
  
  %dig_sfx.stop()
