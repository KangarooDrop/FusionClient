
class_name Validator

####################################################################################################
#TODO: Find a spot for these gubs

enum ELEMENT {NULL = 0, FIRE = 1, WATER = 2, ROCK = 3, NATURE = 4, DEATH = 5, TECH = 6}

####################################################################################################

enum DECK_CODE \
{
	OK,
	
	ERR_NOT_DICT,
	ERR_MISSING_KEY,
	ERR_BAD_KEYS,
	
	ERR_INVALID_CARD,
	
	ERR_SIZE_TOO_LARGE,
	ERR_SIZE_TOO_SMALL,
	ERR_TOO_MANY_COPIES,
}

const numCardsMax : int = 4
const deckSizeMin : int = 20
const deckSizeMax : int = 40

static func validateDeck(deckData : Dictionary) -> int:
	if not typeof(deckData) == TYPE_DICTIONARY:
		return DECK_CODE.ERR_NOT_DICT
	
	if not deckData.has('cards') :
		return DECK_CODE.ERR_MISSING_KEY
	
	if typeof(deckData['cards']) != TYPE_ARRAY:
		return DECK_CODE.ERR_BAD_KEYS
	
	for index in deckData['cards']:
		if typeof(index) != TYPE_FLOAT:
			return DECK_CODE.ERR_INVALID_CARD
		elif index < 0 or index >= ListOfCards.cards.size():
			return DECK_CODE.ERR_INVALID_CARD
	
	return DECK_CODE.OK

####################################################################################################

enum BOARD_CODE \
{
	OK,
	
	ERR_NOT_DICT,
	ERR_BAD_KEYS,
	ERR_OLD_VERSION,
	
	ERR_INVALID_TERR_INDEX
}

static func validateBoard(boardData : Dictionary) -> int:
	return BOARD_CODE.OK
