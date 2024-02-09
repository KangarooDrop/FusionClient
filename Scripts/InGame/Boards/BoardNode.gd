extends Node2D

class_name BoardNode

@onready var territyHolder : Node2D = $TerritoryHolder
@onready var pathHolder : Node2D = $PathHolder

var boardName : String = "_NO_NAME"
var pathData : Dictionary = {}
var pathNodes : Dictionary = {}

func clear() -> void:
	for c in territyHolder.get_children():
		c.free()
	for c in pathHolder.get_children():
		c.free()
	pathData.clear()
	pathNodes.clear()

func load(path : String) -> bool:
	var data : Dictionary = FileIO.readJson(path)
	if data.is_empty():
		print("ERROR: Could not load board from path")
		return false
	
	return true

####################################################################################################

func getTerritoryPacked() -> PackedScene:
	return Preloader.territoryNode

func getAllTerritories() -> Array:
	return territyHolder.get_children()

func makeTerritory(pos : Vector2) -> TerritoryNode:
	var territory : TerritoryNode = getTerritoryPacked().instantiate()
	addToPathData(territory)
	territyHolder.add_child(territory)
	territory.position = pos
	return territory

func removeTerritory(terr : TerritoryNode) -> void:
	for t in pathData[terr].keys():
		if pathData[terr][t]:
			disconnectTerritories(terr, t)
	pathData.erase(terr)
	pathNodes.erase(terr)
	for t in pathData.keys():
		pathData[t].erase(terr)
	for t in pathNodes.keys():
		pathNodes[t].erase(terr)
	terr.queue_free()

#Change the position of a territory and any path connected to it
func moveTerritory(territory : TerritoryNode, newPos : Vector2) -> void:
	territory.position = newPos
	for terr in pathNodes[territory]:
		var path = pathNodes[territory][terr]
		if is_instance_valid(path):
			movePathNode(path, territory.position, terr.position)

####################################################################################################

#Initializes connectivity data of a new territory
func addToPathData(territory : TerritoryNode):
	var oldTerritories : Array = getAllTerritories()
	pathData[territory] = {}
	pathNodes[territory] = {}
	for terr in oldTerritories:
		pathData[terr][territory] = false
		pathNodes[terr][territory] = null
		pathData[territory][terr] = false
		pathNodes[territory][terr] = null

#Returns the path node connecting two territories if it exists
func getPathNode(terr0 : TerritoryNode, terr1 : TerritoryNode) -> Line2D:
	return pathNodes[terr0][terr1]

func getAllPathNodes() -> Array:
	var lines : Array = []
	for terr in pathNodes.keys():
		for t in pathNodes[terr].keys():
			if is_instance_valid(pathNodes[terr][t]):
				lines.append(pathNodes[terr][t])
	return lines

####################################################################################################

func movePathNode(path : Line2D, startPoint : Vector2, endPoint : Vector2) -> void:
	path.position = startPoint
	var dp : Vector2 = endPoint - startPoint
	path.points = PackedVector2Array([Vector2(), dp])

#Creates a path node and places its start at terr0 and end at terr1
func makePathNode(terr0 : TerritoryNode, terr1 : TerritoryNode) -> void:
	var path : Line2D = Line2D.new()
	pathHolder.add_child(path)
	movePathNode(path, terr0.position, terr1.position)
	
	pathNodes[terr0][terr1] = path
	pathNodes[terr1][terr0] = path

func isConnected(terr0 : TerritoryNode, terr1 : TerritoryNode) -> bool:
	return pathData[terr0][terr1]

#Connects two territories and adds a path node if not already connected
func connectTerritories(terr0 : TerritoryNode, terr1 : TerritoryNode) -> void:
	if terr0 != terr1 and not pathData[terr0][terr1]:
		pathData[terr0][terr1] = true
		pathData[terr1][terr0] = true
		makePathNode(terr0, terr1)

func getTerritoriesFromPathNode(pathNode : Line2D) -> Array:
	if not is_instance_valid(pathNode):
		return [null, null]
	for terr in pathNodes.keys():
		for t in pathNodes[terr].keys():
			if pathNodes[terr][t] == pathNode:
				return [terr, t]
	return [null, null]

#Removes the path node that connects terr0 and terr1
func removePathNode(terr0 : TerritoryNode, terr1 : TerritoryNode) -> void:
	var path = pathNodes[terr0][terr1]
	if is_instance_valid(path):
		path.queue_free()
	pathNodes[terr0][terr1] = null
	pathNodes[terr1][terr0] = null

func disconnectTerritories(terr0 : TerritoryNode, terr1 : TerritoryNode) -> void:
	if terr0 != terr1 and pathData[terr0][terr1]:
		pathData[terr0][terr1] = false
		pathData[terr1][terr0] = false
		removePathNode(terr0, terr1)

####################################################################################################

func getOverlappingTerritory(pos : Vector2) -> TerritoryNode:
	for terr in getAllTerritories():
		if (terr.position - pos).length() < terr.radius:
			return terr
	return null

