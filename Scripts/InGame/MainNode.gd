extends Node

var peer : ENetMultiplayerPeer = null

func _ready():
	print("Connecting to game @ " + MatchMakerClient.ip + ":" + str(MatchMakerClient.lastActivePort))
	
	peer = ENetMultiplayerPeer.new()
	peer.connect("peer_connected", self.onPeerConnected)
	peer.connect("peer_disconnected", self.onPeerDisconnected)
	peer.create_client(MatchMakerClient.ip, MatchMakerClient.lastActivePort)
	multiplayer.multiplayer_peer = peer

func onPeerConnected(id : int):
	print("Connected: ", id)

func onPeerDisconnected(id : int):
	print("DC'ed: ", id)
	if id == 1:
		get_tree().change_scene_to_packed(Preloader.startScreen)
		print("Disconnected from server")
