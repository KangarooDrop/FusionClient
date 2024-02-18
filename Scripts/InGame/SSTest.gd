extends Node2D

@onready var stack0 : SpriteStack = $SpriteStack
@onready var stack1 : SpriteStack = $SpriteStack2
@onready var stack2 : SpriteStack = $SpriteStack3

@onready var cardNode : CardNodeStack = $HandHolder/CardNodeStack

@onready var chip : ChipStack = $ChipStack

@onready var cam : CamStack = $Camera2D

func _ready():
	stack0.setTextures(SpriteStack.getTestTextures())
	stack0.height = 10
	stack0.rollAxis = 0.5
	
	var pixPerLevel : float = 8.0
	var ts1 : Array = []
	var carTexture : Texture = load("res://Art/Cards/_TEST/ss_car.png")
	for i in range(11):
		for j in range(round(pixPerLevel)):
			ts1.append(SpriteStack.makeAtlas(carTexture, Rect2(15.0*i, 0.0, 15.0, 32.0)))
	stack1.offset = 2.0/pixPerLevel
	stack1.setTextures(ts1)
	
	stack2.offset = 2
	var ts2 : Array = []
	ts2.append(load("res://Art/Cards/_TEST/back.png"))
	ts2.append(load("res://Art/Cards/_TEST/art.png"))
	ts2.append(load("res://Art/Cards/_TEST/frame_edge.png"))
	ts2.append(load("res://Art/Cards/_TEST/frame_edge.png"))
	ts2.append(load("res://Art/Cards/_TEST/frame.png"))
	stack2.setTextures(ts2)
	stack2.lockPosition.x = 300.0

const WAIT_TIME : float = 3.0
var timer : float = 0.0

func _process(delta):
	timer += delta
	
	var mov : Vector2 = Vector2()
	if Input.is_action_pressed("up"):
		mov.y -= 1
	if Input.is_action_pressed("down"):
		mov.y += 1
	if Input.is_action_pressed("right"):
		mov.x += 1
	if Input.is_action_pressed("left"):
		mov.x -= 1
	if Input.is_key_pressed(KEY_Q):
		cam.rotation += 2*PI*delta
	if Input.is_key_pressed(KEY_E):
		cam.rotation -= 2*PI*delta
	moveCam(mov, delta)

func moveCam(mov : Vector2, delta : float) -> void:
	cam.position += mov.rotated(cam.rotation) * 512.0*delta

const dpToRot : float = PI*2.0/600
const dpToFlip : float = 1.0/300
var rotatingCam : bool = false
var movingCam : bool = false
func _input(event):
	if event is InputEventMouseButton and not event.is_echo():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotatingCam = event.is_pressed()
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			movingCam = event.is_pressed()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			cam.zoom *= 1.0/1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			cam.zoom *= 1.1
	elif event is InputEventMouseMotion:
		if rotatingCam:
			cam.rotation += event.relative.x * dpToRot
			cam.pitch = max(0.5, min(1.0, cam.pitch+event.relative.y * dpToFlip))
		if movingCam:
			var dp : Vector2 = event.relative/cam.zoom
			dp.y = dp.y/cam.pitch
			cam.position -= dp.rotated(cam.rotation)
