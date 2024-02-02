
class_name DeckData

var cards : Array = []

signal beforeDraw(card : CardData)
signal afterDraw(card : CardData)

signal beforeRemove(card : CardData)
signal afterRemove(card : CardData)

signal beforeShuffle(cards : Array)
signal afterShuffle(cards : Array)

signal beforeReset(cards : Array, graveyard : Array)
signal afterReset(cards : Array, graveyard : Array)

func draw(hand : HandData) -> void:
	var cardToDraw = null
	if cards.size() > 0:
		cardToDraw = cards.pop_front()
	emit_signal("beforeDraw", cardToDraw)
	hand.addCard(cardToDraw)
	emit_signal("afterDraw")

func removeCard(cardData : CardData):
	var index : int = cards.find(cardData)
	if index != -1:
		removeAt(index)

func removeAt(index : int):
	if index >= 0 and index < cards.size():
		var cardToRemove : CardData = cards[index]
		emit_signal("beforeRemove", cardToRemove)
		cards.erase(cardToRemove)
		emit_signal("afterRemove", cardToRemove)

func shuffle() -> void:
	emit_signal("beforeShuffle", cards)
	cards.shuffle()
	emit_signal("afterShuffle", cards)

func reset(graveyard : Array):
	emit_signal("beforeReset", cards, graveyard)
	cards += graveyard
	graveyard.clear()
	shuffle()
	emit_signal("afterReset", cards, graveyard)
