extends SpriteStack

class_name CardNodeStack

var power : int = 1
var toughness : int = 1
var element : CardDataBase.ELEMENT = CardDataBase.ELEMENT.FIRE
var artPath : String = "res://Art/Cards/Fire/Fire1.png"
var backPath : String = "res://Art/Cards/Backs/Back1.png"

func getStackTextures() -> Array:
	var rtn : Array = []
	rtn.append(load(backPath))
	rtn.append(load(artPath))
	rtn.append(load("res://Art/Cards/_TEST/frame_edge.png"))
	rtn.append(load("res://Art/Cards/_TEST/frame_edge.png"))
	rtn.append(makeAtlas(load("res://Art/Cards/Frames/frames.png"), Rect2(element*112.0, 0.0, 112.0, 144.0)))
	return rtn

func _init():
	offset = 1

func _ready():
	setTextures(getStackTextures())
	setRoll(PI)
