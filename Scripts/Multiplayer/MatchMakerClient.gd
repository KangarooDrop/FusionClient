extends Node

const address : String = "127.0.0.1"
const port : int = 25565

####################################################################################################

const CLIENT_TYPE_SUCC = 'succ'
const CLIENT_TYPE_ERR = 'err'
const CLIENT_TYPE_INFO = 'info'

const DEL_HANDLER : String = '|'
const DEL_MESSAGE : String = ','
const DEL_SUB     = ':'

####################################################################################################

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




####################################################################################################

const CLIENT_SUCC_HOST_LOBBY = CLIENT_TYPE_SUCC + DEL_MESSAGE +       'lobby_created'
const CLIENT_SUCC_JOIN_LOBBY = CLIENT_TYPE_SUCC + DEL_MESSAGE +       'lobby_joined'
const CLIENT_SUCC_START_GAME = CLIENT_TYPE_SUCC + DEL_MESSAGE +       'start_game'

const CLIENT_SUCCESSES : Array = [CLIENT_SUCC_HOST_LOBBY, CLIENT_SUCC_JOIN_LOBBY, CLIENT_SUCC_START_GAME]

####################################################################################################

const CLIENT_INFO_PLAYERS = CLIENT_TYPE_INFO + DEL_MESSAGE +          'players'
const CLIENT_INFO_PUBLIC_LOBBIES = CLIENT_TYPE_INFO + DEL_MESSAGE +   'public_lobbies'
const CLIENT_INFO_PING = CLIENT_TYPE_INFO + DEL_MESSAGE +             'ping'
const CLIENT_INFO_SET_HOST = CLIENT_TYPE_INFO + DEL_MESSAGE +         'set_host'
const CLIENT_INFO_CHAT = CLIENT_TYPE_INFO + DEL_MESSAGE +             'chat'

const CLIENT_INFOS : Array = [CLIENT_INFO_PLAYERS, CLIENT_INFO_PUBLIC_LOBBIES, CLIENT_INFO_PING, CLIENT_INFO_SET_HOST, CLIENT_INFO_CHAT]

####################################################################################################

const CLIENT_ERR_INVALID_REQUEST = CLIENT_TYPE_ERR + DEL_MESSAGE +    'invalid_request'
const CLIENT_ERR_USER_IN_LOBBY = CLIENT_TYPE_ERR + DEL_MESSAGE +      'user_in_lobby'
const CLIENT_ERR_USER_EXISTS = CLIENT_TYPE_ERR + DEL_MESSAGE +        'user_exists'
const CLIENT_ERR_LOBBY_NAME_TAKEN = CLIENT_TYPE_ERR + DEL_MESSAGE +   'lobby_name_taken'
const CLIENT_ERR_LOBBY_TIMEOUT = CLIENT_TYPE_ERR + DEL_MESSAGE +      'lobby_timeout'
const CLIENT_ERR_USERNAME_TAKEN = CLIENT_TYPE_ERR + DEL_MESSAGE +     'username_taken'
const CLIENT_ERR_USERNAME_BAD = CLIENT_TYPE_ERR + DEL_MESSAGE +       'username_bad'
const CLIENT_ERR_LOBBY_BAD_SIZE = CLIENT_TYPE_ERR + DEL_MESSAGE +     'lobby_bad_size'
const CLIENT_ERR_BAD_CHAT = CLIENT_TYPE_ERR + DEL_MESSAGE +           'bad_chat'
const CLIENT_ERR_NOT_HOST = CLIENT_TYPE_ERR + DEL_MESSAGE +           'not_host'
const CLIENT_ERR_NOT_IN_LOBBY = CLIENT_TYPE_ERR + DEL_MESSAGE +       'not_in_lobby'
const CLIENT_ERR_BAD_START_GAME = CLIENT_TYPE_ERR + DEL_MESSAGE +     'bad_start_game'
const CLIENT_ERR_USERS_NOT_READY = CLIENT_TYPE_ERR + DEL_MESSAGE +    'users_not_ready'
const CLIENT_ERR_NO_LOBBY_FOUND = CLIENT_TYPE_ERR + DEL_MESSAGE +     'lobby_not_found'
const CLIENT_ERR_COULD_NOT_JOIN = CLIENT_TYPE_ERR + DEL_MESSAGE +     'could_not_join'
const CLIENT_ERR_NO_USER_FOUND = CLIENT_TYPE_ERR + DEL_MESSAGE +      'user_not_found'
const CLIENT_ERR_KICKED = CLIENT_TYPE_ERR + DEL_MESSAGE +             'kicked'
const CLIENT_ERR_BANNED = CLIENT_TYPE_ERR + DEL_MESSAGE +             'banned'

