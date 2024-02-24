extends Node2D

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
var playerToNode : Dictionary = {}

####################################################################################################

@onready var timerLabel : Label = $CanvasLayer/TimerLabel
@onready var selectorBoard : SelectorBoard = $SelectorBoard
@onready var selectorDeck : SelectorDeck = $SelectorDeck

@onready var boardHolder : Node2D = $BoardHolder
@onready var boardNode : BoardNodeGame = $BoardHolder/BoardNodeGame

@onready var playerNodeHolder : Node2D = $BoardHolder/PlayerNodeHolder

@onready var confirmButton : Button = $CanvasLayer/ConfirmButton

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



func onConfirmPressed():
	confirmButton.hide()
	if waitingForBoard:
		rpc("onBoardVoteConfirmed")
		waitingForBoard = false
	elif waitingForDeck:
		rpc("onDeckConfirmed")
		waitingForDeck = false
	
	elif waitingForBet:
		rpc("onBetConfirmed")
		possibleBetIndices.clear()
		possibleBetNodes.clear()
		waitingForBet = false
	elif waitingForAction:
		rpc("onActionConfirmed")
		possibleActions.clear()
		waitingForAction = false
	elif waitingForReveals:
		possibleReveals.clear()
		rpc("onRevealConfirmed")
		waitingForReveals = false

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

var mouseGlobalPosition : Vector2 = Vector2()
func _process(delta : float):
	var td : int = int(timeOnEnd - Util.getTimeAbsolute())
	if td > 0:
		timerLabel.text = str(td)
	else:
		timerLabel.text = ""
	
	processInGame()
	
	mouseGlobalPosition = get_global_mouse_position()

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
	
	var playerNode : PlayerNode = Preloader.playerNode.instantiate()
	playerNodeHolder.add_child(playerNode)
	playerToNode[playerData] = playerNode
	playerNode.position = Vector2.DOWN.rotated(PI/2.0 * idToPlayer.size()) * 600.0
	playerNode.rotation = playerNode.position.angle() - PI/2.0
	playerNode.setPlayer(playerData)
	
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
	if idToPlayer.has(oldID):
		var playerData : PlayerBase = idToPlayer[oldID]
		idToPlayer.erase(oldID)
		idToPlayer[newID] = playerData
		playerData.playerID = newID
	print("Player: " + str(oldID) + " reconnected as " + str(newID))

####################################################################################################

var waitingForBoard : bool = false
var waitingForDeck : bool = false

@rpc("authority", "call_remote", "reliable")
func boardAllReceived(boardAllData : Array):
	print("Received all boards")
	selectorBoard.show()
	selectorBoard.addAllPreviews(boardAllData)
	waitingForBoard = true
	confirmButton.show()

@rpc("authority", "call_remote", "reliable")
func setBoardVotes(voteData : Dictionary, totalVotes : int = -1) -> void:
	selectorBoard.setVotes(voteData, totalVotes)

func onBoardVote(preview : PreviewBase) -> void:
	var index : int = selectorBoard.holderToPreview.values().find(preview)
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
	waitingForBoard = false
	waitingForDeck = true
	confirmButton.show()

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
	waitingForDeck = false

@rpc("authority", "call_remote", "reliable")
func setBoardData(data : Dictionary) -> void:
	boardNode.loadSaveData(data)
	boardNode.setPlayers(allPlayers)
	for territory in boardNode.getAllTerritories():
		for slot in territory.getAllSlots():
			slot.connect("slot_pressed", onSlotPressed.bind(slot))

@rpc("authority", "call_remote", "reliable")
func onSetOpponentElements(playerID : int, elements : Array):
	var player : PlayerBase = idToPlayer[playerID]
	print(str(player) + " " + str(elements))

####################################################################################################

var commandQueue : Array = []

var betHovering = null
var betSelected = null
var waitingForBet : bool = false
var possibleBetIndices : Array = []
var possibleBetNodes : Array = []

var waitingForAction : bool = false
var possibleActions : Dictionary = {}

var waitingForReveals : bool = false
var possibleReveals : Dictionary = {}

func processInGame():
	if waitingForBet:
		var newBetHovering = boardNode.getOverlappingTerritory(mouseGlobalPosition)
		if newBetHovering != betHovering:
			if is_instance_valid(betHovering):
				if betHovering == betSelected:
					betHovering.setColor(selfPlayer.color)
				else:
					betHovering.setColorUnselected()
			
			if is_instance_valid(newBetHovering) and newBetHovering in possibleBetNodes:
				newBetHovering.showHighlight()
				if newBetHovering != betSelected:
					newBetHovering.setColorSelected()
				else:
					pass
			
			betHovering = newBetHovering
	
	processCommandQueue()

