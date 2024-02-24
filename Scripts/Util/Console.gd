extends CanvasLayer

@onready var lineEdit : LineEdit = $Control/LineEdit
@onready var label : Label = $Control/ScrollContainer/Label

var previousInputs : Array = []
var inputIndex : int = -1
var currentInput : String = ""

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if visible and get_viewport().gui_get_focus_owner() == lineEdit:
			if event.keycode == KEY_UP:
				inputIndex = min(previousInputs.size()-1, inputIndex+1)
				if inputIndex == 0:
					currentInput = lineEdit.text
				if inputIndex != -1:
					lineEdit.text = previousInputs[inputIndex]
					lineEdit.caret_column = lineEdit.text.length()
			elif event.keycode == KEY_DOWN:
				if inputIndex != -1:
					inputIndex = max(-1, inputIndex-1)
					if inputIndex == -1:
						lineEdit.text = currentInput
					else:
						lineEdit.text = previousInputs[inputIndex]
					lineEdit.caret_column = lineEdit.text.length()
		
		if event.keycode == KEY_QUOTELEFT and not event.ctrl_pressed and not event.shift_pressed and not event.alt_pressed:
			var wasVisible : bool = visible
			if wasVisible:
				visible = false
			await get_tree().process_frame
			if not wasVisible:
				visible = true
			if visible:
				lineEdit.grab_focus()

func clear():
	previousInputs.clear()
	inputIndex = -1
	label.text = ""

func onEnter(text : String = ""):
	text = lineEdit.text
	if text.is_empty():
		return
	inputIndex = -1
	currentInput = ""
	previousInputs.insert(0, text)
	lineEdit.text = ""
	if not label.text.is_empty():
		label.text += "\n"
	label.text += text
	
	processCommand(text)

func processCommand(text):
	if text.length() == 0:
		return
	
	if text == "clear":
		clear()
		return
	
	var main = get_tree().get_current_scene()
	if not main is Main:
		print("ERROR: Not in main")
		return
	
	main.commandQueue.append(Main.parseStringToCommand(text))
