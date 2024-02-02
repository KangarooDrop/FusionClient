
class_name CardData

var uuid : int = -1

var name : String = "_NONE"

var power : int = -1
var toughness : int = -1
var damage : int = 0

var abilities : Array = []

var owner : PlayerData = null
var controller : PlayerData = null

var node = null

enum ZONES {NONE, DECK, HAND, GRAVEYARD, TERRITORY, QUEUE, FUSED}
var zone : int = ZONES.NONE

func _init(uuid : int, name : String, power : int, toughness : int, abilities : Array):
	self.uuid = uuid
	self.name = name
	self.power = power
	self.toughness = toughness
	self.abilities = abilities

func setOwner(owner : PlayerData) -> void:
	self.owner = owner

func setController(controller : PlayerData) -> void:
	self.controller = controller

func setDamage(damage : int) -> void:
	self.damage = damage

func setZone(zone : int) -> void:
	self.zone = zone

func setNode(node) -> void:
	pass