### BET PHASE ###
@rpc("authority", "call_remote", "reliable")
func readyForBetReceived(possibleBets : Array) -> void:
	print("Received possible bets: " + str(possibleBets))
	waitingForBet = true
	self.possibleBetIndices = possibleBets
	var terrs : Array = boardNode.getAllTerritories()
	for id in possibleBets:
		terrs[id].setColorUnselected()
		terrs[id].showHighlight()
		possibleBetNodes.append(terrs[id])
	confirmButton.show()

@rpc("authority", "call_remote", "reliable")
func allBetsReceived(bets : Dictionary) -> void:
	waitingForBet = false
	possibleBetIndices.clear()
	possibleBetNodes.clear()
	
	for territoryNode in boardNode.getAllTerritories():
		territoryNode.setColorUnselected()
		territoryNode.hideHighlight()
	
	betHovering = null
	betSelected = null
	
	for playerID in bets.keys():
		var player : PlayerBase = idToPlayer[playerID]
		boardNode.makeBetChip(player, bets[playerID])

### ACTION PHASE ###
@rpc("authority", "call_remote", "reliable")
func readyForActionReceived(possibleActions : Dictionary) -> void:
	print("Received possible actions: " + str(possibleActions))
	waitingForAction = true
	self.possibleActions = possibleActions
	confirmButton.show()

@rpc("authority", "call_remote", "reliable")
func allActionsReceived(actions : Dictionary) -> void:
	possibleActions.clear()
	waitingForAction = false
	print("ACTIONS: " + str(actions))

### REVEAL PHASE ###
@rpc("authority", "call_remote", "reliable")
func readyForRevealsReceived(possibleReveals : Dictionary) -> void:
	print("Received possible reveals: " + str(possibleReveals))
	waitingForReveals = true
	self.possibleReveals = possibleReveals
	confirmButton.show()

@rpc("authority", "call_remote", "reliable")
func allRevealsReceived(reveals : Dictionary) -> void:
	possibleReveals.clear()
	waitingForReveals = false
	print("REVEALS: " + str(reveals))

### ALL PHASES ###
@rpc("authority", "call_remote", "reliable")
func beginPhaseReceived(phase : CardDataBase.PHASE) -> void:
	match phase:
		CardDataBase.PHASE.START:
			pass
		CardDataBase.PHASE.DRAW:
			pass
		CardDataBase.PHASE.BET:
			pass
		CardDataBase.PHASE.ACTION:
			pass
		CardDataBase.PHASE.REVEAL:
			pass
		CardDataBase.PHASE.INVADE:
			boardNode.clearBetChips()
		CardDataBase.PHASE.END:
			pass

@rpc("authority", "call_remote", "reliable")
func endPhaseReceived(phase : CardDataBase.PHASE) -> void:
	match phase:
		CardDataBase.PHASE.START:
			pass
		CardDataBase.PHASE.DRAW:
			pass
		CardDataBase.PHASE.BET:
			pass
		CardDataBase.PHASE.ACTION:
			pass
		CardDataBase.PHASE.REVEAL:
			pass
		CardDataBase.PHASE.INVADE:
			boardNode.clearBetChips()
		CardDataBase.PHASE.END:
			pass

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and not event.is_echo():
		if waitingForBet:
			var territoryNode = boardNode.getOverlappingTerritory(mouseGlobalPosition)
			if is_instance_valid(territoryNode):
				var index : int = boardNode.bd.territories.find(territoryNode.td)
				if index in possibleBetIndices:
					rpc("onBetSelected", index)
					
					if is_instance_valid(betSelected):
						betSelected.setColorUnselected()
					betSelected = territoryNode
					betSelected.setColor(selfPlayer.color)

@rpc("authority", "call_remote", "reliable")
func receiveCommand(command) -> void:
	commandQueue.append(command)

#make [territory 0 0 0]
func processCommandQueue():
	while commandQueue.size() > 0:
		var command : Array = commandQueue.pop_front()
		if command[0] == "make":
			var loc : Array = command[1]
			if loc[0] == "territory":
				var terr : TerritoryNodeGame = boardNode.findTerritory(loc[1])
				var player : PlayerBase = allPlayers[loc[2]]
				var slotIndex : int = loc[3]
				terr.td.setCreature(CardDataGame.new({}), player, slotIndex)
				print("Setting creature at ", str(terr), " ", str(player), " ", str(slotIndex))
			elif loc[0] == "hand":
				var cardData : CardDataGame = CardDataGame.new(ListOfCards.getCardByID(0).serialize())
				var player : PlayerBase = allPlayers[loc[1]]
				var cardNode : CardNode = playerToNode[player].addToHandData(cardData)
				if player == selfPlayer:
					cardNode.setRoll(0.0)
				cardNode.connect("card_pressed", self.onCardPressed.bind(cardNode))
				print("Setting creature at hand")
		print(command)

