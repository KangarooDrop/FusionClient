
class_name Validator

####################################################################################################

enum DECK_CODE \
{
	OK,
	
	ERR_NOT_DICT,
	ERR_BAD_KEYS,
	ERR_OLD_VERSION,
	
	ERR_SIZE_TOO_LARGE,
	ERR_SIZE_TOO_SMALL,
	ERR_TOO_MANY_COPIES,
	ERR_INVALID_CARD,
}

static func validateDeck(deckData : Dictionary) -> int:
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
