extends TerritoryNodeBase

class_name TerritoryNodeEditor

func onPlusPressed() -> void:
	setSize(td.size + 1)

func onMinusPressed() -> void:
	setSize(td.size - 1)
