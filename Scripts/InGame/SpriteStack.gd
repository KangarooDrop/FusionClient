extends Node2D

class_name SpriteStack

####################################################################################################

const burgerTexture : Texture = preload("res://Art/burger.png")
static func getTestTextures() -> Array:
	var rtn : Array = []
	var w : float = burgerTexture.get_height()
	for i in range(0, burgerTexture.get_width(), w):
		rtn.append(makeAtlas(burgerTexture, Rect2(i, 0, w, w)))
	return rtn
static func makeAtlas(texture : Texture, rect : Rect2) -> AtlasTexture:
	var atlasTexture : AtlasTexture = AtlasTexture.new()
	atlasTexture.atlas = texture
	atlasTexture.region = rect
	return atlasTexture

####################################################################################################

#How high up the stack starts
var hOffset : float = 0.0 : set=setHOffset
func setHOffset(val : float):
	var d : float = val - hOffset
	for sprite in spriteNodes:
		sprite.z_index += d
	hOffset = val
#Distance between sprites
var height : float = 4.0
#Rotation relative to the camera
var rotCamera : float = 0.0
#Rotation relative to the local y-axis
var roll : float = 0.0
#The card was flipped over
var wasHidden : bool = false
#Whether the card is flipping over or not
var flipCount : int = 0

var spriteNodes : Array = []

@onready var spriteHolder : Node2D = $SpriteHolder

const FLIP_TIME : float = 0.5

####################################################################################################

func _ready():
	pass

func setRotation(rot : float) -> void:
	self.ROT = rot

func setRoll(roll : float) -> void:
	roll = fmod(roll + 2.0*PI, 2.0*PI)
	
	self.roll = roll
	if self.roll > PI/2.0 and self.roll < 3.0*PI/2.0:
		if not wasHidden:
			wasHidden = true
			for i in range(spriteNodes.size()):
				spriteNodes[i].z_index = hOffset-i
	else:
		if wasHidden:
			wasHidden = false
			for i in range(spriteNodes.size()):
				spriteNodes[i].z_index = hOffset+i

func flip() -> void:
	flipCount += 1

####################################################################################################

func _process(delta):
	if flipCount > 0:
		var lastRoll : float = self.roll
		setRoll(roll + delta*PI*2.0/FLIP_TIME)
		if lastRoll > self.roll:
			flipCount -= 1
			setRoll(0.0)
		elif lastRoll < PI and self.roll >= PI:
			flipCount -= 1
			setRoll(PI)
	
	var cam : CamStack = Util.getCam()
	
	#Scaling the displacement from the camera by the pitch
	#     X
	#          pan down      X
	#     X       =>>        X
	#
	#
	var d : float = (global_position - cam.global_position).dot(Vector2.UP.rotated(cam.rotation))
	var trans : Transform2D = Transform2D()
	trans = trans.rotated(-cam.rotation)
	trans = trans.translated(Vector2(0, d*(1.0-cam.pitch)))
	trans = trans.rotated(cam.rotation)
	spriteHolder.transform = trans
	
	for i in spriteNodes.size():
		var sprite : Sprite2D = spriteNodes[i]
		var trans2 : Transform2D = Transform2D()
		var flipMul : float = (cos(2.0*roll)+1.0)/2.0
		trans2 = trans2.scaled(Vector2(flipMul, 1.0))
		trans2 = trans2.rotated(rotCamera)
		trans2 = trans2.rotated(-cam.rotation)
		trans2 = trans2.scaled(Vector2(1.0, cam.pitch))
		trans2 = trans2.translated(Vector2.UP*hOffset*height + Vector2.UP.rotated(roll) * (i-(spriteNodes.size()-1)/2.0)*height*lerp(1.0, 0.0, cam.pitch))
		trans2 = trans2.rotated(cam.rotation)
		sprite.transform = trans2

func setTextures(textures : Array) -> void:
	for node in spriteNodes:
		node.free()
	for i in range(textures.size()):
		var tex : Texture = textures[i]
		var sprite : Sprite2D = Sprite2D.new()
		sprite.z_index = hOffset+i
		spriteHolder.add_child(sprite)
		spriteNodes.append(sprite)
		sprite.texture = tex
		sprite.position = Vector2(0, -i*height)
