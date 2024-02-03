extends Control

func onMultiplayerPressed():
	get_tree().change_scene_to_packed(Preloader.multiplayerLobby)

func onBoardEditorPressed():
	get_tree().change_scene_to_packed(Preloader.editorBoard)

func onSettingsPressed():
	pass

func onExitPressed():
	get_tree().quit()
