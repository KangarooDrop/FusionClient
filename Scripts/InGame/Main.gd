extends Node

class_name Main

var peer : ENetMultiplayerPeer = null
var connectIP : String = ""
var connectPort : int = -1

var canReconnect : bool = true
var quitting : bool = false

const RECONNET_TIME_MAX : float = 45.0

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
		rpc("onQuit")

func quitToMenu() -> void:
	if not quitting:
		quitting = true
		FileIO.deleteReconnectFile()
		canReconnect = false
		get_tree().change_scene_to_packed(Preloader.startScreen)

####################################################################################################
###   FUNCTIONS FOR CLIENT RPC   ###

@rpc("authority", "call_remote", "reliable")
func onQuitAnswered():
	quitToMenu()

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
func setDeck(_deckData : Dictionary) -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func voteBoard(name : String) -> void:
	pass

####################################################################################################
