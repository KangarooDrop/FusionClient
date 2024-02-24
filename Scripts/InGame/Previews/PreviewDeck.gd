extends PreviewBase

class_name PreviewDeck

#Vars for previewing cards
const numCards : int = 4
const rotDiff : float = PI/16.0
const dstDiff : float = 16.0
var cardNodes : Array = []

#Takes in parsed deck data and displays a random selection of cards
func preview(deckData : Dictionary) -> void:
	super.preview(deckData)
	
	for c in cardNodes:
		c.queue_free()
	
	var point : Vector2 = Vector2(-dstDiff*numCards/2.0, 0.0)
	for i in range(numCards):
		var randCardIndex : int = getRandomCardIndex(deckData)
		var cardData : CardDataBase = ListOfCards.getCardByID(randCardIndex)
		var cardNode : CardNode = Preloader.cardPacked.instantiate()
		add_child(cardNode)
		cardNode.setCardData(cardData)
		cardNodes.append(cardNode)
		cardNode.position = Vector2(dstDiff*(numCards-1)/2.0 - dstDiff * i, 0.0)
		cardNode.rotation = rotDiff * (numCards-1)/2.0 - rotDiff * i
		cardNode.setRoll(0.0)
	
	nameLabel.set_text(deckData["name"])
	move_child(selectionRect, get_child_count() - 1)

func getRandomCardIndex(deckData : Dictionary) -> int:
	var cardData : Dictionary = deckData['cards']
	var total : int = 0
	for k in cardData.keys():
		total += cardData[k]
	var randIndex : int = randi() % total
	for k in cardData.keys():
		var val : int = cardData[k]
		if val > randIndex:
			return int(k)
		else:
			randIndex -= val
	return cardData.keys()[cardData.keys().size() - 1]
