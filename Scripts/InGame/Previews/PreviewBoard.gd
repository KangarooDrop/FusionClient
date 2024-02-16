extends PreviewBase

class_name PreviewBoard

#Vars for previewing board
@onready var board : BoardNodeBase = $Center/BoardNode
const defaultRectSize : Vector2 = Vector2(200, 200)

func preview(boardData : Dictionary) -> void:
	super.preview(boardData)
	if Validator.validateBoard(boardData) == Validator.BOARD_CODE.OK:
		board.loadSaveData(boardData)
		var boardRect : Rect2 = board.getRect()
		var minBoardScale : float = min(defaultRectSize.x / boardRect.size.x, defaultRectSize.y / boardRect.size.y)
		board.scale = Vector2(minBoardScale, minBoardScale) * 0.9
		setName(board.getBoardName())
