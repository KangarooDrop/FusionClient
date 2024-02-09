extends SelectorBase

func getPreview() -> PreviewBase:
	return Preloader.previewDeck.instantiate()

func _ready():
	var decks : Array = []
	for i in range(13):
		var path : String = ""
		if randi() % 2 == 0:
			path = "res://CustomDecks/test_deck.json"
		else:
			path = "res://CustomDecks/test_deck_2.json"
		decks.append(FileIO.readJson(path))
	addAllPreviews(decks)
	
	"""
	var boards : Array = []
	for i in range(13):
		var path : String = ""
		if randi() % 2 == 0:
			path = "res://CustomBoards/test.json"
		else:
			path = "res://CustomBoards/b2.json"
		boards.append(FileIO.readJson(path))
	addAllPreviews(boards)
	"""
