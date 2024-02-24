extends Node

class_name PlayerNode

var player : PlayerBase

@onready var handHolder : Node2D = $HandHolder
@onready var deckHolder : Node2D = $DeckHolder
@onready var graveHolder : Node2D = $GraveHolder

####################################################################

func setPlayer(player : PlayerBase) -> PlayerNode:
	self.player = player
	return self

####################################################################

func isInHandData(cardData : CardDataGame) -> bool:
	if not cardData.controller == player:
		return false
	for cardNode in handHolder.get_children():
		if cardNode.cardData == cardData:
			return true
	return false

func isInHandNode(cardNode : CardNode) -> bool:
	return cardNode in handHolder.get_children()

func addToHandData(cardData : CardDataGame) -> CardNode:
	var cardNode : CardNode = Util.makeCardNode()
	addToHandNode(cardNode)
	cardData.controller = player
	cardData.zone = CardDataGame.ZONES.HAND
	cardNode.setCardData(cardData)
	return cardNode

func addToHandNode(cardNode : CardNode) -> CardNode:
	var cardNodeParent = cardNode.get_parent()
	if is_instance_valid(cardNodeParent):
		cardNodeParent.remove_child(cardNode)
	handHolder.add_child(cardNode)
	if cardNode.cardData != null:
		cardNode.cardData.zone = CardDataGame.ZONES.HAND
		cardNode.cardData.controller = player
	updateHandPositions()
	return cardNode

func removeFromHandData(cardData : CardDataGame) -> CardNode:
	for cardNode in handHolder.get_children():
		if cardNode.cardData == cardData:
			removeFromHandNode(cardNode)
			return cardNode
	return null

func removeFromHandNode(cardNode : CardNode) -> CardNode:
	if cardNode in handHolder.get_children():
		handHolder.remove_child(cardNode)
		return cardNode
	return null

func updateHandPositions() -> void:
	var numCards : int = handHolder.get_child_count()
	for i in range(numCards):
		var node : CardNode = handHolder.get_child(i)
		node.position = Vector2(Util.CARD_SIZE.x * (i - numCards/2.0), 0.0)

####################################################################
