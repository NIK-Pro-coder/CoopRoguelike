extends Resource
class_name LootTable

## The pool of ites that could be picked
@export var ITEM_POOL: Array[Item] = []
## The maximum rarity that can be unlocked, it is <= that this
@export var MAX_RARITY: Item.Rarity = Item.Rarity.LEGENDARY

## Picks a random item fro the ITEM_POOL, temp is a number in the
## range [0, 1] when temp is 0 rarities have the correct weight,
## when temp is 1 all rarities have the same rarity 
func pick_random_item(temp: float = 0) :
  var rarities = []
  var rar_sum = 0
  
  for i in ITEM_POOL :
    if not i.RARITY in rarities and i.RARITY >= MAX_RARITY :
      rarities.append(i.RARITY)
      rar_sum += i.RARITY
      
  var r = randi_range(0, rar_sum-1)
  
  var rarity_sel: Item.Rarity = Item.Rarity.COMMON
  for i in rarities :
    var w = (i * (1-temp)) + (int(float(rar_sum) / len(rarities)) * temp)
    
    if r < w :
      rarity_sel = i
      break
    
    r -= w
  
  var actual_pool = ITEM_POOL.filter(func (x: Item): return x.RARITY == rarity_sel)
  
  return actual_pool.pick_random().duplicate()

func lock_rarity(wave_num: int) :
  var w = wave_num / 5.0
  
  if w < 1 :
    MAX_RARITY = Item.Rarity.COMMON
  elif w < 2 :
    MAX_RARITY = Item.Rarity.UNCOMMON
  elif w < 3 :
    MAX_RARITY = Item.Rarity.RARE
  elif w < 4 :
    MAX_RARITY = Item.Rarity.EPIC
  elif w < 5 :
    MAX_RARITY = Item.Rarity.MYTHIC
  else :
    MAX_RARITY = Item.Rarity.LEGENDARY
