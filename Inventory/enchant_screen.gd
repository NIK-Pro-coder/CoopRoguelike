extends Control

class_name EnchantScreen

@export var DISPLAY_PLAYER: Player

@export var ALL_GLYPHS: Array[Glyph]

@export var GLYPH_DISPLAY_SIZE: Vector2 = Vector2(3, 3)

@onready var wSlot: InvSlot = %wslot
@onready var wName: RichTextLabel = %wname

@onready var glyphGrid: GridContainer = %glyphs
@onready var equipEnchants: VBoxContainer = %currEnchants

var glyphShards: Dictionary[String, int] = {}

func addGlyphShards(glyph: Glyph, amt: int) :
  glyphShards[glyph.NAME] += amt
  print(glyphShards)

var glyphDispScene = preload("res://Inventory/glyph_display.tscn")
var posToDisp: Dictionary[Vector2, GlyphDisplay] = {}
var glyphToDisp: Dictionary[String, GlyphDisplay] = {}

func _ready() -> void:
  var pos = Vector2.ZERO
  
  for i in ALL_GLYPHS :
    glyphShards[i.NAME] = 0
    
    var disp: GlyphDisplay = glyphDispScene.instantiate()
    disp.GLYPH = i.duplicate()
    glyphGrid.add_child(disp)
    posToDisp[pos] = disp
    glyphToDisp[i.NAME] = disp
    
    pos.x += 1
    if pos.x >= GLYPH_DISPLAY_SIZE.x :
      pos.x = 0
      pos.y += 1
  
  for i in range(GLYPH_DISPLAY_SIZE.x * GLYPH_DISPLAY_SIZE.y - len(ALL_GLYPHS)) :
    var c := Control.new()
    c.size_flags_horizontal |= Control.SIZE_EXPAND
    c.size_flags_vertical |= Control.SIZE_EXPAND
    glyphGrid.add_child(c)
  
  selectSlot(selectPos)

var selectPos = Vector2(0,0)
var moved = false

func unselectSlot(pos: Vector2) :
  posToDisp[pos].color = Color.BLACK

@onready var glyphDesc: RichTextLabel = %glyphDesc

func selectSlot(pos: Vector2) :
  posToDisp[pos].color = Color(.8, .5, 0, .75) if canApply else Color(1, .5, 0, .75) 
  glyphDesc.text = posToDisp[pos].GLYPH.DESCRIPTION

var applied = false

@onready var applyGlyph: RichTextLabel = %applyGlyph

var canApply = false

func _process(_delta: float) -> void:
  if !visible :
    return
  
  if !DISPLAY_PLAYER :
    return

  canApply = glyphShards[posToDisp[selectPos].GLYPH.NAME] >= posToDisp[selectPos].GLYPH.SHARDS_FOR_LEVEL 
  var present = false
  for i in DISPLAY_PLAYER.weapon.enchants :
    if i.NAME == posToDisp[selectPos].GLYPH.NAME :
      present = true
      break
  
  canApply = canApply and (present or len(DISPLAY_PLAYER.weapon.enchants) < DISPLAY_PLAYER.weapon.enchantability)

  selectSlot(selectPos)
  
  var axisX = Input.get_joy_axis(DISPLAY_PLAYER.DEVICE_ID, JOY_AXIS_LEFT_X)
  var axisY = Input.get_joy_axis(DISPLAY_PLAYER.DEVICE_ID, JOY_AXIS_LEFT_Y)
  var axis = Vector2.ZERO
  
  if axisX < -.3 : axis.x = -1
  if axisX > .3 : axis.x = 1
  if axisY < -.3 : axis.y = -1
  if axisY > .3 : axis.y = 1
  
  if axis == Vector2.ZERO :
    moved = false
  elif !moved :
    moved = true
    
    unselectSlot(selectPos)
    
    while true :
      selectPos += axis
    
      if selectPos.x < 0 : selectPos.x += GLYPH_DISPLAY_SIZE.x
      if selectPos.x >= GLYPH_DISPLAY_SIZE.x : selectPos.x -= GLYPH_DISPLAY_SIZE.x
      
      if selectPos.y < 0 : selectPos.y += GLYPH_DISPLAY_SIZE.y
      if selectPos.y >= GLYPH_DISPLAY_SIZE.y : selectPos.y-= GLYPH_DISPLAY_SIZE.y
      
      if selectPos in posToDisp :
        break
  
  wSlot.TEXTURE.texture = DISPLAY_PLAYER.weapon.texture
  wName.text = DISPLAY_PLAYER.weapon.weapon_name

  applyGlyph.visible = canApply

  if Input.is_joy_button_pressed(DISPLAY_PLAYER.DEVICE_ID, JOY_BUTTON_A) :
    if !applied and canApply :
      glyphShards[posToDisp[selectPos].GLYPH.NAME] -= posToDisp[selectPos].GLYPH.SHARDS_FOR_LEVEL
      selectSlot(selectPos)
      
      if present :
        for i in DISPLAY_PLAYER.weapon.enchants :
          if i.NAME == posToDisp[selectPos].GLYPH.NAME :
            i.glyph_level += 1
        reset()
      else :
        var glyf: Glyph = posToDisp[selectPos].GLYPH.duplicate()
        glyf.player = DISPLAY_PLAYER
        DISPLAY_PLAYER.weapon.enchants.append(glyf)
        var txt := RichTextLabel.new()
        txt.fit_content = true
        txt.text = "%s (lvl %s)" % [posToDisp[selectPos].GLYPH.NAME, 1]
        txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        equipEnchants.add_child(txt)
      
      applied = true
  else :
    applied = false

  for i in glyphToDisp :
    glyphToDisp[i].SHARD_NUM = glyphShards[i]

func reset() :
  for i in equipEnchants.get_children() :
    i.queue_free()

  for i in DISPLAY_PLAYER.weapon.enchants :
    var txt := RichTextLabel.new()
    txt.fit_content = true
    txt.text = "%s (lvl %s)" % [i.NAME, i.glyph_level]
    txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    equipEnchants.add_child(txt)
