extends CardDataBase

class_name CardDataGame

var revealed : bool = false
var damage : int = 0
var zone : int = ZONES.NONE

var owner = null
var controller = null

func setDamage(damage : int) -> void:
	self.damage = damage

func setZone(zone : int) -> void:
	self.zone = zone

func canReveal() -> bool:
	return not revealed

func canFuseTo(other : CardDataBase) -> bool:
	return true

func onReveal() -> void:
	self.revealed = true

func setController(player : PlayerBase) -> CardDataGame:
	self.controller = player
	return self

func setOwner(player : PlayerBase) -> CardDataGame:
	self.owner = player
	return self

####################################################################################################

func serialize() -> Dictionary:
	var data : Dictionary = super.serialize()
	print("A ", data)
	data["revealed"] = revealed
	data["damage"] = damage
	data["zone"] = zone
	data["owner"] = owner
	data["controller"] = controller
	return data

func deserialize(data : Dictionary) -> void:
	super.deserialize(data)
	if data.has('revealed'):
		self.revealed = data['revealed']
	if data.has('damage'):
		self.damage = data['damage']
	if data.has('zone'):
		self.zone = data['zone']
	if data.has('owner'):
		self.owner = data['owner']
	if data.has('controller'):
		self.controller = data['controller']

