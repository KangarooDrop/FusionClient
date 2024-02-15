extends TerritoryDataBase

class_name TerritoryDataGame

var controller : int = -1
var playerIdToCreatures : Dictionary = {}
var creatureToPlayerID : Dictionary = {}

func setPlayers(playerIDs : Array) -> void:
	controller = -1
	playerIdToCreatures.clear()
	creatureToPlayerID.clear()
	for id in playerIDs:
		playerIdToCreatures[id] = []

func isAtCapacity(playerID : int) -> bool:
	return playerIdToCreatures[playerID].size() >= size

func hasCreature(cardData : CardData) -> bool:
	return creatureToPlayerID.has(cardData)

func getFuseTargets(cardData : CardData, playerID) -> Array:
	var rtn : Array = []
	for id in playerIdToCreatures.keys():
		var otherCardData : CardData = playerIdToCreatures[id]
		if cardData.canFuseTo(otherCardData):
			rtn.append(otherCardData)
	return rtn

func addCreature(playerID : int, cardData : CardData) -> bool:
	if not isAtCapacity(playerID):
		creatureToPlayerID[playerID].append(cardData)
		playerIdToCreatures[cardData].append(playerID)
		return true
	return false

func removeCreature(cardData : CardData) -> bool:
	if hasCreature(cardData):
		var playerID : int = creatureToPlayerID[cardData]
		creatureToPlayerID.erase(cardData)
		playerIdToCreatures.erase(cardData)
		return true
	return false
