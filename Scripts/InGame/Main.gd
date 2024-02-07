extends Node

var peer : ENetMultiplayerPeer = null

func connectToServer(port : int) -> void:
	print("Connecting to game @ " + MatchMakerClient.ip + ":" + str(port))
	
	peer = ENetMultiplayerPeer.new()
	peer.connect("peer_connected", self.onPeerConnected)
	peer.connect("peer_disconnected", self.onPeerDisconnected)
	peer.create_client(MatchMakerClient.ip, port)
	peer.set_target_peer(MultiplayerPeer.TARGET_PEER_SERVER)
	multiplayer.multiplayer_peer = peer

func onPeerConnected(id : int):
	print("Connected: ", id)

func onPeerDisconnected(id : int):
	print("DC'ed: ", id)
	if id == 1:
		get_tree().change_scene_to_packed(Preloader.startScreen)
		print("Disconnected from server")

func onConcedePressed() -> void:
	rpc("onConcede")

func onQuitPressed() -> void:
	get_tree().change_scene_to_packed(Preloader.startScreen)

####################################################################################################
###   DUMMY FUNCTIONS FOR RPC   ###

@rpc("any_peer", "call_remote", "reliable")
func onConcede() -> void:
	pass

####################################################################################################
