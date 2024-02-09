extends Node

const testPath : String = "res://CustomBoards/test.json"
#const testPath : String = "res://CustomBoards/b2.json"

@onready var clipper : Control = $Clipper
@onready var board : BoardNode = $Clipper/Center/BoardNode

const defaultRectSize : Vector2 = Vector2(200, 200)

func _ready():
	clipper.size = defaultRectSize
	clipper.position = -defaultRectSize/2.0
	preview(FileIO.readJson(testPath))

func preview(data : Dictionary) -> void:
	if Validator.validateBoard(data) == Validator.BOARD_CODE.OK:
		board.loadSaveData(data)
		var boardRect : Rect2 = board.getRect()
		var minBoardScale : float = min(defaultRectSize.x / boardRect.size.x, defaultRectSize.y / boardRect.size.y)
		board.scale = Vector2(minBoardScale, minBoardScale) * 0.9
		board.recenter()
		
		print("A ", clipper.get_rect(), " ", minBoardScale)
