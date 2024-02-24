extends Node2D

class_name ChipNode

const startHeight : float = -64.0*2.0
const startScale : float = 2.0
const fallMaxTime : float = 1.5

var fallTimer : float = 0.0

@onready var sprite : Sprite2D = $Sprite2D

const numBounces : int = 2

static func easePos(t : float) -> float:
	return 1.0 - abs((1-t) * cos(numBounces * PI * pow(2.0, t)))

static func easeRot(t : float) -> float:
	return cos(2.0 * numBounces * PI * pow(2.0, t))

func setColor(color : Color):
	modulate = color

func _ready():
	setFall()

func _process(delta):
	if fallTimer < fallMaxTime:
		fallTimer += delta
		setFall()

func setFall() -> void:
	var t : float = fallTimer / fallMaxTime
	var eP : float = easePos(t)
	var eR : float = easeRot(t)
	sprite.position = Vector2(0, lerp(startHeight, 0.0, eP))
	sprite.scale.y = lerp(startScale, 1.0, eP)
	sprite.region_rect.position.x = int(sprite.texture.get_width() * (1.0 - abs(eR)))/32 * 32.0