const CLIENT_ERRORS : Array = [CLIENT_ERR_INVALID_REQUEST, CLIENT_ERR_USER_IN_LOBBY, CLIENT_ERR_USER_EXISTS, 
		CLIENT_ERR_LOBBY_NAME_TAKEN, CLIENT_ERR_LOBBY_TIMEOUT, CLIENT_ERR_USERNAME_TAKEN, CLIENT_ERR_USERNAME_BAD, 
		CLIENT_ERR_LOBBY_BAD_SIZE, CLIENT_ERR_BAD_CHAT, CLIENT_ERR_NOT_HOST, CLIENT_ERR_NOT_IN_LOBBY,
		CLIENT_ERR_BAD_START_GAME, CLIENT_ERR_USERS_NOT_READY, CLIENT_ERR_NO_LOBBY_FOUND, CLIENT_ERR_COULD_NOT_JOIN,
		CLIENT_ERR_NO_USER_FOUND, CLIENT_ERR_KICKED, CLIENT_ERR_BANNED]

####################################################################################################

var server : PacketPeerUDP

signal onServerSuccess(successMessage : String)
signal onServerInfo(infoMessage : String)
signal onServerError(errorMessage : String)

const printTraffic : bool = false

func _ready():
	server = PacketPeerUDP.new()
	server.set_dest_address(address, port)

func _process(_delta):
	var packet = getPacket()
	if packet != null:
		var packetString : String = packet.get_string_from_utf8()
		if printTraffic:
			print("Received packet: " + packetString)
		if packetString.begins_with(CLIENT_TYPE_SUCC):
			emit_signal("onServerSuccess", packetString)
		elif packetString.begins_with(CLIENT_TYPE_INFO):
			emit_signal("onServerInfo", packetString)
		elif packetString.begins_with(CLIENT_TYPE_ERR):
			emit_signal("onServerError", packetString)

func closeServer() -> void:
	if server != null:
		server.close()
		server = null

func getPacket():
	if server.get_available_packet_count() <= 0:
		return null
	else:
		return server.get_packet()



func hostLobby(lobbyName : String, numUsers : int, username : String) -> void:
	send_message(KEY_HOST_LOBBY + DEL_HANDLER + DEL_MESSAGE.join(PackedStringArray([lobbyName, str(numUsers), username])))

func joinLobby(lobbyName : String, username : String) -> void:
	send_message(KEY_JOIN_LOBBY + DEL_HANDLER + DEL_MESSAGE.join(PackedStringArray([lobbyName, username])))

func getPublicLobbies() -> void:
	send_message(KEY_PUBLIC_QUERY + DEL_HANDLER)



func setReady(val : bool) -> void:
	send_message(KEY_READY + DEL_HANDLER + str(1 if val else 0))

func startGame() -> void:
	send_message(KEY_START + DEL_HANDLER)

func sendChat(chatMessage : String) -> void:
	send_message(KEY_CHAT_MESSAGE + DEL_HANDLER + chatMessage)

func kickUser(username : String) -> void:
	send_message(KEY_KICK + DEL_HANDLER + username)

func banUser(username : String) -> void:
	send_message(KEY_BAN + DEL_HANDLER + username)

func sendPing() -> void:
	send_message(KEY_PING + DEL_HANDLER)

func onExit() -> void:
	send_message(KEY_EXIT + DEL_HANDLER)


func send_test():
	pass
	"""
	var lobbyName : String = "Poopy"
	var playerName0 : String = "Kevin"
	var playerName1 : String = "Aaron"
	var playerName2 : String = "Cam"
	var numPlayers : int = 8
	var chatMessage : String = "Nerd doodles"
	
	#send_message(KEY_HOST_LOBBY + DEL_HANDLER + DEL_MESSAGE.join(PackedStringArray([lobbyName, str(numPlayers), playerName0])))
	#	-> "H|Poopy,8,Kevin"
	#send_message(KEY_JOIN_LOBBY + DEL_HANDLER + DEL_MESSAGE.join(PackedStringArray([lobbyName, playerName1])))
	#	-> "J|Poopy,Aaron"
	#send_message(KEY_PUBLIC_QUERY + DEL_HANDLER)
	#	-> "Q|"
	#send_message(KEY_READY + DEL_HANDLER + str(1 if val else 0)
	#	-> "R|0"
	#send_message(KEY_CHAT_MESSAGE + DEL_HANDLER + chatMessage)
	#	-> "C|Nerd doodles"
	#send_message(KEY_START + DEL_HANDLER)
	#	-> "S|"
	#send_message(KEY_KICK + DEL_HANDLER + playerName1)
	#	-> "K|Aaron"
	#send_message(KEY_BAN + DEL_HANDLER + playerName2)
	#	-> "B|Cam"
	#send_message(KEY_PING + DEL_HANDLER)
	#	-> "P|"
	#send_message(KEY_EXIT + DEL_HANDLER)
	#	-> "X|"
	"""

func send_message(message: String) -> void:
	if printTraffic:
		print("Sending message to server: ", message)
	var buffer = PackedByteArray()
	buffer.append_array(message.to_utf8_buffer())
	server.put_packet(buffer)
