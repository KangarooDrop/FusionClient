extends Node

const cardFilePath : String = "res://shared/CardsData.csv"
var cards : Array = []

func matchElementsFromSave(saveString : String) -> Array:
	var split : Array = saveString.split(" ")
	var data : Array = []
	for s in split:
		if Validator.ELEMENT.has(s):
			data.append(Validator.ELEMENT[s])
		else:
			data.append(Validator.ELEMENT.NULL)
	return data

func matchAbilitiesFromSave(saveString : String) -> Array:
	return []

func _ready():
	var allCardData : Array = FileIO.readCSV(cardFilePath)
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
		
		cards.append(dict)

func getCardData(index : int) -> Dictionary:
	if index >= 0 and index < cards.size():
		return cards[index]
	return {}
