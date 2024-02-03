extends Node

@export var ip : String = "127.0.0.1"
@export var port : int = 25565

const waitTimeMax : float = 8

func _ready():
	LoadingScreen.show()
