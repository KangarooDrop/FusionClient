extends Node2D

class_name CardNode

@onready var holder : Node2D = $Holder
@onready var front : Node2D = $Holder/Front
@onready var back : Node2D = $Holder/Back

@onready var rulesHolder : Control = $Holder/Front/RulesHolder
@onready var rulesLabel : Label = $Holder/Front/RulesHolder/Label
func getRulesWidth() -> float:
	return rulesLabel.size.x

@onready var frameSprite : Sprite2D = $Holder/Front/FrameSprite
@onready var artSprite : Sprite2D = $Holder/Front/ArtSprite
@onready var powerLabel : Label = $Holder/Front/PowerLabel
@onready var toughnessLabel : Label = $Holder/Front/ToughnessLabel

var showRules : bool = false : set=setShowRules
func setShowRules(val : bool):
	showRules = val

var revealed : bool = false : set=setRevealed
func setRevealed(val : bool) -> void:
	revealed = val;

var roll : float = 0.0 : set=setRoll
func setRoll(val : float) -> void:
	val = fmod(val+2*PI, 2*PI)
	roll = val
	scale.x = cos(roll)
	revealed = roll > 3.0*PI/2.0 or roll < PI/2.0
	front.visible = revealed
	back.visible = not revealed

var flipCount : int = 0
func flip() -> void:
	flipCount = 1

func flipToFront() -> void:
	if revealed:
		flipCount = 2
	else:
		flipCount = 1

func flipToBack() -> void:
	if revealed:
		flipCount = 1
	else:
		flipCount = 2

var cardData : CardDataGame = null

const frameOffset : float = 112.0
const FLIP_TIME : float = 0.25
const RULES_EXPAND_TIME : float = 0.25

signal card_pressed(buttonIndex : int)

signal flipped_to_front()
signal flipped_to_back()
signal flipped()

signal rules_shown()
signal rules_hidden()

func _init():
	pass

func _ready():
	pass

func setCardData(cardData : CardDataBase) -> CardNode:
	self.cardData = cardData
	updateAll()
	return self

func updateStats() -> void:
	if cardData != null:
		powerLabel.text = str(cardData.power)
		toughnessLabel.text = str(cardData.toughness)

func updateArt() -> void:
	if cardData != null:
		var path : String = "res://Art/Cards/" + cardData.imagePath
		if self.artSprite.texture == null or self.artSprite.texture.resource_path != path:
			self.artSprite.texture = load(path)

func updateFrame() -> void:
	self.frameSprite.region_rect.position.x = frameOffset * cardData.elements[0]
	
func updateRoll() -> void:
	setRoll(PI if cardData == null or not cardData.revealed else 0.0)

func updateAll() -> void:
	updateStats()
	updateArt()
	updateFrame()
	updateRoll()

func _process(delta):
	if flipCount > 0:
		var lastRoll : float = roll
		setRoll(roll + PI*delta / FLIP_TIME)
		if lastRoll > roll:
			flipCount -= 1
			emit_signal("flipped")
			emit_signal("flipped_to_front")
		elif (lastRoll < PI and roll >= PI):
			flipCount -= 1
			emit_signal("flipped")
			emit_signal("flipped_to_back")
	
	if showRules and rulesHolder.size.x < getRulesWidth():
		rulesHolder.size.x += getRulesWidth() * delta / RULES_EXPAND_TIME
		if rulesHolder.size.x >= getRulesWidth():
			emit_signal("rules_shown")
	elif not showRules and rulesHolder.size.x > 0:
		rulesHolder.size.x -= getRulesWidth() * delta / RULES_EXPAND_TIME
		if rulesHolder.size.x <= 0:
			emit_signal("rules_hidden")

var isHovering : bool = false
func onMouseEnter() -> void:
	isHovering = true
func onMouseExit() -> void:
	isHovering = false

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		if isHovering:
			emit_signal("card_pressed", event.button_index)
