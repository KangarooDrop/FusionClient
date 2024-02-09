extends Node

class_name CardNode

@onready var frameSprite : Sprite2D = $FrameSprite
@onready var artSprite : Sprite2D = $ArtSprite
@onready var powerLabel : Label = $PowerLabel
@onready var toughnessLabel : Label = $ToughnessLabel

var cardName : String = ""
var imagePath : String = ""
var power : int = -1
var toughness : int = -1
var elements : Array = []
var abilities : Array = []

const frameOffset : float = 112.0

func _init():
	pass

func _ready():
	pass

func setData(parsedData : Dictionary) -> CardNode:
	self.cardName = parsedData['name']
	self.imagePath = parsedData['art_file']
	self.power = parsedData['power']
	self.toughness = parsedData['toughness']
	self.elements = parsedData['elements']
	self.abilities = parsedData['abilities']
	
	var texture = load(imagePath)
	if texture != null:
		artSprite.texture = texture
	self.frameSprite.region_rect.position.x = frameOffset * elements[0]
	self.powerLabel.text = str(self.power)
	self.toughnessLabel.text = str(self.toughness)
	
	return self
