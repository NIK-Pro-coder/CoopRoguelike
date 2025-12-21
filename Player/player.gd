extends CharacterBody2D

class_name Player

var SPEED = 600.0

@export var DEVICE_ID = -1
var HUD: HUDTemplate
var WAVE_MNGR: WaveManager
var MAIN_COLOR: float

@export var MAX_MANA = 100
var actual_max_mana = 100
@export var MANA_GAIN = .1

@export var DAMAGE: float = 1
@export var KNOCKBACK: float = 1

@export var POTION_AMOUNT: int = 1

var mana = 0
var potions = 6

var powers: Array[Power] = []
var stat_changes: StatTracker = StatTracker.new()

@export_range(0, 1, .001) var AUTOAIM_STRENGTH: float = .5

@export_category("Heal Potion")
@export var POTION_COOLDOWN = 10
@export var POTION_HEALING = 20

@export_category("Dash")
@export var DASH_DURATION: float = .3
@export var DASH_SPEED: float = 2000
@export var DASH_COOLDOWN: int = 5

@export var MAX_HP: int = 100

@export var DAMAGE_TAKEN: float = 1

@export var NAME: String

var mappedInputs: Dictionary[String, Array] = {}

@export var accessories: Array[Accessory] = [
  null,
  null,
  null,
]

@onready var weapon: Weapon
var spell: Spell = preload("res://Spells/Zap Spell/zap_spell.tres").duplicate()

@onready var dashCooldown: Timer = $dashCooldown
@onready var dashDuration: Timer = $dashDuration

@onready var potionCooldownTimer: Timer = $healPotionCooldown

@onready var nametag: RichTextLabel = $nametag

@onready var healtcomponent: HealthComponent = $healthCoponent

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sprite: AnimatedSprite2D = $Icon

@onready var footstep_particle: GPUParticles2D = %footsteps

@onready var effectcomponent: EffectComponent = %effectComponent

var knockback: Vector2 = Vector2.ZERO

#region STATS
var damageDone: int = 0
var damageGot: int = 0

var timesDied: int = 0
var timesRevived: int = 0

var healingGot: int = 0
var potionsDrank: int = 0

var enemyKills: int = 0
var bossKills: int = 0
#endregion

func play_animation(anim_name: String) :
  for i in accessory_sprites :
    if !i or !i.sprite_frames : continue
    if i.sprite_frames.has_animation(anim_name) and i.animation != anim_name :
      i.play(anim_name)
  
  if sprite.animation == anim_name :
    return
  
  sprite.play(anim_name)

func equip_weapon(w: Weapon) :
  if weapon :
    weapon.on_unequip(self)
  weapon = w.duplicate()
  weapon.on_equip(self)

func is_action_pressed(act_name: String) :
  if !act_name in mappedInputs :
    return false
  
  if DEVICE_ID < 0 :
    return Input.is_action_pressed("k_" + act_name)
  
  var events: Array[InputEvent] = mappedInputs[act_name]
  
  for i in events :
    if i is InputEventJoypadButton :
      if not Input.is_joy_button_pressed(DEVICE_ID, i.button_index) :
        return false
  
  return true

func get_axis(negative: String, positive: String) :
  var n = is_action_pressed(negative)
  var p = is_action_pressed(positive)
  
  if n and p : return 0
  
  if n : return -1
  
  if p : return 1
  
  return 0

func accessory_wave_start() :
  for i in accessories:
    if i :
      i.wave_start(self)

var accessory_sprites: Array[AnimatedSprite2D] = []
var accessory_timers: Array[Timer] = []
func recalculate_accessories() :
  for i in accessory_sprites :
    i.queue_free()
  accessory_sprites.clear()
  
  init_accessories()
  
  if !WAVE_MNGR.wave_start.is_connected(accessory_wave_start) :
    WAVE_MNGR.wave_start.connect(accessory_wave_start)
  
  for i in accessories :
    if !i :
      continue
    
    var spr := AnimatedSprite2D.new()
    spr.sprite_frames = i.ANIMATIONS
    spr.scale = Vector2.ONE * 4
    if i.ANIMATIONS and i.ANIMATIONS.has_animation(sprite.animation) :
      spr.play(sprite.animation)
    spr.frame = sprite.frame
    spr.flip_h = sprite.flip_h
    
    add_child.call_deferred(spr)
    accessory_sprites.append(spr)

func recalculate_powers() :
  for i in powers :
    i.apply_power(stat_changes)
  
  weapon.change_stats(self, stat_changes)

func init_accessories() :
  for i in accessory_timers :
    i.queue_free()
  accessory_timers.clear()
  
  for i in accessories :
    if !i :
      continue
    
    var t := Timer.new()
    add_child(t)
    t.start(i.PASSIVE_UPDATE_TIME)
    t.timeout.connect(func(): i.update_passive(self))
    accessory_timers.append(t)

