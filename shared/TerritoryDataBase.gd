
class_name TerritoryDataBase

var name : String = ""
var position : Vector2 = Vector2()
var value : int = 1
var size : int = 1

const maxSize : int = 4

func _init(name : String, position : Vector2, value : int = 1, size : int = 1):
	self.name = name
	self.position = position
	self.value = value
	self.size = size

func setName(newName : String) -> void:
	name = newName

func getSaveData() -> Dictionary:
	return {"name":name, "pos_x":position.x, "pos_y":position.y, "value":value, "size":size}
