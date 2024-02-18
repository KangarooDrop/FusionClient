extends SpriteStack

class_name ChipStack

var color : Color = Color(1.0, 1.0, 1.0, 1.0) : set=setColor
func setColor(newColor : Color):
	color = newColor
	modulate = color

var velocity : Vector3 = Vector3.ZERO

func getStackTextures() -> Array:
	var rtn : Array = []
	var chipTexture : Texture = load("res://Art/Cards/_TEST/chip_sstack.png")
	for i in range(5):
		rtn.append(makeAtlas(chipTexture, Rect2((4-i)*32.0, 0.0, 32.0, 32.0)))
	for i in range(4):
		rtn.append(makeAtlas(chipTexture, Rect2((i+1)*32.0, 0.0, 32.0, 32.0)))
	return rtn

func _init():
	offset = 1
	#flipCount = 10
	height = 64
	velocity.z = 200

func _ready():
	setTextures(getStackTextures())

func _process(delta):
	super._process(delta)
	if height > 0:
		flipCount = 1
		velocity.z -= 500 * delta
		height += velocity.z * delta
	elif height < 0:
		height = 0
		if velocity.z > -200:
			velocity.z = 0.0
		else:
			velocity.z = -velocity.z*0.35
	else:
		pass
	
	position.x += velocity.x * delta
	position.y += velocity.y * delta

func onClick(buttonIndex) -> void:
	if buttonIndex == MOUSE_BUTTON_LEFT:
		velocity.z = 380
		height += 1

