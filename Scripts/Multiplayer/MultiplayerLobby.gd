extends Control


const lobbyPlayerLabelPacked : PackedScene = preload("res://Scenes/Multiplayer/LobbyPlayerLabel.tscn")

@onready var startButton : Button = $PlayersPanel/StartButton
@onready var readyButton : Button = $PlayersPanel/ReadyButton
@onready var exitLobbyButton : Button = $PlayersPanel/ExitLobbyButton
@onready var mainMenuButton : Button = $PlayersPanel/MainMenuButton

@onready var hostButton : Button = $ButtonsPanel/ButtonHolder/HostButton
@onready var joinButton : Button = $ButtonsPanel/ButtonHolder/JoinButton
@onready var publicButton : Button = $ButtonsPanel/ButtonHolder/PublicLobbiesButton

@onready var sendButton : Button = $ChatPanel/SendHolder/SendButton


@onready var playerVBox : VBoxContainer = $PlayersPanel/PlayersHolder/PlayerVBox

@onready var usernameEdit : LineEdit = $ButtonsPanel/ButtonHolder/UsernameEdit
@onready var roomKeyEdit : LineEdit = $ButtonsPanel/ButtonHolder/RoomKeyEdit
@onready var numPlayersEdit : LineEdit = $ButtonsPanel/ButtonHolder/NumPlayersEdit

@onready var chatHolder : Control = $ChatPanel/ChatHolder
@onready var chatVBox : VBoxContainer = $ChatPanel/ChatHolder/ChatVBox
@onready var sendEdit : LineEdit = $ChatPanel/SendHolder/SendEdit

@onready var acceptDialog : AcceptDialog = $AcceptDialog

const debug : bool = false

var isReady : bool = false
var isHost : bool = false
var inLobby : bool = false
var allReady : bool = false
const  pingMaxTime : float = 1.0
var pingTimer : float = pingMaxTime
var waitingForServer : bool = false

####################################################################################################

func showDialog(title : String, text : String, okButtonText : String = "OK"):
	acceptDialog.title = title
	acceptDialog.dialog_text = text
	acceptDialog.ok_button_text = okButtonText
	acceptDialog.size.x = 100
	acceptDialog.show()

func updateButtons() -> void:
	startButton.disabled = (not allReady or waitingForServer) and not debug
	readyButton.disabled = (not inLobby or waitingForServer) and not debug
	readyButton.set_text("Ready" if self.isReady else "Not Ready")
	exitLobbyButton.disabled = (not inLobby or waitingForServer) and not debug
	mainMenuButton.disabled = not exitLobbyButton.disabled and not debug
	
	hostButton.disabled = (inLobby or waitingForServer) and not debug
	joinButton.disabled = (hostButton.disabled or waitingForServer) and not debug
	publicButton.disabled = (hostButton.disabled or waitingForServer) and not debug
	usernameEdit.editable = (not hostButton.disabled or waitingForServer) and not debug
	roomKeyEdit.editable = (not hostButton.disabled or waitingForServer) and not debug
	numPlayersEdit.editable = (not hostButton.disabled or waitingForServer) and not debug
	
	sendButton.disabled = (not hostButton.disabled or waitingForServer) and not debug

func setInLobby(val : bool) -> void:
	if val != self.inLobby:
		setIsReady(false)
	self.inLobby = val
	if not self.inLobby:
		setPlayerDisplay([])
		allReady = false
	updateButtons()

func setIsHost(val : bool) -> void:
	self.isHost = val
	for playerLabel in playerVBox.get_children():
		setPlayerLabelOptions(playerLabel)
	updateButtons()

func setPlayerLabelOptions(playerLabel) -> void:
	if isHost:
		playerLabel.showOptions()
	else:
		playerLabel.hideOptions()

func setIsReady(val : bool) -> void:
	self.isReady = val
	updateButtons()

func setWaitingForServer(val : bool) -> void:
	if waitingForServer != val:
		waitingForServer = val
		updateButtons()

####################################################################################################

func _ready():
	MatchMakerClient.connect("onServerSuccess", self.onServerSuccess)
	MatchMakerClient.connect("onServerInfo", self.onServerInfo)
	MatchMakerClient.connect("onServerError", self.onServerError)
	
	setInLobby(false)
	setIsHost(false)
	setIsReady(false)

