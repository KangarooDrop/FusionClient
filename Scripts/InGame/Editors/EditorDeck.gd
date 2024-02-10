extends Node

func onExitPressed() -> void:
	get_tree().change_scene_to_packed(Preloader.startScreen)
