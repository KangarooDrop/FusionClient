extends Control

class_name DeckDisplayPanel

var idToEntry : Dictionary = {}

@onready var vbox : VBoxContainer = $ScrollContainer/VBoxContainer

func onResize() -> void:
	if not is_instance_valid(vbox):
		await get_tree().process_frame
	vbox.custom_minimum_size = size - Vector2(8, 8)

func clear() -> void:
	for entry in idToEntry.values():
		entry.queue_free()
	idToEntry.clear()

func removeCardData(cardData : CardDataBase) -> void:
	idToEntry[cardData.uuid].queue_free()
	idToEntry.erase(cardData.uuid)

func addCardData(cardData : CardDataBase, count : int = 1):
	if idToEntry.has(cardData.uuid):
		idToEntry[cardData.uuid].onPlusPressed()
	else:
		var entry : DeckDisplayEntry = Preloader.deckDisplayEntry.instantiate()
		vbox.add_child(entry)
		entry.setCard(cardData)
		entry.connect("remove_self", removeCardData.bind(cardData))
		idToEntry[cardData.uuid] = entry
		if count != 1:
			entry.setCount(count)

func loadData(deckData : Dictionary) -> void:
	clear()
	for k in deckData["cards"].keys():
		var id : int = int(k)
		var count : int = int(deckData["cards"][k])
		addCardData(ListOfCards.getCardByID(id), count)

func getSaveData() -> Dictionary:
	var data : Dictionary = {}
	for id in idToEntry:
		data[str(id)] = idToEntry[id].count
	return data
