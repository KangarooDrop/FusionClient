extends Node

const CARD_SIZE : Vector2 = Vector2(112.0, 144.0)

var cam : Camera2D
func getCam() -> Camera2D:
	return cam

func _process(delta):
	cam = get_viewport().get_camera_2d()

func getTimeAbsolute() -> int:
	return Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())

func getAllDeckData() -> Array:
	var decks : Array = []
	for fn in FileIO.getAllFiles(FileIO.DECK_PATH):
		var path : String = FileIO.DECK_PATH + fn
		var deckData : Dictionary = FileIO.readJson(path)
		if Validator.validateDeck(deckData) == Validator.DECK_CODE.OK:
			decks.append(deckData)
	return decks

func getPerp(dir : Vector2) -> Vector2:
	return Vector2(-dir.y, dir.x)

func makeCardNode() -> CardNode:
	var cardNode = Preloader.cardPacked.instantiate()
	cardNode.z_index = 1
	return cardNode

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_F11:
			print(Main.parseStringToCommand("move [territory 0 1 [0 4]] [territory 0 1 1]"))
		elif event.keycode == KEY_F12:
			Main.swapAndConnect(25565)
