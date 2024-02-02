extends Node2D

@onready var cam : Camera2D = $Camera2D

@onready var boardNode : BoardEditable = $BoardEditable
@onready var pathHighlight : Line2D = $PathHighlight
@onready var ui : Control = $CanvasLayer/UI

####################################################################################################
#Menu Buttons

func onNewPressed() -> void:
	openNewDialog()

func onSavePressed() -> void:
	openSaveDialog()

func onLoadPressed() -> void:
	openLoadDialog()

func onExitPressed() -> void:
	openExitDialog()
	
####################################################################################################

var saveFolder : String = ProjectSettings.globalize_path("res://JSON/")
var loadFolder : String = ProjectSettings.globalize_path("res://JSON/")

@onready var dialogHolder : Control = $CanvasLayer/UI/FileDialogHolder
@onready var newDialog : ConfirmationDialog = $CanvasLayer/UI/FileDialogHolder/NewDialog
@onready var saveDialog : FileDialog = $CanvasLayer/UI/FileDialogHolder/SaveDialog
@onready var loadDialog : FileDialog = $CanvasLayer/UI/FileDialogHolder/LoadDialog
@onready var exitDialog : ConfirmationDialog = $CanvasLayer/UI/FileDialogHolder/ExitDialog
@onready var messageDialog : AcceptDialog = $CanvasLayer/UI/FileDialogHolder/MessageDialog

func _ready():
	for window in dialogHolder.get_children():
		window.connect("visibility_change", self.onDialogVisibilityChange)
	saveDialog.current_path = saveFolder
	loadDialog.current_path = loadFolder

func onDialogVisibilityChange() -> void:
	if is_instance_valid(dialogHolder):
		var isVisible : bool = false
		for c in dialogHolder.get_children():
			if c.visible:
				isVisible = true
				break
		dialogHolder.visible = isVisible

func openNewDialog() -> void:
	newDialog.show()

func openSaveDialog() -> void:
	saveDialog.show()

func openLoadDialog() -> void:
	loadDialog.show()

func openExitDialog() -> void:
	exitDialog.show()

func openMessageDialog(dialogTitle : String, dialogText : String, okButtonText : String = "OK") -> void:
	messageDialog.title = dialogTitle
	messageDialog.dialog_text = dialogText
	messageDialog.ok_button_text = okButtonText
	messageDialog.size = Vector2()
	messageDialog.show()



func onNewConfirmed() -> void:
	boardNode.clear()

func onSaveConfirmed(path : String) -> void:
	var data : Dictionary = boardNode.getSaveData()
	if FileIO.writeJson(path, data):
		openMessageDialog("Success", "Successfully saved file.")
	else:
		openMessageDialog("ERROR", "Could not save file.", "Go back")

func onLoadConfirmed(path : String) -> void:
	print("Loading...")
	var backupData : Dictionary = boardNode.getSaveData()
	var data : Dictionary = FileIO.readJson(path)
	var error : BoardNode.LOAD_ERROR = boardNode.loadSaveData(data)
	if error != BoardNode.LOAD_ERROR.OK:
		boardNode.loadSaveData(backupData)
		openMessageDialog("ERROR", BoardNode.getLoadErrorString(error))
	else:
		resetCam()

func onExitConfirmed() -> void:
	get_tree().change_scene_to_packed(Preloader.startScreen)

####################################################################################################

var lastMousePosition : Vector2 = Vector2()

var waitingForHold : bool = false
const hoverMaxTime : float = 0.5	
var hoverTimer : float = 0.0
const hoverMaxDist : float = TerritoryNode.radius
var hoverTerritory = null
var hoverPosition = null

var holdTerritory = null

var rmbHeld : bool = false

const camZoomAmount : float = 1.1
const camMoveSpeed : float = 10.0
const camRotSpeed : float = PI
var movingCam : bool = false

var isOnButton : bool = true
func onHoverEnterUI() -> void:
	isOnButton = false
func onHoverExitUI() -> void:
	isOnButton = true