var pressedCardNode : CardNode = null

func onCardPressed(buttonIndex : int, cardNode : CardNode):
	if buttonIndex == MOUSE_BUTTON_LEFT:
		if pressedCardNode == cardNode:
			pressedCardNode = null
		else:
			pressedCardNode = cardNode

func onSlotPressed(buttonIndex : int, creatureSlot : CreatureSlot) -> void:
	if buttonIndex == MOUSE_BUTTON_LEFT:
		if pressedCardNode != null and creatureSlot.cardNode == null:
			if pressedCardNode.cardData.zone == CardDataGame.ZONES.HAND:
				for player in playerToNode.keys():
					var playerNode : PlayerNode = playerToNode[player]
					if playerNode.isInHandNode(pressedCardNode):
						playerNode.removeFromHandNode(pressedCardNode)
						creatureSlot.setCardNode(pressedCardNode)
						return
			elif pressedCardNode.cardData.zone == CardDataGame.ZONES.TERRITORY:
				var oldSlot : CreatureSlot = boardNode.getCardNodeToSlot(pressedCardNode)
				if oldSlot != null:
					oldSlot.transferCardNode(creatureSlot)
					pressedCardNode = null
					
		
	elif buttonIndex == MOUSE_BUTTON_RIGHT:
		print("SLOT LOC: " + str(boardNode.slotToLoc(creatureSlot)))
	

#make - makes a card - /make LOC {data} - /make [board 0 1 0] {}
#	 -> Creates a dummy(hidden) card for player=0 at territory1's slot0

#move - moves a card - /move LOC NEW_LOC - /move [board 1 0 0] [board 1 2 0]
#	 -> Moves player=1 's creature from territory0's slot0 to territory2's slot0

#set - sets card data - /set LOC {data} - /set [hand 0 1] {"name":...}
#	 -> Sets the data of player=0 's hand[1] to the given data

#flip - flips a card - /flip LOC {data} - /flip [hand 1 4] {"name":...}
#	 -> Calls set() function and flip() function

#bet - puts chip on territory - /bet player_id territory_id slot - /bet 0 3
#	 -> Creates a chip for player=0 at territory3

#fuse - sets a card to be fused - /fuse SOURCE_LOC TARGET_LOC - /fuse [hand 0 4] [board 1 0 1]
#	 -> Fuses player=0 's hand[4] card onto player=1 's creature at territory0's slot1

#Card Locator [ZONE, OWNER, INDEX] : 
#	ZONE = hand,grave,deck, etc. 
#	OWNER = player_id
#	INDEX = card index in hand, grave, ..., slot number of territory

#"move [territory 0 1 0] [territory 0 1 1]" -> ["move", ["territory", 0, 1, 0], ["territory"], 0, 1, 1]]
static func parseStringToCommand(commandString : String) -> Array:
	print("A ", commandString)
	var arrayCount : int = 0
	var currentLine : String = ""
	var commandData : Array = []
	for i in range(commandString.length()):
		var char : String = commandString[i]
		if char == " " and arrayCount == 0:
			if currentLine != " " and currentLine != "":
				commandData.append(parseStringDataToCommand(currentLine))
			currentLine = ""
		elif char == "[":
			arrayCount += 1
			if arrayCount > 1:
				currentLine += "["
		elif char == "]":
			arrayCount -= 1
			if arrayCount == 0:
				commandData.append(parseStringToCommand(currentLine))
				currentLine = ""
			else:
				currentLine += "]"
		else:
			currentLine += char
	if currentLine != "":
		commandData.append(parseStringDataToCommand(currentLine))
	return commandData

static func parseStringDataToCommand(stringData : String):
	if stringData.is_valid_int():
		return int(stringData)
	elif stringData.is_valid_float():
		return float(stringData)
	else:
		return stringData




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
func onBoardVoteConfirmed():
	pass

@rpc("any_peer", "call_remote", "reliable")
func deckSelected(_deckData : Dictionary) -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func onDeckConfirmed() -> void:
	pass

####################################################################################################

@rpc("any_peer", "call_remote", "reliable")
func onBetSelected(_index : int) -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func onBetConfirmed() -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func onActionSelected(_action : Array) -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func onActionConfirmed() -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func onRevealSelected(_reveals : Array) -> void:
	pass

@rpc("any_peer", "call_remote", "reliable")
func onRevealConfirmed() -> void:
	pass
