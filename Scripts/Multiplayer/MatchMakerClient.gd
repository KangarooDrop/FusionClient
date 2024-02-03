extends Node

const address : String = "127.0.0.1"
const port : int = 25565

const DEL_HANDLER : String = '|'
const DEL_MESSAGE : String = ','

#Performable outside of an active lobby
const KEY_HOST_LOBBY = 'H'
const KEY_JOIN_LOBBY = 'J'
const KEY_PUBLIC_QUERY = 'Q'
#Performable only within an active lobby
const KEY_READY = 'R'
const KEY_CHAT_MESSAGE = 'C'
#Performable only by Lobby host
const KEY_START = "S"
const KEY_KICK = 'K'
const KEY_BAN = 'B'
#Utility
const KEY_PING = "P"
const KEY_EXIT = "X"

var server : PacketPeerUDP

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_F12 and event.pressed and not event.echo:
			send_test()

func _ready():
	server = PacketPeerUDP.new()
	server.set_dest_address(address, port)

func _process(_delta):
	var packet = getPacket()
	if packet != null:
		print("Received packet: ", packet.get_string_from_utf8())

func closeServer() -> void:
	if server != null:
		server.close()
		server = null

func getPacket():
	if server.get_available_packet_count() <= 0:
		return null
	else:
		return server.get_packet()

func send_test():
	var lobbyName : String = "Poopy"
	var playerName0 : String = "Kevin"
	var playerName1 : String = "Aaron"
	var playerName2 : String = "Cam"
	var numPlayers : int = 8
	var chatMessage : String = "Nerd doodles"
	
	#send_message(KEY_HOST_LOBBY + DEL_HANDLER + DEL_MESSAGE.join(PackedStringArray([lobbyName, str(numPlayers), playerName0])))
	#send_message(KEY_JOIN_LOBBY + DEL_HANDLER + DEL_MESSAGE.join(PackedStringArray([lobbyName, playerName1])))
	#send_message(KEY_PUBLIC_QUERY + DEL_HANDLER)
	#send_message(KEY_READY + DEL_HANDLER)
	#send_message(KEY_CHAT_MESSAGE + DEL_HANDLER + chatMessage)
	#send_message(KEY_START + DEL_HANDLER)
	#send_message(KEY_KICK + DEL_HANDLER + playerName1)
	#send_message(KEY_BAN + DEL_HANDLER + playerName2)
	#send_message(KEY_PING + DEL_HANDLER)
	send_message(KEY_EXIT + DEL_HANDLER)

func send_message(message: String) -> void:
	print("Sending message to server: ", message)
	var buffer = PackedByteArray()
	buffer.append_array(message.to_utf8_buffer())
	server.put_packet(buffer)
