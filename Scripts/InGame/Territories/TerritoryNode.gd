extends Node2D

class_name TerritoryNode

var td : BoardData.TerritoryData = null

@onready var sprite : Sprite2D = $Sprite2D

const radius : int = 32

func setColor(color : Color) -> void:
	sprite.modulate = color

func setTerritoryData(td : BoardData.TerritoryData) -> TerritoryNode:
	self.td = td
	return self
