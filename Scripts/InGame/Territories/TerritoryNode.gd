extends Node2D

class_name TerritoryNode

const radius : int = 32

var customName : String = ""

@onready var sprite : Sprite2D = $Sprite2D

func setColor(color : Color) -> void:
	sprite.modulate = color

func getSaveData() -> Dictionary:
	var data : Dictionary = {}
	data["name"] = customName
	data["pos_x"] = position.x
	data["pos_y"] = position.y
	return data

func loadSaveData(data : Dictionary) -> bool:
	if not data.has("name") or not data.has("pos_x") or not data.has("pos_y"):
		print("KEY_ERROR")
		return false
	
	if typeof(data["name"]) != TYPE_STRING or typeof(data["pos_x"]) != TYPE_FLOAT or typeof(data["pos_y"]) != TYPE_FLOAT:
		print("TYPE_ERROR")
		return false
	
	customName = data["name"]
	position.x = data["pos_x"]
	position.y = data["pos_y"]
	return true