func getDistToLineSegment(linePoint0 : Vector2, linePoint1 : Vector2, pos : Vector2) -> float:
	#Return minimum distance between line segment vw and point p
	var l2 : float = (linePoint0 - linePoint1).length_squared()  #i.e. |w-v|^2 -  avoid a sqrt
	if (l2 == 0.0):
		return (pos - linePoint0).length()   #v == w case
	#Consider the line extending the segment, parameterized as v + t (w - v).
	#We find projection of point p onto the line. 
	#It falls where t = [(p-v) . (w-v)] / |w-v|^2
	#We clamp t from [0,1] to handle points outside the segment vw.
	var t : float = max(0, min(1, (pos - linePoint0).dot(linePoint1 - linePoint0) / l2));
	var projection : Vector2 = linePoint0 + t * (linePoint1 - linePoint0);  #Projection falls on the segment
	return (pos - projection).length();

func getOverlappingPath(pos : Vector2) -> Line2D:
	for line in getAllPathNodes():
		var dist : float = getDistToLineSegment(line.position, line.position + line.points[1], pos)
		if dist < line.width * 2:
			return line
	return null

####################################################################################################

func recenter() -> void:
	var rect : Rect2 = getRect()
	var dp : Vector2 = -rect.size/2.0 - rect.position
	for terr in getAllTerritories():
		moveTerritory(terr, terr.position + dp)

func getRect() -> Rect2:
	var terrs : Array = getAllTerritories()
	if terrs.size() == 0:
		return Rect2()
	
	var minX : float = terrs[0].position.x
	var maxX : float = terrs[0].position.x
	var minY : float = terrs[0].position.y
	var maxY : float = terrs[0].position.y
	for i in range(1, terrs.size()):
		var terr : TerritoryNode = terrs[i]
		if terr.position.x < minX:
			minX = terr.position.x
		if terr.position.x > maxX:
			maxX = terr.position.x
		if terr.position.y < minY:
			minY = terr.position.y
		if terr.position.y > maxY:
			maxY = terr.position.y
	
	return Rect2(minX, minY, maxX - minX, maxY - minY)

func getBoardName() -> String:
	return boardName

const BOARD_VERSION : String = "0.01"
func getSaveData() -> Dictionary:
	var data : Dictionary = {"ver":BOARD_VERSION, "terrs":[], "conns":[]}
	data["name"] = getBoardName()
	var territories : Array = getAllTerritories() 
	for terr in getAllTerritories():
		data["terrs"].append(terr.getSaveData())
	for terr in pathData.keys():
		var i0 = territories.find(terr)
		for t in pathData[terr].keys():
			if pathData[terr][t]:
				var i1 = territories.find(t)
				if not [i1, i0] in data["conns"]:
					data["conns"].append([i0, i1])
	return data

enum LOAD_ERROR \
{
	OK,						#Load successful
	
	CORRUPTED,				#An empty dict is given, likely JSON could not be read
	MISSING_KEY,			#Missing a required key
	WRONG_VERSION,			#Version mismatch
	BAD_TYPE,				#A value provided was not the correct type
	
	TERRITORY,				#Territory could not be loaded
	PATH,					#Path could not be loaded
}

static func getLoadErrorString(error : LOAD_ERROR) -> String:
	match error:
		LOAD_ERROR:
			return "Corrupted: The file could not be loaded or the JSON data could not be parsed."
		LOAD_ERROR.MISSING_KEY:
			return "Missing Key: The JSON data was missing a vital key."
		LOAD_ERROR.WRONG_VERSION:
			return "Wrong Version: The versions of the game and save file don't match."
		LOAD_ERROR.BAD_TYPE:
			return "Bad Type: There was an incorrect data type found."
		LOAD_ERROR.TERRITORY:
			return "Territory: An error occured when trying to load in territory data."
		LOAD_ERROR.PATH:
			return "Path: An error occured when trying to connect the paths."
		_:
			return "_NONE"

func loadSaveData(data : Dictionary) -> LOAD_ERROR:
	clear()
	
	if data.is_empty():
		return LOAD_ERROR.CORRUPTED
	if not data.has("name") or not data.has("ver") or not data.has("terrs") or not data.has("conns"):
		return LOAD_ERROR.MISSING_KEY
	if data["ver"] != BOARD_VERSION:
		return LOAD_ERROR.WRONG_VERSION
	
	if typeof(data["terrs"]) != TYPE_ARRAY or typeof(data["conns"]) != TYPE_ARRAY or typeof(data["name"]) != TYPE_STRING or typeof(data["ver"]) != TYPE_STRING:
		return LOAD_ERROR.BAD_TYPE
	
	boardName = data["name"]
	
	for territorySaveData in data["terrs"]:
		if typeof(territorySaveData) != TYPE_DICTIONARY:
			return LOAD_ERROR.TERRITORY
		var terr : TerritoryNode = makeTerritory(Vector2.ZERO)
		if not terr.loadSaveData(territorySaveData):
			return LOAD_ERROR.TERRITORY
	
	var territories : Array = getAllTerritories()
	for pathSaveData in data["conns"]:
		if typeof(pathSaveData) != TYPE_ARRAY:
			return LOAD_ERROR.PATH
		if pathSaveData.size() != 2:
			return LOAD_ERROR.PATH
		if typeof(pathSaveData[0]) != TYPE_FLOAT or typeof(pathSaveData[1]) != TYPE_FLOAT:
			return LOAD_ERROR.PATH
		var index0 = int(pathSaveData[0])
		var index1 = int(pathSaveData[1])
		if index0 >= territories.size() or index1 >= territories.size():
			return LOAD_ERROR.PATH
		var terr0 = territories[index0]
		var terr1 = territories[index1]
		connectTerritories(terr0, terr1)
	
	recenter()
	
	return LOAD_ERROR.OK
	
