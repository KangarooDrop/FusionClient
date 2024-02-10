extends Node

var cards : Array = []

func matchElementsFromSave(saveString : String) -> Array:
	var split : Array = saveString.split(" ")
	var data : Array = []
	for s in split:
		if CardData.ELEMENT.has(s):
			data.append(CardData.ELEMENT[s])
		else:
			data.append(CardData.ELEMENT.NULL)
	return data

func matchAbilitiesFromSave(saveString : String) -> Array:
	return []

func _ready():
	var allCardData : Array = FileIO.readCSV(FileIO.CARDS_PATH)
	var keys : Array = allCardData[0]
	for i in range(1, allCardData.size()-1):
		var cardData : Array = allCardData[i]
		var dict : Dictionary = {'uuid':i-1}
		for j in range(cardData.size()):
			var k : String = keys[j]
			var datum = cardData[j]
			if k == 'power' or k == 'toughness':
				datum = int(datum)
			elif k == 'elements':
				datum = matchElementsFromSave(datum)
			elif k == 'abilities':
				datum = matchAbilitiesFromSave(datum)
			dict[keys[j]] = datum
		var card : CardData = CardData.new(dict)
		cards.append(card)
	
	print(getCardByID(0))

func getCardByID(index : int) -> CardData:
	if index < 0 or index >= cards.size():
		return null
	else:
		return cards[index].copy()
