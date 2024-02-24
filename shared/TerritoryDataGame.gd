extends TerritoryDataBase

class_name TerritoryDataGame

var controller : PlayerBase = null
var playerToCreatures : Dictionary = {}
var creatureToPlayer : Dictionary = {}

signal creature_revealed()
signal creature_set()
signal creature_removed()

func setPlayers(players : Array) -> void:
	controller = null
	playerToCreatures.clear()
	creatureToPlayer.clear()
	for player in players:
		playerToCreatures[player] = []
		for i in range(size):
			playerToCreatures[player].append(null)

func isAtCapacity(player : PlayerBase) -> bool:
	for creature in playerToCreatures[player]:
		if creature == null:
			return false
	return true

func hasCreature(cardData : CardDataGame) -> bool:
	return cardData != null and creatureToPlayer.has(cardData)

func getSlotIndexFromCreature(player : PlayerBase, cardData : CardDataGame) -> int:
	for i in range(playerToCreatures[player].size()):
		if playerToCreatures[player][i] == cardData:
			return i
	return -1

func getCardDataFromSlotIndex(player : PlayerBase, slotIndex : int) -> CardDataGame:
	return playerToCreatures[player][slotIndex]

func getFuseTargets(cardData : CardDataGame, player : PlayerBase) -> Array:
	var rtn : Array = []
	for otherPlayer in playerToCreatures.keys():
		var otherCardData : CardDataGame = playerToCreatures[otherPlayer]
		if cardData == null or cardData.canFuseTo(otherCardData):
			rtn.append(otherCardData)
	return rtn

func setCreature(cardData : CardDataGame, player : PlayerBase, slotIndex : int = 0) -> void:
	removeByIndex(player, slotIndex)
	if cardData != null:
		playerToCreatures[player][slotIndex] = cardData
		creatureToPlayer[cardData] = player
		emit_signal("creature_set", player, slotIndex)

func removeByCreature(cardData : CardDataGame) -> bool:
	if hasCreature(cardData):
		var player : PlayerBase = creatureToPlayer[cardData]
		for i in range(playerToCreatures.size()):
			if playerToCreatures[player][i] == cardData:
				removeByIndex(player, i)
				return true
	return false

func removeByIndex(player : PlayerBase, slotIndex : int = 0) -> bool:
	if playerToCreatures[player][slotIndex] != null:
		var creature : CardDataGame = playerToCreatures[player][slotIndex]
		creatureToPlayer.erase(creature)
		playerToCreatures[player][slotIndex] = null
		emit_signal("creature_removed", player, slotIndex)
		return true
	return false

func revealByCreature(cardData : CardDataGame) -> void:
	if hasCreature(cardData):
		var player : PlayerBase = creatureToPlayer[cardData]
		var slotIndex : int = getSlotIndexFromCreature(player, cardData)
		if slotIndex != -1:
			revealByIndex(player, slotIndex)

func revealByIndex(player : PlayerBase, slotIndex : int = 0) -> void:
	if playerToCreatures[player][slotIndex] != null:
		var creature : CardDataGame = playerToCreatures[player][slotIndex]
		creature.onReveal()
		emit_signal("creature_revealed", player, slotIndex)

func setController(player : PlayerBase) -> void:
	self.controller = player
	self.modulate = player.color
