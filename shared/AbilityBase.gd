
class_name AbilityBase

var name : String = "_Ability"
var desc : String = "_Desc"

func _init(name : String, desc : String):
	self.name = name
	self.desc = desc

func resolve() -> void:
	pass
