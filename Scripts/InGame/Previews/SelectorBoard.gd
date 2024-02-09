extends SelectorBase

func getPreview() -> PreviewBase:
	return Preloader.previewBoard.instantiate()

func _ready():
	var boards : Array = []
	for i in range(13):
		var path : String = ""
		if randi() % 2 == 0:
			path = "res://CustomBoards/test.json"
		else:
			path = "res://CustomBoards/b2.json"
		boards.append(FileIO.readJson(path))
	addAllPreviews(boards)
