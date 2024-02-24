extends BoardNodeBase

class_name BoardNodeGame

@onready var chipHolder : Node2D = $ChipHolder

var players : Array = []
var idToPlayer : Dictionary = {}

####################################################################################################

func getBoardDataScript() -> Script:
	return BoardDataGame

func getTerritoryPacked() -> PackedScene:
	return Preloader.territoryNodeGame

####################################################################################################

func getCardNodeToSlot(cardNode : CardNode) -> CreatureSlot:
	for territory in getAllTerritories():
		for slot in territory.getAllSlots():
			if slot.cardNode == cardNode:
				return slot
	return null

func slotToLoc(creatureSlot : CreatureSlot) -> Array:
	var territories : Array = getAllTerritories()
	for i in range(territories.size()):
		for j in range(players.size()):
			var slots : Array = territories[i].playerToSlots[players[j]]
			for k in slots.size():
				if slots[k] == creatureSlot:
					return ["territory", i, j, k]
	return []

func setPlayers(players : Array) -> void:
	self.players = players
	for terr in getAllTerritories():
		terr.setPlayers(players)

func makeBetChip(player : PlayerBase, index : int) -> void:
	var playerIndex : int = players.find(player)
	var angle : float = float(playerIndex)/players.size() * PI * 2.0
	var dist : float = 20.0
	var pos : Vector2 = bd.territories[index].position + Vector2.RIGHT.rotated(angle) * dist
	
	var chip : ChipNode = Preloader.chipNode.instantiate()
	chipHolder.add_child(chip)
	chip.position = pos
	chip.modulate = player.color

func clearBetChips() -> void:
	for c in chipHolder.get_children():
		c.queue_free()
