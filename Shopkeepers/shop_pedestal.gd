extends InteractionComponent
class_name ItemPedestal

@export var DISPLAY_ITEM: Item

func find_inventory(from: Node) :
  if from is Inventory :
    return from
  
  for i in from.get_children() :
    var r = find_inventory(i)
    
    if r is Inventory :
      return r
  
  return null
  
func _on_interacted(_p: Player) -> void:
  var inv: Inventory = find_inventory(get_tree().get_root())
  
  if inv.coins >= DISPLAY_ITEM.getItemCoinValue() :
    inv.coins -= DISPLAY_ITEM.getItemCoinValue()
    inv.addItem(DISPLAY_ITEM)
    queue_free()

func _process(delta: float) -> void:
  super._process(delta)
  
  if !DISPLAY_ITEM :
    return
    
  var inv: Inventory = find_inventory(get_tree().get_root())
  %tooltip.modulate = Color.WHITE if inv.coins >= DISPLAY_ITEM.getItemCoinValue() else Color.RED
  
  %item_icon.texture = DISPLAY_ITEM.TEXTURE
  
  %item_desc.text = DISPLAY_ITEM.DESCRIPTION
  %item_quote.text = "[i]'%s'[/i]" % [DISPLAY_ITEM.QUOTE]
  
  TOOLTIP = "Buy (%s coins)" % [DISPLAY_ITEM.getItemCoinValue()]
  
  %item_info.visible = len(get_overlapping_bodies()) > 0
  %item_info.size.y = %item_desc.size.y + %item_quote.size.y + 64
  %item_info.position.y = -64 - %item_info.size.y
