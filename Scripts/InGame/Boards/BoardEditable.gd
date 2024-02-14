extends BoardNode

class_name BoardEditable

var editor

func clear():
	super.clear()
	editor.setNameLabelText("")

func loadSaveData(data : Dictionary) -> Validator.BOARD_CODE:
	var error : Validator.BOARD_CODE = super.loadSaveData(data)
	if error != Validator.BOARD_CODE.OK:
		return error
	
	editor.setNameLabelText(bd.name)
	return Validator.BOARD_CODE.OK
