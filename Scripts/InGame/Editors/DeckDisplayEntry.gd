extends Node

class_name DeckDisplayEntry

var cardIndex : int = -1
var cardName : String = "_NONE"
var count : int = 0

@onready var nameLabel : Label = $NameLabel

signal remove_self()

func setCard(cardData : CardDataBase) -> void:
	self.cardIndex = cardData.uuid
	self.cardName = cardData.name
	self.count = 1
	updateNameLabel()

func setCount(count : int) -> void:
	self.count = count
	updateNameLabel()

func updateNameLabel() -> void:
	nameLabel.text = self.cardName + " x" + str(self.count)

func onPlusPressed() -> void:
	setCount(count + 1)

func onMinusPressed() -> void:
	if count <= 1:
		emit_signal("remove_self")
	else:
		setCount(count - 1)
