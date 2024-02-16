extends TerritoryDataBase

class_name TerritoryDataGame

var controller : PlayerBase = null
var playerToCreatures : Dictionary = {}
var creatureToPlayer : Dictionary = {}

func setPlayers(players : Array) -> void:
	controller = null
	playerToCreatures.clear()
	creatureToPlayer.clear()
	for player in players:
		playerToCreatures[player] = []

func isAtCapacity(player : PlayerBase) -> bool:
	return playerToCreatures[player].size() >= size

func hasCreature(cardData : CardDataGame) -> bool:
	return creatureToPlayer.has(cardData)

func getFuseTargets(cardData : CardDataGame, player : PlayerBase) -> Array:
	var rtn : Array = []
	for otherPlayer in playerToCreatures.keys():
		var otherCardData : CardDataGame = playerToCreatures[otherPlayer]
		if cardData.canFuseTo(otherCardData):
			rtn.append(otherCardData)
	return rtn

func addCreature(player : PlayerBase, cardData : CardDataGame) -> bool:
	if not isAtCapacity(player):
		creatureToPlayer[player].append(cardData)
		playerToCreatures[cardData].append(player)
		return true
	return false

func removeCreature(cardData : CardDataGame) -> bool:
	if hasCreature(cardData):
		var player : PlayerBase = creatureToPlayer[cardData]
		creatureToPlayer.erase(cardData)
		playerToCreatures.erase(cardData)
		return true
	return false
