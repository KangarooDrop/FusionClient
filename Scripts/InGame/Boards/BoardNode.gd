extends Node2D

class_name BoardNode

@onready var territyHolder : Node2D = $TerritoryHolder
@onready var lineHolder : Node2D = $LineHolder

var bd : BoardData

var nodeToTerritoryData : Dictionary = {}
var territoryDataToNode : Dictionary = {}

var nodeToLines : Dictionary = {}
var lineToNodes : Dictionary = {}

func _ready():
	bd = BoardData.new()
	bd.connect("onClear", self.onClear)
	
	bd.connect("onTerritoryMoved", self.onTerritoryMoved)
	bd.connect("onTerritoryAdded", self.onTerritoryAdded)
	bd.connect("beforeTerritoryRemoved", self.territoryRemoved)
	
	bd.connect("onPathAdded", self.onPathAdded)
	bd.connect("beforePathRemoved", self.beforePathRemoved)

####################################################################################################

func onClear():
	for terr in getAllTerritories():
		terr.free()
	for line in getAllLines():
		line.free()
	nodeToTerritoryData.clear()
	territoryDataToNode.clear()
	nodeToLines.clear()
	lineToNodes.clear()

func onTerritoryAdded(td : BoardData.TerritoryData):
	var terr : TerritoryNode = getTerritoryPacked().instantiate()
	territyHolder.add_child(terr)
	terr.position = td.position
	territoryDataToNode[td] = terr
	nodeToTerritoryData[terr] = td
	nodeToLines[terr] = []

func territoryRemoved(td : BoardData.TerritoryData):
	var terr : TerritoryNode = territoryDataToNode[td]
	for t in bd.paths[td].keys():
		if bd.paths[td][t]:
			beforePathRemoved(td, t)
	nodeToTerritoryData.erase(terr)
	territoryDataToNode.erase(td)
	terr.queue_free()

func onTerritoryMoved(td : BoardData.TerritoryData):
	var terr : TerritoryNode = territoryDataToNode[td]
	terr.position = td.position
	for line in nodeToLines[terr]:
		moveLine(line, lineToNodes[line][0].position, lineToNodes[line][1].position)

func moveLine(line : Line2D, startPos : Vector2, endPos : Vector2):
	line.position = startPos
	line.points = PackedVector2Array([Vector2(), endPos - startPos])

func onPathAdded(td0 : BoardData.TerritoryData, td1 : BoardData.TerritoryData):
	var terr0 : TerritoryNode = territoryDataToNode[td0]
	var terr1 : TerritoryNode = territoryDataToNode[td1]
	var line : Line2D = Line2D.new()
	lineHolder.add_child(line)
	moveLine(line, terr0.position, terr1.position)
	nodeToLines[terr0].append(line)
	nodeToLines[terr1].append(line)
	lineToNodes[line] = [terr0, terr1]

func beforePathRemoved(td0 : BoardData.TerritoryData, td1 : BoardData.TerritoryData):
	var terr0 : TerritoryNode = territoryDataToNode[td0]
	var terr1 : TerritoryNode = territoryDataToNode[td1]
	var line : Line2D = getLine(terr0, terr1)
	lineToNodes.erase(line)
	nodeToLines[terr0].erase(line)
	nodeToLines[terr1].erase(line)
	line.queue_free()

func connectTerritories(terr0 : TerritoryNode, terr1 : TerritoryNode) -> void:
	if terr0 != terr1:
		var td0 : BoardData.TerritoryData = nodeToTerritoryData[terr0]
		var td1 : BoardData.TerritoryData = nodeToTerritoryData[terr1]
		bd.setPath(td0, td1, true)

func disconnectTerritories(terr0 : TerritoryNode, terr1 : TerritoryNode):
	if terr0 != terr1:
		var td0 : BoardData.TerritoryData = nodeToTerritoryData[terr0]
		var td1 : BoardData.TerritoryData = nodeToTerritoryData[terr1]
		bd.setPath(td0, td1, false)

#Returns the line node connecting two territories if it exists
func getLine(terr0 : TerritoryNode, terr1 : TerritoryNode) -> Line2D:
	for line in lineToNodes.keys():
		if lineToNodes[line] == [terr0, terr1] or lineToNodes[line] == [terr1, terr0]:
			return line
	return null

####################################################################################################

func clear() -> void:
	bd.clear()

####################################################################################################

func getTerritoryPacked() -> PackedScene:
	return Preloader.territoryNode

func getAllTerritories() -> Array:
	return territyHolder.get_children()

func getAllLines() -> Array:
	return lineHolder.get_children()

func makeTerritory(pos : Vector2) -> void:
	bd.addTerritory("", pos)

func removeTerritory(terr : TerritoryNode) -> void:
	bd.removeTerritory(nodeToTerritoryData[terr])

#Change the position of a territory and any line connected to it
func moveTerritory(terr : TerritoryNode, pos : Vector2) -> void:
	var td : BoardData.TerritoryData = nodeToTerritoryData[terr]
	bd.moveTerritory(td, pos)

####################################################################################################

func isConnected(terr0 : TerritoryNode, terr1 : TerritoryNode) -> bool:
	var td0 : BoardData.TerritoryData = nodeToTerritoryData[terr0]
	var td1 : BoardData.TerritoryData = nodeToTerritoryData[terr1]
	return bd.paths[td0][td1]

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

func getOverlappingLine(pos : Vector2) -> Line2D:
	for line in lineToNodes.keys():
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
	return bd.name



func getSaveData() -> Dictionary:
	return bd.getSaveData()

func loadSaveData(data : Dictionary) -> Validator.BOARD_CODE:
	var error : Validator.BOARD_CODE = Validator.validateBoard(data)
	if error != Validator.BOARD_CODE.OK:
		return error
	
	bd.loadSaveData(data)
	recenter()
	return Validator.BOARD_CODE.OK
