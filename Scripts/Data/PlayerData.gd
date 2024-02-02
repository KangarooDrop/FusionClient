
class_name PlayerData

var playerID : int = -1
var color : Color = Color(1.0, 0.0, 1.0, 1.0)

func _init(playerID : int, color : Color):
	self.playerID = playerID
	self.color = color
