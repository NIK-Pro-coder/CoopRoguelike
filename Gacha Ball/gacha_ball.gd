extends InteractionComponent
class_name GachaBall

@export var LOOT_POOL: LootTable

var given_item: Item

@onready var sprite: AnimatedSprite2D = %sprite
@onready var sprite_big: TextureRect = %sprite_big
@onready var sprite_given: TextureRect = %sprite_given

func _ready() -> void:
  given_item = LOOT_POOL.pick_random_item()
  
  sprite.material = sprite.material.duplicate()
  (sprite.material as ShaderMaterial).set_shader_parameter("color", Qol.RARITY_COLORS[given_item.RARITY])

  sprite_big.material = sprite_big.material.duplicate()
  (sprite_big.material as ShaderMaterial).set_shader_parameter("color", Qol.RARITY_COLORS[given_item.RARITY])

  sprite_given.visible = false
  sprite_given.texture = given_item.TEXTURE
  sprite_given.material = sprite_given.material.duplicate()
  (sprite_given.material as ShaderMaterial).set_shader_parameter("color", Qol.RARITY_COLORS[given_item.RARITY])
  
  %item_name.add_theme_color_override("default_color", Qol.RARITY_COLORS[given_item.RARITY])
  %item_name.text = given_item.NAME
  
  $CanvasLayer.visible = false

var shaking = false
var shake_progress: float = 0

var player: Player

func _on_interacted(p: Player) -> void:
  if get_tree().paused == true :
    return
  
  $CanvasLayer.visible = true
  get_tree().paused = true
  shaking = true
  shake_progress = 0
  
  player = p
  
  %claim_text.text = ("(A)" if p.DEVICE_ID >= 0 else "(X)") + " Claim"

var modulate_progress: float = 0.0

func get_inv(from: Node) :
  if from is Inventory :
    return from
  
  for i in from.get_children() :
    var r = get_inv(i)
    
    if r is Inventory :
      return r

  return null

func _process(delta: float) -> void:
  super._process(delta)
  
  if shaking :
    sprite_big.position = Vector2(
      randf_range(-5, 5) - 172,
      randf_range(-5, 5) - 172,
    )
    
    sprite_big.rotation = randf_range(-shake_progress, shake_progress) / 50
    shake_progress += .1

  if shake_progress >= 15 :
    shaking = false
    sprite_big.visible = false
    sprite_given.visible = true
    
    modulate_progress = min(1, modulate_progress + .005)

    sprite_given.modulate.a = modulate_progress

  %claim_text.visible = modulate_progress >= 1
  %item_name.visible = modulate_progress >= 1
  
  if modulate_progress >= 1 and player.is_action_pressed("attack") :
    get_tree().paused = false
    queue_free()
    (get_inv(get_tree().get_root()) as Inventory).addItem(given_item.duplicate())
    
