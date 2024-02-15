
class_name PlayerBase

var playerID : int = -1
var color : Color = Color.BLACK
var username : String = "_NONE"

func _init(playerID : int, color : Color, username : String):
	self.playerID = playerID
	self.color = color
	self.username = username

func _to_string():
	return "PlayerBase(" + "#" + str(playerID) + " | " + username + ")" 
