extends Node

class_name Main

var peer : ENetMultiplayerPeer = null
var connectIP : String = ""
var connectPort : int = -1

var canReconnect : bool = true
var quitting : bool = false

const RECONNET_TIME_MAX : float = 45.0

var timeOnEnd : float = -1

####################################################################################################

var selfPlayer : PlayerBase
var allPlayers : Array = []
var otherPlayers : Array = []
var idToPlayer : Dictionary = {}

####################################################################################################

@onready var timerLabel : Label = $CanvasLayer/TimerLabel
@onready var selectorBoard : SelectorBoard = $SelectorBoard
@onready var selectorDeck : SelectorDeck = $SelectorDeck

@onready var boardHolder : Node2D = $BoardHolder
@onready var boardNode : BoardNodeGame = $BoardHolder/BoardNodeGame

@onready var handHolder : Node2D = $HandHolder
@onready var graveHolder : Node2D = $GraveHolder
@onready var deckHolder : Node2D = $DeckHolder

static func swapAndConnect(port : int) -> void:
	var main = Preloader.main.instantiate()
	var tree = Preloader.get_tree()
	var node = tree.get_current_scene()
	var nodeParent = node.get_parent()
	nodeParent.remove_child(node)
	node.queue_free()
	nodeParent.add_child(main)
	tree.current_scene = main
	main.connectToServer(port)

func connectToServer(port : int) -> void:
	connectIP = MatchMakerClient.ip
	connectPort = port
	print("Connecting to game @ " + connectIP + ":" + str(connectPort))
	
	#Setting up connection to server
	peer = ENetMultiplayerPeer.new()
	peer.create_client(MatchMakerClient.ip, port)
	peer.set_target_peer(MultiplayerPeer.TARGET_PEER_SERVER)
	
	#Setting up connect functions
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("peer_connected", self.onPeerConnected)
	multiplayer.connect("peer_disconnected", self.onPeerDisconnected)
	
	multiplayer.connect("connected_to_server", self.onConnectedToServer)
	multiplayer.connect("connection_failed", self.onConnectFailed)
	multiplayer.connect("server_disconnected", self.onServerDisconnect)

func _exit_tree():
	multiplayer.multiplayer_peer = null
	multiplayer.disconnect("peer_connected", self.onPeerConnected)
	multiplayer.disconnect("peer_disconnected", self.onPeerDisconnected)
	multiplayer.disconnect("connected_to_server", self.onConnectedToServer)
	multiplayer.disconnect("connection_failed", self.onConnectFailed)
	multiplayer.disconnect("server_disconnected", self.onServerDisconnect)
	
	if canReconnect:
		FileIO.makeReconnectFile(connectIP, connectPort)

func onPeerConnected(id : int):
	print("Connected: ", id)

func onPeerDisconnected(id : int):
	print("DC'ed: ", id)

func onConnectedToServer():
	print("Connected to Game Server")
	
	#Saving reconnect data file
	FileIO.makeReconnectFile(connectIP, connectPort)

func onConnectFailed():
	print("Failed to connect to Game Server")
	quitToMenu()

func onServerDisconnect():
	print("Game Server disconnecetd")
	quitToMenu()

func onConcedePressed() -> void:
	rpc("onConcede")

func onQuitPressed() -> void:
	if not quitting:
		quitting = true
		rpc("onQuit")
		await get_tree().create_timer(1.0).timeout
		quitToMenu()

func quitToMenu() -> void:
	FileIO.deleteReconnectFile()
	canReconnect = false
	get_tree().change_scene_to_packed(Preloader.startScreen)

func _process(delta : float):
	var td : int = int(timeOnEnd - Util.getTimeAbsolute())
	if td > 0:
		timerLabel.text = str(td)
	else:
		timerLabel.text = ""

####################################################################################################
###   FUNCTIONS FOR CLIENT RPC   ###

@rpc("authority", "call_remote", "reliable")
func onQuitAnswered():
	quitToMenu()

@rpc("authority", "call_remote", "reliable")
func syncTimerReceived(timeOnEnd : int):
	self.timeOnEnd = timeOnEnd

####################################################################################################
###   BEFORE GAME   ###

@rpc("authority", "call_remote", "reliable")
func playerAdded(isSelf : bool, playerID : int, color : Color, username : String) -> void:
	var playerData : PlayerBase = PlayerBase.new(playerID, color, username)
	if isSelf:
		selfPlayer = playerData
	else:
		otherPlayers.append(playerData)
	idToPlayer[playerID] = playerData
	allPlayers.append(playerData)
	print(str(playerData) + " connected")

@rpc("authority", "call_remote", "reliable")
func playerRemoved(playerID : int) -> void:
	var playerData : PlayerBase = idToPlayer[playerID]
	otherPlayers.erase(playerData)
	idToPlayer.erase(playerID)
	allPlayers.erase(playerData)
	print(str(playerData) + " dc'd")

@rpc("authority", "call_remote", "reliable")
func playerReconnected(oldID : int, newID : int) -> void:
	var playerData : PlayerBase = idToPlayer[oldID]
	idToPlayer.erase(oldID)
	idToPlayer[newID] = playerData
	playerData.playerID = newID
	print("Player: " + str(oldID) + " reconnected as " + str(newID))

####################################################################################################

@rpc("authority", "call_remote", "reliable")
func boardAllReceived(boardAllData : Array):
	print("Received all boards")
	selectorBoard.show()
	selectorBoard.addAllPreviews(boardAllData)

@rpc("authority", "call_remote", "reliable")
func setBoardVotes(voteData : Dictionary, totalVotes : int = -1) -> void:
	selectorBoard.setVotes(voteData, totalVotes)

func onBoardVote(preview : PreviewBase) -> void:
	var index : int = selectorBoard.holderToPreview.values().find(preview)
	if index != -1:
		rpc("onPlayerBoardVote", index)

var deckDataOnCheck : Array = []

@rpc("authority", "call_remote", "reliable")
func onBoardChosen() -> void:
	print("Received chosen board")
	selectorBoard.hide()
	selectorDeck.show()
	deckDataOnCheck = Util.getAllDeckData()
	selectorDeck.addAllPreviews(deckDataOnCheck)
	onDeckSelected(selectorDeck.randomPreview)

func onDeckSelected(preview : PreviewBase) -> void:
	if preview == selectorDeck.randomPreview:
		rpc("deckSelected", deckDataOnCheck[randi() % deckDataOnCheck.size()])
	else:
		var index : int = selectorDeck.holderToPreview.values().find(preview)
		if index != -1:
			rpc("deckSelected", deckDataOnCheck[index-1])

@rpc("authority", "call_remote", "reliable")
func onDeckRejected() -> void:
	print("ERROR: Deck was not validated by server")

@rpc("authority", "call_remote", "reliable")
func gameStarted() -> void:
	print("STARTING GAME!")
	selectorDeck.hide()

@rpc("authority", "call_remote", "reliable")
func setBoardData(data : Dictionary) -> void:
	boardNode.loadSaveData(data)

@rpc("authority", "call_remote", "reliable")
func onSetOpponentElements(playerID : int, elements : Array):
	print(playerID, " ", elements)

####################################################################################################


####################################################################################################
###   DUMMY FUNCTIONS FOR RPC   ###

@rpc("any_peer", "call_remote", "reliable")
func onConcede() -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func onQuit() -> void:
	pass

####################################################################################################

@rpc("any_peer", "call_remote", "reliable")
func onPlayerBoardVote(_index : int) -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func deckSelected(_deckData : Dictionary) -> void:
	pass
