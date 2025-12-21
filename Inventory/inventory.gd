extends Control

class_name Inventory

@export var DISPLAY_PLAYER: Player

@export var STARTING_COINS: int = 10

@onready var wicon: TextureRect = %wicon
@onready var wname: RichTextLabel = %wname

@onready var sicon: TextureRect = %sicon
@onready var sname: RichTextLabel = %sname

@onready var invGrid: GridContainer = %GridContainer

@onready var button_use_equip: RichTextLabel = %useEquip
@onready var button_scavenge: RichTextLabel = %scavenge
@onready var scavenge_progress: ProgressBar = %scavengeProgress

@onready var item_description: RichTextLabel = %description
@onready var item_name: RichTextLabel = %name
@onready var item_quote: RichTextLabel = %quote

@onready var power_container: GridContainer = %powerContainer

@onready var coin_amount: RichTextLabel = %coinAmt

@onready var accessories: HBoxContainer = %accessories

var inventory: Array[Item] = []
var posToItem: Dictionary[Vector2, Item] = {}
var posToSlot: Dictionary[Vector2, InvSlot] = {}

var selectedPos := Vector2(0,0)

var coins: int = 0

@export var INV_SIZE: Vector2 = Vector2(5,4)

var invSlotScene = preload("res://Inventory/inv_slot.tscn")

func _ready() -> void:
  coins = STARTING_COINS
  
  var x = 0
  var y = 0
  for i in range(INV_SIZE.x * INV_SIZE.y) :
    var panel: InvSlot = invSlotScene.instantiate()
    
    invGrid.add_child(panel)
    
    posToSlot[Vector2(x,y)] = panel
    
    unselectSlot(Vector2(x,y))
        
    x += 1
    if x >= invGrid.columns :
      x = 0
      y += 1
  
  for i in range(3) :
    var slot: InvSlot = invSlotScene.instantiate()
    accessories.add_child(slot)
    
    posToSlot[Vector2(i-3, 0)] = slot
  
  if OS.is_debug_build() :
    #region STARTING ACCESSORIES
    # addItem(load("res://Items/Accessories/adrenaline.tres"))
    # addItem(load("res://Items/Accessories/alchemy_kit.tres"))
    # addItem(load("res://Items/Accessories/bandaid_kit.tres"))
    # addItem(load("res://Items/Accessories/bloodthirst.tres"))
    # addItem(load("res://Items/Accessories/bottomless_mana_pouch.tres"))
    # addItem(load("res://Items/Accessories/chitin_extractor.tres"))
    # addItem(load("res://Items/Accessories/combo_gloves.tres"))
    # addItem(load("res://Items/Accessories/crystal_core.tres"))
    # addItem(load("res://Items/Accessories/defensive_matrix.tres"))
    # addItem(load("res://Items/Accessories/equalizer.tres"))
    # addItem(load("res://Items/Accessories/flimsy_shield.tres"))
    # addItem(load("res://Items/Accessories/honey_drop.tres"))
    # addItem(load("res://Items/Accessories/life_support.tres"))
    # addItem(load("res://Items/Accessories/lucky_dice.tres"))
    # addItem(load("res://Items/Accessories/metal_scarf.tres"))
    # addItem(load("res://Items/Accessories/rage_brew.tres"))
    # addItem(load("res://Items/Accessories/ram_horns.tres"))
    # addItem(load("res://Items/Accessories/reactive_nanites.tres"))
    # addItem(load("res://Items/Accessories/regen_band.tres"))
    # addItem(load("res://Items/Accessories/retaliatory_instinct.tres"))
    # addItem(load("res://Items/Accessories/thorn_container.tres"))
    # addItem(load("res://Items/Accessories/true_self.tres"))
    # addItem(load("res://Items/Accessories/vampire_fangs.tres"))
    #endregion
    
    #region STARTING POTIONS
    # addItem(load("res://Potions/endurance_potion.tres"))
    # addItem(load("res://Potions/lifeforce_potion.tres"))
    # addItem(load("res://Potions/rage_potion.tres"))
    # addItem(load("res://Potions/speed_potion.tres"))
    #endregion
    
    #region MELLEE WEAPONS
    # addItem(load("res://Weapons/Rusty Sword/worn_down_sword.tres"))
    # addItem(load("res://Weapons/Rusty Mace/worn_down_mace.tres"))
    # addItem(load("res://Weapons/Rusty Dagger/worn_down_dagger.tres"))
    # addItem(load("res://Weapons/Rusty Spear/worn_down_spear.tres"))
    # addItem(load("res://Weapons/Knockback Stick/knockback_stick.tres"))
    # addItem(load("res://Weapons/Wizard Staff/wizard_staff.tres"))
    # addItem(load("res://Weapons/Metronome/metronome.tres"))
    #endregion
    
    #region RANGED WEAPONS
    # addItem(load("res://Weapons/Recurve Bow/recurve_bow.tres"))
    # addItem(load("res://Weapons/Mana Railgun/mana_railgun.tres"))
    # addItem(load("res://Weapons/Burning Coals/burning_coals.tres"))
    # addItem(load("res://Weapons/Worn Down Boomerang/worn_down_boomerang.tres"))
    # addItem(load("res://Weapons/Javelin/javelin.tres"))
    # addItem(load("res://Weapons/Cosmic Judgement/cosmic_judgement.tres"))
    # addItem(load("res://Weapons/Blowpipe/blowpipe.tres"))
    addItem(load("res://Weapons/Crossbow/crossbow.tres"))
    #endregion
    
    #region SUMMON WEAPONS
    # addItem(load("res://Weapons/Fighter Staff/fighter_staff.tres"))
    # addItem(load("res://Weapons/Mechanic's Wrench/mechanics_wrench.tres"))
    # addItem(load("res://Weapons/Devious Looker/devious_looker.tres"))
    # addItem(load("res://Weapons/Magic Katanas/magic_katanas.tres"))
    #endregion
    
    #region SUPPORT WEAPONS
    # addItem(load("res://Weapons/Flute/flute.tres"))
    # addItem(load("res://Weapons/Heal Ray/heal_ray.tres"))
    # addItem(load("res://Weapons/Deck Of Cards/deck_of_cards.tres"))
    # addItem(load("res://Weapons/Battle Standard/battle_standard.tres"))
    # addItem(load("res://Weapons/Spore Sac/spore_sac.tres"))
    # addItem(load("res://Weapons/Syringes/syringes.tres"))
    #endregion
    
    pass
  
  selectSlot(selectedPos)

