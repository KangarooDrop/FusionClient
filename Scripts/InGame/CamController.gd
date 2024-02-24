extends Camera2D

var mouseGlobalPosition : Vector2 = Vector2()
var mouseCamPosition : Vector2 = Vector2()

const camZoomAmount : float = 1.1
const camMoveSpeed : float = 512.0
const camRotSpeed : float = PI
var movingCam : bool = false
var velocity : Vector2 = Vector2()

func _input(event):
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					setZoom(zoom * camZoomAmount)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					setZoom(zoom / camZoomAmount)
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				movingCam = event.pressed

func resetCam() -> void:
	position = Vector2()
	rotation = 0.0
	zoom = Vector2.ONE

func setZoom(newZoom : Vector2):
	var maxX : float = 5.0
	var minX : float = 0.2
	newZoom.x = min(maxX, max(minX, newZoom.x))
	newZoom.y = min(maxX, max(minX, newZoom.y))
	
	var viewportSize : Vector2 = get_viewport_rect().size
	var oldMousePosition : Vector2 = (mouseCamPosition - viewportSize / 2.0) / self.zoom
	var newMousePosition : Vector2 = (mouseCamPosition - viewportSize / 2.0) / newZoom
	var dp : Vector2 = oldMousePosition - newMousePosition
	
	self.zoom = newZoom
	self.position += dp

func _process(delta):
	var mpLastFrame : Vector2 = mouseGlobalPosition
	mouseGlobalPosition = get_global_mouse_position()
	mouseCamPosition = get_viewport().get_mouse_position()
	if movingCam:
		var dp : Vector2 = mpLastFrame - mouseGlobalPosition
		position += dp
		mouseGlobalPosition += dp
	
	var mov : Vector2 = Vector2()
	if Input.is_key_pressed(KEY_W):
		mov += Vector2.UP.rotated(rotation) * camMoveSpeed
	if Input.is_key_pressed(KEY_S):
		mov += Vector2.DOWN.rotated(rotation) * camMoveSpeed
	if Input.is_key_pressed(KEY_A):
		mov += Vector2.LEFT.rotated(rotation) * camMoveSpeed
	if Input.is_key_pressed(KEY_D):
		mov += Vector2.RIGHT.rotated(rotation) * camMoveSpeed
	
	velocity = lerp(velocity, mov, delta * (12.0 if velocity.length_squared() < mov.length_squared() else 8.0))
	position += velocity*delta
	
	if Input.is_key_pressed(KEY_Q):
		rotation -= camRotSpeed * delta
	if Input.is_key_pressed(KEY_E):
		rotation += camRotSpeed * delta
