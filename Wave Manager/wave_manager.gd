extends Control

class_name WaveManager

@export var delay_between_waves: float = 5
@export var starting_points: int = 100
@export var points_mult: float = .35
@export var waves_per_room: int = 3
@export var biome_list: Array[Biome]
@export var spawn_bosses: bool = true
@export var wave_end_rewards: Array[PackedScene]

@export var loot_tables: Array[LootTable]

@onready var waveTimer = $waveTimer
@onready var waveDisplay = $MarginContainer/RichTextLabel

var points: int

var wavenun: int = 0
var totwavenum: int = 0

var enemy_pool: Array[Enemy] = []
var current_biome = 0

func _ready() -> void:
  for i in biome_list[current_biome].ENEMY_POOL :
    enemy_pool.append(i.instantiate())
  
  points = starting_points

var room_cleared = true

signal room_clear

func _process(_delta: float) -> void:
  if !dungeon_boss :
    %xpManager.visible = true
    %bossbar.visible = false
  
  visible = true
  
  if room_cleared :
    waveTimer.stop()
    waveDisplay.text = ""
  elif not waveTimer.is_stopped() :
    waveDisplay.text = "Wave %s / %s in %ss" % [wavenun+1, waves_per_room, int(int(waveTimer.time_left * 100) / 100.0)]
    if wavenun >= waves_per_room :
      var chest = wave_end_rewards.pick_random().instantiate()
      chest.position.y -= 192
      get_tree().get_root().add_child.call_deferred(chest)
      
      %dungeonManager.posToRoom[%dungeonManager.currentRoom].add_to_storage(chest)
      
      %xpManager.emitLevelUpSignal()
      room_cleared = true
      emit_signal("room_clear")
  elif !room_cleared :
    var rem = len(remaining_enemies.filter(is_instance_valid))
    waveDisplay.text = "Wave %s / %s (%s enem%s remaining)" % [wavenun, waves_per_room, rem, "y" if rem == 1 else "ies"]
  
    var next = true
    for i in remaining_enemies :
      if is_instance_valid(i) :
        next = false
    
    # Wait until there are xp orbs on the field
    var xporbs = len(get_tree().get_nodes_in_group("xporb"))
    if next and xporbs > 0 :
      waveDisplay.text = "Wave %s / %s (%s xp orb%s left)" % [wavenun, waves_per_room, xporbs, "s" if xporbs == 1 else ""]
      next = false

    if next :
      %xpManager.emitLevelUpSignal()
      waveTimer.start(delay_between_waves)

var remaining_enemies: Array[Enemy] = []

signal wave_start

func spawnWave() :
  emit_signal("wave_start")
  remaining_enemies.clear()
  
  for i in loot_tables :
    i.lock_rarity(totwavenum)
  
  var more: float = 1
  var last: float = 0.0
  
  for i in range(len(get_tree().get_nodes_in_group("player"))) :
    more += last
    last = last + (1 - last) * .35
    
  for i in get_tree().get_nodes_in_group("player") :
    (i as Player).potions = 6 + int(totwavenum / 5.0)
  
  wavenun += 1
  totwavenum += 1
  points = int(starting_points * (1 + points_mult * wavenun) * more)
  
  var remaining_points = points * more
  var enemies: Array[Enemy] = []
  
  while true :
    var possible_enemies = enemy_pool.duplicate().filter(func (a: Enemy): 
      return a.points_for_wave <= remaining_points
    )
    
    if len(possible_enemies) == 0 :
      break
    
    possible_enemies.shuffle()
    enemies.append((possible_enemies[0] as Enemy).duplicate())
    remaining_points -= (possible_enemies[0] as Enemy).points_for_wave

  for i in enemies :
    remaining_enemies.append(i)
    
    i.global_position.x = randi_range(-2000, 2000)
    i.global_position.y = randi_range(-2000, 2000)
    
    get_tree().get_root().add_child.call_deferred(i)
    
func _on_wave_timer_timeout() -> void:
  spawnWave()

func _on_dungeon_manager_start_waves() -> void:
  waveTimer.start(delay_between_waves)
  room_cleared = false
  wavenun = 0

signal boss_defeated

var dungeon_boss: Boss = null

func _on_dungeon_manager_spawn_boss() -> void:
  if !spawn_bosses :
    emit_signal("boss_defeated")
    return
  
  # spawn boss
  var boss: Boss = biome_list[current_biome].BOSS.instantiate()
  get_tree().get_root().add_child(boss)
  
  boss.HpComp.DISPLAY_BAR = %bossbar
  boss.cam = %maincamera
  
  boss.defeated.connect(func (): 
    emit_signal("boss_defeated")
    # current_biome += 1  Rn do not progress to next biome (there are no other biomes)
  )
  
  dungeon_boss = boss
