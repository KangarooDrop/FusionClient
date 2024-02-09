extends Control

@onready var multiplayerButton : Button = $VBoxContainer/MultiplayerButton
@onready var boardEditorButton : Button = $VBoxContainer/BoardEditorButton
@onready var settingsButton : Button = $VBoxContainer/SettingsButton
@onready var exitButton : Button = $VBoxContainer/ExitButton
@onready var buttons : Array = [multiplayerButton, boardEditorButton, settingsButton, exitButton]

####################################################################################################
###   RECONNECTION   ###

func _ready():
	await get_tree().process_frame
	if not tryReconnect():
		for b in buttons:
			b.show()

func tryReconnect() -> bool:
	var reconnectData : Dictionary = FileIO.readReconnectFile()
	if not reconnectData.is_empty():
		if not reconnectData.has('time') or not reconnectData.has('ip') or not reconnectData.has('port'):
			print("Error: Could not try reconnecting to last game. The file appears to be corrupted")
			FileIO.deleteReconnectFile()
			return false
		var timeSinceDC : int = int(Util.getTimeAbsolute() - reconnectData['time'])
		print("Time since disconnection: " + str(timeSinceDC))
		var port : int = int(reconnectData['port'])
		if timeSinceDC < Main.RECONNET_TIME_MAX:
			print("Attempting to reconnect to last Game Server")
			Main.swapAndConnect(port)
			return true
		else:
			print("Too long since disconnect: deleting")
			FileIO.deleteReconnectFile()
	else:
		print("No reconnect file found. Starting main menu")
	return false

####################################################################################################
###   BUTTONS   ###

func onDeckEditorPressed():
	get_tree().change_scene_to_packed(Preloader.editorDeck)

func onBoardEditorPressed():
	get_tree().change_scene_to_packed(Preloader.editorBoard)

func onMultiplayerPressed():
	get_tree().change_scene_to_packed(Preloader.multiplayerLobby)

func onSettingsPressed():
	pass

func onExitPressed():
	get_tree().quit()