func _ready() :
  recalculate_powers()
  
  weaponChargeBar.add_theme_stylebox_override("fill", weaponChargeBar.get_theme_stylebox("fill").duplicate())
  
  sprite.material = sprite.material.duplicate()
  mana = actual_max_mana
  
  nametag.text = NAME
  
  %matrix_display.material = %matrix_display.material.duplicate()
  
  var actions = InputMap.get_actions()
  
  for i in actions :
    if (i as String).begins_with("ui_") :
      continue
      
    var events = InputMap.action_get_events(i)
  
    mappedInputs[i] = events

var lastMoveDir: Vector2

var lock_movement: bool = false

func handle_movement() :
  if lock_movement :
    velocity = Vector2.ZERO
    footstep_particle.emitting = false
    return
  
  var direction: Vector2
  if DEVICE_ID >= 0 :
    direction = Vector2(
      Input.get_joy_axis(DEVICE_ID, JOY_AXIS_LEFT_X),
      Input.get_joy_axis(DEVICE_ID, JOY_AXIS_LEFT_Y),
    )
  
    direction.x = move_toward(direction.x, 0, .2)
    direction.y = move_toward(direction.y, 0, .2)
  else :
    direction = Input.get_vector("k_left", "k_right", "k_up", "k_down")
  
  if direction:
    velocity = direction.normalized() * get_actual_stat("speed")
    lastMoveDir = direction.normalized()
    
    if direction.x < 0 :
      sprite.flip_h = true
    elif direction.x > 0 :
      sprite.flip_h = false
      
    for i in accessory_sprites :
      i.flip_h = sprite.flip_h
    
    footstep_particle.emitting = true
  else:
    velocity = Vector2.ZERO
    
    footstep_particle.emitting = false
  
  if is_action_pressed("roll") and dashCooldown.is_stopped() :
    healtcomponent.invincible = true
    
    var dash_cooldown = get_actual_stat("dash_cooldown")
    var dash_duration = get_actual_stat("dash_duration")

    if dash_duration > 0 : dashDuration.start(dash_duration)
    if dash_cooldown > 0 : dashCooldown.start(dash_cooldown)

  move_and_slide()

func get_actual_stat(stat: String) :
  return self[stat.to_upper()] * stat_changes[stat.to_upper() + "_PERCENT"] + stat_changes[stat.to_upper()]

@onready var weaponChargeBar: ProgressBar = %weapon_charge_bar

