extends Node

class_name CardNode

@onready var frameSprite : Sprite2D = $FrameSprite
@onready var artSprite : Sprite2D = $ArtSprite
@onready var powerLabel : Label = $PowerLabel
@onready var toughnessLabel : Label = $ToughnessLabel

var cardData : CardDataGame = null

const frameOffset : float = 112.0

signal card_pressed(buttonIndex : int)

func _init():
	pass

func _ready():
	pass

func setCardData(cardData : CardDataBase) -> CardNode:
	self.cardData = cardData
	
	var texture = load("res://Art/Cards/" + cardData.imagePath)
	if texture != null:
		artSprite.texture = texture
	self.frameSprite.region_rect.position.x = frameOffset * cardData.elements[0]
	self.powerLabel.text = str(cardData.power)
	self.toughnessLabel.text = str(cardData.toughness)
	
	return self

var isHovering : bool = false
func onMouseEnter() -> void:
	isHovering = true
func onMouseExit() -> void:
	isHovering = false

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		if isHovering:
			emit_signal("card_pressed", event.button_index)
