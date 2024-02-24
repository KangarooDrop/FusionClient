extends TerritoryNodeBase

class_name TerritoryNodeGame

var playerToSlotHolder : Dictionary = {}
var playerToSlots : Dictionary = {}

@onready var highlight = $HighlightCirc

signal slot_added(creatureSlot)

func getAllSlots() -> Array:
	var rtn : Array = []
	for player in playerToSlots.keys():
		rtn += playerToSlots[player]
	return rtn

func updateSlotPositions():
	for i in range(playerToSlotHolder.size()):
		var player : PlayerBase = playerToSlotHolder.keys()[i]
		var holder : Node2D = playerToSlotHolder[player]
		add_child(holder)
		holder.z_index = 1
		holder.position = Vector2.RIGHT.rotated(float(i)/playerToSlotHolder.size()) * (radius + 32.0 + 112.0/2.0)
		var perp : Vector2 = Util.getPerp(holder.position).normalized()
		var numSlots : int = playerToSlots[player].size()
		for j in range(numSlots):
			var slot : CreatureSlot = playerToSlots[player][i]
			slot.position = perp * 128.0 * float(j)/numSlots

func setPlayers(players : Array):
	td.setPlayers(players)
	for player in players:
		var holder : Node2D = Node2D.new()
		playerToSlotHolder[player] = holder
		playerToSlots[player] = []
	for i in range(td.size):
		addSlot(false)
	updateSlotPositions()

func setSize(size : int, updateTerritoryData : bool = true) -> void:
	var d : int = td.size - size
	if d > 0:
		addSlot(false)
	elif d < 0:
		removeSlot(false)
	super.setSize(size)
	updateSlotPositions()

func addSlot(updateOnFinish : bool = true) -> void:
	for player in playerToSlotHolder.keys():
		var slot : CreatureSlot = Preloader.slotNode.instantiate()
		playerToSlots[player].append(slot)
		playerToSlotHolder[player].add_child(slot)
		slot.setPlayerAndIndex(player, playerToSlots.size()-1)
		slot.setTerritoryData(td)
		emit_signal("slot_added", slot)
	if updateOnFinish:
		updateSlotPositions()

func removeSlot(updateOnFinish : bool = true) -> void:
	for player in playerToSlotHolder.keys():
		var index : int = playerToSlots.size()-1
		playerToSlots[player][index].queue_free()
		playerToSlots[player].remove_at(index)
	if updateOnFinish:
		updateSlotPositions()

func showHighlight() -> void:
	highlight.show()

func hideHighlight() -> void:
	highlight.hide()

func setColor(color : Color) -> void:
	highlight.setColor(color)

func setColorSelected() -> void:
	highlight.setColor(Color(1.0, 1.0, 0.0, 0.4))

func setColorUnselected() -> void:
	highlight.setColor(Color(1.0, 1.0, 0.0, 0.2))
