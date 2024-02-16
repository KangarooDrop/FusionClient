extends TerritoryNodeBase

class_name TerritoryNodeGame

@onready var highlight = $HighlightCirc

func setSize(size : int, updateTerritoryData : bool = true) -> void:
	super.setSize(size)

func showHighlight() -> void:
	highlight.show()

func hideHighlight() -> void:
	highlight.hide()

func setColor(color : Color) -> void:
	highlight.setColor(color)

func setColorSelected() -> void:
	highlight.setColor(Color(1.0, 1.0, 0.0, 0.4))

func setColorUnselected() -> void:
	highlight.setColor(Color(1.0, 1.0, 0.0, 0.2))

func setPlayers(players : Array):
	td.setPlayers(players)
