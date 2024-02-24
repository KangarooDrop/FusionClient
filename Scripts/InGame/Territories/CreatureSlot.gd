extends Node

class_name CreatureSlot

var cardNode : CardNode = null
var territoryData : TerritoryDataGame

var player : PlayerBase
var slotIndex : int = -1

signal slot_pressed(buttonIndex : int)

func setPlayerAndIndex(player : PlayerBase, slotIndex) -> void:
	self.player = player
	self.slotIndex = slotIndex
	self.modulate = player.color

func setTerritoryData(territoryData : TerritoryDataGame) -> void:
	self.territoryData = territoryData
	territoryData.connect("creature_set", self.onCreatureSet)
	territoryData.connect("creature_removed", self.onCreatureRemoved)
	territoryData.connect("creature_revealed", self.onCreatureRevealed)

func isSelf(player : PlayerBase, slotIndex : int) -> bool:
	return self.player == player and self.slotIndex == slotIndex

func setCardNode(cardNode : CardNode) -> void:
	self.cardNode = cardNode
	var cardParent = cardNode.get_parent()
	if is_instance_valid(cardParent):
		cardParent.remove_child(cardNode)
	add_child(cardNode)
	self.cardNode.position = Vector2()
	self.cardNode.rotation = 0.0
	territoryData.setCreature(cardNode.cardData, player, slotIndex)

func onCreatureSet(player : PlayerBase, slotIndex : int) -> void:
	if isSelf(player, slotIndex):
		var cardData : CardDataGame = territoryData.getCardDataFromSlotIndex(player, slotIndex)
		if not is_instance_valid(cardNode):
			cardNode = Util.makeCardNode()
			add_child(cardNode)
		cardData.zone = CardDataGame.ZONES.TERRITORY
		cardNode.setCardData(cardData)

func onCreatureRemoved(player : PlayerBase, slotIndex : int) -> void:
	if isSelf(player, slotIndex):
		if is_instance_valid(cardNode):
			cardNode.queue_free()

func onCreatureRevealed(player : PlayerBase, slotIndex : int) -> void:
	if isSelf(player, slotIndex):
		if is_instance_valid(cardNode):
			cardNode.flipToFront()

func transferCardNode(other : CreatureSlot):
	if not is_instance_valid(other.cardNode):
		var cardNode = self.cardNode
		self.cardNode = null
		territoryData.setCreature(null, player, slotIndex)
		other.setCardNode(cardNode)

var isHovering : bool = false
func onMouseEnter() -> void:
	isHovering = true
func onMouseExit() -> void:
	isHovering = false

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
		if isHovering:
			emit_signal("slot_pressed", event.button_index)
