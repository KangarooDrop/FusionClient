extends BoardNode

class_name BoardEditable

var editor

func getBoardName() -> String:
	boardName = editor.getBoardName()
	return super.getBoardName()

func loadSaveData(data : Dictionary) -> LOAD_ERROR:
	var err = super.loadSaveData(data)
	if err == LOAD_ERROR.OK:
		editor.setBoardName(boardName)
	return err

func clear():
	super.clear()
	editor.setBoardName("")
