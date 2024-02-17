extends Node2D

@onready var stack0 : SpriteStack = $SpriteStack
@onready var stack1 : SpriteStack = $SpriteStack2
@onready var stack2 : SpriteStack = $SpriteStack3
@onready var cam : CamStack = $Camera2D

func _ready():
	stack0.setTextures(SpriteStack.getTestTextures())
	stack0.hOffset = 10
	
	var ts1 : Array = []
	ts1.append(load("res://Art/Cards/_TEST/back.png"))
	ts1.append(load("res://Art/Cards/_TEST/art.png"))
	ts1.append(load("res://Art/Cards/_TEST/frame.png"))
	stack1.setTextures(ts1)
	
	stack2.height = 2
	var ts2 : Array = []
	ts2.append(load("res://Art/Cards/_TEST/back.png"))
	ts2.append(load("res://Art/Cards/_TEST/art.png"))
	ts2.append(load("res://Art/Cards/_TEST/frame_edge.png"))
	ts2.append(load("res://Art/Cards/_TEST/frame_edge.png"))
	ts2.append(load("res://Art/Cards/_TEST/frame.png"))
	stack2.setTextures(ts2)

const WAIT_TIME : float = 3.0
var timer : float = 0.0

func _process(delta):
	timer += delta
	if timer >= WAIT_TIME:
		stack0.flip()
		stack1.flip()
		stack2.flip()
		timer = 0.0
	
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
