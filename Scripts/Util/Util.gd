extends Node

func getTimeAbsolute() -> int:
	return Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())

func getAllDeckData() -> Array:
	var decks : Array = []
	for fn in FileIO.getAllFiles(FileIO.DECK_PATH):
		var path : String = FileIO.DECK_PATH + fn
		var deckData : Dictionary = FileIO.readJson(path)
		if Validator.validateDeck(deckData):
			decks.append(deckData)
	return decks