func selectSlot(pos: Vector2) :
  (posToSlot[pos].get_theme_stylebox("panel") as StyleBoxFlat).bg_color = Color(0.8, .5, 0, .75)

  button_use_equip.visible = false
  button_scavenge.visible = false

  if pos in posToItem :
    var item = posToItem[pos]
    
    button_use_equip.visible = true
    button_scavenge.visible = true
    
    item_name.text = item.NAME
    item_name.add_theme_color_override("default_color", Qol.RARITY_COLORS[item.RARITY])
    item_description.text = item.DESCRIPTION
    item_quote.text = ("[i]'%s'[/i]" % [item.QUOTE]) if len(item.QUOTE) > 0 else ""
    if item.EQUIP_ENCHANTS :
      item_description.text += "\nHas glyphs:\n"
      for i in item.EQUIP_ENCHANTS :
        item_description.text += "%s (lvl %s)\n" % [(i as Glyph).NAME, (i as Glyph).glyph_level]
        
    if item is Weapon :
      button_use_equip.text = "(%s) Equip" % [button_equip]
      if DISPLAY_PLAYER and !DISPLAY_PLAYER.weapon.canSwap :
        button_use_equip.text = "Cannot equip right now"
    elif item.IS_ACCESSORY and DISPLAY_PLAYER :
      if selectedPos.x >= 0 :
        button_use_equip.text = "(%s) Equip" % [button_equip]
        
        for i in DISPLAY_PLAYER.accessories :
          if i and i.NAME == item.ACCESSORY.NAME :
            button_use_equip.text = "Cannot equip (already equipped)"
            break
        
        var empty: bool = false
        for i in DISPLAY_PLAYER.accessories :
          if !i :
            empty = true
            break
        if !empty:
          button_use_equip.text = "Cannot equip (full)"
      else :
        button_use_equip.text = "(%s) Unequip" % [button_equip]
    else :
      button_use_equip.text = "(%s) Use" % [button_equip]
      if item.MAX_CHARGES > 1 :
        button_use_equip.text += " (%s use%s left)" % [item.MAX_CHARGES - item.charges_used, "" if item.MAX_CHARGES - item.charges_used == 1 else "s"]

  item_description.visible = button_use_equip.visible
  item_name.visible = button_use_equip.visible
  item_quote.visible = button_use_equip.visible

func unselectSlot(pos: Vector2) :
  (posToSlot[pos].get_theme_stylebox("panel") as StyleBoxFlat).bg_color = Color(0, 0, 0, .75)

var dropItemScene = preload("res://Dropped Item/dropped_item.tscn")

