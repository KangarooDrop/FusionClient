extends Node2D

class_name TerritoryNodeBase

var td : TerritoryDataBase = null

@onready var sprite : Sprite2D = $Sprite2D

var radius : float = -1.0
const baseRadius : int = 32
func getRadiusMul() -> float:
	return sqrt(float(td.size))

func getRadiusPixels() -> float:
	return radius

func setColor(color : Color) -> void:
	sprite.modulate = color

func setTerritoryData(td : TerritoryDataBase) -> TerritoryNodeBase:
	self.td = td
	setSize(td.size, false)
	return self

func setSize(size : int, updateTerritoryData : bool = true) -> void:
	size = min(max(size, 1), TerritoryDataBase.maxSize)
	if updateTerritoryData:
		td.size = size
	var mul : float = getRadiusMul()
	radius = mul * baseRadius
	self.scale = Vector2.ONE * mul
