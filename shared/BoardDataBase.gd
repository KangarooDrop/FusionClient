
class_name BoardDataBase

const BOARD_VERSION : String = "0.01"

var name : String = ""
var territories : Array = []
var paths : Dictionary = {}

####################################################################################################

signal onClear()
signal onTerritoryMoved(td : TerritoryDataBase)
signal onTerritoryAdded(td : TerritoryDataBase)
signal beforeTerritoryRemoved(td : TerritoryDataBase)
signal onPathAdded(td0 : TerritoryDataBase, td1 : TerritoryDataBase)
signal beforePathRemoved(td0 : TerritoryDataBase, td1 : TerritoryDataBase)

####################################################################################################

func getTerritoryScript() -> Script:
	return TerritoryDataBase

func clear() -> void:
	name = ""
	territories.clear()
	paths.clear()
	emit_signal("onClear")

func addTerritory(name : String, position : Vector2, value : int = 1, size : int = 1) -> TerritoryDataBase:
	var td0 : TerritoryDataBase = getTerritoryScript().new(name, position, value, size)
	paths[td0] = {}
	for td1 in territories:
		paths[td1][td0] = false
		paths[td0][td1] = false
	territories.append(td0)
	emit_signal("onTerritoryAdded", td0)
	return td0

func removeTerritory(td : TerritoryDataBase) -> void:
	emit_signal("beforeTerritoryRemoved", td)
	paths.erase(td)
	for t in paths.keys():
		paths[t].erase(td)
	territories.erase(td)

func moveTerritory(td, position : Vector2) -> void:
	if typeof(td) == TYPE_INT:
		td = territories[td]
	td.position = position
	emit_signal("onTerritoryMoved", td)

func setPath(td0, td1, val : bool) -> void:
	if typeof(td0) == TYPE_INT:
		td0 = territories[td0]
	if typeof(td1) == TYPE_INT:
		td1 = territories[td1]
	if paths[td0][td1] and not val:
		emit_signal("beforePathRemoved", td0, td1)
	elif not paths[td0][td1] and val:
		emit_signal("onPathAdded", td0, td1)
	paths[td0][td1] = val
	paths[td1][td0] = val

####################################################################################################

func getSaveData() -> Dictionary:
	var data : Dictionary = \
	{
		"name" : name,
		"ver" : BOARD_VERSION,
		"conns" : [],
		"terrs" : []
	}
	for t in territories:
		data["terrs"].append(t.getSaveData())
	
	for terr0 in paths.keys():
		var index0 : int = territories.find(terr0)
		for terr1 in paths[terr0].keys():
			var index1 : int = territories.find(terr1)
			if paths[terr0][terr1] and not [index1, index0] in data["conns"]:
				data["conns"].append([index0, index1])
	
	return data

func loadSaveData(data : Dictionary) -> BoardDataBase:
	clear()
	self.name = data["name"]
	
	for terrData in data["terrs"]:
		var value : int = 1
		if terrData.has("value"):
			value = int(terrData["value"])
		var size : int = 1
		if terrData.has("size"):
			size = int(terrData["size"])
		addTerritory(terrData["name"], Vector2(terrData["pos_x"], terrData["pos_y"]), value, size)
	
	for pathData in data["conns"]:
		setPath(int(pathData[0]), int(pathData[1]), true)
	
	return self