func _process(_delta: float) -> void:
  %weapons_spr.texture = weapon.TEXTURE
  %weapons_spr.visible = !weapon.hasCooldown
  %weapons_spr.position.x = 32 * (-1 if sprite.flip_h else 1)
  %weapons_spr.flip_h = sprite.flip_h
  
  sprite.material.set_shader_parameter("hue_shift", MAIN_COLOR)
  
  weaponChargeBar.visible = weapon.can_charge
  weaponChargeBar.value = weapon.get_charge_progress()
  if weapon.get_charge_progress() >= 1 :
    (weaponChargeBar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color(0.0, 0.718, 0.397)
  else :
    (weaponChargeBar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = Color(0.0, 0.675, 0.773)
  
  HUD.player_name = nametag.text
  HUD.player_color = MAIN_COLOR
  
  HUD.potion_cooldown = 100 - int(potionCooldownTimer.time_left / get_actual_stat("potion_cooldown") * 100)
  HUD.potion_amt = potions
  HUD.can_use_potions = len(get_tree().get_nodes_in_group("enemy")) > 0
  
  HUD.dash_cooldown = int(100.0 - (dashCooldown.time_left / get_actual_stat("dash_cooldown")) * 100.0)
  
  if spell.cooldownTimer and is_instance_valid(spell.cooldownTimer) :
    HUD.spell_cooldown = 100 - int((spell.cooldownTimer.time_left / spell.cooldownTimer.wait_time) * 100)
  else :
    HUD.spell_cooldown = 100
  HUD.spell_cost = spell.MANA_COST
  
  HUD.health = healtcomponent.health
  HUD.max_health = healtcomponent.max_health
  
  HUD.mana = mana
  HUD.max_mana = get_actual_stat("max_mana")
  
  var has_matrix: bool = false
  for i in accessories :
    if i and i.get_script() == load("res://Accessories/Defensive Matrix/defensive_matrix.gd") :
      has_matrix = true
      break
  
  if !has_matrix :
    HUD.matrix = 0
    HUD.matrixready = false
  
  %matrix_display.visible = HUD.matrix > 0
  (%matrix_display.material as ShaderMaterial).set_shader_parameter("shield_hp", HUD.matrix)
  (%matrix_display.material as ShaderMaterial).set_shader_parameter("shield_ready", HUD.matrixready)

@onready var inventoryMngr: Inventory = get_tree().get_root().get_node("/root/main/CanvasLayer/inventory")

var dashTrailScene = preload("res://Player/dash_trail.tscn")

func recalculate_stats() :
  stat_changes.reset()
  
  for i in accessories :
    if i :
      i.change_stats(self, stat_changes)
  
  recalculate_powers()
  effectcomponent.apply_effects(stat_changes)
  
  healtcomponent.set_max_hp(get_actual_stat("max_hp"))
  healtcomponent.damage_mult = get_actual_stat("damage_taken")
  
  actual_max_mana = get_actual_stat("max_mana")

var last_attacking: bool = false

func _physics_process(_delta: float) -> void:
  recalculate_stats()
  
  if knockback != Vector2.ZERO or weapon.isAttacking or velocity == Vector2.ZERO :
    play_animation("idle")
  
  if is_action_pressed("inventory") :
    inventoryMngr.showMyInventory(self)
  
  if !dashDuration.is_stopped() :
    knockback = Vector2.ZERO
  
  nametag.visible = Input.is_action_pressed("shownames")
  
  if knockback != Vector2.ZERO :
    velocity = knockback
    move_and_slide()
    
    knockback.x = move_toward(knockback.x, 0, 10)
    knockback.y = move_toward(knockback.y, 0, 10)
    
    return
  
  if weapon.isAttacking :
    return
  
  if velocity != Vector2.ZERO :
    play_animation("walk")
  
  if !dashDuration.is_stopped() : # Dashing
    velocity = lastMoveDir * get_actual_stat("dash_speed")
    move_and_slide()
    
    var frameIndex: int = sprite.get_frame()
    var animationName: String = sprite.animation
    var spriteFrames: SpriteFrames = sprite.get_sprite_frames()
    var currentTexture: Texture2D = spriteFrames.get_frame_texture(animationName, frameIndex)
      
    var trail: Sprite2D = dashTrailScene.instantiate()
    trail.hue = MAIN_COLOR
    trail.texture = currentTexture
    trail.global_position = global_position
    trail.flip_h = sprite.flip_h
    
    get_parent().add_child.call_deferred(trail)
    
    for i in accessories :
      if i :
        i.on_dash(self)
  
    return
  
  handle_movement()
  
  if !"ally" in get_groups() :
    return
  
  if potions > 0 and potionCooldownTimer.is_stopped() and is_action_pressed("heal") and healtcomponent.health < healtcomponent.max_health and len(get_tree().get_nodes_in_group("enemy")) > 0 :
    if get_actual_stat("potion_cooldown"): potionCooldownTimer.start(get_actual_stat("potion_cooldown"))
    
    for _k in range(get_actual_stat("potion_amount")) :
      healtcomponent.healDmg(get_actual_stat("potion_healing"))
      for i in accessories :
        if i :
          i.on_heal(self)
      
    potions -= 1
    potionsDrank += 1
  
  var enemyPos := Vector2.ZERO
  var enemyDist := -1
  for i in get_tree().get_nodes_in_group("enemy") :
    var pos = (i as Node2D).global_position
    if (pos - global_position).normalized().dot(lastMoveDir) >= .8 and (enemyDist < 0 or pos.distance_squared_to(global_position) < enemyDist) :
      enemyDist = int(pos.distance_squared_to(global_position))
      enemyPos = pos
  
  
  var atkPos := lastMoveDir
  if enemyDist >= 0 :
    atkPos = (enemyPos - global_position).normalized()
    
    
  if is_action_pressed("attack") :
    weapon.attack(self, atkPos)
  elif last_attacking :
    weapon.attack_stop(self, atkPos)
  
  last_attacking = is_action_pressed("attack")
  
  if is_action_pressed("spell") :
    spell.cast(self)

var revivetotem = preload("res://Revive Totem/revive_totem.tscn")

func _on_health_coponent_death() -> void:
  if not "ally" in get_groups() :
    return
  
  timesDied += 1
  
  remove_from_group("ally") # When you die remove from the ally group so enemies / spells can't target you
  $CollisionShape2D.debug_color.a = .25
  $Icon.modulate.a = .25
  
  var totem: ReviveTotem = revivetotem.instantiate()
  totem.global_position = global_position
  totem.player_to_res = self
  
  get_tree().get_root().add_child.call_deferred(totem)

func revive(pos: Vector2) :
  add_to_group("ally")
  $CollisionShape2D.debug_color.a = .42
  $Icon.modulate.a = 1
  $healthCoponent.revive(.5)
  
  global_position = pos

func _on_heal_potion_cooldown_timeout() -> void:
  animation_player.play("potion_ready")

func _on_dash_cooldown_timeout() -> void:
  animation_player.play("dash_ready")

func _on_health_coponent_damaged(amt: int) -> void:
  if DEVICE_ID >= 0 :
   Input.start_joy_vibration(DEVICE_ID, min(1, 100.0 / amt), min(1, 500.0 / amt), .1)
  
  if amt >= 0 :
    damageGot += amt
  for i in accessories :
    if i :
      i.on_hit_taken(self, amt)

func _on_health_coponent_healed(amt: int) -> void:
  healingGot += amt

func _on_dash_duration_timeout() -> void:
  healtcomponent.invincible = false

func _on_effect_component_effects_changed() -> void:
  HUD.effects = effectcomponent.stat_icons.values()
  HUD.update_effects()
