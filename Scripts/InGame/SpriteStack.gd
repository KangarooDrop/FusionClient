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
var height : float = 0.0 : set=setHeight
func setHeight(val : float):
	height = val
	if self.roll > PI/2.0 and self.roll < 3.0*PI/2.0:
			for i in range(spriteNodes.size()):
				spriteNodes[i].z_index = height-i
	else:
			for i in range(spriteNodes.size()):
				spriteNodes[i].z_index = height+i
#Distance between sprites
var offset : float = 4.0
#Rotation relative to the camera
var rotCamera : float = 0.0
#Rotation relative to the local y-axis
var roll : float = 0.0
#The card was flipped over
var wasHidden : bool = false
#Whether the card is flipping over or not
var flipCount : int = 0
#Roll Axis : (0.0=about the bottom, 0.5=about the center, 1.0=about the top)
var rollAxis : float = 0.5
#Automatically set, determines the size of the sprites passed
var clickSize : Vector2 = Vector2()
#Handles mouse input and clicks
var mouseHovering : bool = false
var isPressing : bool = false
#Used to counteract the effects of height and camera rotation (e.g. in hand)
var flatness : float = 0.0

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
				spriteNodes[i].z_index = height-i
	else:
		if wasHidden:
			wasHidden = false
			for i in range(spriteNodes.size()):
				spriteNodes[i].z_index = height+i

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
		var dAxis : float = -(spriteNodes.size()-1) * rollAxis
		trans2 = trans2.translated(Vector2.UP*height*(1.0-cam.pitch) + Vector2.UP.rotated(roll) * (i+dAxis)*offset*(1.0-cam.pitch))
		trans2 = trans2.rotated(cam.rotation)
		sprite.transform = trans2
		
	var trans3 : Transform2D = Transform2D()
	trans3 = trans3.rotated(-cam.rotation)
	trans3 = trans3.scaled(Vector2(1.0, 1.0/cam.pitch))
	trans3 = trans3.rotated(cam.rotation)
	var mousePosTrans : Vector2 = trans3*(get_global_mouse_position()-spriteNodes[0].global_position)
	mouseHovering = abs(mousePosTrans.x) < clickSize.x/2.0 and abs(mousePosTrans.y) < clickSize.y/2.0
	
	if not mouseHovering:
		isPressing = false

func setTextures(textures : Array) -> void:
	var colSize : Vector2 = Vector2()
	for node in spriteNodes:
		node.free()
	for i in range(textures.size()):
		var tex : Texture = textures[i]
		var sprite : Sprite2D = Sprite2D.new()
		sprite.z_index = height+i
		spriteHolder.add_child(sprite)
		spriteNodes.append(sprite)
		sprite.texture = tex
		sprite.position = Vector2(0, -i*offset)
		var size : Vector2 = tex.get_size()
		if size.x > colSize.x:
			colSize.x = size.x
		if size.y > colSize.y:
			colSize.y = size.y
	clickSize = colSize

func _input(event):
	if event is InputEventMouseButton and not event.is_echo() and mouseHovering:
		if event.is_pressed():
			onButtonDown(event.button_index)
		else:
			onButtonUp(event.button_index)

func onButtonUp(buttonIndex : int) -> void:
	isPressing = true

func onButtonDown(buttonIndex : int) -> void:
	if isPressing:
		onClick(buttonIndex)

func onClick(buttonIndex : int) -> void:
	pass
