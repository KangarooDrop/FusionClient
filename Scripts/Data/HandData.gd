
class_name HandData

var player : PlayerData = null
var cards : Array = []

signal beforeAdd(cardData : CardData)
signal afterAdd(cardData : CardData)

signal beforeRemove(cardData : CardData)
signal afterRemove(cardData : CardData)

func _init(player : PlayerData):
	self.player = player

func addCard(cardData : CardData):
	pass

func removeCard(card):
	pass
