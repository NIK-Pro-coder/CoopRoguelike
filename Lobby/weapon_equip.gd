extends InteractionComponent
class_name WeaponPedestal

@export var EQUIP_WEAPON: Weapon

func _ready() -> void:
  %description.text = EQUIP_WEAPON.DESCRIPTION
  TOOLTIP = "Equip '%s'" % [EQUIP_WEAPON.NAME]
  %weapon_icon.texture = EQUIP_WEAPON.TEXTURE

func _process(delta: float) -> void:
  super._process(delta)
  
  %description.visible = %RichTextLabel.visible

func _on_interacted(p: Player) -> void:
  if p.weapon.NAME == EQUIP_WEAPON.NAME :
    return
  p.equip_weapon(EQUIP_WEAPON)
  
  Qol.display_string(p.global_position - Vector2(0, 100), "Equipped '%s'" % [EQUIP_WEAPON.NAME])
