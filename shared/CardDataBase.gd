
class_name CardDataBase

enum ZONES {NONE, DECK, HAND, GRAVEYARD, TERRITORY, QUEUE, FUSED}
enum PHASE {START, DRAW, BET, ACTION, REVEAL, INVADE, END}

####################################################################################################

var uuid : int = -1
var name : String = "_NONE"
var power : int = -1
var toughness : int = -1

var abilities : Array = []

enum ELEMENT {NULL = 0, FIRE = 1, WATER = 2, ROCK = 3, NATURE = 4, DEATH = 5, TECH = 6}
var elements : Array = [ELEMENT.NULL]

var imagePath : String = ""

####################################################################################################

func _init(data : Dictionary):
	deserialize(data)

func serialize() -> Dictionary:
	var data : Dictionary = {}
	data['uuid'] = uuid
	data['name'] = name
	data['power'] = power
	data['toughness'] = toughness
	data['elements'] = elements
	data['abilities'] = abilities
	data['art_file'] = imagePath
	return data

func deserialize(data : Dictionary) -> void:
	if data.has('uuid'):
		self.uuid = data['uuid']
	if data.has('name'):
		self.name = data['name']
	if data.has('power'):
		self.power = data['power']
	if data.has('toughness'):
		self.toughness = data['toughness']
	if data.has('elements'):
		self.elements = data['elements']
	if data.has('abilities'):
		self.abilities = data['abilities']
	if data.has('art_file'):
		self.imagePath = data['art_file']

func copy() -> CardDataBase:
	return self.get_script().new(serialize())

####################################################################################################