func addItem(item: Item) :
  # if item.GLYPH_SHARD :
  #   enchantScreen.addGlyphShards(item.GLYPH, item.SHARD_NUM)
  #   return
  
  if len(inventory) >= INV_SIZE.x * INV_SIZE.y :
    var i: DroppedItem = dropItemScene.instantiate()
    i.ITEM = item.duplicate()
    get_tree().get_root().add_child.call_deferred(i)
    return
    
  inventory.append(item.duplicate())
  
  for y in range(INV_SIZE.y) :
    for x in range(INV_SIZE.x) :
      if !Vector2(x,y) in posToItem :
        posToItem[Vector2(x,y)] = item
        
        var tex := PlaceholderTexture2D.new() if !item.TEXTURE else item.TEXTURE
        posToSlot[Vector2(x,y)].TEXTURE.texture = tex
        
        unselectSlot(selectedPos)
        selectSlot(selectedPos)
        
        return 

var moved = false

var can_open = true
var can_use = true

func removeItem(pos: Vector2) :
  posToItem.erase(pos)
  posToSlot[pos].TEXTURE.texture = null
  inventory.pop_at(0)
  
  unselectSlot(pos)
  selectSlot(pos)

var enchant_open = false
var can_toggle_inv = true

@onready var enchantScreen: EnchantScreen = %enchantScreen

func _process(_delta: float) -> void:
  coin_amount.text = "%s coin%s" % [coins, "" if coins == 1 else "s"]
  
  %scavengeProgress.visible = scavenge_progress.value > 0
  
  if !can_open :
    can_open = !Input.is_action_pressed("inventory") and !Input.is_action_pressed("k_inventory")
    
  if DISPLAY_PLAYER == null :
    return
  
  enchantScreen.DISPLAY_PLAYER = DISPLAY_PLAYER
  
  # if Input.is_joy_button_pressed(DISPLAY_PLAYER.DEVICE_ID, JOY_BUTTON_X) :
  #   if can_toggle_inv :
  #     enchant_open = !enchant_open
  #     enchantScreen.reset()
  #   can_toggle_inv = false
  # else :
  #   can_toggle_inv = true
  
  enchantScreen.visible = enchant_open
    
  if enchant_open :
    return
    
  if !can_use :
    can_use = !Input.is_joy_button_pressed(DISPLAY_PLAYER.DEVICE_ID, JOY_BUTTON_A) if DISPLAY_PLAYER.DEVICE_ID >= 0 else Input.is_action_just_pressed("k_attack")
  
  var axisX = Input.get_joy_axis(DISPLAY_PLAYER.DEVICE_ID, JOY_AXIS_LEFT_X) if DISPLAY_PLAYER.DEVICE_ID >= 0 else Input.get_axis("k_left", "k_right")
  var axisY = Input.get_joy_axis(DISPLAY_PLAYER.DEVICE_ID, JOY_AXIS_LEFT_Y) if DISPLAY_PLAYER.DEVICE_ID >= 0 else Input.get_axis("k_up", "k_down")
  var axis = Vector2.ZERO
  
  if axisX < -.3 : axis.x = -1
  if axisX > .3 : axis.x = 1
  if axisY < -.3 : axis.y = -1
  if axisY > .3 : axis.y = 1
  
  if axis == Vector2.ZERO :
    moved = false
  elif !moved :
    unselectSlot(selectedPos)
    selectedPos += axis
    
    if selectedPos.x < -3 : selectedPos.x += INV_SIZE.x + 3
    if selectedPos.x >= INV_SIZE.x : selectedPos.x -= INV_SIZE.x + 3
    
    if selectedPos.y < 0 : selectedPos.y += INV_SIZE.y
    if selectedPos.y >= INV_SIZE.y : selectedPos.y -= INV_SIZE.y
    
    if selectedPos.x < 0 : selectedPos.y = 0
    
    selectSlot(selectedPos)
    moved = true
  
  if selectedPos in posToItem :
    if Input.is_joy_button_pressed(DISPLAY_PLAYER.DEVICE_ID, JOY_BUTTON_B) if DISPLAY_PLAYER.DEVICE_ID >= 0 else Input.is_action_pressed("k_roll") :
      %scavengeProgress.value += .5
    else :
      %scavengeProgress.value = 0
    
    if %scavengeProgress.value >= 100 :
      coins += int(posToItem[selectedPos].getItemCoinValue() * .75)
      removeItem(selectedPos)
      
      if selectedPos.x < 0 :
        DISPLAY_PLAYER.accessories[3 + selectedPos.x] = null
    
    if (Input.is_joy_button_pressed(DISPLAY_PLAYER.DEVICE_ID, JOY_BUTTON_A) if DISPLAY_PLAYER.DEVICE_ID >= 0 else Input.is_action_just_pressed("k_attack")) and can_use :
      if posToItem[selectedPos] is Weapon and DISPLAY_PLAYER.weapon.canSwap :
        addItem(DISPLAY_PLAYER.weapon)
        
        wname.text = posToItem[selectedPos].NAME
        wicon.texture = posToItem[selectedPos].TEXTURE
      
      posToItem[selectedPos].use(DISPLAY_PLAYER)

      if posToItem[selectedPos].charges_used >= posToItem[selectedPos].MAX_CHARGES :
        removeItem(selectedPos)
      
      if posToItem[selectedPos] is Potion or (posToItem[selectedPos] is Weapon and DISPLAY_PLAYER.weapon.canSwap) :
        removeItem(selectedPos)
      else :
        if posToItem[selectedPos].IS_ACCESSORY :
          if selectedPos.x < 0 :
            addItem(posToItem[selectedPos])
            DISPLAY_PLAYER.accessories[selectedPos.x+3] = null
            removeItem(selectedPos)
          else :
            var equip_slot = -1
            for i in range(len(DISPLAY_PLAYER.accessories)) :
              if DISPLAY_PLAYER.accessories[i] == null and equip_slot == -1 :
                equip_slot = i
              
              if DISPLAY_PLAYER.accessories[i] and DISPLAY_PLAYER.accessories[i].NAME == posToItem[selectedPos].ACCESSORY.NAME :
                equip_slot = -1
                break
            
            if equip_slot >= 0 :
              var a: Accessory = posToItem[selectedPos].ACCESSORY.duplicate()
              a.NAME = posToItem[selectedPos].NAME
              a.DESC = posToItem[selectedPos].DESCRIPTION
              a.QUOTE = posToItem[selectedPos].QUOTE
              a.ICON = posToItem[selectedPos].TEXTURE
              DISPLAY_PLAYER.accessories[equip_slot] = a
              posToItem[Vector2(equip_slot-3, 0)] = posToItem[selectedPos].duplicate()
              posToSlot[Vector2(equip_slot-3, 0)].TEXTURE.texture = posToItem[selectedPos].TEXTURE
              removeItem(selectedPos)
            
          DISPLAY_PLAYER.recalculate_accessories()
        
      unselectSlot(selectedPos)
      selectSlot(selectedPos)
      
      can_use = false
  
  if (Input.is_joy_button_pressed(DISPLAY_PLAYER.DEVICE_ID, JOY_BUTTON_START) if DISPLAY_PLAYER.DEVICE_ID >= 0 else Input.is_action_just_pressed("k_inventory")) and can_open :
    visible = false
    get_tree().paused = false
    DISPLAY_PLAYER = null
    can_open = false

