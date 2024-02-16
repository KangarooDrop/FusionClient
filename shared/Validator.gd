
class_name Validator

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
	
	if typeof(deckData['cards']) != TYPE_DICTIONARY:
		return DECK_CODE.ERR_BAD_KEYS
	
	for index in deckData['cards']:
		if typeof(index) != TYPE_STRING or not index.is_valid_int():
			return DECK_CODE.ERR_INVALID_CARD
		var indexVal : int = int(index)
		if indexVal < 0 or indexVal >= ListOfCards.cards.size():
			return DECK_CODE.ERR_INVALID_CARD
	
	return DECK_CODE.OK

####################################################################################################

const BOARD_VERSION : String = "0.01"

enum BOARD_CODE \
{
	OK,
	
	ERR_NOT_DICT,
	ERR_BAD_KEYS,
	ERR_OLD_VERSION,
	ERR_BAD_TYPE,
	
	ERR_TERR_BAD,
	ERR_PATH_BAD,
}

static func getLoadErrorString(error : BOARD_CODE) -> String:
	match error:
		BOARD_CODE.ERR_NOT_DICT:
			return "Corrupted: The file could not be loaded or the JSON data could not be parsed."
		BOARD_CODE.ERR_BAD_KEYS:
			return "Missing Key: The JSON data was missing a vital key."
		BOARD_CODE.ERR_OLD_VERSION:
			return "Wrong Version: The versions of the game and save file don't match."
		BOARD_CODE.ERR_BAD_TYPE:
			return "Bad Type: There was an incorrect data type found."
		BOARD_CODE.ERR_TERR_BAD:
			return "Territory: An error occured when trying to load in territory data."
		BOARD_CODE.ERR_PATH_BAD:
			return "Path: An error occured when trying to connect the paths."
		_:
			return "_NONE"

static func validateBoard(bd : Dictionary) -> BOARD_CODE:
	if bd.is_empty():
		return BOARD_CODE.ERR_NOT_DICT
	
	elif not bd.has("name") or not bd.has("ver") or not bd.has("terrs") or not bd.has("conns"):
		return BOARD_CODE.ERR_BAD_KEYS
	
	elif bd["ver"] != BOARD_VERSION:
		return BOARD_CODE.ERR_OLD_VERSION
	
	elif typeof(bd["terrs"]) != TYPE_ARRAY or typeof(bd["conns"]) != TYPE_ARRAY or typeof(bd["name"]) != TYPE_STRING or typeof(bd["ver"]) != TYPE_STRING:
		return BOARD_CODE.ERR_BAD_TYPE
	
	for tData in bd["terrs"]:
		if typeof(tData) != TYPE_DICTIONARY:
			return BOARD_CODE.ERR_TERR_BAD
		elif not tData.has("name") or not tData.has("pos_x") or not tData.has("pos_y"):
			return BOARD_CODE.ERR_TERR_BAD
		elif typeof(tData["name"]) != TYPE_STRING or typeof(tData["pos_x"]) != TYPE_FLOAT or typeof(tData["pos_y"]) != TYPE_FLOAT:
			return BOARD_CODE.ERR_TERR_BAD
		elif tData.has("size") and typeof(tData["size"]) != TYPE_FLOAT or tData.has("value") and typeof(tData["value"]) != TYPE_FLOAT:
			return BOARD_CODE.ERR_TERR_BAD
	
	for path in bd["conns"]:
		if typeof(path) != TYPE_ARRAY:
			return BOARD_CODE.ERR_PATH_BAD
		elif path.size() != 2:
			return BOARD_CODE.ERR_PATH_BAD
		elif typeof(path[0]) != TYPE_FLOAT or typeof(path[1]) != TYPE_FLOAT:
			return BOARD_CODE.ERR_PATH_BAD
		elif path[0] < 0 or path[0] >= bd["terrs"].size() or path[1] < 0 or path[1] >= bd["terrs"].size() or int(path[0]) == int(path[1]):
			return BOARD_CODE.ERR_PATH_BAD
	
	return BOARD_CODE.OK
