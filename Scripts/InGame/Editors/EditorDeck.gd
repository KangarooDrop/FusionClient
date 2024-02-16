extends Node

@onready var selectorHolder : Control = $CanvasLayer/UI/SelectorHolder
@onready var selectorDeck : SelectorDeck = $CanvasLayer/UI/SelectorHolder/Center/SelectorDeck
@onready var cardHolder : Control = $CanvasLayer/UI/CardDisplay/ColorRect/ColorRect/CardHolder
@onready var deckDisplay : DeckDisplayPanel = $CanvasLayer/UI/DeckDisplay/ColorRect/DeckDisplayPanel
@onready var pageButtonLeft : Button = $CanvasLayer/UI/CardDisplay/ColorRect/ColorRect/PageButtonLeft
@onready var pageButtonRight : Button = $CanvasLayer/UI/CardDisplay/ColorRect/ColorRect/PageButtonRight
@onready var deckNameLineEdit : LineEdit = $CanvasLayer/UI/CardDisplay/ColorRect2/ColorRect/DeckNameLineEdit

var previewToDeckData : Dictionary = {}

var cardNodes : Array = []
const cardsPerRow : int = 4
const cardsPerColumn : int = 3
const cardsPerPage : int = cardsPerRow*cardsPerColumn
const cardDist : Vector2 = Vector2(128.0, 144.0)

func _ready():
	var off : Vector2 = -Vector2((cardsPerRow-1)/2.0 * cardDist.x, (cardsPerColumn-1)/2.0 * cardDist.x)
	for x in range(cardsPerRow):
		cardNodes.append([])
		for y in range(cardsPerColumn):
			var pos : Vector2 = off + Vector2(x, y) * cardDist
			var cardNode : CardNodeEditor = Preloader.cardNodeEditor.instantiate()
			cardHolder.add_child(cardNode)
			cardNode.position = pos
			cardNodes[x].append(cardNode)
			cardNode.connect("card_pressed", onCardPressed.bind(cardNode))
	showCardPage()

var lastCardIndex : int = 0
func onPageLeftPressed() -> void:
	lastCardIndex = max(0, lastCardIndex - cardsPerPage)
	showCardPage()
func onPageRightPressed() -> void:
	var ind : int = ListOfCards.cards.size()/cardsPerPage
	lastCardIndex = (ind) * cardsPerPage
	showCardPage()
func showCardPage() -> void:
	var pageCont : Array = []
	for i in range(lastCardIndex, lastCardIndex + cardsPerPage):
		if i >= ListOfCards.cards.size():
			break
		pageCont.append(ListOfCards.getCardByID(i))
		setCardData(pageCont)
	pageButtonLeft.visible = lastCardIndex > 0
	pageButtonRight.visible = lastCardIndex + cardsPerPage < ListOfCards.cards.size()

func onCardPressed(buttonIndex : int, cardNode) -> void:
	if buttonIndex == MOUSE_BUTTON_LEFT:
		deckDisplay.addCardData(cardNode.cardData)

func setCardData(cards : Array) -> void:
	var index : int = 0
	for y in range(cardsPerColumn):
		for x in range(cardsPerRow):
			if index >= cards.size():
				cardNodes[x][y].hide()
			else:
				cardNodes[x][y].show()
				cardNodes[x][y].setCardData(cards[index])
			index += 1

func showDecks() -> void:
	if not selectorHolder.visible:
		selectorHolder.show()
		var allDeckData = ["new"] + Util.getAllDeckData()
		selectorDeck.addAllPreviews(allDeckData)

func onDeckPreveiewSelected(preview : PreviewBase):
	var data = preview.getData()
	if typeof(data) == TYPE_STRING and data == "new":
		clearDeck()
	else:
		loadDeck(preview.getData())
	selectorHolder.hide()

func clearDeck() -> void:
	deckDisplay.clear()
	deckNameLineEdit.set_text("")

func loadDeck(deckData : Dictionary) -> void:
	deckDisplay.loadData(deckData)
	deckNameLineEdit.set_text(deckData["name"])

func saveDeck() -> void:
	var deckName : String = deckNameLineEdit.get_text()
	if deckName.is_empty():
		return
	var deckData : Dictionary = {"name":deckName, "cards":deckDisplay.getSaveData()}
	print(deckData)
	
	var error = Validator.validateDeck(deckData)
	if error != Validator.DECK_CODE.OK:
		print("ERROR: Could not validate deck. " + Validator.DECK_CODE.keys()[error])
		return
	
	var allDeckData : Array = Util.getAllDeckData()
	for dat in allDeckData:
		if dat["name"] == deckName:
			return
	
	error = FileIO.writeJson(FileIO.DECK_PATH + deckName + ".json", deckData)
	print(error)

func onExitPressed() -> void:
	get_tree().change_scene_to_packed(Preloader.startScreen)

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			if selectorHolder.visible:
				selectorHolder.hide()
		elif event.keycode == KEY_LEFT:
			onPageLeftPressed()
		elif event.keycode == KEY_RIGHT:
			onPageRightPressed()
