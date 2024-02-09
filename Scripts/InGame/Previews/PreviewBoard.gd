extends PreviewBase

class_name PreviewBoard

#Vars for previewing board
@onready var board : BoardNode = $Center/BoardNode
const defaultRectSize : Vector2 = Vector2(200, 200)

func preview(data : Dictionary) -> void:
	if Validator.validateBoard(data) == Validator.BOARD_CODE.OK:
		board.loadSaveData(data)
		var boardRect : Rect2 = board.getRect()
		var minBoardScale : float = min(defaultRectSize.x / boardRect.size.x, defaultRectSize.y / boardRect.size.y)
		board.scale = Vector2(minBoardScale, minBoardScale) * 0.9