func _exit_tree():
	MatchMakerClient.disconnect("onServerSuccess", self.onServerSuccess)
	MatchMakerClient.disconnect("onServerInfo", self.onServerInfo)
	MatchMakerClient.disconnect("onServerError", self.onServerError)

func onServerSuccess(successMessage : String) -> void:
	var split : Array = successMessage.split(MatchMakerClient.DEL_HANDLER)
	var type : String = split[0]
	if type == MatchMakerClient.CLIENT_SUCC_HOST_LOBBY:
		setInLobby(true)
		setIsHost(true)
		isHost = true
		clearChat()
	elif type == MatchMakerClient.CLIENT_SUCC_JOIN_LOBBY:
		setInLobby(true)
		clearChat()
	elif type == MatchMakerClient.CLIENT_SUCC_START_GAME:
		var main = Preloader.main.instantiate()
		var tree = get_tree()
		var node = tree.get_current_scene()
		var nodeParent = node.get_parent()
		nodeParent.remove_child(node)
		node.queue_free()
		nodeParent.add_child(main)
		tree.current_scene = main
		main.connectToServer(int(split[1]))
	
	setWaitingForServer(false)

func onServerInfo(infoMessage : String) -> void:
	var split : Array = infoMessage.split(MatchMakerClient.DEL_HANDLER, true, 1)
	var type : String = split[0]
	if type == MatchMakerClient.CLIENT_INFO_PLAYERS:
		allReady = true
		var parsed : Array = []
		var playersData : Array = split[1].split(MatchMakerClient.DEL_MESSAGE)
		for pd in playersData:
			var playerSplit : Array = pd.split(MatchMakerClient.DEL_SUB)
			var username : String = playerSplit[0]
			var isReady : bool = playerSplit[1] == "1"
			parsed.append([username, isReady])
			if not isReady:
				allReady = false
			updateButtons()
		setPlayerDisplay(parsed)
	elif type == MatchMakerClient.CLIENT_INFO_SET_HOST:
		showDialog("Host Disconnected", "You are now the host of the lobby")
		setIsHost(true)
	elif type == MatchMakerClient.CLIENT_INFO_CHAT:
		var chatLabel : Label = Label.new()
		chatVBox.add_child(chatLabel)
		chatLabel.text = split[1]
		await get_tree().process_frame
		chatVBox.position.y = chatHolder.size.y - chatVBox.size.y
	
	setWaitingForServer(false)

func onServerError(errorMessage : String) -> void:
	var split : Array = errorMessage.split(MatchMakerClient.DEL_HANDLER)
	var type : String = split[0]
	if type == MatchMakerClient.CLIENT_ERR_LOBBY_TIMEOUT or type == MatchMakerClient.CLIENT_ERR_KICKED or type == MatchMakerClient.CLIENT_ERR_BANNED or type == MatchMakerClient.CLIENT_ERR_SERVER_TIMEOUT:
		if inLobby:
			setInLobby(false)
			setIsHost(false)
	
	match type:
		MatchMakerClient.CLIENT_ERR_USER_IN_LOBBY:
			showDialog("Error", "You are already in a lobby (wait a moment and retry)")
		MatchMakerClient.CLIENT_ERR_LOBBY_NAME_TAKEN:
			showDialog("Error", "That name is already in use")
		MatchMakerClient.CLIENT_ERR_LOBBY_TIMEOUT:
			showDialog("Error", "The lobby timed out")
		MatchMakerClient.CLIENT_ERR_USERNAME_TAKEN:
			showDialog("Error", "That username is already in use by someone in the lobby")
		MatchMakerClient.CLIENT_ERR_LOBBY_BAD_SIZE:
			showDialog("Error", "Too many players (max of 8)")
		MatchMakerClient.CLIENT_ERR_NOT_HOST:
			showDialog("Error", "You are not the host of the lobby")
		MatchMakerClient.CLIENT_ERR_NOT_IN_LOBBY:
			showDialog("Error", "You are not in a lobby")
		MatchMakerClient.CLIENT_ERR_USERS_NOT_READY:
			showDialog("Error", "Some users are not ready")
		MatchMakerClient.CLIENT_ERR_NO_LOBBY_FOUND:
			showDialog("Error", "Could not find the provided lobby")
		MatchMakerClient.CLIENT_ERR_COULD_NOT_JOIN:
			showDialog("Error", "Could not join the lobby")
		MatchMakerClient.CLIENT_ERR_NO_USER_FOUND:
			showDialog("Error", "Could not find the provided user")
		MatchMakerClient.CLIENT_ERR_KICKED:
			showDialog("Kicked", "You have been kicked from the lobby")
		MatchMakerClient.CLIENT_ERR_BANNED:
			showDialog("Banned", "You have been banned from the lobby")
		
		MatchMakerClient.CLIENT_ERR_INVALID_REQUEST:
			showDialog("Error", "Invalid request received")
		MatchMakerClient.CLIENT_ERR_BAD_START_GAME:
			showDialog("Error", "Could not start the game. Please try again")
		MatchMakerClient.CLIENT_ERR_USERNAME_BAD:
			showDialog("Error", "Invalid username")
		MatchMakerClient.CLIENT_ERR_BAD_CHAT:
			showDialog("Error", "Invalid chat message")
		
		MatchMakerClient.CLIENT_ERR_SERVER_TIMEOUT:
			showDialog("Error", "Server timeout. Please contact your nearest Kevin")
	
	setWaitingForServer(false)

