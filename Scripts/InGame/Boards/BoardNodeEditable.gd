extends BoardNodeBase

class_name BoardNodeEditable

var editor

func getTerritoryPacked() -> PackedScene:
	return Preloader.territoryNodeEditable

func clear():
	super.clear()
	editor.setNameLabelText("")

func loadSaveData(data : Dictionary) -> Validator.BOARD_CODE:
	var error : Validator.BOARD_CODE = super.loadSaveData(data)
	if error != Validator.BOARD_CODE.OK:
		return error
	
	editor.setNameLabelText(bd.name)
	return Validator.BOARD_CODE.OK
