extends Node2D

class_name TerritoryNodeBase

var td : TerritoryDataBase = null

@onready var sprite : Sprite2D = $Sprite2D

const radius : int = 32

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
	self.scale = Vector2.ONE * sqrt(float(size))
