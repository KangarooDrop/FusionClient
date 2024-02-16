extends Node2D

@onready var cam : Camera2D = $Camera2D

@onready var boardNode : BoardNodeEditable = $BoardEditable
@onready var lineHighlight : Line2D = $LineHighlight
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

var saveFolder : String = ProjectSettings.globalize_path("user://boards/")
var loadFolder : String = ProjectSettings.globalize_path("user://boards/")

@onready var dialogHolder : Control = $CanvasLayer/UI/FileDialogHolder
@onready var newDialog : ConfirmationDialog = $CanvasLayer/UI/FileDialogHolder/NewDialog
@onready var saveDialog : FileDialog = $CanvasLayer/UI/FileDialogHolder/SaveDialog
@onready var loadDialog : FileDialog = $CanvasLayer/UI/FileDialogHolder/LoadDialog
@onready var exitDialog : ConfirmationDialog = $CanvasLayer/UI/FileDialogHolder/ExitDialog
@onready var messageDialog : AcceptDialog = $CanvasLayer/UI/FileDialogHolder/MessageDialog
@onready var nameEdit : LineEdit = $CanvasLayer/UI/MenuTop/NameEdit

func _ready():
	saveDialog.current_path = saveFolder
	loadDialog.current_path = loadFolder
	
	boardNode.editor = self

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
	var data : Dictionary = FileIO.readJson(path)
	var error : Validator.BOARD_CODE = Validator.validateBoard(data)
	if error != Validator.BOARD_CODE.OK:
		openMessageDialog("ERROR", Validator.getLoadErrorString(error))
	else:
		boardNode.loadSaveData(data)
		resetCam()

func onExitConfirmed() -> void:
	get_tree().change_scene_to_packed(Preloader.startScreen)


func getBoardName() -> String:
	return nameEdit.get_text()

func setBoardName(boardName : String) -> void:
	boardNode.bd.name = boardName

func setNameLabelText(text : String) -> void:
	nameEdit.set_text(text)

####################################################################################################

var mouseGlobalPosition : Vector2 = Vector2()
var mouseCamPosition : Vector2 = Vector2()

var waitingForHold : bool = false
const hoverMaxTime : float = 0.5	
var hoverTimer : float = 0.0
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
					hoverTerritory = getOverlappingTerritory()
					if not is_instance_valid(hoverTerritory):
						boardNode.makeTerritory(get_global_mouse_position())
					else:
						lineHighlight.show()
						waitingForHold = true
						hoverTimer = 0.0
				else:
					if hoverTimer >= hoverMaxTime:
						holdTerritory = null
					else:
						connectHoverTerritory()
						lineHighlight.hide()
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
	var minX : float = 0.2
	zoom.x = min(maxX, max(minX, zoom.x))
	zoom.y = min(maxX, max(minX, zoom.y))
	
	var viewportSize : Vector2 = get_viewport_rect().size
	var oldMousePosition : Vector2 = (mouseCamPosition - viewportSize / 2.0) / cam.zoom
	var newMousePosition : Vector2 = (mouseCamPosition - viewportSize / 2.0) / zoom
	var dp : Vector2 = oldMousePosition - newMousePosition
	
	cam.zoom = zoom
	cam.position += dp

func _process(delta):
	var mpLastFrame : Vector2 = mouseGlobalPosition
	mouseGlobalPosition = get_global_mouse_position()
	mouseCamPosition = get_viewport().get_mouse_position()
	if movingCam:
		var dp : Vector2 = mpLastFrame - mouseGlobalPosition
		cam.position += dp
		mouseGlobalPosition += dp
	
	if waitingForHold:
		if (mouseGlobalPosition - hoverTerritory.global_position).length() >= hoverTerritory.getRadiusPixels():
			waitingForHold = false
		else:
			hoverTimer += delta
			if hoverTimer >= hoverMaxTime:
				holdTerritory = hoverTerritory
				lineHighlight.hide()
				endHover()
	elif is_instance_valid(holdTerritory):
		if holdTerritory.position != mouseGlobalPosition:
			var snappedPos : Vector2 = Vector2(snapped(mouseGlobalPosition, Vector2(32, 32)))
			boardNode.moveTerritory(holdTerritory, snappedPos)
	
	if lineHighlight.visible:
		lineHighlight.points[0] = hoverTerritory.position
		lineHighlight.points[1] = mouseGlobalPosition
	
	if rmbHeld:
		var ov = getOverlappingTerritory()
		var line = getOverlapplingLine()
		if is_instance_valid(ov):
			boardNode.removeTerritory(ov)
		elif is_instance_valid(line):
			var lineTerritories : Array = boardNode.lineToNodes[line]
			boardNode.disconnectTerritories(lineTerritories[0], lineTerritories[1])
	
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

func getOverlappingTerritory() -> TerritoryNodeBase:
	return boardNode.getOverlappingTerritory(mouseGlobalPosition)

func getOverlapplingLine() -> Line2D:
	return boardNode.getOverlappingLine(mouseGlobalPosition)

func connectHoverTerritory() -> void:
	if is_instance_valid(hoverTerritory):
		var otherTerritory = getOverlappingTerritory()
		if is_instance_valid(otherTerritory):
			boardNode.connectTerritories(hoverTerritory, otherTerritory)
			endHover()

func endHover() -> void:
	waitingForHold = false
	hoverTerritory = null
