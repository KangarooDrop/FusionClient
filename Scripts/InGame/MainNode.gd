extends Node

var peer : ENetMultiplayerPeer = null

func _ready():
	print("Connecting to game @ " + MatchMakerClient.ip + ":" + str(MatchMakerClient.lastActivePort))
	
	peer = ENetMultiplayerPeer.new()
	peer.connect("peer_connected", self.onPeerConnected)
	peer.create_client(MatchMakerClient.ip, MatchMakerClient.lastActivePort)
	multiplayer.multiplayer_peer = peer

func onPeerConnected(id : int):
	print(id)