func _process(delta):
	if inLobby:
		pingTimer -= delta
		if pingTimer <= 0:
			pingTimer = pingMaxTime
			MatchMakerClient.sendPing()

####################################################################################################

func clearChat() -> void:
	for c in chatVBox.get_children():
		c.free()
	chatVBox.size.y = 0.0
	
func setPlayerDisplay(playerData : Array) -> void:
	var numLabels : int = playerVBox.get_child_count()
	if numLabels > playerData.size():
		for i in range(numLabels-1, playerData.size()-1, -1):
			playerVBox.get_child(i).queue_free()
	if playerData.size() > numLabels:
		for i in range(numLabels, playerData.size(), 1):
			var lobbyPlayerLabel = lobbyPlayerLabelPacked.instantiate()
			playerVBox.add_child(lobbyPlayerLabel)
			lobbyPlayerLabel.connect("onKick", self.onKick)
			lobbyPlayerLabel.connect("onBan", self.onBan)
			setPlayerLabelOptions(lobbyPlayerLabel)
	
	for i in range(playerData.size()):
		var lobbyPlayerLabel = playerVBox.get_child(i)
		lobbyPlayerLabel.setUsername(playerData[i][0])
		lobbyPlayerLabel.setReady(playerData[i][1])

####################################################################################################

func onKick(username : String) -> void:
	MatchMakerClient.kickUser(username)

func onBan(username : String) -> void:
	MatchMakerClient.banUser(username)

func onStartGamePressed() -> void:
	MatchMakerClient.startGame()

func onReadyPressed() -> void:
	setIsReady(not isReady)
	MatchMakerClient.setReady(isReady)

func onExitLobbyPressed() -> void:
	MatchMakerClient.onExit()
	setInLobby(false)
	setIsHost(false)

func onMainMenuPressed() -> void:
	get_tree().change_scene_to_packed(Preloader.startScreen)



func onHostLobbyPressed() -> void:
	var username : String = usernameEdit.get_text()
	var roomKey : String = roomKeyEdit.get_text()
	var numPlayers : String = numPlayersEdit.get_text()
	setWaitingForServer(true)
	MatchMakerClient.hostLobby(roomKey, int(numPlayers), username)

func onJoinLobbyPressed() -> void:
	var username : String = usernameEdit.get_text()
	var roomKey : String = roomKeyEdit.get_text()
	setWaitingForServer(true)
	MatchMakerClient.joinLobby(roomKey, username)

func onPublicLobbiesPressed() -> void:
	setWaitingForServer(true)
	MatchMakerClient.getPublicLobbies()



func onSendMessagePressed(text : String = "") -> void:
	text = sendEdit.get_text()
	sendEdit.set_text("")
	MatchMakerClient.sendChat(text)