func _input(event):
	if event is InputEventMouseButton:
		if not isOnButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					waitingForHold = true
					hoverTimer = 0.0
					hoverPosition = lastMousePosition
					hoverTerritory = getOverlappingTerritory()
					if not is_instance_valid(hoverTerritory):
						boardNode.makeTerritory(get_global_mouse_position())
					else:
						pathHighlight.show()
				else:
					if hoverTimer >= hoverMaxTime:
						holdTerritory = null
					else:
						connectHoverTerritory()
						pathHighlight.hide()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				rmbHeld = event.pressed
			
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					setZoom(cam.zoom * camZoomAmount)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					setZoom(cam.zoom / camZoomAmount)
			elif event.button_index == MOUSE_BUTTON_MIDDLE:
				movingCam = event.pressed
	
	elif event is InputEventKey:
		if event.ctrl_pressed:
			if event.keycode == KEY_N:
				openNewDialog()
			elif event.keycode == KEY_S:
				openSaveDialog()
			elif event.keycode == KEY_O:
				openLoadDialog()
		else:
			if event.keycode == KEY_R:
				boardNode.recenter()
				resetCam()

func resetCam() -> void:
	cam.position = Vector2()
	cam.rotation = 0.0
	cam.zoom = Vector2.ONE

func setZoom(zoom : Vector2):
	var maxX : float = 5.0
	var minX : float = 0.02
	zoom.x = min(maxX, max(minX, zoom.x))
	zoom.y = min(maxX, max(minX, zoom.y))
	
	var oldZoom : Vector2 = cam.zoom
	cam.zoom = zoom
	
	var oldMousePosition : Vector2 = (lastMousePosition - cam.position) * oldZoom
	var newMousePosition : Vector2 = (lastMousePosition - cam.position) * zoom
	cam.position += newMousePosition - oldMousePosition

func _process(delta):
	var mpLastFrame : Vector2 = lastMousePosition
	lastMousePosition = get_global_mouse_position()
	if movingCam:
		var dp : Vector2 = mpLastFrame - lastMousePosition
		cam.position += dp
		lastMousePosition += dp
	
	if waitingForHold:
		if (lastMousePosition - hoverPosition).length() >= hoverMaxDist:
			waitingForHold = false
		else:
			hoverTimer += delta
			if hoverTimer >= hoverMaxTime:
				holdTerritory = hoverTerritory
				pathHighlight.hide()
				endHover()
	elif is_instance_valid(holdTerritory):
		if holdTerritory.position != lastMousePosition:
			boardNode.moveTerritory(holdTerritory, lastMousePosition)
	
	if pathHighlight.visible:
		pathHighlight.points[0] = hoverTerritory.position
		pathHighlight.points[1] = lastMousePosition
	
	if rmbHeld:
		var ov = getOverlappingTerritory()
		var path = getOverlapplingPath()
		if is_instance_valid(ov):
			boardNode.removeTerritory(ov)
		if is_instance_valid(path):
			var pathTerritories : Array = boardNode.getTerritoriesFromPathNode(path)
			boardNode.disconnectTerritories(pathTerritories[0], pathTerritories[1])
	
	if Input.is_key_pressed(KEY_W):
		cam.position.y -= camMoveSpeed * delta
	if Input.is_key_pressed(KEY_S):
		cam.position.y += camMoveSpeed * delta
	if Input.is_key_pressed(KEY_A):
		cam.position.x -= camMoveSpeed * delta
	if Input.is_key_pressed(KEY_D):
		cam.position.x += camMoveSpeed * delta
	if Input.is_key_pressed(KEY_Q):
		cam.rotation -= camRotSpeed * delta
	if Input.is_key_pressed(KEY_E):
		cam.rotation += camRotSpeed * delta

func getOverlappingTerritory() -> TerritoryNode:
	return boardNode.getOverlappingTerritory(lastMousePosition)

func getOverlapplingPath() -> Line2D:
	return boardNode.getOverlappingPath(lastMousePosition)

func connectHoverTerritory() -> void:
	if is_instance_valid(hoverTerritory):
		var otherTerritory = getOverlappingTerritory()
		if is_instance_valid(otherTerritory):
			boardNode.connectTerritories(hoverTerritory, otherTerritory)
			endHover()

func endHover() -> void:
	waitingForHold = false
	hoverTerritory = null