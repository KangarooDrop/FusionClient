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

@onready var chatVBox : VBoxContainer = $ChatPanel/ChatHolder/ChatVBox
@onready var sendEdit : LineEdit = $ChatPanel/SendHolder/SendEdit

const debug : bool = false

var isReady : bool = false
var isHost : bool = false
var inLobby : bool = false
var allReady : bool = false
const  pingMaxTime : float = 1.0
var pingTimer : float = pingMaxTime

####################################################################################################

func updateButtons() -> void:
	startButton.disabled = not allReady and not debug
	readyButton.disabled = not inLobby and not debug
	readyButton.set_text("Ready" if self.isReady else "Not Ready")
	exitLobbyButton.disabled = not inLobby and not debug
	mainMenuButton.disabled = not exitLobbyButton.disabled and not debug
	
	hostButton.disabled = inLobby and not debug
	joinButton.disabled = hostButton.disabled and not debug
	publicButton.disabled = hostButton.disabled and not debug
	usernameEdit.editable = not hostButton.disabled and not debug
	roomKeyEdit.editable = not hostButton.disabled and not debug
	numPlayersEdit.editable = not hostButton.disabled and not debug
	
	sendButton.disabled = not hostButton.disabled and not debug

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
	if val:
		for playerLabel in playerVBox.get_children():
			playerLabel.showOptions()
	else:
		for playerLabel in playerVBox.get_children():
			playerLabel.hideOptions()
	updateButtons()

func setIsReady(val : bool) -> void:
	self.isReady = val
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
	elif type == MatchMakerClient.CLIENT_SUCC_JOIN_LOBBY:
		setInLobby(true)

func onServerInfo(infoMessage : String) -> void:
	var split : Array = infoMessage.split(MatchMakerClient.DEL_HANDLER)
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

func onServerError(errorMessage : String) -> void:
	var split : Array = errorMessage.split(MatchMakerClient.DEL_HANDLER)
	var type : String = split[0]
	if type == MatchMakerClient.CLIENT_ERR_LOBBY_TIMEOUT or type == MatchMakerClient.CLIENT_ERR_KICKED or type == MatchMakerClient.CLIENT_ERR_BANNED:
		if inLobby:
			setInLobby(false)
			setIsHost(false)

func _process(delta):
	if inLobby:
		pingTimer -= delta
		if pingTimer <= 0:
			pingTimer = pingMaxTime
			MatchMakerClient.sendPing()

####################################################################################################

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
	MatchMakerClient.hostLobby(roomKey, int(numPlayers), username)

func onJoinLobbyPressed() -> void:
	var username : String = usernameEdit.get_text()
	var roomKey : String = roomKeyEdit.get_text()
	MatchMakerClient.joinLobby(roomKey, username)

func onPublicLobbiesPressed() -> void:
	MatchMakerClient.getPublicLobbies()



func onSendMessagePressed() -> void:
	var text : String = sendEdit.get_text()
	sendEdit.set_text("")
	MatchMakerClient.sendChat(text)
