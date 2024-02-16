extends Node2D

class_name ChipNode

const startHeight : float = -64.0
const startScale : float = 2.0
const fallMaxTime : float = 1.0

var fallTimer : float = 0.0

var spriteSlices : Array = []

const height : int = 4
const numBounces : int = 2

static func easePos(t : float) -> float:
	#return 1.0 - abs(cos(3.5*PI*t) / pow(t + 1, 3.0))
	return 1.0 - abs((1-t) * cos(numBounces * PI * pow(2.0, t)))

static func easeRot(t : float) -> float:
	return cos(2.0 * numBounces * PI * pow(2.0, t))

func setColor(color : Color):
	for sprite in spriteSlices:
		sprite.modulate = color

func _ready():
	for i in range(height):
		var sprite : Sprite2D = Sprite2D.new()
		add_child(sprite)
		sprite.texture = Preloader.chipTexture
		sprite.position.y = -i
		spriteSlices.append(sprite)
	setFall()

func _process(delta):
	if fallTimer < fallMaxTime:
		fallTimer += delta
		setFall()

func setFall() -> void:
	var t : float = fallTimer / fallMaxTime
	var eP : float = easePos(t)
	var eR : float = easeRot(t)
	for i in range(spriteSlices.size()):
		var sprite : Sprite2D = spriteSlices[i]
		sprite.position = Vector2(0, lerp(startHeight, 0.0, eP) - i)
		sprite.scale.x = lerp(startScale, 1.0, eP)
		sprite.scale.y = lerp(0.0, 1.0, eR)
