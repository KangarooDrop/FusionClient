extends BoardDataBase

class_name BoardDataGame

func findTerritory(territoryIndex : int) -> TerritoryDataGame:
	return territories[territoryIndex]

func getTerritoryScript() -> Script:
	return TerritoryDataGame
