extends Resource

class_name Item

enum Rarity {
  COMMON =   11,
  UNCOMMON =  9,
  RARE =      7,
  EPIC =      5,
  MYTHIC =    3,
  LEGENDARY = 1
}

@export var NAME: String = "Base Item"
@export_multiline var DESCRIPTION: String = "Lorem ipsum dolor sit amet"
@export var QUOTE: String = ""

@export var TEXTURE: Texture2D

@export var RARITY: Rarity = Rarity.COMMON
@export var VALUE_OFFSET: int = 0

@export var EQUIPPABLE: bool = false
var GLYPH_SHARD: bool = false
var IS_POTION: bool = false

var EQUIP_SCENE: Weapon
var EQUIP_ENCHANTS: Array[Glyph]

@export_subgroup("Consumable")
@export var MAX_CHARGES: int = 1

var GLYPH: Glyph
var SHARD_NUM: int = 1

@export_subgroup("Accessory")
@export var IS_ACCESSORY: bool = false
@export var ACCESSORY: Accessory

var charges_used = 0

var coin_val: int = -1
func getItemCoinValue() -> int :
  if coin_val < 0 :
    coin_val = int(pow(float(Rarity.COMMON) / float(RARITY) * randf_range(.6, 1.4) * 2.0 + VALUE_OFFSET, 2.0))
  
  return coin_val

func use(p: Player) :
  if self is Potion :
    p.effectcomponent.add_potion(self)
  elif EQUIPPABLE :
    p.equip_weapon(self)
  elif IS_ACCESSORY :
    return
  else :
    consume(p)

func consume(p: Player) :
  if charges_used >= MAX_CHARGES :
    return
  
  charges_used += 1
  
  _consume(p)

func _consume(_p: Player) :
  pass
