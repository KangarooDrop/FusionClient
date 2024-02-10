extends Node

class_name CardNode

@onready var frameSprite : Sprite2D = $FrameSprite
@onready var artSprite : Sprite2D = $ArtSprite
@onready var powerLabel : Label = $PowerLabel
@onready var toughnessLabel : Label = $ToughnessLabel

var cardData : CardData = null

const frameOffset : float = 112.0

func _init():
	pass

func _ready():
	pass

func setCardData(cardData : CardData) -> CardNode:
	self.cardData = cardData
	
	var texture = load(cardData.imagePath)
	if texture != null:
		artSprite.texture = texture
	self.frameSprite.region_rect.position.x = frameOffset * cardData.elements[0]
	self.powerLabel.text = str(cardData.power)
	self.toughnessLabel.text = str(cardData.toughness)
	
	return self