var button_equip = "A"
func showMyInventory(p: Player) :
  if !can_open :
    return
  
  %powerups.visible = len(p.powers) > 0
  
  button_equip = "A" if p.DEVICE_ID >= 0 else "X"
  %scavenge.text = "(B) Scavenge" if p.DEVICE_ID >= 0 else "(C) Scavenge"
  
  unselectSlot(selectedPos)
  selectSlot(selectedPos)
  
  DISPLAY_PLAYER = p
  visible = true
  get_tree().paused = true
  
  %playerName.text = p.nametag.text
  
  wname.text = p.weapon.NAME
  wicon.texture = p.weapon.TEXTURE
  
  sname.text = p.spell.NAME
  sicon.texture = p.spell.TEXTURE

  for i in power_container.get_children() :
    i.queue_free()
  
  for i in p.powers :
    var hbox := HBoxContainer.new()
    hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    hbox.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
    
    var tex := TextureRect.new()
    tex.texture = i.TEXTURE if i.TEXTURE else PlaceholderTexture2D.new()
    tex.custom_minimum_size = Vector2(96, 96)
    
    var info := RichTextLabel.new()
    info.text = "%s\n%s stack%s" % [i.NAME, i.stack_level, "" if i.stack_level == 1 else "s"]
    info.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
    
    hbox.add_child(tex)
    hbox.add_child(info)
    
    power_container.add_child(hbox)
  
  var x := -3
  for i in p.accessories :
    if i :
      posToSlot[Vector2(x, 0)].TEXTURE.texture = i.ICON
      
      var item := Item.new()
      item.IS_ACCESSORY = true
      item.ACCESSORY = i
      item.DESCRIPTION = i.DESC
      item.NAME = i.NAME
      item.TEXTURE = i.ICON
      item.QUOTE = i.QUOTE
      
      posToItem[Vector2(x, 0)] = item
    else :
      posToSlot[Vector2(x, 0)].TEXTURE.texture = null
      
    x += 1
  
  can_open = false

func _on_wave_manager_room_clear() -> void:
  coins += 5
